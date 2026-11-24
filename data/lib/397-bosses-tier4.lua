-- Bosses of the tier IV invasions (mechanics in data/lib/394-boss-spells.lua, documentation in doc/sistemas/36-bosses.md).
-- Besides everything of tier III they have: debuffs that pile up (stack = ...), puddles that stay (linger = ...), color matching (polarity),
-- bombs with a countdown that heal the boss (bombs), spells that chain two mechanics and an ENRAGE TIMER: after 8 minutes of life
-- the boss goes to the final state for good.
--
--   Wyrmlord Azhrakar     Dragon Siege      Descent ─> Bone Aegis (shield) ─> Dragonfire ─> Undying Wrath ─> Calamity
--   Countess Sanguessa    Blood Moon        Court ─> Veil of Blood (shield) ─> Blood Moon ─> Eclipse ─> Bloodbath
--   Warlord Zhardakkan    Draken Legion     Onslaught ─> Drakeguard (shield) ─> Drakefire ─> Frenzy ─> Last Dragon
--   Matriarch Ignaria     Asura Onslaught   Dawn ─> Pyre Barrier (shield) ─> Noon ─> Dusk ─> Dawnbreak
--   Forgelord Vexmar      Plague Legion     Forging ─> Bile Armor (shield) ─> Contagion ─> Epidemic ─> Pandemic

local BS, T, ready = BossSpell, DecisionTree, Cond.ready
local C = Cond

local ENRAGE_MS = 8 * 60 * 1000

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

-- every state (except the final one) also goes to the final state when the boss is older than `ms`
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

