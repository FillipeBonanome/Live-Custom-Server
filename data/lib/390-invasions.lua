-- Invasions: world events where waves of monsters spawn around a town and the players have to repel them.
-- See doc/sistemas/35-invasoes.md for the list of invasions and the full description.
--
-- * Every Invasions.intervalHours (2) hours the scheduler starts an invasion: first a PRELUDE of preludeMinutes (5) with a different
--   message every minute, then the waves. The monsters of each wave appear little by little (waveSpawnTime) during the wave (waveDuration). The STRENGTH depends on the AVERAGE level of the
--   players online: each invasion belongs to a tier with a level band (minLevel..maxLevel) and the scheduler draws one whose band
--   contains the average; inside the band the amount of invaders grows with the average (Invasions.strengthMin..strengthMax).
-- * An invasion has waves; every wave announces something and triggers an EVENT (storm of elemental strikes on the players,
--   an ambush of extra monsters next to a player, or haste for all the invaders). With some chance (def.boss.chance, or the
--   /invasion start ... boss flag) a BOSS wave comes after the last one. Killing the boss gives a SERVER BONUS to every
--   player online for a while (more experience, more loot or faster skill training).
-- * If nobody hurts or kills an invader for Invasions.idleTimeout seconds, or the duration runs out, the invaders vanish
--   (a loss). A win needs every wave (and the boss, when there is one) dead.
-- * Every player that damages the invaders gets score (damage, limited to the health of each invader). Everybody online with
--   at least minScore gets the reward of the tier at the end (top 3 get a bonus). A loss only gives a consolation.
--
-- LUA STATES: every kind of script (globalevents, creaturescripts, talkactions...) runs in its own Lua state and this file is
-- loaded in all of them, but a table is NOT shared. The state of the globalevent "invasions" (Invasions.tick, every 2 s) is the
-- OWNER of the running invasion (Invasions.active). The other states talk to it through the global storage (shared by all
-- states, strings must start with "I:", see Invasions.storage): the kill/death scripts append to an inbox, the talkaction
-- sends commands, and the owner publishes the status that !invasion and the login message read.
-- The state lives in memory: a server restart cancels the running invasion (the server bonus is kept in the global storage only
-- until the restart too).
--
-- Option in config.lua: invasionsEnabled.

Invasions = {
	-- an invasion starts when (hour * 60 + minute) % (intervalHours * 60) == startMinute. The PRELUDE starts preludeMinutes before:
	-- the invasion is drawn and a different message is broadcast every minute (the type of the invasion is revealed with 3 minutes
	-- left); when the countdown ends the first wave appears. /invasion start skips the prelude.
	intervalHours = 2,
	startMinute = 0,
	preludeMinutes = 5,
	-- the scheduler only starts an invasion when there are at least this many players online
	minPlayers = 1,
	-- accounts with this access or more are staff: they are not counted in the average level
	staffAccess = 3,

	-- inside the level band the amount of invaders goes from strengthMin (average at minLevel) to strengthMax (average at
	-- minLevel + strengthSpan or more)
	strengthMin = 0.85,
	strengthMax = 1.5,
	strengthSpan = 80,
	-- the amount of invaders also grows by this fraction for each online player after the first (up to the max)
	playerScaleStep = 0.05,
	playerScaleMax = 1.5,

	-- the monsters of a wave appear little by little during waveSpawnTime seconds (they are drawn in random order) and the wave lasts
	-- waveDuration seconds: the next wave only comes after all the monsters of the current one appeared AND (waveDuration seconds
	-- passed since it began, or only waveClearRatio of the monsters that appeared are still alive, so fast players are not kept waiting).
	-- A wave can set its own spawnTime / duration (the boss wave appears at once: spawnTime = 0).
	waveSpawnTime = 60,
	waveDuration = 120,
	waveClearRatio = 0.2,
	-- the invaders vanish when nobody damages or kills one of them for this many seconds
	idleTimeout = 300,

	-- distance (sqm) an invader without target looks for players, and seconds between the searches
	huntRange = 40,
	huntInterval = 6,
	-- attempts to find a walkable tile for each invader
	spawnAttempts = 40,

	-- top 1/2/3 get this fraction of extra gold and exp
	rankBonus = {0.5, 0.3, 0.15},
	-- consolation (fraction of the gold and exp) when the invasion is lost
	lossRewardRatio = 0.25,

	-- chance (%) of the boss wave when the invasion has a boss and def.boss.chance is not set
	bossChance = 35,

	-- delay between the warning mark and the impact of a strike of the "storm" event (ms), and between strikes
	strikeDelay = 1500,
	strikeInterval = 450,

	-- level band, reward and storm damage of each tier. exp is multiplied by the level of the player (up to the maxLevel
	-- of the invasion). minScore = damage needed to be rewarded.
	tiers = {
		{name = "I", minLevel = 8, maxLevel = 40, gold = 10000, exp = 120, minScore = 300, damage = {30, 70}},
		{name = "II", minLevel = 30, maxLevel = 80, gold = 25000, exp = 200, minScore = 1000, damage = {80, 160}},
		{name = "III", minLevel = 60, maxLevel = 130, gold = 50000, exp = 300, minScore = 2500, damage = {150, 300}},
		{name = "IV", minLevel = 100, maxLevel = 180, gold = 100000, exp = 450, minScore = 5000, damage = {250, 450}},
		{name = "V", minLevel = 150, maxLevel = 999, gold = 200000, exp = 700, minScore = 9000, damage = {400, 700}}
	},

	-- elements of the storm event: combat type, impact effect and warning effect
	elements = {
		physical = {combat = COMBAT_PHYSICALDAMAGE, effect = CONST_ME_EXPLOSIONAREA, warn = CONST_ME_MAGIC_RED},
		fire = {combat = COMBAT_FIREDAMAGE, effect = CONST_ME_FIREAREA, warn = CONST_ME_MAGIC_RED},
		energy = {combat = COMBAT_ENERGYDAMAGE, effect = CONST_ME_ENERGYAREA, warn = CONST_ME_MAGIC_BLUE},
		earth = {combat = COMBAT_EARTHDAMAGE, effect = CONST_ME_POISONAREA, warn = CONST_ME_MAGIC_GREEN},
		ice = {combat = COMBAT_ICEDAMAGE, effect = CONST_ME_ICEAREA, warn = CONST_ME_MAGIC_BLUE},
		death = {combat = COMBAT_DEATHDAMAGE, effect = CONST_ME_MORTAREA, warn = CONST_ME_MAGIC_RED}
	},

	-- bonus the whole server gets when a boss dies. percent/minutes can be overridden by def.boss.percent/minutes.
	-- Only one bonus of each type at a time (a new one replaces the old one).
	bonusMinutes = 60,
	bonusOrder = {"experience", "loot", "skills"},
	bonusTypes = {
		experience = {storage = 54710, subId = 9501, param = CONDITION_PARAM_EXPERIENCE, percent = 25, label = "experience"},
		loot = {storage = 54711, subId = 9502, param = CONDITION_PARAM_LOOT, percent = 30, label = "loot"},
		skills = {storage = 54712, rate = true, percent = 50, label = "skill and magic level training"}
	},

	-- global storage (shared by all the Lua states) and the creature storage that marks the invaders (1 = invader, 2 = boss)
	storage = {
		head = 54700, rank = 54701, scores = 54702, inbox = 54703, command = 54704, prelude = 54705, creature = 54720
	},

	-- messages of the prelude by minutes left (%s = town). The def can override them with def.prelude = {[5] = "...", ...}.
	-- With 3 minutes left the intro of the invasion is used (it says what is coming).
	preludeMessages = {
		[5] = "Scouts report strange movements near %s. Something is coming...",
		[4] = "The guards of %s are sounding the alarm! Gather your allies and prepare your gear.",
		[2] = "The invaders are close to %s! Heal up, stock your potions and take your positions.",
		[1] = "Last minute! The invasion of %s begins in 60 seconds!"
	}
}

-- Builders used by the list below. makeWave(message, {{"Monster", count[, true = boss: not scaled]}, ...}, event)
local function makeWave(message, monsters, event)
	return {message = message, monsters = monsters, event = event}
end

