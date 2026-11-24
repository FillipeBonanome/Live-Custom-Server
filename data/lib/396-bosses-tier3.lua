-- Bosses of the tier III invasions (mechanics in data/lib/394-boss-spells.lua, tier II in 395-bosses-tier2.lua, documentation in
-- doc/sistemas/36-bosses.md). 5 states each (one of them shielded) and the mechanics that make the players depend on each other
-- (tether, stack, cleanse) and on the arena (field, rotating beams, pull, echoes).
--
--   Necrarch Mortheus      Undead Uprising   Gravecall ─> Harvest (shield) ─> Deathbound ─> Requiem ─> Oblivion
--   Pyrothane Cinderlord   Elemental Surge   Smolder ─> Inferno Shell (shield) ─> Wildfire ─> Supernova ─> Cinderstorm
--   Glaciarch Vorthrax     Frost Siege       Chill ─> Carapace (shield) ─> Whiteout ─> Deep Freeze ─> Absolute Zero
--   Iron Overseer Kragmor  Golem Foundry     Assembly ─> Armor Plating (shield) ─> Overclock ─> Magnetize ─> Meltdown
--   Nightmare Weaver       Nightmare Horde   Twilight ─> Dreamveil (shield) ─> Terror ─> Lucid Dream ─> Nightfall
--   Syrelith

local BS, T, ready = BossSpell, DecisionTree, Cond.ready
local C = Cond

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

-- rotation of spells: entries = {{"Spell", chance[, extra condition]}, ...}; the first one that rolls its chance and is ready is cast,
-- otherwise the first ready spell of `fallback`
local function rotation(entries, fallback)
	local node = T.priority(fallback)
	for i = #entries, 1, -1 do
		local entry = entries[i]
		local condition = C.all(C.chance(entry[2]), ready(entry[1]), entry[3] or function() return true end)
		node = T.branch(condition, T.action(entry[1]), node)
	end

	return node
end

local pair = C.playersAround(2, 12)

-- ===========================================================================================================================
-- Necrarch Mortheus (Undead Uprising) - death
-- ===========================================================================================================================
def("Mortheus Grave Hands", function(cid, mem)
	local options = {count = mem.rage and 7 or 5, radius = 1, spread = 1, delay = 1600, interval = 350, combat = COMBAT_DEATHDAMAGE, min = 140, max = 220, effect = CONST_ME_MORTAREA, ani = CONST_ANI_DEATH}
	if(not BS.rain(cid, options)) then return false end
	if(mem.rage) then
		-- echo: the hands come back over the same players
		BS.later(cid, 2200, function()
			options.count = 3
			BS.rain(cid, options)
		end)
	end
end)

def("Mortheus Soul Tether", function(cid, mem)
	return BS.tether(cid, {pairs = mem.rage and 2 or 1, mode = "together", distance = 4, time = 5000, combat = COMBAT_DEATHDAMAGE, min = 260, max = 380, effect = CONST_ME_MORTAREA, ani = CONST_ANI_DEATH})
end)

def("Mortheus Death Mark", function(cid, mem)
	return BS.cleanse(cid, {count = mem.rage and 3 or 2, spots = 3, radius = 6, time = 5500, combat = COMBAT_DEATHDAMAGE, min = 300, max = 420, effect = CONST_ME_MORTAREA,
		dot = {combat = COMBAT_DEATHDAMAGE, damage = 40, ticks = 5, interval = 1000, effect = CONST_ME_MORTAREA}})
end)

def("Mortheus Bone Beam", function(cid, mem)
	return BS.beam(cid, {arms = 2, steps = mem.rage and 12 or 8, width = mem.rage and 3 or 1, length = 9, interval = 450, delay = 1000, combat = COMBAT_DEATHDAMAGE, min = 170, max = 260, effect = CONST_ME_MORTAREA})
end)

def("Mortheus Raise Dead", function(cid)
	local ok = BS.summon(cid, {{"Skeleton", 3}, {"Ghoul", 2}}, 8, CONST_ANI_DEATH)
	BS.siphon(cid, {ticks = 12, percent = 0.5})
	return ok
end)