-- ===========================================================================================================================
-- Wyrmlord Azhrakar (Dragon Siege) - fire / death
-- ===========================================================================================================================
def("Azhrakar Doom Breath", function(cid, mem, target)
	if(not target) then return false end
	local options = {length = 10, turns = mem.rage and {0, 2} or {0}, delay = 1500, combat = COMBAT_FIREDAMAGE, min = 280, max = 420, effect = CONST_ME_FIREAREA, ani = CONST_ANI_FIRE,
		stack = {extra = 70, max = 5, ms = 20000, name = "Scorched"}}
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

def("Azhrakar Wing Gale", function(cid, mem)
	return BS.waves(cid, {bands = {{0, 2}, {2, 4}, {4, 6}, {6, 8}, {8, 10}}, interval = 550, delay = 1200, reverse = mem.final, combat = COMBAT_DEATHDAMAGE, min = 230, max = 350, effect = CONST_ME_MORTAREA})
end)

def("Azhrakar Ember Rain", function(cid, mem)
	return BS.rain(cid, {count = mem.rage and 9 or 7, radius = 1, spread = 2, delay = 1700, interval = 300, combat = COMBAT_FIREDAMAGE, min = 200, max = 300, effect = CONST_ME_FIREAREA, ani = CONST_ANI_FIRE,
		linger = {ticks = 6, interval = 1000, min = 70, max = 110, effect = CONST_ME_FIREAREA}})
end)

def("Azhrakar Soul Rend", function(cid, mem)
	return BS.polarity(cid, {time = 6000, radius = 7, zone = 2, combat = COMBAT_DEATHDAMAGE, min = 420, max = 560, effect = CONST_ME_MORTAREA,
		dot = {combat = COMBAT_DEATHDAMAGE, damage = 50, ticks = 5, interval = 1000, effect = CONST_ME_MORTAREA}})
end)

def("Azhrakar Doom Orbs", function(cid, mem)
	return BS.bombs(cid, {monster = "Doomfire Orb", count = mem.rage and 3 or 2, time = 9000, radius = 4, combat = COMBAT_FIREDAMAGE, min = 450, max = 600, effect = CONST_ME_FIREAREA, heal = 4})
end)

def("Azhrakar Tail Lash", function(cid)
	return BS.nova(cid, {radius = 3, delay = 1100, combat = COMBAT_PHYSICALDAMAGE, min = 260, max = 380, effect = CONST_ME_GROUNDSHAKER})
end)

def("Azhrakar Dread Brood", function(cid)
	local ok = BS.summon(cid, {{"Dragon Hatchling", 4}, {"Dragon Lord", 1}}, 8, CONST_ANI_FIRE)
	BS.siphon(cid, {ticks = 14, percent = 0.5})
	return ok
end)

def("Azhrakar Bone Aegis", function(cid)
	BS.shield(cid, {{"Dragon Lord", 2}, {"Dragon", 3}, {"Hydra", 1}}, "My bones will not break!", CONST_ANI_FIRE)
	BS.siphon(cid, {ticks = 24, percent = 0.4})
	return true
end)

-- safe squares, then a breath at the target and, with luck, a second pass of puddles
def("Azhrakar Calamity", function(cid)
	BS.safeSpots(cid, {radius = 10, spots = 3, delay = 2800, combat = COMBAT_DEATHDAMAGE, min = 480, max = 680, effect = CONST_ME_MORTAREA})
	BS.later(cid, 3100, function()
		local target = getCreatureTarget(cid)
		if(target and target ~= 0 and isCreature(target)) then
			BS.cone(cid, at(target), {length = 10, delay = 1500, combat = COMBAT_FIREDAMAGE, min = 320, max = 460, effect = CONST_ME_FIREAREA, ani = CONST_ANI_FIRE,
				stack = {extra = 70, max = 5, ms = 20000, name = "Scorched"}})
		end
	end)
end)

MonsterAI.register("Wyrmlord Azhrakar", withEnrageTimer({
	initialState = "Descent",
	globalCooldown = 2000,
	spells = {
		["Azhrakar Doom Breath"] = {cooldown = 7000, range = 10},
		["Azhrakar Wing Gale"] = {cooldown = 12000},
		["Azhrakar Ember Rain"] = {cooldown = 10000},
		["Azhrakar Soul Rend"] = {cooldown = 20000, say = "Your souls, split in two!"},
		["Azhrakar Doom Orbs"] = {cooldown = 24000, say = "Feed the flames!"},
		["Azhrakar Tail Lash"] = {cooldown = 8000, range = 3},
		["Azhrakar Dread Brood"] = {cooldown = 22000},
		["Azhrakar Bone Aegis"] = {cooldown = 1000},
		["Azhrakar Calamity"] = {cooldown = 26000, say = "CALAMITY!"}
	},
	states = {
		Descent = {
			transitions = {{to = "Bone Aegis", condition = C.hpBelow(80)}},
			tree = rotation({{"Azhrakar Tail Lash", 60, C.playersAround(1, 3)}, {"Azhrakar Dread Brood", 30, C.summonsBelow(2)}, {"Azhrakar Soul Rend", 25, pair}, {"Azhrakar Ember Rain", 35}, {"Azhrakar Wing Gale", 30}}, {"Azhrakar Doom Breath", "Azhrakar Ember Rain"})
		},
		["Bone Aegis"] = shieldState("Azhrakar Bone Aegis", "Dragonfire", "My aegis is broken!", 45000,
			rotation({{"Azhrakar Ember Rain", 50}, {"Azhrakar Wing Gale", 35}}, {"Azhrakar Doom Breath"})),
		Dragonfire = {
			onEnter = enrage("THE SKY BURNS!", 0),
			transitions = {{to = "Undying Wrath", condition = C.hpBelow(50)}},
			tree = rotation({{"Azhrakar Doom Orbs", 35}, {"Azhrakar Soul Rend", 35, pair}, {"Azhrakar Tail Lash", 60, C.playersAround(1, 3)}, {"Azhrakar Ember Rain", 40}, {"Azhrakar Wing Gale", 35}, {"Azhrakar Dread Brood", 25, C.summonsBelow(3)}}, {"Azhrakar Doom Breath"})
		},
		["Undying Wrath"] = {
			transitions = {{to = "Calamity", condition = C.hpBelow(22)}},
			tree = rotation({{"Azhrakar Doom Orbs", 40}, {"Azhrakar Soul Rend", 40, pair}, {"Azhrakar Ember Rain", 45}, {"Azhrakar Wing Gale", 40}, {"Azhrakar Tail Lash", 60, C.playersAround(1, 3)}}, {"Azhrakar Doom Breath"})
		},
		Calamity = {
			onEnter = enrage("DEATH CANNOT HOLD ME!", 40, true),
			tree = rotation({{"Azhrakar Calamity", 100}, {"Azhrakar Doom Orbs", 45}, {"Azhrakar Soul Rend", 40, pair}, {"Azhrakar Ember Rain", 45}, {"Azhrakar Wing Gale", 40}}, {"Azhrakar Doom Breath", "Azhrakar Tail Lash"})
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "Finally... rest...", TALKTYPE_MONSTER)
	end
}, "Calamity", ENRAGE_MS))

-- ===========================================================================================================================
-- Countess Sanguessa (Blood Moon) - death / blood
-- ===========================================================================================================================
def("Sanguessa Crimson Bats", function(cid, mem)
	return BS.rain(cid, {count = mem.rage and 10 or 8, radius = 1, spread = 2, delay = 1600, interval = 300, combat = COMBAT_DEATHDAMAGE, min = 180, max = 280, effect = CONST_ME_MORTAREA, ani = CONST_ANI_DEATH,
		stack = {extra = 50, max = 5, ms = 20000, name = "Bleeding"}})
end)

def("Sanguessa Blood Link", function(cid, mem)
	return BS.tether(cid, {pairs = mem.rage and 2 or 1, mode = "together", distance = 3, time = 5500, combat = COMBAT_DEATHDAMAGE, min = 380, max = 520, effect = CONST_ME_MORTAREA, ani = CONST_ANI_DEATH})
end)

def("Sanguessa Hemorrhage", function(cid, mem)
	return BS.cleanse(cid, {count = mem.rage and 3 or 2, spots = 3, radius = 7, time = 5500, combat = COMBAT_DEATHDAMAGE, min = 400, max = 550, effect = CONST_ME_MORTAREA,
		dot = {combat = COMBAT_DEATHDAMAGE, damage = 60, ticks = 6, interval = 1000, effect = CONST_ME_MORTAREA}})
end)

def("Sanguessa Blood Pool", function(cid, mem)
	return BS.nova(cid, {radius = 5, safe = 1, delay = 1800, combat = COMBAT_DEATHDAMAGE, min = 250, max = 380, effect = CONST_ME_MORTAREA,
		linger = {ticks = 8, interval = 1000, min = 60, max = 100, effect = CONST_ME_MORTAREA}})
end)

def("Sanguessa Moonlit Sweep", function(cid, mem)
	return BS.beam(cid, {arms = 4, steps = mem.rage and 10 or 8, width = 3, length = 10, interval = 450, delay = 1000, reverse = math.random(2) == 1, combat = COMBAT_DEATHDAMAGE, min = 220, max = 320, effect = CONST_ME_MORTAREA})
end)

def("Sanguessa Crimson Pact", function(cid)
	return BS.polarity(cid, {time = 6000, radius = 7, zone = 2, combat = COMBAT_DEATHDAMAGE, min = 420, max = 560, effect = CONST_ME_MORTAREA,
		dot = {combat = COMBAT_DEATHDAMAGE, damage = 50, ticks = 5, interval = 1000, effect = CONST_ME_MORTAREA}})
end)

def("Sanguessa Blood Orbs", function(cid, mem)
	return BS.bombs(cid, {monster = "Bloodmoon Orb", count = mem.rage and 3 or 2, time = 9000, radius = 4, combat = COMBAT_DEATHDAMAGE, min = 450, max = 600, effect = CONST_ME_MORTAREA, heal = 4})
end)

def("Sanguessa Vampire Brood", function(cid)
	local ok = BS.summon(cid, {{"Vampire", 3}, {"Vampire Bride", 2}}, 8, CONST_ANI_DEATH)
	BS.siphon(cid, {ticks = 14, percent = 0.5})
	return ok
end)

def("Sanguessa Veil of Blood", function(cid)
	BS.shield(cid, {{"Vampire Bride", 3}, {"Vampire", 3}, {"Banshee", 1}}, "My courtiers, drink for me!", CONST_ANI_DEATH)
	BS.siphon(cid, {ticks = 24, percent = 0.4})
	return true
end)

-- safe squares and, right after, a stack that the survivors have to share
def("Sanguessa Eclipse", function(cid)
	BS.safeSpots(cid, {radius = 9, spots = 2, delay = 2600, combat = COMBAT_DEATHDAMAGE, min = 480, max = 680, effect = CONST_ME_MORTAREA})
	BS.later(cid, 3000, function()
		BS.stack(cid, {count = 2, radius = 2, follow = 1500, delay = 1000, total = 1500, maxEach = 600, combat = COMBAT_DEATHDAMAGE, effect = CONST_ME_MORTAREA})
	end)
end)

MonsterAI.register("Countess Sanguessa", withEnrageTimer({
	initialState = "Court",
	globalCooldown = 2000,
	spells = {
		["Sanguessa Crimson Bats"] = {cooldown = 9000},
		["Sanguessa Blood Link"] = {cooldown = 18000, say = "Bound by blood!"},
		["Sanguessa Hemorrhage"] = {cooldown = 17000, say = "Bleed for me."},
		["Sanguessa Blood Pool"] = {cooldown = 12000},
		["Sanguessa Moonlit Sweep"] = {cooldown = 11000},
		["Sanguessa Crimson Pact"] = {cooldown = 22000, say = "Choose your side!"},
		["Sanguessa Blood Orbs"] = {cooldown = 24000},
		["Sanguessa Vampire Brood"] = {cooldown = 22000},
		["Sanguessa Veil of Blood"] = {cooldown = 1000},
		["Sanguessa Eclipse"] = {cooldown = 26000, say = "THE MOON GOES DARK!"}
	},
	states = {
		Court = {
			transitions = {{to = "Veil of Blood", condition = C.hpBelow(80)}},
			tree = rotation({{"Sanguessa Vampire Brood", 30, C.summonsBelow(2)}, {"Sanguessa Blood Link", 25, pair}, {"Sanguessa Hemorrhage", 30}, {"Sanguessa Blood Pool", 35}, {"Sanguessa Moonlit Sweep", 30}}, {"Sanguessa Crimson Bats", "Sanguessa Blood Pool"})
		},
		["Veil of Blood"] = shieldState("Sanguessa Veil of Blood", "Blood Moon", "The veil is torn!", 45000,
			rotation({{"Sanguessa Crimson Bats", 50}, {"Sanguessa Moonlit Sweep", 35}}, {"Sanguessa Crimson Bats"})),
		["Blood Moon"] = {
			onEnter = enrage("THE MOON IS RED TONIGHT!", 0),
			transitions = {{to = "Eclipse", condition = C.hpBelow(50)}},
			tree = rotation({{"Sanguessa Blood Orbs", 35}, {"Sanguessa Crimson Pact", 35}, {"Sanguessa Blood Link", 35, pair}, {"Sanguessa Hemorrhage", 35}, {"Sanguessa Moonlit Sweep", 35}, {"Sanguessa Blood Pool", 35}, {"Sanguessa Vampire Brood", 25, C.summonsBelow(3)}}, {"Sanguessa Crimson Bats"})
		},
		Eclipse = {
			transitions = {{to = "Bloodbath", condition = C.hpBelow(22)}},
			tree = rotation({{"Sanguessa Blood Orbs", 40}, {"Sanguessa Crimson Pact", 40}, {"Sanguessa Hemorrhage", 40}, {"Sanguessa Blood Link", 35, pair}, {"Sanguessa Moonlit Sweep", 40}, {"Sanguessa Blood Pool", 35}}, {"Sanguessa Crimson Bats"})
		},
		Bloodbath = {
			onEnter = enrage("DROWN IN CRIMSON!", 40, true),
			tree = rotation({{"Sanguessa Eclipse", 100}, {"Sanguessa Blood Orbs", 45}, {"Sanguessa Crimson Pact", 40}, {"Sanguessa Hemorrhage", 40}, {"Sanguessa Moonlit Sweep", 45}}, {"Sanguessa Crimson Bats", "Sanguessa Blood Pool"})
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "Dawn... comes...", TALKTYPE_MONSTER)
	end
}, "Bloodbath", ENRAGE_MS))

-- ===========================================================================================================================
-- Warlord Zhardakkan (Draken Legion) - fire / physical
-- ===========================================================================================================================
-- two grids of fire: the second one covers the gaps of the first (and the burning stacks)
def("Zhardak Fire Volley", function(cid, mem, target)
	if(not target) then return false end
	local to = at(target)
	local options = {offsets = {-4, -2, 0, 2, 4}, length = 11, delay = 1500, combat = COMBAT_FIREDAMAGE, min = 260, max = 380, effect = CONST_ME_FIREAREA, ani = CONST_ANI_FIRE,
		stack = {extra = 60, max = 5, ms = 20000, name = "Burning"}}
	if(not BS.lanes(cid, to, options)) then return false end
	BS.later(cid, 1700, function()
		options.offsets = {-5, -3, -1, 1, 3, 5}
		options.delay = 1400
		BS.lanes(cid, to, options)
	end)
end)

def("Zhardak Leaping Slam", function(cid, mem, target)
	if(not target) then return false end
	return BS.leap(cid, at(target), {radius = 2, delay = 1500, combat = COMBAT_PHYSICALDAMAGE, min = 280, max = 400, effect = CONST_ME_GROUNDSHAKER,
		after = function(boss)
			BS.later(boss, 200, function()
				BS.nova(boss, {radius = 4, delay = 1200, combat = COMBAT_FIREDAMAGE, min = 260, max = 380, effect = CONST_ME_FIREAREA})
			end)
		end})
end)

def("Zhardak War Drums", function(cid, mem)
	return BS.field(cid, {inner = 6, outer = 10, ticks = mem.rage and 10 or 8, interval = 1000, delay = 800, combat = COMBAT_PHYSICALDAMAGE, min = 110, max = 170, effect = CONST_ME_HITAREA})
end)

def("Zhardak Dragonfire Rain", function(cid, mem)
	return BS.rain(cid, {count = mem.rage and 9 or 7, radius = 2, disc = true, spread = 2, delay = 1800, interval = 350, combat = COMBAT_FIREDAMAGE, min = 200, max = 300, effect = CONST_ME_FIREAREA, ani = CONST_ANI_FIRE,
		linger = {ticks = 6, interval = 1000, min = 70, max = 110, effect = CONST_ME_FIREAREA}})
end)

def("Zhardak Banner Bearers", function(cid, mem)
	return BS.bombs(cid, {monster = "Drakenfire Totem", count = mem.rage and 3 or 2, time = 9000, radius = 5, combat = COMBAT_FIREDAMAGE, min = 450, max = 600, effect = CONST_ME_FIREAREA, heal = 4})
end)

def("Zhardak Blood Oath", function(cid, mem)
	return BS.tether(cid, {pairs = mem.rage and 2 or 1, mode = "apart", distance = 6, time = 5500, combat = COMBAT_FIREDAMAGE, min = 380, max = 520, effect = CONST_ME_FIREAREA, ani = CONST_ANI_FIRE})
end)

def("Zhardak Frenzy Chain", function(cid, mem)
	return BS.chain(cid, {hops = mem.rage and 8 or 6, radius = 1, delay = 650, hop = 5, combat = COMBAT_FIREDAMAGE, min = 250, max = 350, effect = CONST_ME_FIREAREA, ani = CONST_ANI_FIRE})
end)

def("Zhardak Legion Call", function(cid)
	local ok = BS.summon(cid, {{"Draken Warmaster", 2}, {"Draken Spellweaver", 2}}, 8, CONST_ANI_FIRE)
	BS.siphon(cid, {ticks = 14, percent = 0.5})
	return ok
end)

def("Zhardak Drakeguard", function(cid)
	BS.shield(cid, {{"Draken Elite", 3}, {"Draken Spellweaver", 2}, {"Draken Warmaster", 1}}, "Drakeguard, form up!", CONST_ANI_FIRE)
	BS.siphon(cid, {ticks = 24, percent = 0.4})
	return true
end)

-- safe squares, then everybody is pulled in and the area explodes
def("Zhardak Dragonfall", function(cid)
	BS.safeSpots(cid, {radius = 10, spots = 3, delay = 2800, combat = COMBAT_FIREDAMAGE, min = 500, max = 700, effect = CONST_ME_FIREAREA})
	BS.later(cid, 3200, function()
		if(BS.pull(cid, {to = 2, ani = CONST_ANI_FIRE})) then
			BS.later(cid, 400, function()
				BS.nova(cid, {radius = 5, delay = 2000, combat = COMBAT_FIREDAMAGE, min = 380, max = 540, effect = CONST_ME_FIREAREA})
			end)
		end
	end)
end)

MonsterAI.register("Warlord Zhardakkan", withEnrageTimer({
	initialState = "Onslaught",
	globalCooldown = 2000,
	spells = {
		["Zhardak Fire Volley"] = {cooldown = 9000, range = 11},
		["Zhardak Leaping Slam"] = {cooldown = 12000, range = 9, say = "CRUSH THEM!"},
		["Zhardak War Drums"] = {cooldown = 20000, say = "Beat the drums!"},
		["Zhardak Dragonfire Rain"] = {cooldown = 10000},
		["Zhardak Banner Bearers"] = {cooldown = 24000},
		["Zhardak Blood Oath"] = {cooldown = 18000, say = "Swear it in blood!"},
		["Zhardak Frenzy Chain"] = {cooldown = 12000},
		["Zhardak Legion Call"] = {cooldown = 22000},
		["Zhardak Drakeguard"] = {cooldown = 1000},
		["Zhardak Dragonfall"] = {cooldown = 28000, say = "THE LEGION FALLS ON YOU!"}
	},
	states = {
		Onslaught = {
			transitions = {{to = "Drakeguard", condition = C.hpBelow(80)}},
			tree = rotation({{"Zhardak Legion Call", 30, C.summonsBelow(2)}, {"Zhardak Blood Oath", 25, pair}, {"Zhardak War Drums", 25}, {"Zhardak Leaping Slam", 35}, {"Zhardak Dragonfire Rain", 35}}, {"Zhardak Fire Volley", "Zhardak Dragonfire Rain"})
		},
		Drakeguard = shieldState("Zhardak Drakeguard", "Drakefire", "The guard has fallen!", 45000,
			rotation({{"Zhardak Dragonfire Rain", 50}, {"Zhardak Fire Volley", 35}}, {"Zhardak Dragonfire Rain"})),
		Drakefire = {
			onEnter = enrage("BURN EVERYTHING!", 0),
			transitions = {{to = "Frenzy", condition = C.hpBelow(50)}},
			tree = rotation({{"Zhardak Banner Bearers", 35}, {"Zhardak Blood Oath", 35, pair}, {"Zhardak Frenzy Chain", 35}, {"Zhardak War Drums", 30}, {"Zhardak Leaping Slam", 35}, {"Zhardak Fire Volley", 35}, {"Zhardak Legion Call", 25, C.summonsBelow(3)}}, {"Zhardak Dragonfire Rain"})
		},
		Frenzy = {
			transitions = {{to = "Last Dragon", condition = C.hpBelow(22)}},
			tree = rotation({{"Zhardak Banner Bearers", 40}, {"Zhardak Frenzy Chain", 40}, {"Zhardak Blood Oath", 35, pair}, {"Zhardak War Drums", 30}, {"Zhardak Leaping Slam", 35}, {"Zhardak Fire Volley", 40}}, {"Zhardak Dragonfire Rain"})
		},
		["Last Dragon"] = {
			onEnter = enrage("I AM THE LAST DRAGON!", 40, true),
			tree = rotation({{"Zhardak Dragonfall", 100}, {"Zhardak Banner Bearers", 45}, {"Zhardak Frenzy Chain", 45}, {"Zhardak Fire Volley", 45}, {"Zhardak Leaping Slam", 40}}, {"Zhardak Dragonfire Rain", "Zhardak Blood Oath"})
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "The legion... endures...", TALKTYPE_MONSTER)
	end
}, "Last Dragon", ENRAGE_MS))

-- ===========================================================================================================================
-- Matriarch Ignaria (Asura Onslaught) - fire
-- ===========================================================================================================================
def("Ignaria Dawn Beam", function(cid, mem)
	return BS.beam(cid, {arms = 2, steps = 10, width = 3, length = 10, interval = 450, delay = 1000, reverse = math.random(2) == 1, combat = COMBAT_FIREDAMAGE, min = 230, max = 340, effect = CONST_ME_FIREAREA,
		stack = {extra = 55, max = 5, ms = 20000, name = "Dawnfire"}})
end)

def("Ignaria Flame Shackles", function(cid, mem)
	return BS.tether(cid, {pairs = mem.rage and 2 or 1, mode = "apart", distance = 6, time = 5500, combat = COMBAT_FIREDAMAGE, min = 380, max = 520, effect = CONST_ME_FIREAREA, ani = CONST_ANI_FIRE})
end)

def("Ignaria Ember Mark", function(cid, mem)
	return BS.cleanse(cid, {count = mem.rage and 3 or 2, spots = 3, radius = 7, time = 5500, combat = COMBAT_FIREDAMAGE, min = 400, max = 550, effect = CONST_ME_FIREAREA,
		dot = {combat = COMBAT_FIREDAMAGE, damage = 60, ticks = 6, interval = 1000, effect = CONST_ME_FIREAREA}})
end)

def("Ignaria Sunburst", function(cid, mem)
	return BS.nova(cid, {radius = 6, safe = 2, delay = 1900, combat = COMBAT_FIREDAMAGE, min = 300, max = 440, effect = CONST_ME_FIREAREA,
		linger = {ticks = 6, interval = 1000, min = 70, max = 110, effect = CONST_ME_FIREAREA}})
end)

def("Ignaria Rite of Dawn", function(cid)
	return BS.polarity(cid, {time = 6000, radius = 7, zone = 2, combat = COMBAT_FIREDAMAGE, min = 420, max = 560, effect = CONST_ME_FIREAREA,
		dot = {combat = COMBAT_FIREDAMAGE, damage = 50, ticks = 5, interval = 1000, effect = CONST_ME_FIREAREA}})
end)

def("Ignaria Phoenix Pyre", function(cid, mem)
	return BS.bombs(cid, {monster = "Dawnfire Ember", count = mem.rage and 3 or 2, time = 9000, radius = 4, combat = COMBAT_FIREDAMAGE, min = 450, max = 600, effect = CONST_ME_FIREAREA, heal = 4})
end)

def("Ignaria Asura Call", function(cid)
	local ok = BS.summon(cid, {{"Midnight Asura", 2}, {"Dawnfire Asura", 2}}, 8, CONST_ANI_FIRE)
	BS.siphon(cid, {ticks = 14, percent = 0.5})
	return ok
end)

def("Ignaria Pyre Barrier", function(cid)
	BS.shield(cid, {{"Hellfire Fighter", 2}, {"Midnight Asura", 2}, {"Dawnfire Asura", 2}}, "The pyre protects its matriarch!", CONST_ANI_FIRE)
	BS.siphon(cid, {ticks = 24, percent = 0.4})
	return true
end)

def("Ignaria Burning Pact", function(cid, mem)
	return BS.stack(cid, {count = mem.final and 3 or 2, radius = 2, follow = 2600, delay = 1000, total = 1500, maxEach = 600, combat = COMBAT_FIREDAMAGE, effect = CONST_ME_FIREAREA})
end)

-- safe squares, then waves from the outside in, and a stack for whoever survives
def("Ignaria Dawnbreak", function(cid)
	BS.safeSpots(cid, {radius = 10, spots = 3, delay = 2800, combat = COMBAT_FIREDAMAGE, min = 500, max = 700, effect = CONST_ME_FIREAREA})
	BS.later(cid, 3100, function()
		BS.waves(cid, {bands = {{0, 2}, {2, 4}, {4, 6}, {6, 8}, {8, 10}}, interval = 500, delay = 1100, reverse = true, combat = COMBAT_FIREDAMAGE, min = 300, max = 440, effect = CONST_ME_FIREAREA})
	end)
	BS.later(cid, 6400, function()
		BS.stack(cid, {count = 2, radius = 2, follow = 1500, delay = 1000, total = 1500, maxEach = 600, combat = COMBAT_FIREDAMAGE, effect = CONST_ME_FIREAREA})
	end)
end)

MonsterAI.register("Matriarch Ignaria", withEnrageTimer({
	initialState = "Dawn",
	globalCooldown = 2000,
	spells = {
		["Ignaria Dawn Beam"] = {cooldown = 10000},
		["Ignaria Flame Shackles"] = {cooldown = 18000, say = "Chained by fire!"},
		["Ignaria Ember Mark"] = {cooldown = 17000, say = "Burn, little ember."},
		["Ignaria Sunburst"] = {cooldown = 12000},
		["Ignaria Rite of Dawn"] = {cooldown = 22000, say = "Dawn or dusk, choose!"},
		["Ignaria Phoenix Pyre"] = {cooldown = 24000},
		["Ignaria Asura Call"] = {cooldown = 22000},
		["Ignaria Pyre Barrier"] = {cooldown = 1000},
		["Ignaria Burning Pact"] = {cooldown = 18000, say = "Share the fire!"},
		["Ignaria Dawnbreak"] = {cooldown = 28000, say = "DAWNBREAK!"}
	},
	states = {
		Dawn = {
			transitions = {{to = "Pyre Barrier", condition = C.hpBelow(80)}},
			tree = rotation({{"Ignaria Asura Call", 30, C.summonsBelow(2)}, {"Ignaria Flame Shackles", 25, pair}, {"Ignaria Ember Mark", 30}, {"Ignaria Sunburst", 35}}, {"Ignaria Dawn Beam", "Ignaria Sunburst"})
		},
		["Pyre Barrier"] = shieldState("Ignaria Pyre Barrier", "Noon", "The pyre is out!", 45000,
			rotation({{"Ignaria Dawn Beam", 50}, {"Ignaria Sunburst", 35}}, {"Ignaria Dawn Beam"})),
		Noon = {
			onEnter = enrage("THE SUN IS HIGH!", 0),
			transitions = {{to = "Dusk", condition = C.hpBelow(50)}},
			tree = rotation({{"Ignaria Phoenix Pyre", 35}, {"Ignaria Rite of Dawn", 35}, {"Ignaria Burning Pact", 35}, {"Ignaria Flame Shackles", 35, pair}, {"Ignaria Ember Mark", 35}, {"Ignaria Sunburst", 35}, {"Ignaria Asura Call", 25, C.summonsBelow(3)}}, {"Ignaria Dawn Beam"})
		},
		Dusk = {
			transitions = {{to = "Dawnbreak", condition = C.hpBelow(22)}},
			tree = rotation({{"Ignaria Phoenix Pyre", 40}, {"Ignaria Rite of Dawn", 40}, {"Ignaria Burning Pact", 40}, {"Ignaria Ember Mark", 40}, {"Ignaria Flame Shackles", 35, pair}, {"Ignaria Sunburst", 40}}, {"Ignaria Dawn Beam"})
		},
		Dawnbreak = {
			onEnter = enrage("THE SUN NEVER SETS!", 40, true),
			tree = rotation({{"Ignaria Dawnbreak", 100}, {"Ignaria Phoenix Pyre", 45}, {"Ignaria Rite of Dawn", 40}, {"Ignaria Ember Mark", 40}, {"Ignaria Burning Pact", 40}}, {"Ignaria Dawn Beam", "Ignaria Sunburst"})
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "The sun... sets...", TALKTYPE_MONSTER)
	end
}, "Dawnbreak", ENRAGE_MS))

-- ===========================================================================================================================
-- Forgelord Vexmar (Plague Legion) - earth / poison
-- ===========================================================================================================================
def("Vexmar Toxic Hammer", function(cid, mem, target)
	if(not target) then return false end
	return BS.cone(cid, at(target), {length = 6, turns = {0, 2}, delay = 1400, combat = COMBAT_EARTHDAMAGE, min = 280, max = 400, effect = CONST_ME_POISONAREA, ani = CONST_ANI_POISON,
		stack = {extra = 80, max = 5, ms = 20000, name = "Plague"}})
end)

def("Vexmar Spore Burst", function(cid, mem)
	return BS.rain(cid, {count = mem.rage and 9 or 7, radius = 2, disc = true, spread = 2, delay = 1800, interval = 350, combat = COMBAT_EARTHDAMAGE, min = 190, max = 290, effect = CONST_ME_POISONAREA, ani = CONST_ANI_POISON,
		linger = {ticks = 7, interval = 1000, min = 60, max = 100, effect = CONST_ME_POISONAREA}, stack = {extra = 80, max = 5, ms = 20000, name = "Plague"}})
end)

def("Vexmar Plague Pods", function(cid, mem)
	return BS.bombs(cid, {monster = "Plague Pod", count = mem.rage and 3 or 2, time = 9000, radius = 4, combat = COMBAT_EARTHDAMAGE, min = 450, max = 600, effect = CONST_ME_POISONAREA, heal = 5})
end)

def("Vexmar Rot Link", function(cid, mem)
	return BS.tether(cid, {pairs = mem.rage and 2 or 1, mode = "together", distance = 3, time = 5500, combat = COMBAT_EARTHDAMAGE, min = 380, max = 520, effect = CONST_ME_POISONAREA, ani = CONST_ANI_POISON})
end)

def("Vexmar Purge", function(cid, mem)
	return BS.cleanse(cid, {count = mem.rage and 3 or 2, spots = 3, radius = 7, time = 5500, combat = COMBAT_EARTHDAMAGE, min = 400, max = 550, effect = CONST_ME_POISONAREA,
		dot = {combat = COMBAT_EARTHDAMAGE, damage = 60, ticks = 6, interval = 1000, effect = CONST_ME_POISONAREA}})
end)

def("Vexmar Corrosion Waves", function(cid, mem)
	return BS.waves(cid, {bands = {{0, 2}, {2, 4}, {4, 6}, {6, 8}, {8, 10}}, interval = 550, delay = 1200, reverse = mem.final, combat = COMBAT_EARTHDAMAGE, min = 230, max = 350, effect = CONST_ME_POISONAREA,
		stack = {extra = 80, max = 5, ms = 20000, name = "Plague"}})
end)

def("Vexmar Blight Beam", function(cid, mem)
	return BS.beam(cid, {arms = 4, steps = mem.rage and 10 or 8, width = 1, length = 10, interval = 450, delay = 1000, reverse = math.random(2) == 1, combat = COMBAT_EARTHDAMAGE, min = 220, max = 320, effect = CONST_ME_POISONAREA})
end)

def("Vexmar Antidote", function(cid)
	return BS.polarity(cid, {time = 6000, radius = 7, zone = 2, combat = COMBAT_EARTHDAMAGE, min = 420, max = 560, effect = CONST_ME_POISONAREA,
		dot = {combat = COMBAT_EARTHDAMAGE, damage = 50, ticks = 5, interval = 1000, effect = CONST_ME_POISONAREA}})
end)

def("Vexmar Plague Call", function(cid)
	local ok = BS.summon(cid, {{"Defiler", 1}, {"Demon Skeleton", 3}}, 8, CONST_ANI_POISON)
	BS.siphon(cid, {ticks = 14, percent = 0.5})
	return ok
end)

def("Vexmar Bile Armor", function(cid)
	BS.shield(cid, {{"Demon Skeleton", 3}, {"Defiler", 2}, {"Blightwalker", 1}}, "My armor is forged from your bones!", CONST_ANI_POISON)
	BS.siphon(cid, {ticks = 24, percent = 0.4})
	return true
end)

-- safe squares and, right after, a second round with other squares and a pull + nova: the plague spreads
def("Vexmar Pandemic", function(cid)
	BS.safeSpots(cid, {radius = 10, spots = 3, delay = 2800, combat = COMBAT_EARTHDAMAGE, min = 480, max = 680, effect = CONST_ME_POISONAREA})
	BS.later(cid, 3100, function()
		BS.safeSpots(cid, {radius = 10, spots = 3, delay = 2200, combat = COMBAT_EARTHDAMAGE, min = 350, max = 500, effect = CONST_ME_POISONAREA})
	end)
	BS.later(cid, 5600, function()
		if(BS.pull(cid, {to = 2, ani = CONST_ANI_POISON})) then
			BS.later(cid, 400, function()
				BS.nova(cid, {radius = 5, delay = 2000, combat = COMBAT_EARTHDAMAGE, min = 380, max = 540, effect = CONST_ME_POISONAREA})
			end)
		end
	end)
end)

MonsterAI.register("Forgelord Vexmar", withEnrageTimer({
	initialState = "Forging",
	globalCooldown = 2000,
	spells = {
		["Vexmar Toxic Hammer"] = {cooldown = 7000, range = 6},
		["Vexmar Spore Burst"] = {cooldown = 10000},
		["Vexmar Plague Pods"] = {cooldown = 24000, say = "Grow, my pods!"},
		["Vexmar Rot Link"] = {cooldown = 18000, say = "Rot together!"},
		["Vexmar Purge"] = {cooldown = 17000, say = "Be purged."},
		["Vexmar Corrosion Waves"] = {cooldown = 12000},
		["Vexmar Blight Beam"] = {cooldown = 11000},
		["Vexmar Antidote"] = {cooldown = 22000, say = "Only one cure for each of you!"},
		["Vexmar Plague Call"] = {cooldown = 22000},
		["Vexmar Bile Armor"] = {cooldown = 1000},
		["Vexmar Pandemic"] = {cooldown = 30000, say = "PANDEMIC!"}
	},
	states = {
		Forging = {
			transitions = {{to = "Bile Armor", condition = C.hpBelow(80)}},
			tree = rotation({{"Vexmar Toxic Hammer", 60, C.playersAround(1, 4)}, {"Vexmar Plague Call", 30, C.summonsBelow(2)}, {"Vexmar Rot Link", 25, pair}, {"Vexmar Purge", 30}, {"Vexmar Corrosion Waves", 30}}, {"Vexmar Spore Burst", "Vexmar Blight Beam"})
		},
		["Bile Armor"] = shieldState("Vexmar Bile Armor", "Contagion", "My armor is cracked!", 45000,
			rotation({{"Vexmar Spore Burst", 50}, {"Vexmar Blight Beam", 35}}, {"Vexmar Spore Burst"})),
		Contagion = {
			onEnter = enrage("THE PLAGUE SPREADS!", 0),
			transitions = {{to = "Epidemic", condition = C.hpBelow(50)}},
			tree = rotation({{"Vexmar Plague Pods", 35}, {"Vexmar Antidote", 35}, {"Vexmar Rot Link", 35, pair}, {"Vexmar Purge", 35}, {"Vexmar Blight Beam", 35}, {"Vexmar Corrosion Waves", 35}, {"Vexmar Plague Call", 25, C.summonsBelow(3)}}, {"Vexmar Spore Burst"})
		},
		Epidemic = {
			transitions = {{to = "Pandemic", condition = C.hpBelow(22)}},
			tree = rotation({{"Vexmar Plague Pods", 40}, {"Vexmar Antidote", 40}, {"Vexmar Purge", 40}, {"Vexmar Rot Link", 35, pair}, {"Vexmar Blight Beam", 40}, {"Vexmar Corrosion Waves", 35}}, {"Vexmar Spore Burst"})
		},
		Pandemic = {
			onEnter = enrage("NOTHING SURVIVES THE PLAGUE!", 40, true),
			tree = rotation({{"Vexmar Pandemic", 100}, {"Vexmar Plague Pods", 45}, {"Vexmar Antidote", 40}, {"Vexmar Purge", 40}, {"Vexmar Blight Beam", 45}}, {"Vexmar Spore Burst", "Vexmar Corrosion Waves"})
		}
	},
	onDeath = function(monster)
		doCreatureSay(monster, "The forge... cools...", TALKTYPE_MONSTER)
	end
}, "Pandemic", ENRAGE_MS))