-- elemental strikes around the players (the damage comes from the tier)
local function storm(element, strikes)
	return {type = "storm", element = element, strikes = strikes}
end

-- extra monsters appear next to a random player
local function ambush(monster, count)
	return {type = "ambush", monster = monster, count = count}
end

-- every invader gets faster
local function haste(speed)
	return {type = "haste", speed = speed}
end

local wave = makeWave

-- Invasions. key (unique, used by /invasion start), name, tier (index of Invasions.tiers), waves and boss. Optional: minLevel,
-- maxLevel (default: the ones of the tier), town (default 1, the temple is the center) or center = {x=, y=, z=}, minRadius,
-- maxRadius, duration (seconds), minScore, reward = {gold=, exp=, items={{id, count}}}, intro (%s = town name).
-- boss = {name = monster, chance = %, message = text, event = event of the boss wave, bonuses = {types}, percent = N, minutes = N}.
-- The boss monsters are placeholders until the boss system is made (any monster of monsters.xml works).
Invasions.list = {
	-- tier I
	{key = "orcs", name = "Orc Horde", tier = 1, intro = "A horde of orcs is marching on %s!",
		boss = {name = "Warlord Ruzad", message = "Warlord Ruzad himself leads the final charge!", event = storm("fire", 5)},
		waves = {
			wave("Orc vanguard is attacking! War drums make them faster.", {{"Orc", 12}, {"Orc Spearman", 8}, {"Orc Warrior", 8}}, haste(40)),
			wave("The orc elite joins the fight, with more orcs in ambush!", {{"Orc Berserker", 6}, {"Orc Shaman", 4}, {"Orc Rider", 4}}, ambush("Orc Spearman", 4)),
			wave("The orc leaders set the fields on fire!", {{"Orc Leader", 2}, {"Orc Warlord", 1}}, storm("fire", 5))
		}},
	{key = "spiders", name = "Spider Nest", tier = 1, intro = "A nest of spiders broke open near %s!",
		boss = {name = "Queen Silkara", message = "Queen Silkara, the brood mother, crawls out of the nest!", event = ambush("Poison Spider", 6)},
		waves = {
			wave("Thousands of little legs! Poison rains on the ground.", {{"Spider", 14}, {"Poison Spider", 10}}, storm("earth", 4)),
			wave("Bigger spiders are crawling out of the nest.", {{"Tarantula", 8}, {"Giant Spider", 4}}, ambush("Poison Spider", 6)),
			wave("The nest is boiling, the spiders are in a frenzy!", {{"Giant Spider", 6}, {"Tarantula", 8}}, haste(50))
		}},
	{key = "trolls", name = "Troll Warband", tier = 1, intro = "A warband of trolls is attacking %s!",
		boss = {name = "Chief Grumbak", message = "Chief Grumbak roars from the frozen hills!", event = storm("ice", 5)},
		waves = {
			wave("Trolls swarm out of the woods, throwing rocks.", {{"Troll", 14}, {"Island Troll", 10}}, storm("physical", 4)),
			wave("Swamp and frost trolls join, with some trolls waiting in ambush.", {{"Swamp Troll", 8}, {"Frost Troll", 8}}, ambush("Troll", 6)),
			wave("The trolls drink their war brew and charge!", {{"Troll", 12}, {"Frost Troll", 8}}, haste(50))
		}},
	{key = "wolves", name = "Wolf Pack", tier = 1, intro = "A pack of hungry wolves is circling %s!",
		boss = {name = "Fenrak Moonfang", message = "The moon rises and Fenrak Moonfang, the pack alpha, howls!", event = haste(80)},
		waves = {
			wave("The pack is fast and hungry!", {{"Wolf", 16}, {"Winter Wolf", 10}}, haste(60)),
			wave("Bears join the hunt, and wolves ambush from the shadows.", {{"Bear", 8}, {"Winter Wolf", 10}}, ambush("Wolf", 6)),
			wave("A freezing wind blows over the city.", {{"Bear", 8}, {"Winter Wolf", 12}}, storm("ice", 4))
		}},

	-- tier II
	{key = "dwarves", name = "Dwarven Uprising", tier = 2, intro = "The dwarves are rising against %s!",
		boss = {name = "Forgemaster Brokk", message = "Forgemaster Brokk fires up the great forge!", event = storm("physical", 6)},
		waves = {
			wave("Dwarves are blasting the city walls with powder!", {{"Dwarf", 14}, {"Dwarf Soldier", 10}, {"Dwarf Guard", 8}}, storm("fire", 5)),
			wave("Geomancers and golems join, and soldiers ambush from the tunnels.", {{"Dwarf Geomancer", 6}, {"Stone Golem", 4}}, ambush("Dwarf Soldier", 6)),
			wave("The dwarven guard charges!", {{"Dwarf Guard", 10}, {"War Golem", 2}}, haste(50))
		}},
	{key = "minotaurs", name = "Minotaur Warband", tier = 2, intro = "A minotaur warband is marching on %s!",
		boss = {name = "Hexlord Mokthar", message = "Hexlord Mokthar rises to curse the city!", event = storm("energy", 6)},
		waves = {
			wave("The minotaur vanguard charges with a roar.", {{"Minotaur", 14}, {"Minotaur Archer", 8}}, haste(50)),
			wave("Guards and mages join, and lightning crashes down.", {{"Minotaur Guard", 8}, {"Minotaur Mage", 6}}, storm("energy", 5)),
			wave("Archers close in from the flanks.", {{"Minotaur Guard", 10}, {"Minotaur Mage", 6}}, ambush("Minotaur Archer", 6))
		}},
	{key = "amazons", name = "Amazon Assault", tier = 2, intro = "The amazons are storming %s!",
		boss = {name = "Empress Aethra", message = "Empress Aethra leads the final charge!", event = ambush("Valkyrie", 6)},
		waves = {
			wave("Amazons and valkyries charge at full speed!", {{"Amazon", 14}, {"Valkyrie", 10}}, haste(60)),
			wave("The witches poison the air.", {{"Witch", 6}, {"Valkyrie", 8}}, storm("earth", 5)),
			wave("The last warriors strike from behind your lines.", {{"Amazon", 10}, {"Valkyrie", 10}}, ambush("Witch", 4))
		}},
	{key = "pirates", name = "Pirate Raid", tier = 2, intro = "Pirates are landing at %s!",
		boss = {name = "Captain Blackreef", message = "Captain Blackreef rolls his cannons ashore!", event = storm("fire", 6)},
		waves = {
			wave("Cannons roar from the pirate ships!", {{"Pirate Marauder", 10}, {"Pirate Cutthroat", 8}}, storm("fire", 5)),
			wave("Buccaneers and corsairs land, with skeleton crews in ambush.", {{"Pirate Buccaneer", 8}, {"Pirate Corsair", 6}}, ambush("Pirate Skeleton", 6)),
			wave("The crew is drunk on rum and in a frenzy!", {{"Pirate Skeleton", 10}, {"Pirate Corsair", 6}}, haste(60))
		}},
	{key = "cyclops", name = "Cyclops Rampage", tier = 2, minLevel = 40, maxLevel = 90, intro = "The cyclops are rampaging through %s!",
		boss = {name = "Titan Korg", message = "Titan Korg comes down from the mountain!", event = storm("physical", 6)},
		waves = {
			wave("Giants throw boulders at the city.", {{"Cyclops", 10}, {"Cyclops Drone", 8}}, storm("physical", 5)),
			wave("The smiths bring their hammers and the cyclops get faster.", {{"Cyclops Smith", 8}, {"Cyclops", 8}}, haste(50)),
			wave("A behemoth and more cyclops come out of the mountain.", {{"Cyclops", 12}, {"Behemoth", 2}}, ambush("Cyclops Drone", 4))
		}},
	{key = "lizards", name = "Lizard Legion", tier = 2, minLevel = 35, maxLevel = 85, intro = "The lizard legion is attacking %s!",
		boss = {name = "Hierarch Ssurrak", message = "Hierarch Ssurrak slithers out of the sun!", event = storm("earth", 6)},
		waves = {
			wave("Toxic spit falls on the defenders.", {{"Lizard Templar", 10}, {"Lizard Sentinel", 8}}, storm("earth", 5)),
			wave("Legionnaires and snakecharmers, with templars in ambush.", {{"Lizard Legionnaire", 8}, {"Lizard Snakecharmer", 6}}, ambush("Lizard Templar", 6)),
			wave("The legion advances in a fast march.", {{"Lizard Legionnaire", 10}, {"Lizard Snakecharmer", 6}}, haste(60))
		}},
	{key = "djinns", name = "Djinn War", tier = 2, minLevel = 40, maxLevel = 90, intro = "The djinn armies are attacking %s!",
		boss = {name = "Vizier Khalzar", message = "Vizier Khalzar opens the lamp of ruin!", event = storm("energy", 7)},
		waves = {
			wave("Blue and green djinns cast storms over the city.", {{"Blue Djinn", 8}, {"Green Djinn", 8}}, storm("energy", 5)),
			wave("Efreet and marid appear out of nowhere.", {{"Efreet", 6}, {"Marid", 6}}, ambush("Green Djinn", 4)),
			wave("The djinns charge with all their power.", {{"Efreet", 8}, {"Marid", 8}}, haste(60))
		}},

	-- tier III
	{key = "undead", name = "Undead Uprising", tier = 3, intro = "The dead are rising around %s!",
		boss = {name = "Necrarch Mortheus", message = "Necrarch Mortheus has come to harvest the city!", event = storm("death", 7)},
		waves = {
			wave("Skeletons and ghouls crawl out of the ground, and a cold death wind blows.", {{"Skeleton", 15}, {"Ghoul", 10}, {"Zombie", 8}}, storm("death", 5)),
			wave("Mummies and bone beasts join, with skeletons rising next to you.", {{"Mummy", 8}, {"Crypt Shambler", 6}, {"BoneBeast", 6}}, ambush("Skeleton", 8)),
			wave("Vampires and liches lead the undead, and the dead move faster.", {{"Vampire", 6}, {"Lich", 3}, {"Banshee", 4}}, haste(50))
		}},
	{key = "elementals", name = "Elemental Surge", tier = 3, intro = "The elements are going mad around %s!",
		boss = {name = "Pyrothane the Cinderlord", message = "Pyrothane the Cinderlord sets the sky on fire!", event = storm("fire", 8)},
		waves = {
			wave("Elementals of fire, energy, water and earth appear.", {{"Fire Elemental", 6}, {"Energy Elemental", 6}, {"Water Elemental", 6}, {"Earth Elemental", 6}}, storm("fire", 5)),
			wave("Massive elementals of fire and energy.", {{"Massive Fire Elemental", 3}, {"Massive Energy Elemental", 3}}, storm("energy", 6)),
			wave("Massive elementals of water and earth, with elementals in ambush.", {{"Massive Water Elemental", 3}, {"Massive Earth Elemental", 3}}, ambush("Earth Elemental", 6))
		}},
	{key = "frost", name = "Frost Siege", tier = 3, intro = "A blizzard is burying %s under an army of ice!",
		boss = {name = "Glaciarch Vorthrax", message = "Glaciarch Vorthrax descends from the blizzard!", event = storm("ice", 8)},
		waves = {
			wave("Ice shards fall with the blizzard.", {{"Winter Wolf", 12}, {"Yeti", 6}, {"Ice Witch", 6}}, storm("ice", 5)),
			wave("Ice golems and frost giants march in, faster with the cold.", {{"Ice Golem", 6}, {"Frost Giant", 4}}, haste(50)),
			wave("Frost dragons fly in, with golems in ambush.", {{"Frost Dragon", 4}, {"Ice Golem", 6}}, ambush("Yeti", 4))
		}},
	{key = "golems", name = "Golem Foundry", tier = 3, intro = "The golems of an old foundry are marching on %s!",
		boss = {name = "Iron Overseer Kragmor", message = "Iron Overseer Kragmor brings the foundry online!", event = storm("energy", 8)},
		waves = {
			wave("Workers and stone golems march out with the engines roaring.", {{"Worker Golem", 10}, {"Stone Golem", 6}}, haste(50)),
			wave("War golems join, and the machines send sparks flying.", {{"War Golem", 6}, {"Worker Golem", 8}}, storm("energy", 5)),
			wave("The foundry sends its last war golems, with stone golems in ambush.", {{"War Golem", 8}}, ambush("Stone Golem", 4))
		}},
	{key = "nightmare", name = "Nightmare Horde", tier = 3, minLevel = 70, maxLevel = 140, intro = "Nightmares are crawling out of the dark around %s!",
		boss = {name = "Nightmare Weaver Syrelith", message = "Nightmare Weaver Syrelith drags the dream into the waking world!", event = storm("death", 7)},
		waves = {
			wave("Gargoyles and stalkers swoop down, trailing death.", {{"Gargoyle", 10}, {"Nightstalker", 6}}, storm("death", 5)),
			wave("Nightmares and wraiths, faster in the dark.", {{"Nightmare", 6}, {"Betrayed Wraith", 4}}, haste(50)),
			wave("Souleaters, with nightmares in ambush.", {{"Souleater", 4}, {"Nightmare", 6}}, ambush("Nightstalker", 4))
		}},

	-- tier IV
	{key = "dragons", name = "Dragon Siege", tier = 4, intro = "Dragons are circling over %s!",
		boss = {name = "Wyrmlord Azhrakar", message = "Wyrmlord Azhrakar darkens the sky!", event = storm("death", 8)},
		waves = {
			wave("Wyverns and dragons land, with fire raining from the sky.", {{"Wyvern", 6}, {"Dragon", 8}}, storm("fire", 6)),
			wave("Dragon lords and frost dragons arrive, with more dragons in ambush.", {{"Dragon Lord", 6}, {"Frost Dragon", 4}}, ambush("Dragon", 3)),
			wave("The ancient wyrms and hydras awake and charge.", {{"Wyrm", 4}, {"Hydra", 4}}, haste(50))
		}},
	{key = "bloodmoon", name = "Blood Moon", tier = 4, intro = "The blood moon rose over %s and the night creatures hunt!",
		boss = {name = "Countess Sanguessa", message = "Countess Sanguessa walks under the blood moon!", event = storm("death", 8)},
		waves = {
			wave("Vampires and werewolves attack under the red moon.", {{"Vampire", 8}, {"Vampire Bride", 6}, {"Werewolf", 6}}, storm("death", 6)),
			wave("Banshees and liches, faster with the moon.", {{"Banshee", 6}, {"Lich", 4}}, haste(50)),
			wave("The night belongs to them: more vampires and werewolves in ambush.", {{"Vampire", 10}, {"Werewolf", 8}}, ambush("Vampire Bride", 4))
		}},
	{key = "drakens", name = "Draken Legion", tier = 4, intro = "The draken legion is attacking %s!",
		boss = {name = "Warlord Zhardakkan", message = "Warlord Zhardakkan breaks through the walls!", event = storm("fire", 8)},
		waves = {
			wave("Draken warmasters and spellweavers burn the streets.", {{"Draken Warmaster", 6}, {"Draken Spellweaver", 6}}, storm("fire", 6)),
			wave("Abominations join the legion, faster in battle.", {{"Draken Abomination", 4}, {"Draken Warmaster", 6}}, haste(50)),
			wave("The last abominations, with spellweavers in ambush.", {{"Draken Abomination", 6}}, ambush("Draken Spellweaver", 4))
		}},
	{key = "asuras", name = "Asura Onslaught", tier = 4, intro = "The asuras are burning %s!",
		boss = {name = "Matriarch Ignaria", message = "Matriarch Ignaria ignites the city!", event = storm("fire", 8)},
		waves = {
			wave("Midnight and dawnfire asuras bring the flames.", {{"Midnight Asura", 6}, {"Dawnfire Asura", 6}}, storm("fire", 6)),
			wave("Hellfire fighters and infernalists, faster in the heat.", {{"Hellfire Fighter", 6}, {"Infernalist", 4}}, haste(50)),
			wave("The last asuras, with hellfire fighters in ambush.", {{"Midnight Asura", 6}, {"Dawnfire Asura", 6}}, ambush("Hellfire Fighter", 4))
		}},
	{key = "plague", name = "Plague Legion", tier = 4, minLevel = 110, maxLevel = 190, intro = "A plague is spreading from the dead around %s!",
		boss = {name = "Forgelord Vexmar", message = "Forgelord Vexmar forges the end of the city!", event = storm("earth", 8)},
		waves = {
			wave("Blightwalkers, defilers and destroyers spread poison.", {{"Blightwalker", 6}, {"Defiler", 4}, {"Destroyer", 4}}, storm("earth", 6)),
			wave("Demon skeletons, faster in the plague.", {{"Plaguesmith", 3}, {"Demon Skeleton", 6}}, haste(50)),
			wave("Ghastly dragons, with defilers in ambush.", {{"Ghastly Dragon", 3}}, ambush("Defiler", 3))
		}},

	-- tier V
	{key = "demons", name = "Demonic Rift", tier = 5, intro = "A rift to hell opened near %s!",
		boss = {name = "Archfiend Zulkarath", message = "Archfiend Zulkarath tears the rift wide open!", event = storm("fire", 9)},
		waves = {
			wave("Hellhounds and hellspawns pour out of the rift, and fire falls.", {{"Hellhound", 6}, {"Hellspawn", 6}, {"Fury", 6}}, storm("fire", 6)),
			wave("Torturers and juggernauts march behind them, faster.", {{"Dark Torturer", 4}, {"Juggernaut", 3}, {"Behemoth", 4}}, haste(50)),
			wave("Demons cross the rift, with hounds in ambush.", {{"Demon", 6}}, ambush("Hellhound", 4))
		}},
	{key = "deaddragons", name = "Wrath of the Dead Dragons", tier = 5, intro = "The skies of %s are filled with dead dragons!",
		boss = {name = "Deathwyrm Nekhrazul", message = "Deathwyrm Nekhrazul rises from the ashes of the ages!", event = storm("death", 9)},
		waves = {
			wave("Ghastly and undead dragons breathe death on the city.", {{"Ghastly Dragon", 6}, {"Undead Dragon", 4}}, storm("death", 6)),
			wave("Demon skeletons and blightwalkers, faster in the dark.", {{"Demon Skeleton", 8}, {"Blightwalker", 6}}, haste(50)),
			wave("Defilers and destroyers, with demon skeletons in ambush.", {{"Defiler", 4}, {"Destroyer", 4}}, ambush("Demon Skeleton", 4))
		}},
	{key = "hellslegion", name = "Hell's Legion", tier = 5, intro = "The legion of hell is marching on %s!",
		boss = {name = "Hellforged Overlord Malgorath", message = "Hellforged Overlord Malgorath leads the legion of hell!", event = storm("energy", 9)},
		waves = {
			wave("Hellfire fighters, infernalists and furies burn the streets.", {{"Hellfire Fighter", 8}, {"Infernalist", 6}, {"Fury", 6}}, storm("fire", 6)),
			wave("Demons and juggernauts, faster in the flames.", {{"Demon", 6}, {"Juggernaut", 4}}, haste(50)),
			wave("The Grim Reapers come for the survivors, with demons in ambush.", {{"Grim Reaper", 2}, {"Hellhound", 8}}, ambush("Demon", 2))
		}}
}

