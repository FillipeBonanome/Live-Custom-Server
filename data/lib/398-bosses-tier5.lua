-- Bosses of the tier V invasions (mechanics in data/lib/394-boss-spells.lua, documentation in doc/sistemas/36-bosses.md).
-- The hardest ones: 6 states (one of them shielded), 13-14 spells, an ENRAGE TIMER of 7 minutes and, besides the mechanics of the tiers
-- before, three new ones: sectors (pie slices of the arena that hit twice), seekers (marks that chase the players) and the channel
-- (a DPS CHECK that wipes the group if it does not damage the boss enough in time). Gravity (pull to the edge, pull back, explode)
-- and the "last spell" that chains 3 mechanics close the fight.
--
--   Archfiend Zulkarath    Demonic Rift       Rift ─> Infernal Gate (shield) ─> Hellfire ─> Soulstorm ─> Abyss ─> Armageddon
--   Deathwyrm Nekhrazul    Dead Dragons       Awakening ─> Bone Citadel (shield) ─> Deathstorm ─> Soulfeast ─> Tomb of Ages ─> Final Requiem
--   Hellforged Overlord    Hell's Legion      Muster ─> Legion Barrier (shield) ─> Siege ─> Conquest ─> Overrun ─> Final Verdict
--   Malgorath

local BS, T, ready = BossSpell, DecisionTree, Cond.ready
local C = Cond

local ENRAGE_MS = 7 * 60 * 1000

local function def(name, fn)
	BS.define(name, fn)
end

local function at(target)
	return getCreaturePosition(target)
end

local function shieldState(spell, nextState, exitSay, maxMs, tree)
	return {
		onEnter = function(monster)
			doCreatureCastSpell(monster, spell, true)
		end,
		onExit = function(monster)
			MonsterAI.setImmune(monster, false)
			MonsterAI.say(monster, exitSay)
			doSendMagicEffect(getCreaturePosition(monster), CONST_ME_MAGIC_RED)
		end,
		transitions = {
			{to = nextState, condition = C.all(C.inState(2000), C.noSummons())},
			{to = nextState, condition = C.inState(maxMs)}
		},
		tree = tree
	}
end

local function enrage(text, speed, final)
	return function(monster, target, memory)
		memory.rage = true
		if(final) then
			memory.final = true
		end

		MonsterAI.say(monster, text, TALKTYPE_MONSTER_YELL)
		if(speed and speed > 0) then
			doChangeSpeed(monster, speed)
		end

		doSendMagicEffect(getCreaturePosition(monster), CONST_ME_MAGIC_RED)
	end
end

local function rotation(entries, fallback)
	local node = T.priority(fallback)
	for i = #entries, 1, -1 do
		local entry = entries[i]
		local condition = C.all(C.chance(entry[2]), ready(entry[1]), entry[3] or function() return true end)
		node = T.branch(condition, T.action(entry[1]), node)
	end

	return node
end

local function withEnrageTimer(definition, finalState, ms)
	for name, state in pairs(definition.states) do
		if(name ~= finalState) then
			state.transitions = state.transitions or {}
			table.insert(state.transitions, {to = finalState, condition = C.age(ms)})
		end
	end

	return definition
end

local pair = C.playersAround(2, 12)

-- the group is thrown to the edge of the arena, dragged back to the boss and the area explodes
local function gravity(cid, radius, combat, min, max, effect, ani)
	if(not BS.pull(cid, {to = 7, ani = ani})) then return false end
	BS.later(cid, 1600, function()
		BS.pull(cid, {to = 2, ani = ani})
		BS.later(cid, 400, function()
			BS.nova(cid, {radius = radius, delay = 1800, combat = combat, min = min, max = max, effect = effect})
		end)
	end)
end

-- ===========================================================================================================================
-- Archfiend Zulkarath (Demonic Rift) - fire
-- ===========================================================================================================================
def("Zulkarath Hellfire Breath", function(cid, mem, target)
	if(not target) then return false end
	local options = {length = 11, turns = mem.rage and {0, 2} or {0}, delay = 1500, combat = COMBAT_FIREDAMAGE, min = 450, max = 650, effect = CONST_ME_FIREAREA, ani = CONST_ANI_FIRE,
		stack = {extra = 100, max = 5, ms = 20000, name = "Hellburn"}}
	if(not BS.cone(cid, at(target), options)) then return false end
	if(mem.rage) then
		BS.later(cid, 2000, function()
			local again = getCreatureTarget(cid)
			if(again and again ~= 0 and isCreature(again)) then
				options.turns = {0}
				BS.cone(cid, at(again), options)
			end
		end)
	end
end)

