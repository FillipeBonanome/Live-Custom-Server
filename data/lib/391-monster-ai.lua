-- Monster AI: decision tree + state machine, in the style of the WoL AI. See doc/sistemas/36-bosses.md.
--
-- The AI NEVER does the attacks itself: it only DECIDES which spell to cast and sends it to doCreatureCastSpell(cid, name, true).
-- The spells are ordinary instant spells of data/spells/spells.xml (script in data/spells/scripts/ai/), so every boss can have
-- completely custom spells (telegraphed areas with Telegraph, summons, shields...), and the same spell can be used by several bosses.
--
-- HOW IT RUNS: a spell "AI Think" (spells.xml) calls MonsterAI.think(cid). The monster XML fires it as a normal attack:
--   <attack name="AI Think" interval="1000" chance="100"/>
-- (like any monster attack it only runs while the monster has a target).
--
-- TWO LAYERS:
-- 1) STATE MACHINE: the monster is always in one state (a mood/phase: "Assault", "Enraged"...). Each state lists `transitions`
--    {to = "State", condition = function(monster, target, memory) ... end}; they are checked on EVERY think, before deciding the
--    spell, and the first one that is true wins. onEnter / onExit run when the state changes.
-- 2) DECISION TREE (per state): `tree` decides which spell to cast in THIS tick. Nodes (DecisionTree.*):
--      action("Spell")                  cast this spell
--      branch(condition, ifTrue, ifFalse)  condition(monster, target, memory) -> true goes to ifTrue, false to ifFalse (nest freely;
--                                       either side can be a node or nil = "no spell on this path")
--      priority({"A", "B", "C"})        the FIRST spell of the list that is ready (cooldown and group) and in range
--      chance(percent, ifTrue, ifFalse) branch with a dice
--      custom(function(monster, target, memory) return "Spell" or nil end)   escape hatch (memory = free table of the monster)
--    `monster` and `target` are creature ids (this server has no creature objects).
--
-- REGISTER (by monster name, case does not matter):
--   MonsterAI.register("Warlord Ruzad", {
--       initialState = "Assault",
--       globalCooldown = 2500,     -- ms between two spells of the monster (default 1500)
--       spells = {                 -- metadata of the spells used by the AI (this server cannot read it from the spell):
--           ["Ruzad Warcry"] = {cooldown = 10000, range = 6, say = "RANAT ULDEREK!", group = "area", groupCooldown = 3000},
--       },
--       states = {
--           Assault = {
--               onEnter = function(monster, target, memory) end,    -- optional
--               onExit = function(monster, target, memory) end,     -- optional
--               cooldowns = {["Ruzad Warcry"] = 6000},              -- optional, only LENGTHENS the cooldown of the spell in this state
--               transitions = {{to = "Rally", condition = function(monster, target, memory) return MonsterAI.hpPercent(monster) < 66 end}},
--               tree = DecisionTree.priority({"Ruzad Warcry", "Ruzad Axe Storm"}),
--           },
--       },
--       onDeath = function(monster) end,  -- optional (runs in the Lua state of the creature events, without memory)
--   })
--
-- spells[name]: cooldown (ms, 0 = none), range (the spell is only chosen if the target is within it), say (the monster shouts it when
-- it casts), group + groupCooldown (all the spells of the same group wait groupCooldown ms after any of them). doCreatureCastSpell with
-- force ignores the cooldown/mana/range of spells.xml, that is why the AI keeps the cooldowns itself.
--
-- A spell that FAILS (returns false: no target, no room...) is put on a short cooldown (MonsterAI.retryCooldown) so it does not block
-- the spells after it in a priority list.
--
-- LUA STATES: the think spell and the spells it casts run in the Lua state of the spells, where the runtime of the monsters lives
-- (MonsterAI.runtime). The statschange/death events run in another state, so what they need is kept in creature storages: the
-- shield (MonsterAI.storage.shield) and a mirror of the state (MonsterAI.storage.state, read by /boss).

DecisionTree = {}

MonsterAI = {
	registry = {},  -- lower case name -> definition
	runtime = {},   -- cid -> {state, memory, cooldowns, groups, ...} (spells state only)

	defaultGlobalCooldown = 1500,
	retryCooldown = 2000, -- after a cast that failed
	-- events registered on the monster at its first think (statschange: shield; death: cleanup of the summons)
	events = {"AIShield", "AIDeath"},
	storage = {state = 54730, shield = 54731}
}

-- ---------------------------------------------------------------------------------------------------------------------------
-- Decision tree
-- ---------------------------------------------------------------------------------------------------------------------------

function DecisionTree.action(spellName)
	return {kind = "action", spell = spellName}
end

