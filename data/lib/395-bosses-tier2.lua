-- Bosses of the tier II invasions (mechanics library in data/lib/394-boss-spells.lua, AI system in data/lib/391-monster-ai.lua,
-- documentation in doc/sistemas/36-bosses.md). Each boss has 4 states and the spells below; the scripts of the spells
-- (data/spells/scripts/ai/<spell>.lua) only call BossSpell.cast(cid, "Spell Name").
--
--   Forgemaster Brokk   Dwarven Uprising     Forge ─> Overheat (shield) ─> Meltdown ─> Cataclysm
--   Hexlord Mokthar     Minotaur Warband     Ritual ─> Warded (shield) ─> Unbound ─> Overload
--   Empress Aethra      Amazon Assault       Skirmish ─> Phalanx (shield) ─> Onslaught ─> Last Stand
--   Captain Blackreef   Pirate Raid          Broadside ─> Boarding (shield) ─> Powder Hold ─> Scuttle
--   Titan Korg          Cyclops Rampage      Smash ─> Stone Skin (shield) ─> Rockfall ─> Titanfall
--   Hierarch Ssurrak    Lizard Legion        Ambush ─> Shed Skin (shield) ─> Venom ─> Sunscale
--   Vizier Khalzar      Djinn War            Court ─> Lamp Guard (shield) ─> Wrath ─> Wishbreaker

local BS, T, ready = BossSpell, DecisionTree, Cond.ready
local C = Cond

local function def(name, fn)
	BS.define(name, fn)
end

local function at(target)
	return getCreaturePosition(target)
end

-- state of the shield: the spell summons the guards and turns the shield on; the AI turns it off when every guard is dead (or after maxMs)
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

-- onEnter of the last states: sets the flags the spells read (memory.rage / memory.final), yells and gets faster
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

-- ===========================================================================================================================
-- Forgemaster Brokk (Dwarven Uprising)
-- ===========================================================================================================================
def("Brokk Hammer Slam", function(cid, mem, target)
	if(not target) then return false end
	return BS.cone(cid, at(target), {length = 5, turns = mem.rage and {0, 2} or {0}, delay = 1300, combat = COMBAT_PHYSICALDAMAGE, min = 90, max = 150, effect = CONST_ME_HITAREA, ani = CONST_ANI_SMALLSTONE})
end)

def("Brokk Powder Keg", function(cid, mem)
	return BS.bait(cid, {count = mem.rage and 3 or 2, radius = 2, follow = 2400, delay = 900, combat = COMBAT_FIREDAMAGE, min = 110, max = 180,
		effect = CONST_ME_EXPLOSIONAREA, dot = {combat = COMBAT_FIREDAMAGE, damage = 20, ticks = 4, interval = 1000, effect = CONST_ME_FIREAREA}})
end)

def("Brokk Anvil Waves", function(cid, mem)
	return BS.waves(cid, {bands = {{0, 2}, {2, 4}, {4, 6}, {6, 8}}, interval = 650, delay = 1200, reverse = mem.final, combat = COMBAT_PHYSICALDAMAGE, min = 80, max = 140, effect = CONST_ME_GROUNDSHAKER})
end)

def("Brokk Molten Rain", function(cid, mem)
	return BS.rain(cid, {count = mem.rage and 8 or 6, radius = 1, spread = 1, delay = 1700, interval = 350, combat = COMBAT_FIREDAMAGE, min = 70, max = 120,
		effect = CONST_ME_FIREAREA, ani = CONST_ANI_FIRE, dot = {combat = COMBAT_FIREDAMAGE, damage = 15, ticks = 3, interval = 1000, effect = CONST_ME_FIREAREA}})
end)

def("Brokk Forge Guards", function(cid)
	return BS.shield(cid, {{"Dwarf Guard", 4}, {"Dwarf Geomancer", 2}}, "The forge protects me! Guards!", CONST_ANI_FIRE)
end)

def("Brokk Cataclysm", function(cid)
	return BS.safeSpots(cid, {radius = 7, spots = 3, delay = 2600, combat = COMBAT_FIREDAMAGE, min = 160, max = 260, effect = CONST_ME_FIREAREA})
end)