def("Mortheus Bone Cage", function(cid)
	BS.shield(cid, {{"Crypt Shambler", 2}, {"BoneBeast", 2}, {"Banshee", 2}}, "Your souls are mine! Cage them!", CONST_ANI_DEATH)
	BS.siphon(cid, {ticks = 20, percent = 0.4})
	return true
end)

def("Mortheus Requiem", function(cid, mem)
	return BS.stack(cid, {count = mem.final and 2 or 1, radius = 2, follow = 2600, delay = 1000, total = 1100, maxEach = 480, combat = COMBAT_DEATHDAMAGE, effect = CONST_ME_MORTAREA})
end)

def("Mortheus Oblivion", function(cid)
	BS.safeSpots(cid, {radius = 8, spots = 3, delay = 2600, combat = COMBAT_DEATHDAMAGE, min = 330, max = 480, effect = CONST_ME_MORTAREA})
	-- the spots change right after the first hit
	BS.later(cid, 2900, function()
		BS.safeSpots(cid, {radius = 8, spots = 3, delay = 2200, combat = COMBAT_DEATHDAMAGE, min = 250, max = 380, effect = CONST_ME_MORTAREA})
	end)
end)

MonsterAI.register("Necrarch Mortheus", {
	initialState = "Gravecall",
	globalCooldown = 2000,
	spells = {
		["Mortheus Grave Hands"] = {cooldown = 8000},
		["Mortheus Soul Tether"] = {cooldown = 16000, say = "Bound in death!"},
		["Mortheus Death Mark"] = {cooldown = 15000, say = "Your time has come."},
		["Mortheus Bone Beam"] = {cooldown = 10000},
		["Mortheus Raise Dead"] = {cooldown = 20000, say = "Rise!"},
		["Mortheus Bone Cage"] = {cooldown = 1000},
		["Mortheus Requiem"] = {cooldown = 17000, say = "A requiem for the living!"},
		["Mortheus Oblivion"] = {cooldown = 24000, say = "OBLIVION!"}
	},
	states = {
		Gravecall = {
			transitions = {{to = "Harvest", condition = C.hpBelow(78)}},
			tree = rotation({{"Mortheus Soul Tether", 25, pair}, {"Mortheus Raise Dead", 30, C.summonsBelow(2)}, {"Mortheus Death Mark", 30}, {"Mortheus Bone Beam", 35}}, {"Mortheus Grave Hands", "Mortheus Bone Beam"})
		},
		Harvest = shieldState("Mortheus Bone Cage", "Deathbound", "My cage... broken?!", 45000,
			rotation({{"Mortheus Grave Hands", 55}, {"Mortheus Bone Beam", 35}}, {"Mortheus Grave Hands"})),
		Deathbound = {
			onEnter = enrage("DEATH BINDS YOU ALL!", 0),
			transitions = {{to = "Requiem", condition = C.hpBelow(50)}},
			tree = rotation({{"Mortheus Death Mark", 35}, {"Mortheus Soul Tether", 35, pair}, {"Mortheus Raise Dead", 25, C.summonsBelow(3)}, {"Mortheus Bone Beam", 40}}, {"Mortheus Grave Hands"})
		},
		Requiem = {
			transitions = {{to = "Oblivion", condition = C.hpBelow(22)}},
			tree = rotation({{"Mortheus Requiem", 40}, {"Mortheus Death Mark", 35}, {"Mortheus Soul Tether", 35, pair}, {"Mortheus Bone Beam", 40}, {"Mortheus Raise Dead", 20, C.summonsBelow(2)}}, {"Mortheus Grave Hands"})
		},
		Oblivion = {
			onEnter = enrage("THERE IS NO ESCAPE FROM THE VOID!", 40, true),
			tree = rotation({{"Mortheus Oblivion", 100}, {"Mortheus Requiem", 45}, {"Mortheus Death Mark", 40}, {"Mortheus Bone Beam", 45}}, {"Mortheus Grave Hands", "Mortheus Soul Tether"})
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "Death... was never... my master...", TALKTYPE_MONSTER)
	end
})

-- ===========================================================================================================================
-- Pyrothane the Cinderlord (Elemental Surge) - fire
-- ===========================================================================================================================
def("Pyrothane Magma Ring", function(cid, mem)
	return BS.field(cid, {inner = 5, outer = 9, ticks = mem.rage and 10 or 7, interval = 1000, delay = 800, combat = COMBAT_FIREDAMAGE, min = 90, max = 140, effect = CONST_ME_FIREAREA})
end)

def("Pyrothane Ember Stack", function(cid, mem)
	return BS.stack(cid, {count = mem.final and 2 or 1, radius = 2, follow = 2600, delay = 1000, total = 1200, maxEach = 500, combat = COMBAT_FIREDAMAGE, effect = CONST_ME_FIREAREA})
end)

def("Pyrothane Flare Beam", function(cid, mem)
	return BS.beam(cid, {arms = mem.rage and 2 or 1, steps = 10, width = 3, length = 10, interval = 400, delay = 1000, reverse = math.random(2) == 1, combat = COMBAT_FIREDAMAGE, min = 160, max = 240, effect = CONST_ME_FIREAREA})
end)

def("Pyrothane Repel", function(cid, mem)
	return BS.tether(cid, {pairs = mem.rage and 2 or 1, mode = "apart", distance = 5, time = 5000, combat = COMBAT_FIREDAMAGE, min = 250, max = 360, effect = CONST_ME_FIREAREA, ani = CONST_ANI_FIRE})
end)

def("Pyrothane Eruption", function(cid, mem)
	local options = {count = 6, radius = 2, disc = true, spread = 2, delay = 1800, interval = 400, combat = COMBAT_FIREDAMAGE, min = 150, max = 230, effect = CONST_ME_FIREAREA, ani = CONST_ANI_FIRE,
		dot = {combat = COMBAT_FIREDAMAGE, damage = 30, ticks = 4, interval = 1000, effect = CONST_ME_FIREAREA}}
	if(not BS.rain(cid, options)) then return false end
	if(mem.rage) then
		BS.later(cid, 2600, function()
			options.count = 4
			BS.rain(cid, options)
		end)
	end
end)

def("Pyrothane Elemental Call", function(cid)
	local ok = BS.summon(cid, {{"Fire Elemental", 2}, {"Energy Elemental", 1}, {"Earth Elemental", 1}}, 8, CONST_ANI_FIRE)
	BS.siphon(cid, {ticks = 12, percent = 0.5})
	return ok
end)

def("Pyrothane Inferno Shell", function(cid)
	BS.shield(cid, {{"Fire Elemental", 3}, {"Earth Elemental", 2}, {"Water Elemental", 1}}, "The flames shield their lord!", CONST_ANI_FIRE)
	BS.siphon(cid, {ticks = 20, percent = 0.4})
	return true
end)

-- everybody is dragged to the boss and the area explodes: run out of the circle
def("Pyrothane Supernova", function(cid, mem)
	if(not BS.pull(cid, {to = 2, ani = CONST_ANI_FIRE})) then return false end
	BS.later(cid, 400, function()
		BS.nova(cid, {radius = mem.final and 7 or 5, delay = 2200, combat = COMBAT_FIREDAMAGE, min = 280, max = 400, effect = CONST_ME_FIREAREA})
	end)
end)

MonsterAI.register("Pyrothane the Cinderlord", {
	initialState = "Smolder",
	globalCooldown = 2000,
	spells = {
		["Pyrothane Magma Ring"] = {cooldown = 18000, say = "The ground burns!"},
		["Pyrothane Ember Stack"] = {cooldown = 16000, say = "Share the flame!"},
		["Pyrothane Flare Beam"] = {cooldown = 10000},
		["Pyrothane Repel"] = {cooldown = 15000, say = "Burn apart!"},
		["Pyrothane Eruption"] = {cooldown = 9000},
		["Pyrothane Elemental Call"] = {cooldown = 20000},
		["Pyrothane Inferno Shell"] = {cooldown = 1000},
		["Pyrothane Supernova"] = {cooldown = 22000, say = "COLLAPSE!"}
	},
	states = {
		Smolder = {
			transitions = {{to = "Inferno Shell", condition = C.hpBelow(78)}},
			tree = rotation({{"Pyrothane Elemental Call", 30, C.summonsBelow(2)}, {"Pyrothane Magma Ring", 25}, {"Pyrothane Repel", 30, pair}, {"Pyrothane Flare Beam", 35}}, {"Pyrothane Eruption", "Pyrothane Flare Beam"})
		},
		["Inferno Shell"] = shieldState("Pyrothane Inferno Shell", "Wildfire", "My shell cracks!", 45000,
			rotation({{"Pyrothane Eruption", 55}, {"Pyrothane Flare Beam", 35}}, {"Pyrothane Eruption"})),
		Wildfire = {
			onEnter = enrage("THE WORLD IS KINDLING!", 0),
			transitions = {{to = "Supernova", condition = C.hpBelow(50)}},
			tree = rotation({{"Pyrothane Ember Stack", 35}, {"Pyrothane Repel", 35, pair}, {"Pyrothane Magma Ring", 30}, {"Pyrothane Flare Beam", 40}, {"Pyrothane Elemental Call", 25, C.summonsBelow(3)}}, {"Pyrothane Eruption"})
		},
		Supernova = {
			transitions = {{to = "Cinderstorm", condition = C.hpBelow(22)}},
			tree = rotation({{"Pyrothane Supernova", 45}, {"Pyrothane Ember Stack", 35}, {"Pyrothane Repel", 35, pair}, {"Pyrothane Magma Ring", 30}, {"Pyrothane Flare Beam", 40}}, {"Pyrothane Eruption"})
		},
		Cinderstorm = {
			onEnter = enrage("I AM THE END OF ALL THINGS!", 40, true),
			tree = rotation({{"Pyrothane Supernova", 60}, {"Pyrothane Ember Stack", 45}, {"Pyrothane Magma Ring", 35}, {"Pyrothane Repel", 40, pair}, {"Pyrothane Flare Beam", 45}}, {"Pyrothane Eruption"})
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "The embers... fade...", TALKTYPE_MONSTER)
	end
})

-- ===========================================================================================================================
-- Glaciarch Vorthrax (Frost Siege) - ice
-- ===========================================================================================================================
def("Vorthrax Frost Breath", function(cid, mem, target)
	if(not target) then return false end
	local to = at(target)
	local options = {length = 9, turns = mem.rage and {0, 2} or {0}, delay = 1500, combat = COMBAT_ICEDAMAGE, min = 180, max = 280, effect = CONST_ME_ICEAREA, ani = CONST_ANI_SMALLICE}
	if(not BS.cone(cid, to, options)) then return false end
	if(mem.rage) then
		-- the breath comes back, now at wherever the target stands
		BS.later(cid, 2000, function()
			local again = getCreatureTarget(cid)
			if(again and again ~= 0 and isCreature(again)) then
				options.turns = {0}
				BS.cone(cid, at(again), options)
			end
		end)
	end
end)

-- hazard BAND: staying next to the dragon or far away is safe, the middle is not
def("Vorthrax Whiteout", function(cid, mem)
	return BS.field(cid, {inner = 3, outer = 6, ticks = mem.rage and 10 or 7, interval = 1000, delay = 800, combat = COMBAT_ICEDAMAGE, min = 100, max = 150, effect = CONST_ME_ICEAREA})
end)

def("Vorthrax Ice Tether", function(cid, mem)
	return BS.tether(cid, {pairs = mem.rage and 2 or 1, mode = "together", distance = 3, time = 5000, combat = COMBAT_ICEDAMAGE, min = 250, max = 360, effect = CONST_ME_ICEAREA, ani = CONST_ANI_ICE})
end)

def("Vorthrax Shatter", function(cid, mem)
	return BS.stack(cid, {count = mem.final and 2 or 1, radius = 2, follow = 2600, delay = 1000, total = 1100, maxEach = 480, combat = COMBAT_ICEDAMAGE, effect = CONST_ME_ICEAREA})
end)

-- two grids of hail one after the other: the lane of the first one may be hit by the second
def("Vorthrax Hail Grid", function(cid, mem)
	local options = {width = 2, gap = 1, n = 3, span = 9, delay = 1900, combat = COMBAT_ICEDAMAGE, min = 150, max = 230, effect = CONST_ME_ICEAREA}
	BS.stripes(cid, options)
	BS.later(cid, 1600, function()
		options.delay = 1700
		BS.stripes(cid, options)
	end)
end)

def("Vorthrax Rime Call", function(cid)
	local ok = BS.summon(cid, {{"Winter Wolf", 3}, {"Yeti", 1}}, 8, CONST_ANI_SMALLICE)
	BS.siphon(cid, {ticks = 12, percent = 0.5})
	return ok
end)

def("Vorthrax Crystal Carapace", function(cid)
	BS.shield(cid, {{"Ice Golem", 3}, {"Yeti", 2}, {"Ice Witch", 1}}, "The ice protects its dragon!", CONST_ANI_SMALLICE)
	BS.siphon(cid, {ticks = 20, percent = 0.4})
	return true
end)

-- the safe squares appear and, right after the hit, a breath at the target catches whoever hides there
def("Vorthrax Absolute Zero", function(cid, mem, target)
	BS.safeSpots(cid, {radius = 9, spots = 3, delay = 2600, combat = COMBAT_ICEDAMAGE, min = 330, max = 480, effect = CONST_ME_ICEAREA})
	BS.later(cid, 2900, function()
		local again = getCreatureTarget(cid)
		if(again and again ~= 0 and isCreature(again)) then
			BS.cone(cid, at(again), {length = 9, delay = 1400, combat = COMBAT_ICEDAMAGE, min = 220, max = 330, effect = CONST_ME_ICEAREA, ani = CONST_ANI_SMALLICE})
		end
	end)
end)

MonsterAI.register("Glaciarch Vorthrax", {
	initialState = "Chill",
	globalCooldown = 2000,
	spells = {
		["Vorthrax Frost Breath"] = {cooldown = 7000, range = 9},
		["Vorthrax Whiteout"] = {cooldown = 18000, say = "The blizzard comes!"},
		["Vorthrax Ice Tether"] = {cooldown = 16000, say = "Bound by the frost!"},
		["Vorthrax Shatter"] = {cooldown = 16000, say = "Stand together or shatter!"},
		["Vorthrax Hail Grid"] = {cooldown = 12000},
		["Vorthrax Rime Call"] = {cooldown = 20000},
		["Vorthrax Crystal Carapace"] = {cooldown = 1000},
		["Vorthrax Absolute Zero"] = {cooldown = 24000, say = "ABSOLUTE ZERO!"}
	},
	states = {
		Chill = {
			transitions = {{to = "Carapace", condition = C.hpBelow(78)}},
			tree = rotation({{"Vorthrax Rime Call", 30, C.summonsBelow(2)}, {"Vorthrax Whiteout", 25}, {"Vorthrax Ice Tether", 30, pair}, {"Vorthrax Hail Grid", 35}}, {"Vorthrax Frost Breath", "Vorthrax Hail Grid"})
		},
		Carapace = shieldState("Vorthrax Crystal Carapace", "Whiteout", "The carapace shatters!", 45000,
			rotation({{"Vorthrax Frost Breath", 55}, {"Vorthrax Hail Grid", 35}}, {"Vorthrax Frost Breath"})),
		Whiteout = {
			onEnter = enrage("THE STORM IS MINE!", 0),
			transitions = {{to = "Deep Freeze", condition = C.hpBelow(50)}},
			tree = rotation({{"Vorthrax Shatter", 35}, {"Vorthrax Ice Tether", 35, pair}, {"Vorthrax Whiteout", 30}, {"Vorthrax Hail Grid", 40}, {"Vorthrax Rime Call", 25, C.summonsBelow(3)}}, {"Vorthrax Frost Breath"})
		},
		["Deep Freeze"] = {
			transitions = {{to = "Absolute Zero", condition = C.hpBelow(22)}},
			tree = rotation({{"Vorthrax Absolute Zero", 40}, {"Vorthrax Shatter", 35}, {"Vorthrax Ice Tether", 35, pair}, {"Vorthrax Whiteout", 30}, {"Vorthrax Hail Grid", 40}}, {"Vorthrax Frost Breath"})
		},
		["Absolute Zero"] = {
			onEnter = enrage("EVERYTHING FREEZES!", 40, true),
			tree = rotation({{"Vorthrax Absolute Zero", 100}, {"Vorthrax Shatter", 45}, {"Vorthrax Whiteout", 35}, {"Vorthrax Hail Grid", 45}}, {"Vorthrax Frost Breath", "Vorthrax Ice Tether"})
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "The winter... ends...", TALKTYPE_MONSTER)
	end
})

-- ===========================================================================================================================
-- Iron Overseer Kragmor (Golem Foundry) - physical / energy
-- ===========================================================================================================================
-- two grids of pistons: the second one covers the gaps of the first
def("Kragmor Piston Slam", function(cid, mem, target)
	if(not target) then return false end
	local to = at(target)
	local options = {offsets = {-4, -2, 0, 2, 4}, length = 10, delay = 1500, combat = COMBAT_PHYSICALDAMAGE, min = 170, max = 260, effect = CONST_ME_GROUNDSHAKER, ani = CONST_ANI_LARGEROCK}
	if(not BS.lanes(cid, to, options)) then return false end
	BS.later(cid, 1700, function()
		options.offsets = {-5, -3, -1, 1, 3, 5}
		options.delay = 1400
		BS.lanes(cid, to, options)
	end)
end)

-- hazard AROUND the boss: melee range burns
def("Kragmor Steam Vents", function(cid, mem)
	return BS.field(cid, {inner = 1, outer = 4, ticks = mem.rage and 10 or 7, interval = 1000, delay = 800, combat = COMBAT_FIREDAMAGE, min = 90, max = 140, effect = CONST_ME_FIREAREA})
end)

def("Kragmor Magnet Pull", function(cid, mem)
	if(not BS.pull(cid, {to = 2, ani = CONST_ANI_ENERGY})) then return false end
	BS.later(cid, 400, function()
		BS.nova(cid, {radius = 5, delay = 2000, combat = COMBAT_ENERGYDAMAGE, min = 240, max = 340, effect = CONST_ME_ENERGYAREA})
	end)
end)

def("Kragmor Overcharge", function(cid, mem)
	return BS.tether(cid, {pairs = mem.rage and 2 or 1, mode = "apart", distance = 5, time = 5000, combat = COMBAT_ENERGYDAMAGE, min = 260, max = 380, effect = CONST_ME_ENERGYAREA, ani = CONST_ANI_ENERGY})
end)

def("Kragmor Gear Beam", function(cid, mem)
	return BS.beam(cid, {arms = 4, steps = mem.rage and 10 or 6, width = 1, length = 9, interval = 500, delay = 1000, reverse = math.random(2) == 1, combat = COMBAT_PHYSICALDAMAGE, min = 160, max = 250, effect = CONST_ME_HITAREA})
end)

def("Kragmor Scrap Call", function(cid)
	local ok = BS.summon(cid, {{"Worker Golem", 3}, {"Stone Golem", 1}}, 8, CONST_ANI_SMALLSTONE)
	BS.siphon(cid, {ticks = 12, percent = 0.5})
	return ok
end)

def("Kragmor Armor Plating", function(cid)
	BS.shield(cid, {{"Stone Golem", 3}, {"Worker Golem", 2}, {"War Golem", 1}}, "Armor plating engaged!", CONST_ANI_SMALLSTONE)
	BS.siphon(cid, {ticks = 20, percent = 0.4})
	return true
end)

def("Kragmor Meltdown", function(cid)
	BS.safeSpots(cid, {radius = 9, spots = 2, delay = 2400, combat = COMBAT_ENERGYDAMAGE, min = 350, max = 480, effect = CONST_ME_ENERGYAREA})
	-- the survivors, huddled in the squares, must share the next hit
	BS.later(cid, 3000, function()
		BS.stack(cid, {count = 1, radius = 2, follow = 1500, delay = 1000, total = 1000, maxEach = 450, combat = COMBAT_ENERGYDAMAGE, effect = CONST_ME_ENERGYAREA})
	end)
end)

MonsterAI.register("Iron Overseer Kragmor", {
	initialState = "Assembly",
	globalCooldown = 2000,
	spells = {
		["Kragmor Piston Slam"] = {cooldown = 8000, range = 10},
		["Kragmor Steam Vents"] = {cooldown = 18000, say = "Venting steam!"},
		["Kragmor Magnet Pull"] = {cooldown = 20000, say = "MAGNETS ONLINE!"},
		["Kragmor Overcharge"] = {cooldown = 16000, say = "Polarity reversed!"},
		["Kragmor Gear Beam"] = {cooldown = 10000},
		["Kragmor Scrap Call"] = {cooldown = 20000},
		["Kragmor Armor Plating"] = {cooldown = 1000},
		["Kragmor Meltdown"] = {cooldown = 24000, say = "CORE MELTDOWN!"}
	},
	states = {
		Assembly = {
			transitions = {{to = "Armor Plating", condition = C.hpBelow(78)}},
			tree = rotation({{"Kragmor Scrap Call", 30, C.summonsBelow(2)}, {"Kragmor Steam Vents", 25}, {"Kragmor Overcharge", 30, pair}, {"Kragmor Gear Beam", 35}}, {"Kragmor Piston Slam", "Kragmor Gear Beam"})
		},
		["Armor Plating"] = shieldState("Kragmor Armor Plating", "Overclock", "Plating breached!", 45000,
			rotation({{"Kragmor Piston Slam", 55}, {"Kragmor Gear Beam", 35}}, {"Kragmor Piston Slam"})),
		Overclock = {
			onEnter = enrage("OVERCLOCKING!", 0),
			transitions = {{to = "Magnetize", condition = C.hpBelow(50)}},
			tree = rotation({{"Kragmor Magnet Pull", 30}, {"Kragmor Overcharge", 35, pair}, {"Kragmor Steam Vents", 30}, {"Kragmor Gear Beam", 40}, {"Kragmor Scrap Call", 25, C.summonsBelow(3)}}, {"Kragmor Piston Slam"})
		},
		Magnetize = {
			transitions = {{to = "Meltdown", condition = C.hpBelow(22)}},
			tree = rotation({{"Kragmor Magnet Pull", 40}, {"Kragmor Overcharge", 35, pair}, {"Kragmor Steam Vents", 30}, {"Kragmor Gear Beam", 40}}, {"Kragmor Piston Slam"})
		},
		Meltdown = {
			onEnter = enrage("CRITICAL FAILURE! NO SURVIVORS!", 40, true),
			tree = rotation({{"Kragmor Meltdown", 100}, {"Kragmor Magnet Pull", 45}, {"Kragmor Gear Beam", 45}, {"Kragmor Overcharge", 35, pair}}, {"Kragmor Piston Slam", "Kragmor Steam Vents"})
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "System... offline...", TALKTYPE_MONSTER)
	end
})

-- ===========================================================================================================================
-- Nightmare Weaver Syrelith (Nightmare Horde) - death
-- ===========================================================================================================================
def("Syrelith Nightmare Beam", function(cid, mem)
	return BS.beam(cid, {arms = 2, steps = 10, width = 3, length = 9, interval = 450, delay = 1000, reverse = math.random(2) == 1, combat = COMBAT_DEATHDAMAGE, min = 170, max = 260, effect = CONST_ME_MORTAREA})
end)

def("Syrelith Dread Mark", function(cid, mem)
	return BS.cleanse(cid, {count = mem.rage and 3 or 2, spots = 3, radius = 7, time = 5000, combat = COMBAT_DEATHDAMAGE, min = 280, max = 400, effect = CONST_ME_MORTAREA,
		dot = {combat = COMBAT_DEATHDAMAGE, damage = 35, ticks = 5, interval = 1000, effect = CONST_ME_MORTAREA}})
end)

-- she jumps next to a random player and the area around her explodes right after
def("Syrelith Shadow Step", function(cid, mem)
	local players = MonsterAI.playersAround(cid, 9)
	if(#players == 0) then return false end
	return BS.leap(cid, at(players[math.random(#players)]), {radius = 2, delay = 1400, combat = COMBAT_DEATHDAMAGE, min = 150, max = 230, effect = CONST_ME_MORTAREA,
		after = function(boss)
			BS.later(boss, 200, function()
				BS.nova(boss, {radius = 3, delay = 1200, combat = COMBAT_DEATHDAMAGE, min = 170, max = 260, effect = CONST_ME_MORTAREA})
			end)
		end})
end)

def("Syrelith Terror Tether", function(cid, mem)
	return BS.tether(cid, {pairs = mem.rage and 2 or 1, mode = "apart", distance = 6, time = 5000, combat = COMBAT_DEATHDAMAGE, min = 260, max = 380, effect = CONST_ME_MORTAREA, ani = CONST_ANI_DEATH})
end)

def("Syrelith Dream Eater", function(cid, mem)
	return BS.stack(cid, {count = mem.final and 2 or 1, radius = 3, disc = true, follow = 2600, delay = 1100, total = 1200, maxEach = 520, combat = COMBAT_DEATHDAMAGE, effect = CONST_ME_MORTAREA})
end)

def("Syrelith Nightmare Call", function(cid)
	local ok = BS.summon(cid, {{"Nightstalker", 2}, {"Gargoyle", 2}}, 8, CONST_ANI_DEATH)
	BS.siphon(cid, {ticks = 12, percent = 0.5})
	return ok
end)

def("Syrelith Dreamveil", function(cid)
	BS.shield(cid, {{"Nightmare", 3}, {"Nightstalker", 2}, {"Gargoyle", 1}}, "Sleep... and let them guard your dreams.", CONST_ANI_DEATH)
	BS.siphon(cid, {ticks = 20, percent = 0.4})
	return true
end)

-- long hazard ring (outside) while two players carry a mark and have to find the cleansing squares
def("Syrelith Nightfall", function(cid, mem)
	BS.field(cid, {inner = 5, outer = 9, ticks = 9, interval = 1000, delay = 800, combat = COMBAT_DEATHDAMAGE, min = 100, max = 150, effect = CONST_ME_MORTAREA})
	BS.later(cid, 600, function()
		BS.cleanse(cid, {count = 2, spots = 2, radius = 4, time = 5000, combat = COMBAT_DEATHDAMAGE, min = 320, max = 450, effect = CONST_ME_MORTAREA})
	end)
end)

MonsterAI.register("Nightmare Weaver Syrelith", {
	initialState = "Twilight",
	globalCooldown = 2000,
	spells = {
		["Syrelith Nightmare Beam"] = {cooldown = 10000},
		["Syrelith Dread Mark"] = {cooldown = 15000, say = "I see your fears."},
		["Syrelith Shadow Step"] = {cooldown = 12000, range = 9},
		["Syrelith Terror Tether"] = {cooldown = 16000, say = "Fear keeps you apart!"},
		["Syrelith Dream Eater"] = {cooldown = 17000, say = "Share your dreams!"},
		["Syrelith Nightmare Call"] = {cooldown = 20000},
		["Syrelith Dreamveil"] = {cooldown = 1000},
		["Syrelith Nightfall"] = {cooldown = 26000, say = "NIGHT FALLS!"}
	},
	states = {
		Twilight = {
			transitions = {{to = "Dreamveil", condition = C.hpBelow(78)}},
			tree = rotation({{"Syrelith Nightmare Call", 30, C.summonsBelow(2)}, {"Syrelith Dread Mark", 30}, {"Syrelith Terror Tether", 30, pair}, {"Syrelith Shadow Step", 35}}, {"Syrelith Nightmare Beam", "Syrelith Shadow Step"})
		},
		Dreamveil = shieldState("Syrelith Dreamveil", "Terror", "You woke me!", 45000,
			rotation({{"Syrelith Nightmare Beam", 55}, {"Syrelith Shadow Step", 35}}, {"Syrelith Nightmare Beam"})),
		Terror = {
			onEnter = enrage("DROWN IN YOUR NIGHTMARES!", 0),
			transitions = {{to = "Lucid Dream", condition = C.hpBelow(50)}},
			tree = rotation({{"Syrelith Dream Eater", 35}, {"Syrelith Terror Tether", 35, pair}, {"Syrelith Dread Mark", 35}, {"Syrelith Shadow Step", 40}, {"Syrelith Nightmare Call", 25, C.summonsBelow(3)}}, {"Syrelith Nightmare Beam"})
		},
		["Lucid Dream"] = {
			transitions = {{to = "Nightfall", condition = C.hpBelow(22)}},
			tree = rotation({{"Syrelith Nightfall", 35}, {"Syrelith Dream Eater", 35}, {"Syrelith Terror Tether", 35, pair}, {"Syrelith Dread Mark", 35}, {"Syrelith Shadow Step", 40}}, {"Syrelith Nightmare Beam"})
		},
		Nightfall = {
			onEnter = enrage("THE DREAM NEVER ENDS!", 40, true),
			tree = rotation({{"Syrelith Nightfall", 70}, {"Syrelith Dream Eater", 45}, {"Syrelith Shadow Step", 45}, {"Syrelith Nightmare Beam", 45}}, {"Syrelith Dread Mark", "Syrelith Terror Tether"})
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "Wake... me... not...", TALKTYPE_MONSTER)
	end
})
