-- Cleric helpers shared by the Cleric spells (data/spells/scripts/*: holy ray, holy nova, pillar of light etc.).
--
-- Cleric.values(cid, minl, maxl, minm, maxm [, minc, maxc])  same formula as setAttackFormula(LEVELMAGIC):
--                                                              min = level/minl + magic*minm + minc (max the same with maxl/maxm/maxc)
-- Cleric.isAlly(cid, tid)            true for the caster and for the members of the caster's party
-- Cleric.allies(cid, pos, radius)    players (caster + party) at most `radius` tiles from pos
-- Cleric.heal(cid, targets, min, max, effect)   heals each creature in the list for a random value between min and max (plus the Faith bonus)
-- Cleric.addBuff(cid, key)          gives one of the Cleric buffs (Cleric.buffs) with addCreatureBuff
-- Cleric.faith(cid)                  passive Faith: call it when a holy spell of the Cleric is cast (+1 stack, max 5, 8s)
-- Cleric.faithStacks(cid), Cleric.faithMultiplier(cid)   current stacks / 1 + 3% per stack (damage and healing)
-- Cleric.zone{...}                   repeats damage / heal pulses (see the function), used by Rain of Light and Final Prayer

Cleric = {}

function Cleric.values(cid, minl, maxl, minm, maxm, minc, maxc)
	local level, magic = getPlayerLevel(cid), getPlayerMagLevel(cid)
	return math.floor(level / minl + magic * minm + (minc or 0)), math.floor(level / maxl + magic * maxm + (maxc or 0))
end

function Cleric.isAlly(cid, tid)
	if(cid == tid) then
		return true
	end

	local members = getPartyMembers(cid)
	return type(members) == 'table' and isInArray(members, tid)
end

function Cleric.allies(cid, pos, radius)
	local list = {}
	local spectators = getSpectators(pos, radius, radius, false)
	if(type(spectators) ~= 'table') then
		spectators = {}
	end

	-- the caster always counts, even when getSpectators does not return the center tile
	if(not isInArray(spectators, cid)) then
		table.insert(spectators, cid)
	end

	for _, tid in ipairs(spectators) do
		if(isPlayer(tid) and Cleric.isAlly(cid, tid) and getCreatureHealth(tid) > 0 and getDistanceBetween(getCreaturePosition(tid), pos) <= radius) then
			table.insert(list, tid)
		end
	end

	return list
end

function Cleric.heal(cid, targets, min, max, effect)
	local multiplier = Cleric.faithMultiplier(cid)
	for _, tid in ipairs(targets) do
		doCreatureAddHealth(tid, math.floor(math.random(min, max) * multiplier))
		if(effect) then
			doSendMagicEffect(getCreaturePosition(tid), effect)
		end
	end
end

-- Holy pulses. params:
--   cid      caster (the zone stops when the caster leaves the game)
--   pos      center (fixed) -- or follow = true to use the caster position at each pulse
--   area     area id (createCombatArea) for the damage        damage = {min, max}  (optional)
--   radius   heal radius (caster + party)                     heal   = {min, max}  (optional)
--   effect   magic effect shown on each damaged tile          ticks, interval (ms)
function Cleric.zone(params)
	local function pulse(left)
		local cid = params.cid
		if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
			return
		end

		local pos = params.follow and getCreaturePosition(cid) or params.pos
		if(params.damage) then
			doAreaCombatHealth(cid, COMBAT_HOLYDAMAGE, pos, params.area, -params.damage[1], -params.damage[2], params.effect)
		end

		if(params.heal) then
			Cleric.heal(cid, Cleric.allies(cid, pos, params.radius), params.heal[1], params.heal[2], CONST_ME_MAGIC_BLUE)
		end

		if(left > 1) then
			addEvent(pulse, params.interval, left - 1)
		end
	end

	pulse(params.ticks)
end

-- Cleric buffs, given with addCreatureBuff (data/lib/370-buffs.lua). Each one is a condition (CONDITION_ATTRIBUTES) with the
-- same duration as the buff; its sub id is unique so the conditions do not replace each other. Used by the spells through
-- Cleric.addBuff(cid, key).
--   name: name and category of the buff (shown in !buffs); duration in ms; params: CONDITION_PARAM_* -> value (times the stacks)
Cleric.buffs = {
	holy_fury = {
		name = "Holy Fury", subId = 8310, duration = 15000, description = "+20% holy damage.",
		params = {[CONDITION_PARAM_ELEMENTAL_AMP_HOLY] = 20}
	},
	divine_grace = {
		name = "Divine Grace", subId = 8311, duration = 15000, description = "+10% magic level.",
		params = {[CONDITION_PARAM_STAT_MAGICLEVELPERCENT] = 110}
	},
	wall_of_light = {
		name = "Wall of Light", subId = 8312, duration = 10000, description = "+5 armor and +4 defense.",
		params = {[CONDITION_PARAM_ARMOR] = 5, [CONDITION_PARAM_DEFENSE] = 4}
	},
	divine_vitality = {
		name = "Divine Vitality", subId = 8314, duration = 120000, description = "+10% max health and max mana.",
		params = {[CONDITION_PARAM_STAT_MAXHEALTHPERCENT] = 110, [CONDITION_PARAM_STAT_MAXMANAPERCENT] = 110}
	},
	radiant_strikes = {
		name = "Radiant Strikes", subId = 8315, duration = 60000, description = "Basic attacks deal +15% of the damage as holy damage.",
		params = {[CONDITION_PARAM_ONHIT_HOLY] = 15}
	},
	-- Faith (passive): stackable, the value is multiplied by the stacks; silent because it is renewed on every holy spell
	faith = {
		name = "Faith", subId = 8320, duration = 8000, description = "+3% holy damage and healing per stack.",
		params = {[CONDITION_PARAM_ELEMENTAL_AMP_HOLY] = 3}, stackable = true, maxStacks = 5, silent = true
	}
}

function Cleric.addBuff(cid, key)
	local def = Cleric.buffs[key]
	if(not def or not isPlayer(cid)) then
		return false
	end

	return addCreatureBuff(cid, {
		name = def.name, category = def.name, duration = def.duration, description = def.description,
		stackable = def.stackable, maxStacks = def.maxStacks,
		onActivate = function(id, stacks)
			local condition = createConditionObject(CONDITION_ATTRIBUTES, def.duration, true, def.subId)
			for param, value in pairs(def.params) do
				setConditionParam(condition, param, value * stacks)
			end

			doAddCondition(id, condition)
			if(not def.silent) then
				doSendMagicEffect(getCreaturePosition(id), CONST_ME_MAGIC_BLUE)
				doPlayerSendTextMessage(id, MESSAGE_STATUS_CONSOLE_BLUE, def.name .. " activated for " .. Buffs.formatTime(def.duration / 1000) .. ".")
			end
		end,
		onRemove = function(id)
			if(isCreature(id)) then
				doRemoveCondition(id, CONDITION_ATTRIBUTES, def.subId)
			end
		end
	})
end

-- Faith (passive): every holy spell cast gives 1 stack (max 5) that lasts 8 seconds and is renewed by each new cast.
-- Each stack gives +3% holy damage (buff condition) and +3% healing (Cleric.heal and the Cleric healing formulas).
-- Faith is one stackable buff ("Faith", Cleric.buffs above), so it shows in !buffs with its stacks.
Cleric.maxFaith = 5

function Cleric.faithStacks(cid)
	return getCreatureBuffStacks(cid, "Faith")
end

function Cleric.faithMultiplier(cid)
	return 1 + 0.03 * Cleric.faithStacks(cid)
end

-- No vocation check: Faith is only given by the Cleric spells, and a GM (or anyone allowed to cast them) must get it too.
function Cleric.faith(cid)
	if(not isPlayer(cid)) then
		return
	end

	Cleric.addBuff(cid, "faith")
	if(Cleric.faithStacks(cid) >= Cleric.maxFaith) then
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_FIREWORK_YELLOW)
	end
end