MonsterAI.register("Forgemaster Brokk", {
	initialState = "Forge",
	globalCooldown = 1800,
	spells = {
		["Brokk Hammer Slam"] = {cooldown = 5000, range = 5},
		["Brokk Powder Keg"] = {cooldown = 11000, say = "Fire in the hole!"},
		["Brokk Anvil Waves"] = {cooldown = 9000, say = "Feel the anvil!"},
		["Brokk Molten Rain"] = {cooldown = 8000},
		["Brokk Forge Guards"] = {cooldown = 1000},
		["Brokk Cataclysm"] = {cooldown = 20000, say = "THE FORGE BURNS EVERYTHING!"}
	},
	states = {
		Forge = {
			transitions = {{to = "Overheat", condition = C.hpBelow(70)}},
			tree = T.branch(C.all(C.chance(35), ready("Brokk Powder Keg")), T.action("Brokk Powder Keg"),
				T.branch(C.targetFar(3), T.priority({"Brokk Molten Rain", "Brokk Anvil Waves"}),
					T.branch(C.all(C.chance(55), ready("Brokk Hammer Slam")), T.action("Brokk Hammer Slam"),
						T.priority({"Brokk Anvil Waves", "Brokk Molten Rain"}))))
		},
		-- shielded: the guards protect him while the forge rains fire and the anvil waves keep the players moving
		Overheat = shieldState("Brokk Forge Guards", "Meltdown", "Your hammers are useless!", 40000,
			T.branch(C.chance(60), T.priority({"Brokk Molten Rain", "Brokk Anvil Waves"}))),
		Meltdown = {
			onEnter = enrage("THE FORGE IS MELTING!", 0),
			transitions = {{to = "Cataclysm", condition = C.hpBelow(35)}},
			tree = T.branch(C.all(C.chance(40), ready("Brokk Powder Keg")), T.action("Brokk Powder Keg"),
				T.branch(C.all(C.chance(50), ready("Brokk Anvil Waves")), T.action("Brokk Anvil Waves"),
					T.branch(C.all(C.playersAround(1, 5), ready("Brokk Hammer Slam")), T.action("Brokk Hammer Slam"),
						T.priority({"Brokk Molten Rain", "Brokk Hammer Slam"}))))
		},
		Cataclysm = {
			onEnter = enrage("NOTHING WILL LEAVE THIS FORGE ALIVE!", 50, true),
			tree = T.branch(ready("Brokk Cataclysm"), T.action("Brokk Cataclysm"),
				T.branch(C.all(C.chance(45), ready("Brokk Powder Keg")), T.action("Brokk Powder Keg"),
					T.priority({"Brokk Anvil Waves", "Brokk Molten Rain", "Brokk Hammer Slam"})))
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "The forge... goes cold...", TALKTYPE_MONSTER)
	end
})

-- ===========================================================================================================================
-- Hexlord Mokthar (Minotaur Warband)
-- ===========================================================================================================================
def("Mokthar Arcane Lines", function(cid, mem)
	local stages = {BS.STRAIGHT, BS.DIAGONAL, BS.STRAIGHT}
	if(mem.rage) then
		table.insert(stages, BS.DIAGONAL)
	end

	return BS.arms(cid, {stages = stages, length = 7, interval = 700, delay = 1400, combat = COMBAT_ENERGYDAMAGE, min = 80, max = 140, effect = CONST_ME_ENERGYAREA})
end)

def("Mokthar Hex Bolt", function(cid, mem)
	return BS.bait(cid, {count = mem.rage and 3 or 2, radius = 1, follow = 2200, delay = 900, combat = COMBAT_ENERGYDAMAGE, min = 110, max = 170,
		effect = CONST_ME_ENERGYAREA, slow = {0.5, 3000}})
end)

def("Mokthar Chain Lightning", function(cid, mem)
	return BS.chain(cid, {hops = mem.rage and 6 or 4, radius = 1, delay = 800, hop = 5, combat = COMBAT_ENERGYDAMAGE, min = 90, max = 150, effect = CONST_ME_ENERGYAREA, ani = CONST_ANI_ENERGY})
end)

def("Mokthar Overload", function(cid)
	return BS.nova(cid, {radius = 7, safe = 2, delay = 2000, combat = COMBAT_ENERGYDAMAGE, min = 120, max = 190, effect = CONST_ME_ENERGYAREA})
end)

def("Mokthar Call Herd", function(cid)
	return BS.summon(cid, {{"Minotaur Guard", 2}, {"Minotaur Archer", 2}}, 6, CONST_ANI_ENERGY)
end)

def("Mokthar Mystic Ward", function(cid)
	return BS.shield(cid, {{"Minotaur Mage", 3}, {"Minotaur Guard", 2}}, "The ward answers my call!", CONST_ANI_ENERGY)
end)

MonsterAI.register("Hexlord Mokthar", {
	initialState = "Ritual",
	globalCooldown = 1800,
	spells = {
		["Mokthar Arcane Lines"] = {cooldown = 7000},
		["Mokthar Hex Bolt"] = {cooldown = 10000, say = "Hexed!"},
		["Mokthar Chain Lightning"] = {cooldown = 9000, say = "Let the storm choose!"},
		["Mokthar Overload"] = {cooldown = 15000, say = "OVERLOAD!"},
		["Mokthar Call Herd"] = {cooldown = 15000, say = "To me, herd!"},
		["Mokthar Mystic Ward"] = {cooldown = 1000}
	},
	states = {
		Ritual = {
			transitions = {{to = "Warded", condition = C.hpBelow(70)}},
			tree = T.branch(C.all(C.summonsBelow(2), C.chance(30), ready("Mokthar Call Herd")), T.action("Mokthar Call Herd"),
				T.branch(C.all(C.chance(45), ready("Mokthar Chain Lightning")), T.action("Mokthar Chain Lightning"),
					T.branch(C.all(C.chance(55), ready("Mokthar Hex Bolt")), T.action("Mokthar Hex Bolt"),
						T.priority({"Mokthar Arcane Lines", "Mokthar Chain Lightning"}))))
		},
		Warded = shieldState("Mokthar Mystic Ward", "Unbound", "The ward is broken!", 40000,
			T.branch(C.chance(55), T.priority({"Mokthar Arcane Lines", "Mokthar Chain Lightning"}))),
		Unbound = {
			onEnter = enrage("NO MORE WARDS! FEEL MY POWER!", 0),
			transitions = {{to = "Overload", condition = C.hpBelow(35)}},
			tree = T.branch(C.all(C.chance(50), ready("Mokthar Chain Lightning")), T.action("Mokthar Chain Lightning"),
				T.branch(C.all(C.chance(50), ready("Mokthar Hex Bolt")), T.action("Mokthar Hex Bolt"),
					T.priority({"Mokthar Arcane Lines", "Mokthar Chain Lightning"})))
		},
		Overload = {
			onEnter = enrage("I AM THE STORM!", 40, true),
			tree = T.branch(C.all(C.chance(60), ready("Mokthar Overload")), T.action("Mokthar Overload"),
				T.branch(C.all(C.chance(50), ready("Mokthar Chain Lightning")), T.action("Mokthar Chain Lightning"),
					T.branch(C.all(C.chance(50), ready("Mokthar Hex Bolt")), T.action("Mokthar Hex Bolt"),
						T.priority({"Mokthar Arcane Lines", "Mokthar Call Herd"}))))
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "The hex... ends...", TALKTYPE_MONSTER)
	end
})

-- ===========================================================================================================================
-- Empress Aethra (Amazon Assault)
-- ===========================================================================================================================
def("Aethra Spear Barrage", function(cid, mem, target)
	if(not target) then return false end
	return BS.lanes(cid, at(target), {offsets = mem.rage and {-4, -2, 0, 2, 4} or {-3, 0, 3}, length = 9, delay = 1400, combat = COMBAT_PHYSICALDAMAGE, min = 90, max = 150, effect = CONST_ME_HITAREA, ani = CONST_ANI_SPEAR})
end)

def("Aethra Javelin Rain", function(cid, mem)
	return BS.rain(cid, {count = mem.rage and 7 or 5, radius = 1, spread = 1, delay = 1600, interval = 400, combat = COMBAT_PHYSICALDAMAGE, min = 70, max = 120,
		effect = CONST_ME_HITAREA, ani = CONST_ANI_SPEAR, slow = {0.4, 3000}})
end)

def("Aethra Mark of Prey", function(cid, mem)
	return BS.bait(cid, {count = mem.rage and 2 or 1, radius = 2, follow = 3000, delay = 900, combat = COMBAT_PHYSICALDAMAGE, min = 160, max = 260, effect = CONST_ME_HITAREA})
end)

def("Aethra Phalanx Charge", function(cid, mem, target)
	if(not target) then return false end
	return BS.leap(cid, at(target), {radius = 1, delay = 1400, combat = COMBAT_PHYSICALDAMAGE, min = 90, max = 150, effect = CONST_ME_HITAREA, ani = CONST_ANI_SPEAR,
		after = function(boss, center)
			addEvent(function()
				if(isCreature(boss)) then
					BS.cone(boss, center, {length = 4, delay = 1000, combat = COMBAT_PHYSICALDAMAGE, min = 90, max = 140, effect = CONST_ME_HITAREA})
				end
			end, 200)
		end})
end)

def("Aethra Shield Wall", function(cid)
	return BS.shield(cid, {{"Valkyrie", 3}, {"Amazon", 2}}, "Shields up! Protect your empress!", CONST_ANI_SPEAR)
end)

def("Aethra Last Stand", function(cid, mem)
	mem.lastStand = true
	MonsterAI.say(cid, "An empress never kneels!")
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_BLOCKHIT)
	MonsterAI.heal(cid, 12)
	return true
end)

MonsterAI.register("Empress Aethra", {
	initialState = "Skirmish",
	globalCooldown = 1800,
	spells = {
		["Aethra Spear Barrage"] = {cooldown = 6500, range = 9},
		["Aethra Javelin Rain"] = {cooldown = 8000},
		["Aethra Mark of Prey"] = {cooldown = 14000, say = "You. Yes, you."},
		["Aethra Phalanx Charge"] = {cooldown = 9000, range = 8, say = "CHARGE!"},
		["Aethra Shield Wall"] = {cooldown = 1000},
		["Aethra Last Stand"] = {cooldown = 1000}
	},
	states = {
		Skirmish = {
			transitions = {{to = "Phalanx", condition = C.hpBelow(68)}},
			tree = T.branch(C.all(C.chance(30), ready("Aethra Mark of Prey")), T.action("Aethra Mark of Prey"),
				T.branch(C.targetFar(4), T.priority({"Aethra Phalanx Charge", "Aethra Javelin Rain"}),
					T.branch(C.all(C.chance(55), ready("Aethra Spear Barrage")), T.action("Aethra Spear Barrage"),
						T.priority({"Aethra Javelin Rain", "Aethra Spear Barrage"}))))
		},
		Phalanx = shieldState("Aethra Shield Wall", "Onslaught", "Your wall has fallen!", 40000,
			T.branch(C.chance(55), T.priority({"Aethra Javelin Rain", "Aethra Spear Barrage"}))),
		Onslaught = {
			onEnter = enrage("NOW YOU FACE THE EMPRESS!", 40),
			transitions = {{to = "Last Stand", condition = C.hpBelow(30)}},
			tree = T.branch(C.all(C.chance(40), ready("Aethra Mark of Prey")), T.action("Aethra Mark of Prey"),
				T.branch(C.all(C.chance(45), ready("Aethra Phalanx Charge")), T.action("Aethra Phalanx Charge"),
					T.branch(C.all(C.chance(55), ready("Aethra Spear Barrage")), T.action("Aethra Spear Barrage"),
						T.priority({"Aethra Javelin Rain", "Aethra Phalanx Charge"}))))
		},
		["Last Stand"] = {
			onEnter = function(monster, target, memory)
				memory.final = true
			end,
			tree = T.branch(C.all(C.hpBelow(15), C.no(C.flag("lastStand")), ready("Aethra Last Stand")), T.action("Aethra Last Stand"),
				T.branch(C.all(C.chance(45), ready("Aethra Mark of Prey")), T.action("Aethra Mark of Prey"),
					T.branch(C.all(C.chance(50), ready("Aethra Phalanx Charge")), T.action("Aethra Phalanx Charge"),
						T.priority({"Aethra Spear Barrage", "Aethra Javelin Rain"}))))
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "Sisters... avenge me...", TALKTYPE_MONSTER)
	end
})

-- ===========================================================================================================================
-- Captain Blackreef (Pirate Raid)
-- ===========================================================================================================================
def("Blackreef Cannon Barrage", function(cid, mem)
	return BS.rain(cid, {count = mem.rage and 8 or 6, radius = 1, spread = 1, delay = 1800, interval = 350, combat = COMBAT_FIREDAMAGE, min = 80, max = 140, effect = CONST_ME_EXPLOSIONAREA, ani = CONST_ANI_FIRE})
end)

def("Blackreef Broadside", function(cid)
	return BS.stripes(cid, {width = 2, gap = 1, n = 2, span = 8, delay = 1900, combat = COMBAT_FIREDAMAGE, min = 90, max = 150, effect = CONST_ME_EXPLOSIONAREA})
end)

-- a random player is marked (red), hooked and dragged next to the captain, who slashes the spot 1.1 s later
def("Blackreef Grapple Hook", function(cid)
	local players = MonsterAI.playersAround(cid, 9)
	if(#players == 0) then return false end
	local pid = players[math.random(#players)]
	for t = 0, 1000, 500 do
		addEvent(function()
			if(isCreature(cid) and isPlayer(pid)) then
				doSendMagicEffect(getCreaturePosition(pid), CONST_ME_MAGIC_RED)
			end
		end, t)
	end

	addEvent(function()
		if(not isCreature(cid) or not isPlayer(pid)) then return end
		local boss = getCreaturePosition(cid)
		doSendDistanceShoot(boss, getCreaturePosition(pid), CONST_ANI_THROWINGKNIFE)
		for _, tile in ipairs(Telegraph.ring(boss, 1)) do
			if(doTeleportThing(pid, tile, false)) then
				doSendMagicEffect(tile, CONST_ME_POFF)
				break
			end
		end

		BS.cone(cid, getCreaturePosition(pid), {length = 3, delay = 1100, combat = COMBAT_PHYSICALDAMAGE, min = 120, max = 190, effect = CONST_ME_HITAREA})
	end, 1500)

	return true
end)

def("Blackreef Sea Mines", function(cid, mem)
	return BS.rain(cid, {count = mem.rage and 9 or 7, radius = 1, spread = 3, delay = 3800, interval = 200, combat = COMBAT_FIREDAMAGE, min = 100, max = 160, effect = CONST_ME_EXPLOSIONAREA})
end)

def("Blackreef Boarding Party", function(cid)
	return BS.shield(cid, {{"Pirate Marauder", 3}, {"Pirate Cutthroat", 2}, {"Pirate Buccaneer", 1}}, "Boarding party! Cover your captain!", CONST_ANI_THROWINGKNIFE)
end)

def("Blackreef Scuttle", function(cid)
	return BS.safeSpots(cid, {radius = 8, spots = 2, delay = 2600, combat = COMBAT_FIREDAMAGE, min = 170, max = 270, effect = CONST_ME_EXPLOSIONAREA})
end)

MonsterAI.register("Captain Blackreef", {
	initialState = "Broadside",
	globalCooldown = 1800,
	spells = {
		["Blackreef Cannon Barrage"] = {cooldown = 7500, say = "Fire the cannons!"},
		["Blackreef Broadside"] = {cooldown = 11000, say = "BROADSIDE!"},
		["Blackreef Grapple Hook"] = {cooldown = 12000, say = "Come aboard!"},
		["Blackreef Sea Mines"] = {cooldown = 13000},
		["Blackreef Boarding Party"] = {cooldown = 1000},
		["Blackreef Scuttle"] = {cooldown = 20000, say = "SCUTTLE THE SHIP!"}
	},
	states = {
		Broadside = {
			transitions = {{to = "Boarding", condition = C.hpBelow(68)}},
			tree = T.branch(C.all(C.chance(35), ready("Blackreef Grapple Hook")), T.action("Blackreef Grapple Hook"),
				T.branch(C.all(C.chance(40), ready("Blackreef Broadside")), T.action("Blackreef Broadside"),
					T.priority({"Blackreef Cannon Barrage", "Blackreef Broadside"})))
		},
		Boarding = shieldState("Blackreef Boarding Party", "Powder Hold", "My crew! Ye scurvy dogs!", 40000,
			T.branch(C.chance(55), T.priority({"Blackreef Cannon Barrage", "Blackreef Broadside"}))),
		["Powder Hold"] = {
			onEnter = enrage("The powder hold is open! Bwahaha!", 30),
			transitions = {{to = "Scuttle", condition = C.hpBelow(35)}},
			tree = T.branch(C.all(C.chance(45), ready("Blackreef Sea Mines")), T.action("Blackreef Sea Mines"),
				T.branch(C.all(C.chance(40), ready("Blackreef Grapple Hook")), T.action("Blackreef Grapple Hook"),
					T.branch(C.all(C.chance(40), ready("Blackreef Broadside")), T.action("Blackreef Broadside"),
						T.priority({"Blackreef Cannon Barrage", "Blackreef Sea Mines"}))))
		},
		Scuttle = {
			onEnter = enrage("IF I SINK, YE ALL SINK WITH ME!", 40, true),
			tree = T.branch(ready("Blackreef Scuttle"), T.action("Blackreef Scuttle"),
				T.branch(C.all(C.chance(40), ready("Blackreef Sea Mines")), T.action("Blackreef Sea Mines"),
					T.branch(C.all(C.chance(40), ready("Blackreef Grapple Hook")), T.action("Blackreef Grapple Hook"),
						T.priority({"Blackreef Broadside", "Blackreef Cannon Barrage"}))))
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "The sea... takes me...", TALKTYPE_MONSTER)
	end
})

-- ===========================================================================================================================
-- Titan Korg (Cyclops Rampage)
-- ===========================================================================================================================
def("Korg Ground Slam", function(cid, mem)
	local bands = {{0, 2}, {2, 4}, {4, 6}}
	if(mem.rage) then
		table.insert(bands, {6, 8})
	end

	return BS.waves(cid, {bands = bands, interval = 600, delay = 1200, combat = COMBAT_PHYSICALDAMAGE, min = 90, max = 150, effect = CONST_ME_GROUNDSHAKER})
end)

def("Korg Boulder Barrage", function(cid, mem)
	return BS.rain(cid, {count = mem.rage and 7 or 5, radius = 2, spread = 2, delay = 2000, interval = 400, combat = COMBAT_PHYSICALDAMAGE, min = 100, max = 170, effect = CONST_ME_HITAREA, ani = CONST_ANI_LARGEROCK})
end)

def("Korg Rock Chain", function(cid, mem)
	return BS.chain(cid, {hops = mem.rage and 5 or 4, radius = 1, delay = 800, hop = 5, combat = COMBAT_PHYSICALDAMAGE, min = 100, max = 160, effect = CONST_ME_GROUNDSHAKER, ani = CONST_ANI_LARGEROCK})
end)

def("Korg Stomp", function(cid, mem, target)
	if(not target) then return false end
	return BS.leap(cid, at(target), {radius = 2, delay = 1500, combat = COMBAT_PHYSICALDAMAGE, min = 110, max = 180, effect = CONST_ME_GROUNDSHAKER, ani = CONST_ANI_LARGEROCK})
end)

def("Korg Stone Skin", function(cid)
	return BS.shield(cid, {{"Cyclops", 3}, {"Cyclops Smith", 2}}, "Stone skin! Brothers, to me!", CONST_ANI_SMALLSTONE)
end)

def("Korg Titanfall", function(cid)
	return BS.safeSpots(cid, {radius = 8, spots = 3, delay = 2600, combat = COMBAT_PHYSICALDAMAGE, min = 170, max = 270, effect = CONST_ME_GROUNDSHAKER})
end)

MonsterAI.register("Titan Korg", {
	initialState = "Smash",
	globalCooldown = 2000,
	spells = {
		["Korg Ground Slam"] = {cooldown = 8000, say = "KORG SMASH!"},
		["Korg Boulder Barrage"] = {cooldown = 9000},
		["Korg Rock Chain"] = {cooldown = 10000},
		["Korg Stomp"] = {cooldown = 9000, range = 8, say = "STOMP!"},
		["Korg Stone Skin"] = {cooldown = 1000},
		["Korg Titanfall"] = {cooldown = 20000, say = "THE MOUNTAIN FALLS!"}
	},
	states = {
		Smash = {
			transitions = {{to = "Stone Skin", condition = C.hpBelow(70)}},
			tree = T.branch(C.all(C.playersAround(2, 3), C.chance(55), ready("Korg Ground Slam")), T.action("Korg Ground Slam"),
				T.branch(C.targetFar(4), T.priority({"Korg Stomp", "Korg Boulder Barrage"}),
					T.branch(C.all(C.chance(40), ready("Korg Rock Chain")), T.action("Korg Rock Chain"),
						T.priority({"Korg Ground Slam", "Korg Boulder Barrage"}))))
		},
		["Stone Skin"] = shieldState("Korg Stone Skin", "Rockfall", "Korg angry now!", 40000,
			T.branch(C.chance(55), T.priority({"Korg Boulder Barrage", "Korg Ground Slam"}))),
		Rockfall = {
			onEnter = enrage("ROCKS! EVERYWHERE ROCKS!", 0),
			transitions = {{to = "Titanfall", condition = C.hpBelow(35)}},
			tree = T.branch(C.all(C.chance(50), ready("Korg Boulder Barrage")), T.action("Korg Boulder Barrage"),
				T.branch(C.all(C.chance(45), ready("Korg Rock Chain")), T.action("Korg Rock Chain"),
					T.branch(C.targetFar(3), T.priority({"Korg Stomp", "Korg Ground Slam"}),
						T.priority({"Korg Ground Slam", "Korg Stomp"}))))
		},
		Titanfall = {
			onEnter = enrage("KORG IS MOUNTAIN!", 50, true),
			tree = T.branch(ready("Korg Titanfall"), T.action("Korg Titanfall"),
				T.branch(C.all(C.chance(45), ready("Korg Rock Chain")), T.action("Korg Rock Chain"),
					T.priority({"Korg Boulder Barrage", "Korg Ground Slam", "Korg Stomp"})))
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "Korg... falls...", TALKTYPE_MONSTER)
	end
})

-- ===========================================================================================================================
-- Hierarch Ssurrak (Lizard Legion)
-- ===========================================================================================================================
def("Ssurrak Spear Volley", function(cid, mem, target)
	if(not target) then return false end
	return BS.lanes(cid, at(target), {offsets = mem.rage and {-4, -2, 0, 2, 4} or {-2, 0, 2}, length = 8, delay = 1300, combat = COMBAT_EARTHDAMAGE, min = 90, max = 150, effect = CONST_ME_POISONAREA, ani = CONST_ANI_SPEAR})
end)

def("Ssurrak Venom Cloud", function(cid, mem)
	return BS.rain(cid, {count = mem.rage and 6 or 4, radius = 2, disc = true, spread = 1, delay = 1900, interval = 450, combat = COMBAT_EARTHDAMAGE, min = 60, max = 100,
		effect = CONST_ME_POISONAREA, ani = CONST_ANI_POISON, dot = {combat = COMBAT_EARTHDAMAGE, damage = 25, ticks = 5, interval = 1000, effect = CONST_ME_POISONAREA}})
end)

def("Ssurrak Tail Sweep", function(cid)
	return BS.cone(cid, getCreaturePosition(cid), {length = 3, turns = {0, 1, 2, 3}, delay = 1100, combat = COMBAT_PHYSICALDAMAGE, min = 100, max = 160, effect = CONST_ME_HITAREA})
end)

def("Ssurrak Marked Prey", function(cid, mem)
	return BS.bait(cid, {count = mem.rage and 3 or 2, radius = 2, follow = 2200, delay = 900, combat = COMBAT_EARTHDAMAGE, min = 110, max = 170, effect = CONST_ME_POISONAREA,
		dot = {combat = COMBAT_EARTHDAMAGE, damage = 25, ticks = 5, interval = 1000, effect = CONST_ME_POISONAREA}})
end)

def("Ssurrak Snake Charm", function(cid)
	return BS.summon(cid, {{"Lizard Snakecharmer", 2}, {"Lizard Sentinel", 1}}, 5, CONST_ANI_POISON)
end)

def("Ssurrak Shed Skin", function(cid)
	return BS.shield(cid, {{"Lizard Sentinel", 3}, {"Lizard Legionnaire", 2}}, "Sssshed the skin! Guard me!", CONST_ANI_POISON)
end)

def("Ssurrak Sunfire", function(cid)
	return BS.safeSpots(cid, {radius = 7, spots = 3, delay = 2400, combat = COMBAT_FIREDAMAGE, min = 160, max = 260, effect = CONST_ME_FIREAREA})
end)

MonsterAI.register("Hierarch Ssurrak", {
	initialState = "Ambush",
	globalCooldown = 1800,
	spells = {
		["Ssurrak Spear Volley"] = {cooldown = 6500, range = 9},
		["Ssurrak Venom Cloud"] = {cooldown = 9000},
		["Ssurrak Tail Sweep"] = {cooldown = 6000, range = 3},
		["Ssurrak Marked Prey"] = {cooldown = 12000, say = "Sssmell... fear..."},
		["Ssurrak Snake Charm"] = {cooldown = 15000, say = "Sssserve me!"},
		["Ssurrak Shed Skin"] = {cooldown = 1000},
		["Ssurrak Sunfire"] = {cooldown = 20000, say = "THE SUN... CLEANSES!"}
	},
	states = {
		Ambush = {
			transitions = {{to = "Shed Skin", condition = C.hpBelow(68)}},
			tree = T.branch(C.all(C.summonsBelow(2), C.chance(30), ready("Ssurrak Snake Charm")), T.action("Ssurrak Snake Charm"),
				T.branch(C.all(C.playersAround(1, 2), C.chance(60), ready("Ssurrak Tail Sweep")), T.action("Ssurrak Tail Sweep"),
					T.branch(C.all(C.chance(30), ready("Ssurrak Marked Prey")), T.action("Ssurrak Marked Prey"),
						T.branch(C.targetFar(3), T.priority({"Ssurrak Spear Volley", "Ssurrak Venom Cloud"}),
							T.priority({"Ssurrak Venom Cloud", "Ssurrak Spear Volley"})))))
		},
		["Shed Skin"] = shieldState("Ssurrak Shed Skin", "Venom", "My new skin is stronger!", 40000,
			T.branch(C.chance(55), T.priority({"Ssurrak Venom Cloud", "Ssurrak Spear Volley"}))),
		Venom = {
			onEnter = enrage("SSSTRIKE FROM THE SHADOWS!", 30),
			transitions = {{to = "Sunscale", condition = C.hpBelow(35)}},
			tree = T.branch(C.all(C.chance(45), ready("Ssurrak Marked Prey")), T.action("Ssurrak Marked Prey"),
				T.branch(C.all(C.playersAround(1, 2), C.chance(60), ready("Ssurrak Tail Sweep")), T.action("Ssurrak Tail Sweep"),
					T.branch(C.all(C.chance(50), ready("Ssurrak Venom Cloud")), T.action("Ssurrak Venom Cloud"),
						T.priority({"Ssurrak Spear Volley", "Ssurrak Snake Charm"}))))
		},
		Sunscale = {
			onEnter = enrage("THE SUN BURNS IN MY SCALES!", 40, true),
			tree = T.branch(ready("Ssurrak Sunfire"), T.action("Ssurrak Sunfire"),
				T.branch(C.all(C.chance(45), ready("Ssurrak Marked Prey")), T.action("Ssurrak Marked Prey"),
					T.branch(C.all(C.playersAround(1, 2), C.chance(60), ready("Ssurrak Tail Sweep")), T.action("Ssurrak Tail Sweep"),
						T.priority({"Ssurrak Venom Cloud", "Ssurrak Spear Volley"}))))
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "The legion... will rise again...", TALKTYPE_MONSTER)
	end
})

-- ===========================================================================================================================
-- Vizier Khalzar (Djinn War)
-- ===========================================================================================================================
def("Khalzar Lightning Chain", function(cid, mem)
	return BS.chain(cid, {hops = mem.rage and 7 or 5, radius = 1, delay = 750, hop = 5, combat = COMBAT_ENERGYDAMAGE, min = 90, max = 150, effect = CONST_ME_ENERGYAREA, ani = CONST_ANI_ENERGY})
end)

def("Khalzar Flame Waves", function(cid, mem)
	return BS.waves(cid, {bands = {{0, 2}, {2, 4}, {4, 6}, {6, 8}}, interval = 600, delay = 1200, reverse = mem.final, combat = COMBAT_FIREDAMAGE, min = 80, max = 140, effect = CONST_ME_FIREAREA})
end)

def("Khalzar Genie Lines", function(cid)
	return BS.arms(cid, {stages = {BS.DIAGONAL, BS.STRAIGHT, BS.DIAGONAL}, length = 8, interval = 700, delay = 1400, combat = COMBAT_ENERGYDAMAGE, min = 90, max = 150, effect = CONST_ME_ENERGYAREA})
end)

def("Khalzar Sand Prison", function(cid, mem)
	return BS.bait(cid, {count = 2, radius = 1, follow = 2000, delay = 900, combat = COMBAT_ENERGYDAMAGE, min = 100, max = 160, effect = CONST_ME_ENERGYAREA, slow = {0.9, 2500}})
end)

def("Khalzar Lamp Guards", function(cid)
	return BS.shield(cid, {{"Green Djinn", 3}, {"Blue Djinn", 3}}, "Genies of the lamp, protect your master!", CONST_ANI_ENERGY)
end)

def("Khalzar Wish Storm", function(cid)
	return BS.safeSpots(cid, {radius = 8, spots = 3, delay = 2400, combat = COMBAT_ENERGYDAMAGE, min = 170, max = 270, effect = CONST_ME_ENERGYAREA})
end)

MonsterAI.register("Vizier Khalzar", {
	initialState = "Court",
	globalCooldown = 1800,
	spells = {
		["Khalzar Lightning Chain"] = {cooldown = 9000, say = "The lightning finds its own!"},
		["Khalzar Flame Waves"] = {cooldown = 10000},
		["Khalzar Genie Lines"] = {cooldown = 7500},
		["Khalzar Sand Prison"] = {cooldown = 12000, say = "Be still!"},
		["Khalzar Lamp Guards"] = {cooldown = 1000},
		["Khalzar Wish Storm"] = {cooldown = 20000, say = "YOUR LAST WISH!"}
	},
	states = {
		Court = {
			transitions = {{to = "Lamp Guard", condition = C.hpBelow(68)}},
			tree = T.branch(C.all(C.chance(30), ready("Khalzar Sand Prison")), T.action("Khalzar Sand Prison"),
				T.branch(C.all(C.chance(45), ready("Khalzar Lightning Chain")), T.action("Khalzar Lightning Chain"),
					T.branch(C.all(C.chance(45), ready("Khalzar Flame Waves")), T.action("Khalzar Flame Waves"),
						T.priority({"Khalzar Genie Lines", "Khalzar Flame Waves"}))))
		},
		["Lamp Guard"] = shieldState("Khalzar Lamp Guards", "Wrath", "The lamp is broken!", 40000,
			T.branch(C.chance(55), T.priority({"Khalzar Genie Lines", "Khalzar Flame Waves"}))),
		Wrath = {
			onEnter = enrage("YOU DARE BREAK MY LAMP?!", 30),
			transitions = {{to = "Wishbreaker", condition = C.hpBelow(35)}},
			tree = T.branch(C.all(C.chance(45), ready("Khalzar Sand Prison")), T.action("Khalzar Sand Prison"),
				T.branch(C.all(C.chance(50), ready("Khalzar Lightning Chain")), T.action("Khalzar Lightning Chain"),
					T.branch(C.all(C.chance(50), ready("Khalzar Genie Lines")), T.action("Khalzar Genie Lines"),
						T.priority({"Khalzar Flame Waves", "Khalzar Lightning Chain"}))))
		},
		Wishbreaker = {
			onEnter = enrage("ALL YOUR WISHES END HERE!", 40, true),
			tree = T.branch(ready("Khalzar Wish Storm"), T.action("Khalzar Wish Storm"),
				T.branch(C.all(C.chance(45), ready("Khalzar Sand Prison")), T.action("Khalzar Sand Prison"),
					T.branch(C.all(C.chance(50), ready("Khalzar Lightning Chain")), T.action("Khalzar Lightning Chain"),
						T.priority({"Khalzar Flame Waves", "Khalzar Genie Lines"}))))
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "My... last... wish...", TALKTYPE_MONSTER)
	end
})