-- fills in the default values of every invasion from its tier
for _, def in ipairs(Invasions.list) do
	local tier = Invasions.tiers[def.tier]
	def.tierName = tier.name
	if(not def.town and not def.center) then
		def.town = 1
	end

	def.minLevel = def.minLevel or tier.minLevel
	def.maxLevel = def.maxLevel or tier.maxLevel
	def.minRadius = def.minRadius or 14
	def.maxRadius = def.maxRadius or 26
	def.duration = def.duration or (20 + def.tier * 2) * 60
	def.minScore = def.minScore or tier.minScore
	def.reward = def.reward or {gold = tier.gold, exp = tier.exp}
	def.intro = def.intro or "An invasion is coming to %s!"
end

-- runtime state, only meaningful in the state of the owner (see the header): nil when there is no invasion running
Invasions.active = nil
Invasions.prelude = nil
Invasions.lastKey = nil
Invasions.firedSlots = {}
Invasions.firedDay = nil
Invasions.lastBonusCheck = 0

local S = Invasions.storage

local function cfg(key, default)
	local value = getConfigValue(key)
	if(value == nil) then
		return default
	end

	return value
end

-- text in the global storage: the "I:" prefix keeps the engine from reading the text as a number
local function readText(key)
	local value = getStorage(key)
	if(type(value) == "string" and value:sub(1, 2) == "I:") then
		return value:sub(3)
	end

	return ""