function DecisionTree.branch(condition, ifTrue, ifFalse)
	return {kind = "branch", condition = condition, ifTrue = ifTrue, ifFalse = ifFalse}
end

function DecisionTree.priority(spellNames)
	return {kind = "priority", spells = spellNames}
end

function DecisionTree.chance(percent, ifTrue, ifFalse)
	return {kind = "branch", condition = function() return math.random(100) <= percent end, ifTrue = ifTrue, ifFalse = ifFalse}
end

function DecisionTree.custom(resolver)
	return {kind = "custom", resolver = resolver}
end

-- walks the tree and returns the name of the spell chosen (or nil)
function DecisionTree.evaluate(node, monster, target, memory)
	if(not node) then
		return nil
	end

	if(node.kind == "action") then
		return node.spell
	end

	if(node.kind == "custom") then
		return node.resolver(monster, target, memory)
	end

	if(node.kind == "priority") then
		for _, spellName in ipairs(node.spells) do
			if(MonsterAI.isReady(monster, spellName) and MonsterAI.isInRange(monster, target, spellName)) then
				return spellName
			end
		end

		return nil
	end

	if(node.condition(monster, target, memory)) then
		return DecisionTree.evaluate(node.ifTrue, monster, target, memory)
	end

	return DecisionTree.evaluate(node.ifFalse, monster, target, memory)
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Registry and runtime
-- ---------------------------------------------------------------------------------------------------------------------------

local function now()
	return os.mtime()
end

function MonsterAI.register(name, definition)
	if(not definition.initialState or not definition.states or not definition.states[definition.initialState]) then
		print("[Warning - MonsterAI] " .. tostring(name) .. ": initialState is invalid or missing.")
		return false
	end

	definition.name = name
	definition.spells = definition.spells or {}
	MonsterAI.registry[name:lower()] = definition
	return true
end

function MonsterAI.getDefinition(cid)
	return MonsterAI.registry[getCreatureName(cid):lower()]
end

function MonsterAI.getRuntime(cid)
	local runtime = MonsterAI.runtime[cid]
	if(not runtime) then
		runtime = {state = nil, stateSince = now(), bornAt = now(), memory = {}, cooldowns = {}, groups = {}, nextCastAt = 0, lastSpell = nil, thinks = 0}
		MonsterAI.runtime[cid] = runtime
	end

	return runtime
end

function MonsterAI.getMemory(cid)
	return MonsterAI.getRuntime(cid).memory
end

function MonsterAI.getState(cid)
	local runtime = MonsterAI.runtime[cid]
	return runtime and runtime.state
end

-- milliseconds the monster is in the current state
function MonsterAI.stateAge(cid)
	local runtime = MonsterAI.runtime[cid]
	return runtime and (now() - runtime.stateSince) or 0
end

-- milliseconds since the first think
function MonsterAI.age(cid)
	local runtime = MonsterAI.runtime[cid]
	return runtime and (now() - runtime.bornAt) or 0
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Helpers for conditions and spells (monster/target are creature ids)
-- ---------------------------------------------------------------------------------------------------------------------------

function MonsterAI.hpPercent(cid)
	return getCreatureHealth(cid) * 100 / math.max(1, getCreatureMaxHealth(cid))
end

-- distance in sqm between two creatures (nil on different floors)
function MonsterAI.distance(cid, target)
	if(not target or not isCreature(target)) then
		return nil
	end

	local a, b = getCreaturePosition(cid), getCreaturePosition(target)
	if(a.z ~= b.z) then
		return nil
	end

	return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

-- players (outside protection zones, same floor) within range sqm of the monster
function MonsterAI.playersAround(cid, range)
	local pos = getCreaturePosition(cid)
	local list = {}
	for _, pid in ipairs(getPlayersOnline()) do
		local ppos = getCreaturePosition(pid)
		if(ppos.z == pos.z and math.max(math.abs(pos.x - ppos.x), math.abs(pos.y - ppos.y)) <= range and not getTilePzInfo(ppos)) then
			table.insert(list, pid)
		end
	end

	return list
end

function MonsterAI.summonCount(cid)
	local summons = getCreatureSummons(cid)
	return type(summons) == "table" and #summons or 0
end

function MonsterAI.say(cid, text, talkType)
	doCreatureSay(cid, text, talkType or TALKTYPE_MONSTER)
end

-- runs fn() after ms if the monster still exists
function MonsterAI.after(cid, ms, fn)
	addEvent(function()
		if(isCreature(cid) and getCreatureHealth(cid) > 0) then
			fn()
		end
	end, ms)
end

function MonsterAI.heal(cid, percent)
	doCreatureAddHealth(cid, math.floor(getCreatureMaxHealth(cid) * percent / 100))
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
end

-- the shield blocks all the damage (event AIShield)
function MonsterAI.setImmune(cid, on)
	doCreatureSetStorage(cid, MonsterAI.storage.shield, on and 1 or 0)