def("Zulkarath Rift Beams", function(cid, mem)
	return BS.beam(cid, {arms = 4, steps = 12, width = 3, length = 11, interval = 420, delay = 1000, reverse = math.random(2) == 1, combat = COMBAT_FIREDAMAGE, min = 400, max = 580, effect = CONST_ME_FIREAREA})
end)

def("Zulkarath Brimstone Rain", function(cid, mem)
	return BS.rain(cid, {count = mem.rage and 11 or 9, radius = 2, disc = true, spread = 2, delay = 1800, interval = 300, combat = COMBAT_FIREDAMAGE, min = 380, max = 560, effect = CONST_ME_FIREAREA, ani = CONST_ANI_FIRE,
		linger = {ticks = 8, interval = 1000, min = 120, max = 180, effect = CONST_ME_FIREAREA}})
end)

def("Zulkarath Chains of Torment", function(cid)
	return BS.tether(cid, {pairs = 2, mode = "apart", distance = 6, time = 5500, combat = COMBAT_FIREDAMAGE, min = 600, max = 850, effect = CONST_ME_FIREAREA, ani = CONST_ANI_FIRE})
end)

def("Zulkarath Damnation", function(cid, mem)
	return BS.cleanse(cid, {count = mem.rage and 4 or 3, spots = 3, radius = 7, time = 5500, combat = COMBAT_FIREDAMAGE, min = 650, max = 900, effect = CONST_ME_FIREAREA,
		dot = {combat = COMBAT_FIREDAMAGE, damage = 90, ticks = 6, interval = 1000, effect = CONST_ME_FIREAREA}})
end)

def("Zulkarath Demonic Pact", function(cid)
	return BS.polarity(cid, {time = 6000, radius = 8, zone = 2, combat = COMBAT_FIREDAMAGE, min = 700, max = 950, effect = CONST_ME_FIREAREA,
		dot = {combat = COMBAT_FIREDAMAGE, damage = 80, ticks = 5, interval = 1000, effect = CONST_ME_FIREAREA}})
end)

def("Zulkarath Hellfire Idols", function(cid, mem)
	return BS.bombs(cid, {monster = "Hellfire Idol", count = mem.rage and 4 or 3, time = 10000, radius = 5, combat = COMBAT_FIREDAMAGE, min = 700, max = 950, effect = CONST_ME_FIREAREA, heal = 5})
end)

def("Zulkarath Rift Sectors", function(cid)
	return BS.sectors(cid, {slices = 8, count = 4, radius = 10, delay = 1800, combat = COMBAT_FIREDAMAGE, min = 500, max = 700, effect = CONST_ME_FIREAREA, complement = true, gap = 1600, delay2 = 1300})
end)

def("Zulkarath Flame Seekers", function(cid, mem)
	return BS.seeker(cid, {count = mem.rage and 4 or 3, steps = 8, interval = 450, radius = 1, delay = 800, combat = COMBAT_FIREDAMAGE, min = 450, max = 650, effect = CONST_ME_FIREAREA,
		stack = {extra = 100, max = 5, ms = 20000, name = "Hellburn"}})
end)

def("Zulkarath Abyssal Gravity", function(cid)
	return gravity(cid, 5, COMBAT_FIREDAMAGE, 600, 850, CONST_ME_FIREAREA, CONST_ANI_FIRE)
end)

def("Zulkarath Annihilation", function(cid)
	return BS.channel(cid, {time = 10000, percent = 4, text = "ANNIHILATION", failText = "ANNIHILATION!", combat = COMBAT_FIREDAMAGE, min = 1500, max = 2000, effect = CONST_ME_FIREAREA})
end)

def("Zulkarath Infernal Gate", function(cid)
	BS.shield(cid, {{"Hellspawn", 3}, {"Dark Torturer", 2}, {"Hellhound", 2}}, "The gate is open! Legion, defend me!", CONST_ANI_FIRE)
	BS.siphon(cid, {ticks = 28, percent = 0.4})
	return true
end)