end

local function writeText(key, text)
	doSetStorage(key, "I:" .. text)
end

local function split(text, separator)
	local pattern = "(.-)" .. separator:gsub("%p", "%%%0")
	local parts = {}
	for part in (text .. separator):gmatch(pattern) do
		table.insert(parts, part)
	end

	return parts
end

local function broadcast(text)
	doBroadcastMessage(text, MESSAGE_STATUS_WARNING)
end

function Invasions.isEnabled()
	return cfg("invasionsEnabled", true) == true
end

function Invasions.getDefinition(key)
	key = tostring(key):lower()
	for index, def in ipairs(Invasions.list) do
		if(def.key == key or tostring(index) == key or def.name:lower() == key) then
			return def
		end
	end

	return nil
end

function Invasions.formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

function Invasions.getCenter(def)
	if(def.center) then
		return {x = def.center.x, y = def.center.y, z = def.center.z}
	end

	local pos = getTownTemplePosition(def.town)
	if(type(pos) == "table" and pos.x and pos.x > 0) then
		return {x = pos.x, y = pos.y, z = pos.z}
	end

	return nil
end

function Invasions.getPlaceName(def)
	if(def.town) then
		local name = getTownName(def.town)
		if(type(name) == "string" and name ~= "") then
			return name
		end
	end

	return "the city"
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Any state: messages between the states (inbox, commands), status and server bonuses
-- ---------------------------------------------------------------------------------------------------------------------------

-- adds an entry to the inbox that the owner reads (kill/death scripts)
function Invasions.push(entry)
	writeText(S.inbox, readText(S.inbox) .. entry .. ";")
end

-- sends a command to the owner: "start|key|requester name|boss", "stop||requester name|"
function Invasions.sendCommand(action, argument, requester, flag)
	writeText(S.command, table.concat({action, argument or "", requester or "", flag or ""}, "|"))
end

function Invasions.isInvader(uid)
	return getCreatureStorage(uid, S.creature) > 0
end

-- fields of the running invasion published by the owner, or nil when there is none
function Invasions.readStatus()
	local text = readText(S.head)
	if(text == "") then
		return nil
	end

	local f = split(text, "|")
	return {
		name = f[1], minLevel = tonumber(f[2]), place = f[3], x = f[4], y = f[5], z = f[6], wave = tonumber(f[7]), waves = tonumber(f[8]),
		alive = tonumber(f[9]), killed = tonumber(f[10]), endsAt = tonumber(f[11]), minScore = tonumber(f[12]), tier = f[13]
	}
end

-- the countdown published by the owner: {name = text ("" until it is revealed), startsAt, minLevel}, or nil
function Invasions.readPrelude()
	local text = readText(S.prelude)
	if(text == "") then
		return nil
	end

	local f = split(text, "|")
	return {name = f[1], startsAt = tonumber(f[2]), minLevel = tonumber(f[3])}
end

function Invasions.getPlayerScore(cid)
	local guid = getPlayerGUID(cid)
	for id, score in readText(S.scores):gmatch("(%d+)=(%d+)") do
		if(tonumber(id) == guid) then
			return tonumber(score)
		end
	end

	return 0
end

-- active server bonuses: list of {type, label, percent, endsAt, by}
function Invasions.getBonuses()
	local list = {}
	for _, key in ipairs(Invasions.bonusOrder) do
		local bonus = Invasions.bonusTypes[key]
		local f = split(readText(bonus.storage), "|")
		local endsAt, percent = tonumber(f[1]), tonumber(f[2])
		if(endsAt and percent and endsAt > os.time()) then
			table.insert(list, {type = key, label = bonus.label, percent = percent, endsAt = endsAt, by = f[3] or ""})
		end
	end

	return list