end

function MonsterAI.isImmune(cid)
	return getCreatureStorage(cid, MonsterAI.storage.shield) == 1
end

-- creates summons of the monster until it has `max` of them (they follow its fate: see the AIDeath event); returns how many were created
function MonsterAI.summon(cid, name, count, max)
	local created = 0
	for i = 1, count do
		if(max and MonsterAI.summonCount(cid) >= max) then
			break
		end

		if(doSummonMonster(cid, name) == RETURNVALUE_NOERROR) then
			created = created + 1
		end
	end

	return created
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Ready-made conditions (functions (monster, target, memory) -> boolean, for DecisionTree.branch and the transitions)
-- ---------------------------------------------------------------------------------------------------------------------------

Cond = {}

function Cond.all(...)
	local list = {...}
	return function(monster, target, memory)
		for _, condition in ipairs(list) do
			if(not condition(monster, target, memory)) then
				return false
			end
		end

		return true
	end
end

function Cond.any(...)
	local list = {...}
	return function(monster, target, memory)
		for _, condition in ipairs(list) do
			if(condition(monster, target, memory)) then
				return true
			end
		end

		return false
	end
end

function Cond.no(condition)
	return function(monster, target, memory) return not condition(monster, target, memory) end
end

function Cond.hpBelow(percent)
	return function(monster) return MonsterAI.hpPercent(monster) < percent end
end

function Cond.hpAbove(percent)
	return function(monster) return MonsterAI.hpPercent(monster) >= percent end
end

-- at least `count` players within `range` sqm of the monster
function Cond.playersAround(count, range)
	return function(monster) return #MonsterAI.playersAround(monster, range) >= count end
end

-- the target is farther than `distance` sqm / at most `distance` sqm
function Cond.targetFar(distance)
	return function(monster, target)
		local d = MonsterAI.distance(monster, target)
		return d ~= nil and d > distance
	end
end

function Cond.targetNear(distance)
	return function(monster, target)
		local d = MonsterAI.distance(monster, target)
		return d ~= nil and d <= distance
	end
end

function Cond.summonsBelow(count)
	return function(monster) return MonsterAI.summonCount(monster) < count end
end

function Cond.noSummons()
	return function(monster) return MonsterAI.summonCount(monster) == 0 end
end

-- the spell is ready (cooldown and group). Use it in branches so the tree falls to the next option instead of wasting the tick.
function Cond.ready(spellName)
	return function(monster) return MonsterAI.isReady(monster, spellName) end
end

-- the monster is in the current state for at least `ms`
function Cond.inState(ms)
	return function(monster) return MonsterAI.stateAge(monster) >= ms end
end

-- the monster exists for at least `ms`
function Cond.age(ms)
	return function(monster) return MonsterAI.age(monster) >= ms end
end

function Cond.chance(percent)
	return function() return math.random(100) <= percent end
end

-- memory[name] is set (the spells and states keep free flags in the memory table)
function Cond.flag(name)
	return function(monster, target, memory) return memory[name] and true or false end
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Cooldowns
-- ---------------------------------------------------------------------------------------------------------------------------

function MonsterAI.getSpellInfo(cid, spellName)
	local definition = MonsterAI.getDefinition(cid)
	return definition and definition.spells[spellName] or {}
end

function MonsterAI.setCooldown(cid, spellName, ms)
	if(ms and ms > 0) then
		MonsterAI.getRuntime(cid).cooldowns[spellName] = now() + ms
	end
end

-- cooldown of the spell and of its group are over
function MonsterAI.isReady(cid, spellName)
	local runtime = MonsterAI.getRuntime(cid)
	local current = now()
	if(current < (runtime.cooldowns[spellName] or 0)) then
		return false
	end

	local info = MonsterAI.getSpellInfo(cid, spellName)
	return not info.group or current >= (runtime.groups[info.group] or 0)
end

-- the spell has no range, or the target is within it
function MonsterAI.isInRange(cid, target, spellName)
	local range = MonsterAI.getSpellInfo(cid, spellName).range
	if(not range) then
		return true
	end

	local distance = MonsterAI.distance(cid, target)
	return distance ~= nil and distance <= range
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- State machine and think
-- ---------------------------------------------------------------------------------------------------------------------------

local function mirror(cid, runtime)
	doCreatureSetStorage(cid, MonsterAI.storage.state, "B:" .. tostring(runtime.state) .. "|" .. tostring(runtime.lastSpell or "-"))
end

