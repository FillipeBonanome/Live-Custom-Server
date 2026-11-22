-- Buffs registered on the server (see data/lib/370-buffs.lua for the format and the events).
-- Use them from any script: Buffs.add(cid, "haste") or Buffs.add(cid, "haste", 120) to change the duration.

-- Buffs that only change attributes share this helper: the condition is removed when the buff stops, whatever the reason.
local function attributeBuff(subId, params)
	return {
		onActivate = function(cid, buff)
			local condition = createConditionObject(CONDITION_ATTRIBUTES)
			setConditionParam(condition, CONDITION_PARAM_TICKS, -1)
			setConditionParam(condition, CONDITION_PARAM_SUBID, subId)
			for param, value in pairs(params) do
				setConditionParam(condition, param, value)
			end

			doAddCondition(cid, condition)
			doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, buff.name .. " activated for " .. Buffs.formatTime(buff.duration) .. ".")
		end,
		onExpire = function(cid, buff)
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, buff.name .. " has expired.")
		end,
		onRemove = function(cid, buff, reason)
			doRemoveCondition(cid, CONDITION_ATTRIBUTES, subId)
		end
	}
end

local function register(def, subId, params)
	local base = attributeBuff(subId, params)
	def.onActivate, def.onExpire, def.onRemove = base.onActivate, base.onExpire, base.onRemove
	Buffs.register(def)
end

register({
	id = "blessing_vitality", name = "Blessing of Vitality", category = "blessing", duration = 1800,
	description = "+300 max health."
}, 8301, {[CONDITION_PARAM_STAT_MAXHEALTH] = 300})

register({
	id = "blessing_wisdom", name = "Blessing of Wisdom", category = "blessing", duration = 1800,
	description = "+300 max mana."
}, 8302, {[CONDITION_PARAM_STAT_MAXMANA] = 300})

register({
	id = "exp_boost", name = "Experience Boost", category = "experience", duration = 3600,
	description = "+10% experience."
}, 8303, {[CONDITION_PARAM_EXPERIENCE] = 10})

register({
	id = "loot_boost", name = "Loot Boost", category = "loot", duration = 3600,
	description = "+10% loot."
}, 8304, {[CONDITION_PARAM_LOOT] = 10})

register({
	id = "iron_skin", name = "Iron Skin", category = "defense", duration = 600,
	description = "+3 armor and +2 defense."
}, 8305, {[CONDITION_PARAM_ARMOR] = 3, [CONDITION_PARAM_DEFENSE] = 2})

-- Fist Fury: +20 fist fighting for 10 seconds (cast with the spell "utito punho").
Buffs.register({
	id = "fist_fury", name = "Fist Fury", category = "fist", duration = 10,
	description = "+20 fist fighting.",
	onActivate = function(cid, buff)
		local condition = createConditionObject(CONDITION_ATTRIBUTES)
		setConditionParam(condition, CONDITION_PARAM_TICKS, -1)
		setConditionParam(condition, CONDITION_PARAM_SUBID, 8306)
		setConditionParam(condition, CONDITION_PARAM_SKILL_FIST, 20)
		doAddCondition(cid, condition)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Fist Fury activated: +20 fist fighting for " .. buff.duration .. " seconds.")
	end,
	onExpire = function(cid, buff)
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Fist Fury has ended.")
	end,
	onRemove = function(cid, buff, reason)
		doRemoveCondition(cid, CONDITION_ATTRIBUTES, 8306)
	end
})

-- Cleric buffs (spells in data/spells/scripts/support and healing). Each one has its own category, so they do not replace each other.
register({
	id = "holy_fury", name = "Holy Fury", category = "holy_attack", duration = 15,
	description = "+20% holy damage."
}, 8310, {[CONDITION_PARAM_ELEMENTAL_AMP_HOLY] = 20})

register({
	id = "divine_grace", name = "Divine Grace", category = "holy_grace", duration = 15,
	description = "+10% magic level."
}, 8311, {[CONDITION_PARAM_STAT_MAGICLEVELPERCENT] = 110})

register({
	id = "wall_of_light", name = "Wall of Light", category = "holy_ward", duration = 10,
	description = "+5 armor and +4 defense."
}, 8312, {[CONDITION_PARAM_ARMOR] = 5, [CONDITION_PARAM_DEFENSE] = 4})

-- Shield of Faith: +8 armor and +6 defense for 6 seconds; when the time runs out it heals the target (value set by the spell).
do
	local base = attributeBuff(8313, {[CONDITION_PARAM_ARMOR] = 8, [CONDITION_PARAM_DEFENSE] = 6})
	Buffs.register({
		id = "faith_shield", name = "Shield of Faith", category = "shield", duration = 6,
		description = "+8 armor and +6 defense; heals when it ends.",
		onActivate = base.onActivate,
		onExpire = function(cid, buff)
			base.onExpire(cid, buff)
			local heal = Cleric and Cleric.shieldHeal[cid]
			if(heal) then
				doCreatureAddHealth(cid, math.random(heal[1], heal[2]))
				doSendMagicEffect(getCreaturePosition(cid), CONST_ME_HOLYAREA)
			end
		end,
		onRemove = function(cid, buff, reason)
			base.onRemove(cid, buff, reason)
			if(Cleric) then
				Cleric.shieldHeal[cid] = nil
			end
		end
	})
end