end

function Invasions.getBonusLines()
	local lines = {}
	for _, bonus in ipairs(Invasions.getBonuses()) do
		table.insert(lines, "+" .. bonus.percent .. "% " .. bonus.label .. " for " .. Invasions.formatTime(bonus.endsAt - os.time()) .. " (" .. bonus.by .. " was defeated)")
	end

	return lines
end

-- text of !invasion
function Invasions.getStatusText(cid)
	local lines = {}
	local status = Invasions.readStatus()
	if(status) then
		table.insert(lines, "Invasion in progress: " .. status.name .. " (tier " .. status.tier .. ", recommended level " .. status.minLevel .. "+)")
		table.insert(lines, "Where: around the temple of " .. status.place .. " (" .. status.x .. ", " .. status.y .. ", " .. status.z .. ")")
		table.insert(lines, "Wave " .. status.wave .. " of " .. status.waves .. ", " .. status.alive .. " invaders alive, " .. status.killed .. " defeated.")
		table.insert(lines, "Time left: " .. Invasions.formatTime(status.endsAt - os.time()))
		table.insert(lines, "Your damage: " .. Invasions.getPlayerScore(cid) .. " (" .. status.minScore .. " needed for the reward)")

		local rank = readText(S.rank)
		if(rank ~= "") then
			table.insert(lines, "")
			table.insert(lines, "Best defenders:")
			local position = 0
			for name, score, kills in rank:gmatch("([^=;]+)=(%d+)=(%d+)") do
				position = position + 1
				table.insert(lines, position .. ". " .. name .. " - " .. score .. " damage, " .. kills .. " kills")
			end
		end
	elseif(Invasions.readPrelude()) then
		local prelude = Invasions.readPrelude()
		table.insert(lines, "An invasion is coming in " .. Invasions.formatTime(prelude.startsAt - os.time()) .. "!" .. (prelude.name ~= "" and (" Incoming: " .. prelude.name .. " (recommended level " .. prelude.minLevel .. "+).") or " Nobody knows what yet..."))
	else
		table.insert(lines, "There is no invasion right now.")
		table.insert(lines, "An invasion starts every " .. Invasions.intervalHours .. " hours (even hours, server time). Its strength depends on the average level of the players online.")
	end

	local bonuses = Invasions.getBonusLines()
	if(#bonuses > 0) then
		table.insert(lines, "")
		table.insert(lines, "Server bonuses (boss defeated):")
		for _, line in ipairs(bonuses) do
			table.insert(lines, "- " .. line)
		end
	end

	table.insert(lines, "")
	table.insert(lines, "Invasions (tier, level band):")
	for _, def in ipairs(Invasions.list) do
		table.insert(lines, "- " .. def.name .. " (tier " .. def.tierName .. ", level " .. def.minLevel .. (def.maxLevel >= 999 and "+" or ("-" .. def.maxLevel)) .. ", " .. #def.waves .. " waves)")
	end

	return table.concat(lines, "\n")
end

-- applies one server bonus to one player (conditions are only added when missing, the skill rate is set every time)
local function applyBonus(cid, bonus, endsAt, percent, force)
	local category = "Invasion bonus: " .. bonus.label
	local missing = force or not hasCreatureBuff(cid, category)

	if(bonus.rate) then
		for skill = 0, 7 do
			doPlayerSetRate(cid, skill, 1 + percent / 100)
		end
	elseif(force or not getCreatureCondition(cid, CONDITION_ATTRIBUTES, bonus.subId)) then
		doRemoveCondition(cid, CONDITION_ATTRIBUTES, bonus.subId)
		local condition = createConditionObject(CONDITION_ATTRIBUTES)
		setConditionParam(condition, CONDITION_PARAM_TICKS, math.max(1000, (endsAt - os.time()) * 1000))
		setConditionParam(condition, CONDITION_PARAM_SUBID, bonus.subId)
		setConditionParam(condition, bonus.param, percent)
		doAddCondition(cid, condition)
		missing = true
	end

	-- shows the bonus in !buffs (the effect itself is the condition / the skill rate above; the buffs are lost on death and login, and given again here)
	if(missing) then
		addCreatureBuff(cid, {
			name = "Invasion bonus", category = category, duration = math.max(1000, (endsAt - os.time()) * 1000),
			description = "+" .. percent .. "% " .. bonus.label .. " (boss of the invasion defeated)."
		})
	end
end

-- keeps the server bonuses on every online player (new logins, deaths) and ends the expired ones. Owner state, every few seconds.
function Invasions.ensureBonuses(force)
	for _, key in ipairs(Invasions.bonusOrder) do
		local bonus = Invasions.bonusTypes[key]
		local text = readText(bonus.storage)
		if(text ~= "") then
			local f = split(text, "|")
			local endsAt, percent = tonumber(f[1]), tonumber(f[2])
			if(endsAt and percent and endsAt > os.time()) then
				for _, pid in ipairs(getPlayersOnline()) do
					applyBonus(pid, bonus, endsAt, percent, force)
				end
			else
				writeText(bonus.storage, "")
				if(bonus.rate) then
					for _, pid in ipairs(getPlayersOnline()) do
						for skill = 0, 7 do
							doPlayerSetRate(pid, skill, 1)
						end
					end
				end

				broadcast("[Invasion] The server bonus of +" .. (percent or 0) .. "% " .. bonus.label .. " is over.")
			end
		end
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Owner state (globalevent "invasions")
-- ---------------------------------------------------------------------------------------------------------------------------

local function newMonsterInfo(inv, uid, waveIndex, isBoss)
	doCreatureSetStorage(uid, S.creature, isBoss and 2 or 1)
	registerCreatureEvent(uid, "InvasionDeath")
	inv.monsters[uid] = {wave = waveIndex, maxHealth = getCreatureMaxHealth(uid), boss = isBoss or false}
	inv.waveAlive[waveIndex] = (inv.waveAlive[waveIndex] or 0) + 1
	inv.alive = inv.alive + 1
	inv.total = inv.total + 1
	doSendMagicEffect(getCreaturePosition(uid), CONST_ME_TELEPORT)

	-- the haste event of the wave also reaches the monsters that appear after it
	if(inv.hasteSpeed[waveIndex]) then
		doChangeSpeed(uid, inv.hasteSpeed[waveIndex])
	end
end

-- creates one monster at a random tile of the ring around the position, returns its id or nil
local function createAround(center, minRadius, maxRadius, name)
	for attempt = 1, Invasions.spawnAttempts do
		local angle = math.random() * 2 * math.pi
		local radius = minRadius + math.random() * (maxRadius - minRadius)
		local pos = {
			x = math.floor(center.x + math.cos(angle) * radius + 0.5),
			y = math.floor(center.y + math.sin(angle) * radius + 0.5),
			z = center.z
		}

		-- doCreateMonster returns the creature id (a number) on success and a boolean when the tile is not valid
		local uid = doCreateMonster(name, pos, false, false, false)
		if(type(uid) == "number" and uid > 0) then
			return uid
		end
	end

	return nil
end

local function getScale()
	return math.min(Invasions.playerScaleMax, 1 + Invasions.playerScaleStep * math.max(0, #getPlayersOnline() - 1))
end

-- players outside protection zones, with their positions
local function getTargets()
	local list = {}
	for _, pid in ipairs(getPlayersOnline()) do
		local pos = getCreaturePosition(pid)
		if(not getTilePzInfo(pos)) then
			table.insert(list, {cid = pid, pos = pos})
		end
	end

	return list
end

-- STORM: elemental strikes on random players: a mark appears and the strike lands Invasions.strikeDelay ms later (move away!)
local function runStorm(inv, event)
	local element = Invasions.elements[event.element] or Invasions.elements.fire
	local damage = Invasions.tiers[inv.def.tier].damage
	local center = inv.center
	local targets = {}
	for _, target in ipairs(getTargets()) do
		if(target.pos.z == center.z and math.max(math.abs(target.pos.x - center.x), math.abs(target.pos.y - center.y)) <= Invasions.huntRange + 10) then
			table.insert(targets, target)
		end
	end

	if(#targets == 0) then
		return
	end

	for strike = 1, event.strikes do
		local target = targets[math.random(#targets)]
		local impact = {x = target.pos.x + math.random(-2, 2), y = target.pos.y + math.random(-2, 2), z = target.pos.z}
		addEvent(function()
			if(Invasions.active == inv) then
				doSendMagicEffect(impact, element.warn)
			end
		end, (strike - 1) * Invasions.strikeInterval)

		addEvent(function()
			if(Invasions.active ~= inv) then
				return
			end

			doSendMagicEffect(impact, element.effect)
			for _, pid in ipairs(getPlayersOnline()) do
				local pos = getCreaturePosition(pid)
				if(pos.z == impact.z and math.abs(pos.x - impact.x) <= 1 and math.abs(pos.y - impact.y) <= 1 and not getTilePzInfo(pos)) then
					doTargetCombatHealth(0, pid, element.combat, -damage[1], -damage[2], element.effect)
				end
			end
		end, (strike - 1) * Invasions.strikeInterval + Invasions.strikeDelay)
	end
end

-- AMBUSH: extra monsters of the wave appear next to a random player
local function runAmbush(inv, event, waveIndex)
	local targets = getTargets()
	if(#targets == 0) then
		return
	end

	local target = targets[math.random(#targets)]
	for i = 1, event.count do
		local uid = createAround(target.pos, 2, 4, event.monster)
		if(uid) then
			newMonsterInfo(inv, uid, waveIndex, false)
		end
	end
end

-- HASTE: every invader alive gets faster, and so do the ones of this wave that have not appeared yet
local function runHaste(inv, event, waveIndex)
	inv.hasteSpeed[waveIndex] = event.speed
	for uid in pairs(inv.monsters) do
		if(isCreature(uid)) then
			doChangeSpeed(uid, event.speed)
			doSendMagicEffect(getCreaturePosition(uid), CONST_ME_MAGIC_RED)
		end
	end
end

local eventRunners = {storm = runStorm, ambush = runAmbush, haste = runHaste}

-- creates the monsters of the queue of the current wave that are due: they come little by little during the spawn time of the wave
-- (at least one right away, all of them when the spawn time is over). Returns how many invaders were created now.
function Invasions.releaseQueue()
	local inv = Invasions.active
	local total = #inv.queue
	if(inv.released >= total) then
		return 0
	end

	local target = total
	if(inv.waveSpawnTime > 0) then
		target = math.min(total, math.max(1, math.ceil(total * (os.time() - inv.waveTime) / inv.waveSpawnTime)))
	end

	local created = 0
	while(inv.released < target) do
		inv.released = inv.released + 1
		local entry = inv.queue[inv.released]
		local uid = createAround(inv.center, inv.def.minRadius, inv.def.maxRadius, entry[1])
		if(uid) then
			newMonsterInfo(inv, uid, inv.wave, entry[2])
			inv.waveSpawned[inv.wave] = (inv.waveSpawned[inv.wave] or 0) + 1
			created = created + 1
		end
	end

	return created
end

-- begins the wave with the given index: draws the monsters (scaled), creates the first ones, runs its event; returns how many invaders were created
function Invasions.beginWave(index)
	local inv = Invasions.active
	local current = inv.waves[index]
	local scale = inv.strength * getScale()

	local queue = {}
	for _, entry in ipairs(current.monsters) do
		local count = entry[3] and entry[2] or math.ceil(entry[2] * scale)
		for i = 1, count do
			table.insert(queue, {entry[1], entry[3]})
		end
	end

	-- random order, so the types come mixed
	for i = #queue, 2, -1 do
		local j = math.random(i)
		queue[i], queue[j] = queue[j], queue[i]
	end

	inv.wave = index
	inv.queue = queue
	inv.released = 0
	inv.waveSpawned[index] = 0
	inv.waveTime = os.time()
	inv.waveSpawnTime = current.spawnTime or Invasions.waveSpawnTime
	inv.waveDuration = current.duration or Invasions.waveDuration

	local created = Invasions.releaseQueue()
	if(created > 0 and current.event and eventRunners[current.event.type]) then
		eventRunners[current.event.type](inv, current.event, index)
	end

	return created
end

-- the strength (scale of the amount of invaders) of an invasion for an average level
function Invasions.getStrength(def, averageLevel)
	local span = math.min(def.maxLevel - def.minLevel, Invasions.strengthSpan)
	local t = span > 0 and math.max(0, math.min(1, (averageLevel - def.minLevel) / span)) or 1
	return Invasions.strengthMin + (Invasions.strengthMax - Invasions.strengthMin) * t
end

-- average level of the players online (staff accounts are ignored unless they are the only ones) and how many were counted
function Invasions.getAverageLevel()
	local sum, count, all, allCount = 0, 0, 0, 0
	for _, pid in ipairs(getPlayersOnline()) do
		local level = getPlayerLevel(pid)
		all, allCount = all + level, allCount + 1
		if(getPlayerAccess(pid) < Invasions.staffAccess) then
			sum, count = sum + level, count + 1
		end
	end

	if(count > 0) then
		return sum / count, count
	end

	return allCount > 0 and all / allCount or 0, allCount
end

-- starts the invasion. opts = {boss = true|false|nil (nil: rolls the chance), averageLevel = N}. Returns true or false plus the reason.
function Invasions.start(def, opts)
	opts = opts or {}
	if(Invasions.active) then
		return false, "There is already an invasion running (" .. Invasions.active.def.name .. ")."
	end

	-- starting by hand while the countdown runs cancels the countdown
	if(Invasions.prelude) then
		Invasions.prelude = nil
		writeText(S.prelude, "")
	end

	local center = Invasions.getCenter(def)
	if(not center) then
		return false, "The invasion '" .. def.key .. "' has no valid town or center."
	end

	local average = opts.averageLevel or Invasions.getAverageLevel()
	local waves = {}
	for _, item in ipairs(def.waves) do
		table.insert(waves, item)
	end

	local boss = false
	if(def.boss) then
		if(opts.boss == nil) then
			boss = math.random(100) <= (def.boss.chance or Invasions.bossChance)
		else
			boss = opts.boss
		end
	end

	if(boss) then
		local bossWave = makeWave(def.boss.message or (def.boss.name .. " has appeared!"), {{def.boss.name, 1, true}}, def.boss.event)
		bossWave.spawnTime = 0 -- the boss appears at once
		table.insert(waves, bossWave)
	end

	Invasions.active = {
		def = def,
		center = center,
		waves = waves,
		boss = boss,
		strength = Invasions.getStrength(def, average),
		startedAt = os.time(),
		lastActivity = os.time(),
		lastHunt = 0,
		wave = 0,
		waveTime = os.time(),
		waveSpawnTime = 0,
		waveDuration = 0,
		queue = {},
		released = 0,
		hasteSpeed = {},
		waveAlive = {},
		waveSpawned = {},
		monsters = {},
		credit = {},
		scores = {},
		alive = 0,
		total = 0,
		killed = 0
	}

	if(Invasions.beginWave(1) == 0) then
		Invasions.active = nil
		return false, "No invader could be placed around the center (" .. center.x .. "," .. center.y .. "," .. center.z .. "). Check the town/center and radius of '" .. def.key .. "'."
	end

	Invasions.lastKey = def.key
	if(opts.fromPrelude) then
		broadcast("[Invasion] The invasion has begun: " .. def.name .. "! Defend " .. Invasions.getPlaceName(def) .. "! (tier " .. def.tierName .. ", recommended level " .. def.minLevel .. "+)")
	else
		broadcast("[Invasion] " .. string.format(def.intro, Invasions.getPlaceName(def)) .. " (tier " .. def.tierName .. ", recommended level " .. def.minLevel .. "+)")
	end

	broadcast("[Invasion] Wave 1/" .. #waves .. ": " .. waves[1].message)
	Invasions.publish()
	return true
end

local function getRanking(inv)
	local list = {}
	for guid, data in pairs(inv.scores) do
		table.insert(list, {guid = guid, name = data.name, score = data.score, kills = data.kills})
	end

	table.sort(list, function(a, b) return a.score > b.score end)
	return list
end

local function removeInvaders(inv)
	for uid in pairs(inv.monsters) do
		if(isCreature(uid)) then
			doSendMagicEffect(getCreaturePosition(uid), CONST_ME_POFF)
			doRemoveCreature(uid)
		end
	end
end

local function giveReward(cid, def, rank, success)
	local reward = def.reward
	local bonus = 1 + (Invasions.rankBonus[rank] or 0)
	local ratio = success and 1 or Invasions.lossRewardRatio
	local lines = {}

	local gold = math.floor((reward.gold or 0) * bonus * ratio)
	if(gold > 0) then
		doPlayerAddMoney(cid, gold)
		table.insert(lines, gold .. " gold")
	end

	local exp = math.floor((reward.exp or 0) * math.min(getPlayerLevel(cid), def.maxLevel) * bonus * ratio)
	if(exp > 0) then
		doPlayerAddExp(cid, exp)
		table.insert(lines, exp .. " experience")
	end

	if(success and reward.items) then
		for _, item in ipairs(reward.items) do
			if(doPlayerAddItem(cid, item[1], item[2] or 1)) then
				table.insert(lines, (item[2] or 1) .. "x " .. getItemNameById(item[1]))
			end
		end
	end

	return table.concat(lines, ", ")
end

-- ends the invasion. reason (loss only): "time" or "idle"
function Invasions.finish(success, reason)
	local inv = Invasions.active
	if(not inv) then
		return false
	end

	Invasions.active = nil
	local def = inv.def
	removeInvaders(inv)

	if(success) then
		broadcast("[Invasion] " .. def.name .. " was repelled! " .. inv.killed .. " invaders defeated.")
	elseif(reason == "idle") then
		broadcast("[Invasion] Nobody fought back and the invaders of " .. def.name .. " left, leaving " .. inv.alive .. " of " .. inv.total .. " alive.")
	else
		broadcast("[Invasion] " .. def.name .. " is over: time ran out and the invaders retreated with " .. inv.alive .. " of " .. inv.total .. " still alive.")
	end

	local ranking = getRanking(inv)
	local online = {}
	for _, pid in ipairs(getPlayersOnline()) do
		online[getPlayerGUID(pid)] = pid
	end

	local top = {}
	for rank, entry in ipairs(ranking) do
		if(rank <= 3) then
			table.insert(top, rank .. ". " .. entry.name .. " (" .. entry.score .. ")")
		end

		local pid = online[entry.guid]
		if(pid and entry.score >= def.minScore) then
			local text = giveReward(pid, def, rank, success)
			doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, "[Invasion] You ranked " .. rank .. " of " .. #ranking .. " with " .. entry.score .. " damage and " .. entry.kills .. " invaders killed. Reward: " .. (text ~= "" and text or "none") .. ".")
		elseif(pid) then
			doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, "[Invasion] You helped with " .. entry.score .. " damage, but at least " .. def.minScore .. " is needed to be rewarded.")
		end
	end

	if(#top > 0) then
		broadcast("[Invasion] Best defenders: " .. table.concat(top, ", "))
	end

	Invasions.publish()
	return true
end

-- called by /invasion stop: the invaders vanish and nobody is rewarded
function Invasions.stop()
	-- cancels the countdown too
	if(Invasions.prelude) then
		Invasions.prelude = nil
		writeText(S.prelude, "")
		broadcast("[Invasion] The coming invasion was called off.")
		if(not Invasions.active) then
			return true
		end
	end

	local inv = Invasions.active
	if(not inv) then
		return false
	end

	Invasions.active = nil
	removeInvaders(inv)
	broadcast("[Invasion] " .. inv.def.name .. " was called off.")
	Invasions.publish()
	return true, inv.def
end

-- gives the server bonus of the defeated boss to everybody online (and to whoever logs in while it lasts)
function Invasions.grantBonus(def)
	local pool = def.boss.bonuses or Invasions.bonusOrder
	local key = pool[math.random(#pool)]
	local bonus = Invasions.bonusTypes[key]
	local percent = def.boss.percent or bonus.percent
	local minutes = def.boss.minutes or Invasions.bonusMinutes
	local endsAt = os.time() + minutes * 60

	writeText(bonus.storage, endsAt .. "|" .. percent .. "|" .. def.boss.name)
	Invasions.ensureBonuses(true)
	broadcast("[Invasion] " .. def.boss.name .. " was defeated! The whole server gets +" .. percent .. "% " .. bonus.label .. " for " .. minutes .. " minutes!")
end

-- every online player that damages an invader gets score (damage, up to the health of the invader)
local function onDamage(inv, guid, name, uid, damage)
	local info = inv.monsters[uid]
	if(not info or damage <= 0) then
		return
	end

	inv.lastActivity = os.time()
	local credit = inv.credit[uid]
	if(not credit) then
		credit = {}
		inv.credit[uid] = credit
	end

	local before = credit[guid] or 0
	local after = math.min(info.maxHealth, before + damage)
	credit[guid] = after

	local data = inv.scores[guid]
	if(not data) then
		data = {name = name, score = 0, kills = 0}
		inv.scores[guid] = data
	end

	data.score = data.score + (after - before)
	if(before == 0) then
		data.kills = data.kills + 1
	end
end

local function onDeath(inv, uid)
	local info = inv.monsters[uid]
	if(not info) then
		return
	end

	inv.lastActivity = os.time()
	inv.monsters[uid] = nil
	inv.credit[uid] = nil
	inv.waveAlive[info.wave] = inv.waveAlive[info.wave] - 1
	inv.alive = inv.alive - 1
	inv.killed = inv.killed + 1

	if(info.boss) then
		Invasions.grantBonus(inv.def)
	end
end

-- reads what the kill/death scripts of the other states sent: "D,guid,name,uid,damage" and "K,uid"
function Invasions.processInbox()
	local text = readText(S.inbox)
	if(text == "") then
		return
	end

	writeText(S.inbox, "")
	local inv = Invasions.active
	if(not inv) then
		return
	end

	for entry in text:gmatch("[^;]+") do
		local f = split(entry, ",")
		if(f[1] == "D") then
			onDamage(inv, tonumber(f[2]), f[3], tonumber(f[4]), tonumber(f[5]) or 0)
		elseif(f[1] == "K") then
			onDeath(inv, tonumber(f[2]))
		end
	end
end

-- commands sent by /invasion (see Invasions.sendCommand)
function Invasions.processCommand()
	local text = readText(S.command)
	if(text == "") then
		return
	end

	writeText(S.command, "")
	local f = split(text, "|")
	local pid = f[3] ~= "" and getPlayerByName(f[3]) or nil
	local function reply(message)
		if(pid) then
			doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_BLUE, message)
		end
	end

	if(f[1] == "stop") then
		if(not Invasions.stop()) then
			reply("There is no invasion running.")
		end

		return
	end

	if(f[1] == "start") then
		local ok, reason
		local boss = f[4] == "boss" and true or nil
		if(f[2] == "") then
			ok, reason = Invasions.startForLevel({boss = boss})
		else
			local def = Invasions.getDefinition(f[2])
			if(not def) then
				reply("Invasion not found: " .. f[2] .. ". Use /invasion list.")
				return
			end

			ok, reason = Invasions.start(def, {boss = boss})
		end

		reply(ok and "Invasion started." or (reason or "Could not start the invasion."))
	end
end

-- picks the invasion of the tier that fits the average level of the players online: returns the definition and the average, or nil and the reason
function Invasions.pickForLevel()
	local average, count = Invasions.getAverageLevel()
	if(count < Invasions.minPlayers) then
		return nil, "not enough players online"
	end

	local candidates = {}
	for _, def in ipairs(Invasions.list) do
		if(average >= def.minLevel and average <= def.maxLevel and def.key ~= Invasions.lastKey) then
			table.insert(candidates, def)
		end
	end

	if(#candidates == 0) then
		-- nothing fits (the average is out of every band): the closest band
		local bestDistance
		for _, def in ipairs(Invasions.list) do
			local distance = average < def.minLevel and def.minLevel - average or math.max(0, average - def.maxLevel)
			if(def.key ~= Invasions.lastKey) then
				if(not bestDistance or distance < bestDistance) then
					bestDistance = distance
					candidates = {def}
				elseif(distance == bestDistance) then
					table.insert(candidates, def)
				end
			end
		end
	end

	return candidates[math.random(#candidates)], average
end

-- picks the invasion by the average level and starts it right away, without the countdown (/invasion start with no key)
function Invasions.startForLevel(opts)
	opts = opts or {}
	local def, average = Invasions.pickForLevel()
	if(not def) then
		return false, average
	end

	opts.averageLevel = average
	return Invasions.start(def, opts)
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Prelude: countdown of preludeMinutes with a different message every minute, then the invasion starts
-- ---------------------------------------------------------------------------------------------------------------------------

-- message of the prelude for the minutes left (1 = last minute)
function Invasions.getPreludeMessage(def, minutesLeft)
	local place = Invasions.getPlaceName(def)
	local custom = def.prelude and def.prelude[minutesLeft]
	if(custom) then
		return string.format(custom, place)
	end

	if(minutesLeft == 3) then
		return string.format(def.intro, place) .. " They arrive in 3 minutes! (tier " .. def.tierName .. ", recommended level " .. def.minLevel .. "+)"
	end

	local text = Invasions.preludeMessages[minutesLeft] or Invasions.preludeMessages[5]
	return string.format(text, place) .. (minutesLeft > 1 and (" (" .. minutesLeft .. " minutes)") or "")
end

function Invasions.beginPrelude(def, opts)
	Invasions.prelude = {def = def, opts = opts or {}, startedAt = os.time(), lastAnnounced = nil, revealed = false}
	Invasions.prelude.opts.fromPrelude = true
	Invasions.updatePrelude()
end

-- announces the message of each minute and starts the invasion when the countdown ends
function Invasions.updatePrelude()
	local prelude = Invasions.prelude
	if(not prelude) then
		return
	end

	local total = Invasions.preludeMinutes * 60
	local elapsed = os.time() - prelude.startedAt
	if(elapsed >= total) then
		Invasions.prelude = nil
		writeText(S.prelude, "")
		local ok, reason = Invasions.start(prelude.def, prelude.opts)
		if(not ok) then
			broadcast("[Invasion] The invaders turned back. (" .. tostring(reason) .. ")")
		end

		return
	end

	local minutesLeft = math.ceil((total - elapsed) / 60)
	if(minutesLeft ~= prelude.lastAnnounced) then
		prelude.lastAnnounced = minutesLeft
		if(minutesLeft <= 3) then
			prelude.revealed = true
		end

		broadcast("[Invasion] " .. Invasions.getPreludeMessage(prelude.def, minutesLeft))
	end

	-- name (only after it was revealed) | when it starts | recommended level
	writeText(S.prelude, (prelude.revealed and prelude.def.name or "") .. "|" .. (prelude.startedAt + total) .. "|" .. prelude.def.minLevel)
end

-- seconds left of the running invasion
function Invasions.getTimeLeft()
	local inv = Invasions.active
	if(not inv) then
		return 0
	end

	return math.max(0, inv.startedAt + inv.def.duration - os.time())
end

-- invaders without a target go to the nearest player outside protection zones
function Invasions.hunt()
	local inv = Invasions.active
	if(not inv or inv.alive <= 0) then
		return
	end

	local players = getTargets()
	if(#players == 0) then
		return
	end

	for uid in pairs(inv.monsters) do
		if(getCreatureTarget(uid) == 0) then
			local pos = getCreaturePosition(uid)
			local best, bestDistance = nil, Invasions.huntRange + 1
			for _, player in ipairs(players) do
				if(player.pos.z == pos.z) then
					local distance = math.max(math.abs(player.pos.x - pos.x), math.abs(player.pos.y - pos.y))
					if(distance < bestDistance) then
						best, bestDistance = player.cid, distance
					end
				end
			end

			if(best) then
				doMonsterSetTarget(uid, best)
			end
		end
	end
end

-- progress of the invasion: removes vanished invaders, ends it (time, idle, victory), brings the next wave and sends idle invaders to the players
function Invasions.update()
	local inv = Invasions.active
	if(not inv) then
		return
	end

	for uid, info in pairs(inv.monsters) do
		if(not isCreature(uid) or getCreatureHealth(uid) <= 0) then
			inv.monsters[uid] = nil
			inv.credit[uid] = nil
			inv.waveAlive[info.wave] = inv.waveAlive[info.wave] - 1
			inv.alive = inv.alive - 1
		end
	end

	if(Invasions.getTimeLeft() <= 0) then
		Invasions.finish(false, "time")
		return
	end

	if(os.time() - inv.lastActivity >= Invasions.idleTimeout) then
		Invasions.finish(false, "idle")
		return
	end

	-- the monsters of the wave appear little by little
	Invasions.releaseQueue()
	local allAppeared = inv.released >= #inv.queue

	if(inv.wave >= #inv.waves) then
		if(allAppeared and inv.alive <= 0) then
			Invasions.finish(true)
			return
		end
	elseif(allAppeared) then
		local alive = inv.waveAlive[inv.wave] or 0
		local needed = math.floor((inv.waveSpawned[inv.wave] or 0) * Invasions.waveClearRatio)
		if(alive <= needed or os.time() - inv.waveTime >= inv.waveDuration) then
			local index = inv.wave + 1
			if(Invasions.beginWave(index) > 0) then
				local label = (inv.boss and index == #inv.waves) and "BOSS WAVE" or ("Wave " .. index .. "/" .. #inv.waves)
				broadcast("[Invasion] " .. label .. ": " .. inv.waves[index].message)
			elseif(inv.alive <= 0) then
				Invasions.finish(true)
				return
			end
		end
	end

	if(os.time() - inv.lastHunt >= Invasions.huntInterval) then
		inv.lastHunt = os.time()
		Invasions.hunt()
	end
end

-- starts the countdown of each slot (intervalHours): the invasion begins preludeMinutes later, at the hour of the slot
function Invasions.checkSchedule()
	local now = os.date("*t")
	local nowMinute = now.hour * 60 + now.min
	local dayKey = now.year * 1000 + now.yday
	if(Invasions.firedDay ~= dayKey) then
		Invasions.firedDay = dayKey
		Invasions.firedSlots = {}
	end

	local period = Invasions.intervalHours * 60
	local key = dayKey .. ":" .. nowMinute
	if((nowMinute + Invasions.preludeMinutes) % period == Invasions.startMinute and not Invasions.firedSlots[key]) then
		Invasions.firedSlots[key] = true
		if(not Invasions.active and not Invasions.prelude) then
			-- the invasion is drawn now (its type is revealed with 3 minutes left); the strength uses the average level when it begins
			local def = Invasions.pickForLevel()
			if(def) then
				Invasions.beginPrelude(def)
			end
		end
	end
end

-- publishes the state for the other Lua states (!invasion, login message)
function Invasions.publish()
	local inv = Invasions.active
	if(not inv) then
		writeText(S.head, "")
		writeText(S.rank, "")
		writeText(S.scores, "")
		return
	end

	local def = inv.def
	writeText(S.head, table.concat({def.name, def.minLevel, Invasions.getPlaceName(def), inv.center.x, inv.center.y, inv.center.z, inv.wave, #inv.waves,
		inv.alive, inv.killed, inv.startedAt + def.duration, def.minScore, def.tierName}, "|"))

	local ranking = getRanking(inv)
	local rank, scores = {}, {}
	for position, entry in ipairs(ranking) do
		table.insert(scores, entry.guid .. "=" .. entry.score)
		if(position <= 5) then
			table.insert(rank, entry.name .. "=" .. entry.score .. "=" .. entry.kills)
		end
	end

	writeText(S.rank, table.concat(rank, ";"))
	writeText(S.scores, table.concat(scores, ";"))
end

-- everything the owner does every 2 seconds
function Invasions.tick()
	Invasions.processCommand()
	Invasions.processInbox()
	Invasions.checkSchedule()
	Invasions.updatePrelude()
	Invasions.update()
	Invasions.publish()

	if(os.time() - Invasions.lastBonusCheck >= 10) then
		Invasions.lastBonusCheck = os.time()
		Invasions.ensureBonuses(false)
	end
end