-- changes the state now (onExit of the old one, onEnter of the new one). Can be called by the spells.
function MonsterAI.setState(cid, stateName, target)
	local definition = MonsterAI.getDefinition(cid)
	local runtime = MonsterAI.getRuntime(cid)
	local new = definition and definition.states[stateName]
	if(not new) then
		print("[Warning - MonsterAI] " .. tostring(definition and definition.name) .. " has no state '" .. tostring(stateName) .. "'.")
		return false
	end

	local old = runtime.state and definition.states[runtime.state]
	if(old and old.onExit) then
		old.onExit(cid, target, runtime.memory)
	end

	runtime.state = stateName
	runtime.stateSince = now()
	if(new.onEnter) then
		new.onEnter(cid, target, runtime.memory)
	end

	mirror(cid, runtime)
	return true
end

local function updateState(cid, definition, runtime, target)
	if(not runtime.state) then
		MonsterAI.setState(cid, definition.initialState, target)
		return
	end

	local current = definition.states[runtime.state]
	if(not current or not current.transitions) then
		return
	end

	for _, transition in ipairs(current.transitions) do
		if(transition.condition(cid, target, runtime.memory)) then
			if(transition.to ~= runtime.state) then
				MonsterAI.setState(cid, transition.to, target)
			end

			break
		end
	end
end

local function tryCastSpell(cid, definition, stateDefinition, runtime, target)
	if(not target or not stateDefinition.tree or now() < runtime.nextCastAt) then
		return
	end

	local spellName = DecisionTree.evaluate(stateDefinition.tree, cid, target, runtime.memory)
	if(not spellName or not MonsterAI.isReady(cid, spellName) or not MonsterAI.isInRange(cid, target, spellName)) then
		return
	end

	local info = definition.spells[spellName] or {}
	local current = now()
	if(not doCreatureCastSpell(cid, spellName, true)) then
		-- it did not work: wait a little before trying it again, so it does not block the spells after it
		MonsterAI.setCooldown(cid, spellName, MonsterAI.retryCooldown)
		return
	end

	if(info.say) then
		MonsterAI.say(cid, info.say)
	end

	local configured = stateDefinition.cooldowns and stateDefinition.cooldowns[spellName] or 0
	MonsterAI.setCooldown(cid, spellName, math.max(configured, info.cooldown or 0))
	if(info.group and info.groupCooldown) then
		runtime.groups[info.group] = current + info.groupCooldown
	end

	runtime.nextCastAt = current + (definition.globalCooldown or MonsterAI.defaultGlobalCooldown)
	runtime.lastSpell = spellName
	mirror(cid, runtime)
end

-- removes the runtime of monsters that are gone (the death event runs in another Lua state and cannot do it)
local function prune()
	for cid in pairs(MonsterAI.runtime) do
		if(not isCreature(cid)) then
			MonsterAI.runtime[cid] = nil
		end
	end
end

local function doThink(cid)
	local definition = MonsterAI.getDefinition(cid)
	if(not definition or getCreatureHealth(cid) <= 0) then
		return
	end

	local runtime = MonsterAI.getRuntime(cid)
	runtime.thinks = runtime.thinks + 1
	if(runtime.thinks == 1) then
		for _, event in ipairs(MonsterAI.events) do
			registerCreatureEvent(cid, event)
		end
	end

	if(runtime.thinks % 120 == 0) then
		prune()
	end

	local target = getCreatureTarget(cid)
	if(not target or target == 0 or not isCreature(target) or getCreatureHealth(target) <= 0) then
		target = nil
	end

	updateState(cid, definition, runtime, target)
	local stateDefinition = definition.states[runtime.state]
	if(stateDefinition) then
		tryCastSpell(cid, definition, stateDefinition, runtime, target)
	end
end

-- called by the spell "AI Think"
function MonsterAI.think(cid)
	local ok, err = pcall(doThink, cid)
	if(not ok) then
		print("[Error - MonsterAI] think of " .. tostring(getCreatureName(cid)) .. ": " .. tostring(err))
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Events (creature events state)
-- ---------------------------------------------------------------------------------------------------------------------------

-- event AIShield: blocks the damage while the shield is on
function MonsterAI.onStats(cid, statType)
	if(statType == STATSCHANGE_HEALTHLOSS and MonsterAI.isImmune(cid)) then
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_BLOCKHIT)
		return false
	end

	return true
end

-- event AIDeath: the summons vanish with the monster and the onDeath hook of the definition runs
function MonsterAI.onDeath(cid)
	local definition = MonsterAI.getDefinition(cid)
	if(definition and definition.onDeath) then
		pcall(definition.onDeath, cid)
	end

	local summons = getCreatureSummons(cid)
	if(type(summons) == "table") then
		for _, uid in ipairs(summons) do
			if(isCreature(uid)) then
				doSendMagicEffect(getCreaturePosition(uid), CONST_ME_POFF)
				doRemoveCreature(uid)
			end
		end
	end
end