-- safe squares, then pie slices (twice) and, to finish, flame seekers
def("Zulkarath Armageddon", function(cid)
	BS.safeSpots(cid, {radius = 11, spots = 3, delay = 2800, combat = COMBAT_FIREDAMAGE, min = 800, max = 1100, effect = CONST_ME_FIREAREA})
	BS.later(cid, 3100, function()
		BS.sectors(cid, {slices = 8, count = 4, radius = 11, delay = 1600, combat = COMBAT_FIREDAMAGE, min = 600, max = 850, effect = CONST_ME_FIREAREA, complement = true, gap = 1400, delay2 = 1200})
	end)
	BS.later(cid, 7200, function()
		BS.seeker(cid, {count = 4, steps = 8, interval = 450, radius = 1, delay = 800, combat = COMBAT_FIREDAMAGE, min = 450, max = 650, effect = CONST_ME_FIREAREA})
	end)
end)

MonsterAI.register("Archfiend Zulkarath", withEnrageTimer({
	initialState = "Rift",
	globalCooldown = 2000,
	spells = {
		["Zulkarath Hellfire Breath"] = {cooldown = 7000, range = 11},
		["Zulkarath Rift Beams"] = {cooldown = 12000},
		["Zulkarath Brimstone Rain"] = {cooldown = 10000},
		["Zulkarath Chains of Torment"] = {cooldown = 20000, say = "Chained in hellfire!"},
		["Zulkarath Damnation"] = {cooldown = 19000, say = "DAMNED!"},
		["Zulkarath Demonic Pact"] = {cooldown = 24000, say = "Choose your master!"},
		["Zulkarath Hellfire Idols"] = {cooldown = 28000, say = "Rise, my idols!"},
		["Zulkarath Rift Sectors"] = {cooldown = 16000},
		["Zulkarath Flame Seekers"] = {cooldown = 14000},
		["Zulkarath Abyssal Gravity"] = {cooldown = 26000, say = "THE ABYSS PULLS!"},
		["Zulkarath Annihilation"] = {cooldown = 50000},
		["Zulkarath Infernal Gate"] = {cooldown = 1000},
		["Zulkarath Armageddon"] = {cooldown = 32000, say = "ARMAGEDDON!"}
	},
	states = {
		Rift = {
			transitions = {{to = "Infernal Gate", condition = C.hpBelow(85)}},
			tree = rotation({{"Zulkarath Chains of Torment", 25, pair}, {"Zulkarath Damnation", 30}, {"Zulkarath Rift Sectors", 35}, {"Zulkarath Flame Seekers", 30}, {"Zulkarath Rift Beams", 30}}, {"Zulkarath Hellfire Breath", "Zulkarath Brimstone Rain"})
		},
		["Infernal Gate"] = shieldState("Zulkarath Infernal Gate", "Hellfire", "The gate is shut!", 45000,
			rotation({{"Zulkarath Brimstone Rain", 50}, {"Zulkarath Rift Beams", 35}}, {"Zulkarath Hellfire Breath"})),
		Hellfire = {
			onEnter = enrage("THE RIFT BURNS!", 0),
			transitions = {{to = "Soulstorm", condition = C.hpBelow(62)}},
			tree = rotation({{"Zulkarath Annihilation", 60}, {"Zulkarath Hellfire Idols", 35}, {"Zulkarath Demonic Pact", 35}, {"Zulkarath Chains of Torment", 30, pair}, {"Zulkarath Damnation", 30}, {"Zulkarath Rift Sectors", 35}, {"Zulkarath Flame Seekers", 30}, {"Zulkarath Rift Beams", 30}}, {"Zulkarath Hellfire Breath", "Zulkarath Brimstone Rain"})
		},
		Soulstorm = {
			transitions = {{to = "Abyss", condition = C.hpBelow(38)}},
			tree = rotation({{"Zulkarath Annihilation", 60}, {"Zulkarath Abyssal Gravity", 40}, {"Zulkarath Hellfire Idols", 35}, {"Zulkarath Demonic Pact", 35}, {"Zulkarath Damnation", 35}, {"Zulkarath Rift Sectors", 35}, {"Zulkarath Flame Seekers", 35}, {"Zulkarath Chains of Torment", 30, pair}}, {"Zulkarath Rift Beams", "Zulkarath Brimstone Rain"})
		},
		Abyss = {
			onEnter = enrage("THE ABYSS HUNGERS!", 30),
			transitions = {{to = "Armageddon", condition = C.hpBelow(16)}},
			tree = rotation({{"Zulkarath Annihilation", 60}, {"Zulkarath Abyssal Gravity", 45}, {"Zulkarath Hellfire Idols", 40}, {"Zulkarath Demonic Pact", 40}, {"Zulkarath Damnation", 40}, {"Zulkarath Rift Sectors", 40}, {"Zulkarath Flame Seekers", 40}, {"Zulkarath Hellfire Breath", 40, C.targetNear(11)}}, {"Zulkarath Rift Beams", "Zulkarath Brimstone Rain"})
		},
		Armageddon = {
			onEnter = enrage("EVERYTHING BURNS! ARMAGEDDON!", 40, true),
			tree = rotation({{"Zulkarath Armageddon", 100}, {"Zulkarath Annihilation", 50}, {"Zulkarath Abyssal Gravity", 45}, {"Zulkarath Hellfire Idols", 40}, {"Zulkarath Flame Seekers", 40}, {"Zulkarath Rift Sectors", 40}}, {"Zulkarath Rift Beams", "Zulkarath Brimstone Rain"})
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "The rift... closes...", TALKTYPE_MONSTER)
	end
}, "Armageddon", ENRAGE_MS))

-- ===========================================================================================================================
-- Deathwyrm Nekhrazul (Wrath of the Dead Dragons) - death
-- ===========================================================================================================================
def("Nekhrazul Grave Breath", function(cid, mem, target)
	if(not target) then return false end
	local options = {length = 12, turns = mem.rage and {0, 2} or {0}, delay = 1500, combat = COMBAT_DEATHDAMAGE, min = 450, max = 650, effect = CONST_ME_MORTAREA, ani = CONST_ANI_DEATH,
		stack = {extra = 100, max = 5, ms = 20000, name = "Withering"}}
	if(not BS.cone(cid, at(target), options)) then return false end
	if(mem.rage) then
		BS.later(cid, 2000, function()
			local again = getCreatureTarget(cid)
			if(again and again ~= 0 and isCreature(again)) then
				options.turns = {0}
				BS.cone(cid, at(again), options)
			end
		end)
	end
end)

def("Nekhrazul Wing Storm", function(cid, mem)
	return BS.waves(cid, {bands = {{0, 2}, {2, 4}, {4, 6}, {6, 8}, {8, 10}, {10, 12}}, interval = 500, delay = 1200, reverse = mem.final, combat = COMBAT_DEATHDAMAGE, min = 400, max = 580, effect = CONST_ME_MORTAREA})
end)

def("Nekhrazul Bone Rain", function(cid, mem)
	return BS.rain(cid, {count = mem.rage and 12 or 10, radius = 1, spread = 2, delay = 1700, interval = 280, combat = COMBAT_DEATHDAMAGE, min = 380, max = 560, effect = CONST_ME_MORTAREA, ani = CONST_ANI_DEATH,
		linger = {ticks = 8, interval = 1000, min = 100, max = 150, effect = CONST_ME_MORTAREA}})
end)

def("Nekhrazul Soul Chains", function(cid)
	return BS.tether(cid, {pairs = 2, mode = "together", distance = 3, time = 5500, combat = COMBAT_DEATHDAMAGE, min = 600, max = 850, effect = CONST_ME_MORTAREA, ani = CONST_ANI_DEATH})
end)

def("Nekhrazul Marked for Death", function(cid, mem)
	return BS.cleanse(cid, {count = mem.rage and 4 or 3, spots = 3, radius = 7, time = 5500, combat = COMBAT_DEATHDAMAGE, min = 650, max = 900, effect = CONST_ME_MORTAREA,
		dot = {combat = COMBAT_DEATHDAMAGE, damage = 90, ticks = 6, interval = 1000, effect = CONST_ME_MORTAREA}})
end)

def("Nekhrazul Twin Souls", function(cid)
	return BS.polarity(cid, {time = 6000, radius = 8, zone = 2, combat = COMBAT_DEATHDAMAGE, min = 700, max = 950, effect = CONST_ME_MORTAREA,
		dot = {combat = COMBAT_DEATHDAMAGE, damage = 80, ticks = 5, interval = 1000, effect = CONST_ME_MORTAREA}})
end)

def("Nekhrazul Soul Phylacteries", function(cid, mem)
	return BS.bombs(cid, {monster = "Soulbound Skull", count = mem.rage and 4 or 3, time = 10000, radius = 5, combat = COMBAT_DEATHDAMAGE, min = 700, max = 950, effect = CONST_ME_MORTAREA, heal = 5})
end)

def("Nekhrazul Tomb Sectors", function(cid)
	return BS.sectors(cid, {slices = 6, count = 3, radius = 11, delay = 1800, combat = COMBAT_DEATHDAMAGE, min = 520, max = 720, effect = CONST_ME_MORTAREA, complement = true, gap = 1600, delay2 = 1300})
end)

def("Nekhrazul Wraith Seekers", function(cid, mem)
	return BS.seeker(cid, {count = mem.rage and 4 or 3, steps = 8, interval = 450, radius = 1, delay = 800, combat = COMBAT_DEATHDAMAGE, min = 450, max = 650, effect = CONST_ME_MORTAREA,
		stack = {extra = 100, max = 5, ms = 20000, name = "Withering"}})
end)

def("Nekhrazul Tomb Gravity", function(cid)
	return gravity(cid, 5, COMBAT_DEATHDAMAGE, 600, 850, CONST_ME_MORTAREA, CONST_ANI_DEATH)
end)

def("Nekhrazul Death Knell", function(cid)
	return BS.channel(cid, {time = 10000, percent = 4, text = "DEATH KNELL", failText = "THE BELL TOLLS FOR YOU!", combat = COMBAT_DEATHDAMAGE, min = 1500, max = 2000, effect = CONST_ME_MORTAREA})
end)

def("Nekhrazul Bone Citadel", function(cid)
	BS.shield(cid, {{"Demon Skeleton", 4}, {"Defiler", 2}, {"Destroyer", 1}}, "The citadel of bone rises!", CONST_ANI_DEATH)
	BS.siphon(cid, {ticks = 28, percent = 0.4})
	return true
end)

-- safe squares, pie slices and then a stack that the survivors share
def("Nekhrazul Final Requiem", function(cid)
	BS.safeSpots(cid, {radius = 11, spots = 3, delay = 2800, combat = COMBAT_DEATHDAMAGE, min = 800, max = 1100, effect = CONST_ME_MORTAREA})
	BS.later(cid, 3100, function()
		BS.sectors(cid, {slices = 6, count = 3, radius = 11, delay = 1600, combat = COMBAT_DEATHDAMAGE, min = 600, max = 850, effect = CONST_ME_MORTAREA, complement = true, gap = 1400, delay2 = 1200})
	end)
	BS.later(cid, 7200, function()
		BS.stack(cid, {count = 2, radius = 2, follow = 1500, delay = 1000, total = 2600, maxEach = 1000, combat = COMBAT_DEATHDAMAGE, effect = CONST_ME_MORTAREA})
	end)
end)

MonsterAI.register("Deathwyrm Nekhrazul", withEnrageTimer({
	initialState = "Awakening",
	globalCooldown = 2000,
	spells = {
		["Nekhrazul Grave Breath"] = {cooldown = 7000, range = 12},
		["Nekhrazul Wing Storm"] = {cooldown = 13000},
		["Nekhrazul Bone Rain"] = {cooldown = 10000},
		["Nekhrazul Soul Chains"] = {cooldown = 20000, say = "Bound in death!"},
		["Nekhrazul Marked for Death"] = {cooldown = 19000, say = "Your names are written."},
		["Nekhrazul Twin Souls"] = {cooldown = 24000, say = "Two souls, two paths!"},
		["Nekhrazul Soul Phylacteries"] = {cooldown = 28000, say = "Feed the phylacteries!"},
		["Nekhrazul Tomb Sectors"] = {cooldown = 16000},
		["Nekhrazul Wraith Seekers"] = {cooldown = 14000},
		["Nekhrazul Tomb Gravity"] = {cooldown = 26000, say = "THE TOMB CLAIMS YOU!"},
		["Nekhrazul Death Knell"] = {cooldown = 50000},
		["Nekhrazul Bone Citadel"] = {cooldown = 1000},
		["Nekhrazul Final Requiem"] = {cooldown = 32000, say = "THE FINAL REQUIEM!"}
	},
	states = {
		Awakening = {
			transitions = {{to = "Bone Citadel", condition = C.hpBelow(85)}},
			tree = rotation({{"Nekhrazul Soul Chains", 25, pair}, {"Nekhrazul Marked for Death", 30}, {"Nekhrazul Tomb Sectors", 35}, {"Nekhrazul Wraith Seekers", 30}, {"Nekhrazul Wing Storm", 30}}, {"Nekhrazul Grave Breath", "Nekhrazul Bone Rain"})
		},
		["Bone Citadel"] = shieldState("Nekhrazul Bone Citadel", "Deathstorm", "The citadel crumbles!", 45000,
			rotation({{"Nekhrazul Bone Rain", 50}, {"Nekhrazul Wing Storm", 35}}, {"Nekhrazul Grave Breath"})),
		Deathstorm = {
			onEnter = enrage("DEATH RAINS FROM THE SKY!", 0),
			transitions = {{to = "Soulfeast", condition = C.hpBelow(62)}},
			tree = rotation({{"Nekhrazul Death Knell", 60}, {"Nekhrazul Soul Phylacteries", 35}, {"Nekhrazul Twin Souls", 35}, {"Nekhrazul Soul Chains", 30, pair}, {"Nekhrazul Marked for Death", 30}, {"Nekhrazul Tomb Sectors", 35}, {"Nekhrazul Wraith Seekers", 30}, {"Nekhrazul Wing Storm", 30}}, {"Nekhrazul Grave Breath", "Nekhrazul Bone Rain"})
		},
		Soulfeast = {
			transitions = {{to = "Tomb of Ages", condition = C.hpBelow(38)}},
			tree = rotation({{"Nekhrazul Death Knell", 60}, {"Nekhrazul Tomb Gravity", 40}, {"Nekhrazul Soul Phylacteries", 35}, {"Nekhrazul Twin Souls", 35}, {"Nekhrazul Marked for Death", 35}, {"Nekhrazul Tomb Sectors", 35}, {"Nekhrazul Wraith Seekers", 35}, {"Nekhrazul Soul Chains", 30, pair}}, {"Nekhrazul Wing Storm", "Nekhrazul Bone Rain"})
		},
		["Tomb of Ages"] = {
			onEnter = enrage("I HAVE FED ON AGES!", 30),
			transitions = {{to = "Final Requiem", condition = C.hpBelow(16)}},
			tree = rotation({{"Nekhrazul Death Knell", 60}, {"Nekhrazul Tomb Gravity", 45}, {"Nekhrazul Soul Phylacteries", 40}, {"Nekhrazul Twin Souls", 40}, {"Nekhrazul Marked for Death", 40}, {"Nekhrazul Tomb Sectors", 40}, {"Nekhrazul Wraith Seekers", 40}, {"Nekhrazul Grave Breath", 40, C.targetNear(12)}}, {"Nekhrazul Wing Storm", "Nekhrazul Bone Rain"})
		},
		["Final Requiem"] = {
			onEnter = enrage("DEATH IS ALL THAT REMAINS!", 40, true),
			tree = rotation({{"Nekhrazul Final Requiem", 100}, {"Nekhrazul Death Knell", 50}, {"Nekhrazul Tomb Gravity", 45}, {"Nekhrazul Soul Phylacteries", 40}, {"Nekhrazul Wraith Seekers", 40}, {"Nekhrazul Tomb Sectors", 40}}, {"Nekhrazul Wing Storm", "Nekhrazul Bone Rain"})
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "Ashes... to ashes...", TALKTYPE_MONSTER)
	end
}, "Final Requiem", ENRAGE_MS))

-- ===========================================================================================================================
-- Hellforged Overlord Malgorath (Hell's Legion) - energy
-- ===========================================================================================================================
-- two grids of lightning: the second one covers the gaps of the first
def("Malgorath Hellstorm Volley", function(cid, mem, target)
	if(not target) then return false end
	local to = at(target)
	local options = {offsets = {-4, -2, 0, 2, 4}, length = 12, delay = 1500, combat = COMBAT_ENERGYDAMAGE, min = 450, max = 650, effect = CONST_ME_ENERGYAREA, ani = CONST_ANI_ENERGY,
		stack = {extra = 100, max = 5, ms = 20000, name = "Overcharged"}}
	if(not BS.lanes(cid, to, options)) then return false end
	BS.later(cid, 1700, function()
		options.offsets = {-5, -3, -1, 1, 3, 5}
		options.delay = 1400
		BS.lanes(cid, to, options)
	end)
end)

def("Malgorath Arc Chain", function(cid, mem)
	return BS.chain(cid, {hops = mem.rage and 10 or 8, radius = 1, delay = 600, hop = 5, combat = COMBAT_ENERGYDAMAGE, min = 400, max = 580, effect = CONST_ME_ENERGYAREA, ani = CONST_ANI_ENERGY})
end)

def("Malgorath Legion Beams", function(cid, mem)
	return BS.beam(cid, {arms = 2, steps = 12, width = 3, length = 12, interval = 420, delay = 1000, reverse = math.random(2) == 1, combat = COMBAT_ENERGYDAMAGE, min = 400, max = 580, effect = CONST_ME_ENERGYAREA})
end)

def("Malgorath Doom Rain", function(cid, mem)
	return BS.rain(cid, {count = mem.rage and 11 or 9, radius = 2, disc = true, spread = 2, delay = 1800, interval = 300, combat = COMBAT_ENERGYDAMAGE, min = 380, max = 560, effect = CONST_ME_ENERGYAREA, ani = CONST_ANI_ENERGY,
		linger = {ticks = 8, interval = 1000, min = 120, max = 180, effect = CONST_ME_ENERGYAREA}})
end)

def("Malgorath Binding Sigils", function(cid)
	return BS.tether(cid, {pairs = 2, mode = "apart", distance = 7, time = 5500, combat = COMBAT_ENERGYDAMAGE, min = 600, max = 850, effect = CONST_ME_ENERGYAREA, ani = CONST_ANI_ENERGY})
end)

def("Malgorath Mark of the Legion", function(cid, mem)
	return BS.cleanse(cid, {count = mem.rage and 4 or 3, spots = 3, radius = 7, time = 5500, combat = COMBAT_ENERGYDAMAGE, min = 650, max = 900, effect = CONST_ME_ENERGYAREA,
		dot = {combat = COMBAT_ENERGYDAMAGE, damage = 90, ticks = 6, interval = 1000, effect = CONST_ME_ENERGYAREA}})
end)

def("Malgorath Dual Allegiance", function(cid)
	return BS.polarity(cid, {time = 6000, radius = 8, zone = 2, combat = COMBAT_ENERGYDAMAGE, min = 700, max = 950, effect = CONST_ME_ENERGYAREA,
		dot = {combat = COMBAT_ENERGYDAMAGE, damage = 80, ticks = 5, interval = 1000, effect = CONST_ME_ENERGYAREA}})
end)

def("Malgorath Hellforged Cores", function(cid, mem)
	return BS.bombs(cid, {monster = "Hellforged Core", count = mem.rage and 4 or 3, time = 10000, radius = 5, combat = COMBAT_ENERGYDAMAGE, min = 700, max = 950, effect = CONST_ME_ENERGYAREA, heal = 5})
end)

def("Malgorath Phalanx Sectors", function(cid)
	return BS.sectors(cid, {slices = 12, count = 6, radius = 12, delay = 1800, combat = COMBAT_ENERGYDAMAGE, min = 500, max = 700, effect = CONST_ME_ENERGYAREA, complement = true, gap = 1600, delay2 = 1300})
end)

def("Malgorath Hunter Drones", function(cid, mem)
	return BS.seeker(cid, {count = mem.rage and 4 or 3, steps = 8, interval = 450, radius = 1, delay = 800, combat = COMBAT_ENERGYDAMAGE, min = 450, max = 650, effect = CONST_ME_ENERGYAREA,
		stack = {extra = 100, max = 5, ms = 20000, name = "Overcharged"}})
end)

def("Malgorath Siege Gravity", function(cid)
	return gravity(cid, 5, COMBAT_ENERGYDAMAGE, 600, 850, CONST_ME_ENERGYAREA, CONST_ANI_ENERGY)
end)

def("Malgorath Judgement", function(cid)
	return BS.channel(cid, {time = 10000, percent = 4, text = "JUDGEMENT", failText = "YOU ARE JUDGED!", combat = COMBAT_ENERGYDAMAGE, min = 1500, max = 2000, effect = CONST_ME_ENERGYAREA})
end)

def("Malgorath Legion Barrier", function(cid)
	BS.shield(cid, {{"Hellfire Fighter", 3}, {"Infernalist", 2}, {"Grim Reaper", 1}}, "The legion shields its overlord!", CONST_ANI_ENERGY)
	BS.siphon(cid, {ticks = 28, percent = 0.4})
	return true
end)

-- safe squares, then a chain of lightning, pie slices and the hunters
def("Malgorath Final Verdict", function(cid)
	BS.safeSpots(cid, {radius = 11, spots = 3, delay = 2800, combat = COMBAT_ENERGYDAMAGE, min = 800, max = 1100, effect = CONST_ME_ENERGYAREA})
	BS.later(cid, 3100, function()
		BS.chain(cid, {hops = 8, radius = 1, delay = 600, hop = 5, combat = COMBAT_ENERGYDAMAGE, min = 450, max = 650, effect = CONST_ME_ENERGYAREA, ani = CONST_ANI_ENERGY})
	end)
	BS.later(cid, 8200, function()
		BS.sectors(cid, {slices = 12, count = 6, radius = 12, delay = 1600, combat = COMBAT_ENERGYDAMAGE, min = 600, max = 850, effect = CONST_ME_ENERGYAREA, complement = true, gap = 1400, delay2 = 1200})
	end)
end)

MonsterAI.register("Hellforged Overlord Malgorath", withEnrageTimer({
	initialState = "Muster",
	globalCooldown = 2000,
	spells = {
		["Malgorath Hellstorm Volley"] = {cooldown = 9000, range = 12},
		["Malgorath Arc Chain"] = {cooldown = 11000},
		["Malgorath Legion Beams"] = {cooldown = 12000},
		["Malgorath Doom Rain"] = {cooldown = 10000},
		["Malgorath Binding Sigils"] = {cooldown = 20000, say = "Sigils of binding!"},
		["Malgorath Mark of the Legion"] = {cooldown = 19000, say = "You are marked."},
		["Malgorath Dual Allegiance"] = {cooldown = 24000, say = "Pledge yourselves!"},
		["Malgorath Hellforged Cores"] = {cooldown = 28000, say = "Cores, online!"},
		["Malgorath Phalanx Sectors"] = {cooldown = 16000},
		["Malgorath Hunter Drones"] = {cooldown = 14000},
		["Malgorath Siege Gravity"] = {cooldown = 26000, say = "THE SIEGE BEGINS!"},
		["Malgorath Judgement"] = {cooldown = 50000},
		["Malgorath Legion Barrier"] = {cooldown = 1000},
		["Malgorath Final Verdict"] = {cooldown = 34000, say = "THE FINAL VERDICT!"}
	},
	states = {
		Muster = {
			transitions = {{to = "Legion Barrier", condition = C.hpBelow(85)}},
			tree = rotation({{"Malgorath Binding Sigils", 25, pair}, {"Malgorath Mark of the Legion", 30}, {"Malgorath Phalanx Sectors", 35}, {"Malgorath Hunter Drones", 30}, {"Malgorath Legion Beams", 30}}, {"Malgorath Hellstorm Volley", "Malgorath Doom Rain"})
		},
		["Legion Barrier"] = shieldState("Malgorath Legion Barrier", "Siege", "The barrier falls!", 45000,
			rotation({{"Malgorath Doom Rain", 50}, {"Malgorath Legion Beams", 35}}, {"Malgorath Arc Chain"})),
		Siege = {
			onEnter = enrage("THE SIEGE BEGINS!", 0),
			transitions = {{to = "Conquest", condition = C.hpBelow(62)}},
			tree = rotation({{"Malgorath Judgement", 60}, {"Malgorath Hellforged Cores", 35}, {"Malgorath Dual Allegiance", 35}, {"Malgorath Binding Sigils", 30, pair}, {"Malgorath Mark of the Legion", 30}, {"Malgorath Phalanx Sectors", 35}, {"Malgorath Hunter Drones", 30}, {"Malgorath Arc Chain", 30}}, {"Malgorath Hellstorm Volley", "Malgorath Doom Rain"})
		},
		Conquest = {
			transitions = {{to = "Overrun", condition = C.hpBelow(38)}},
			tree = rotation({{"Malgorath Judgement", 60}, {"Malgorath Siege Gravity", 40}, {"Malgorath Hellforged Cores", 35}, {"Malgorath Dual Allegiance", 35}, {"Malgorath Mark of the Legion", 35}, {"Malgorath Phalanx Sectors", 35}, {"Malgorath Hunter Drones", 35}, {"Malgorath Binding Sigils", 30, pair}}, {"Malgorath Legion Beams", "Malgorath Doom Rain"})
		},
		Overrun = {
			onEnter = enrage("THE LEGION OVERRUNS YOU!", 30),
			transitions = {{to = "Final Verdict", condition = C.hpBelow(16)}},
			tree = rotation({{"Malgorath Judgement", 60}, {"Malgorath Siege Gravity", 45}, {"Malgorath Hellforged Cores", 40}, {"Malgorath Dual Allegiance", 40}, {"Malgorath Mark of the Legion", 40}, {"Malgorath Phalanx Sectors", 40}, {"Malgorath Hunter Drones", 40}, {"Malgorath Hellstorm Volley", 40, C.targetNear(12)}}, {"Malgorath Legion Beams", "Malgorath Arc Chain"})
		},
		["Final Verdict"] = {
			onEnter = enrage("THE VERDICT IS DEATH!", 40, true),
			tree = rotation({{"Malgorath Final Verdict", 100}, {"Malgorath Judgement", 50}, {"Malgorath Siege Gravity", 45}, {"Malgorath Hellforged Cores", 40}, {"Malgorath Hunter Drones", 40}, {"Malgorath Phalanx Sectors", 40}}, {"Malgorath Legion Beams", "Malgorath Doom Rain"})
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "Hell... will... remember...", TALKTYPE_MONSTER)
	end
}, "Final Verdict", ENRAGE_MS))
