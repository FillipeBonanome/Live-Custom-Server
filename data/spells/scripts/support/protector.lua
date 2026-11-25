-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.ward  = {percent, duration}          the caster takes `percent`% less damage from every source (buff "Iron Wall")
--   glyph.regen = {percent, ticks, interval}   the caster recovers `percent`% of its maximum health every `interval` ms
local KEY = "support/protector"
local WARD_SUBID = 8824

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)

local condition = createConditionObject(CONDITION_ATTRIBUTES)
setConditionParam(condition, CONDITION_PARAM_TICKS, 10000)
setConditionParam(condition, CONDITION_PARAM_SKILL_SHIELDPERCENT, 220)
setConditionParam(condition, CONDITION_PARAM_BUFF, true)
setCombatCondition(combat, condition)

local disable = createConditionObject(CONDITION_PACIFIED)
setConditionParam(disable, CONDITION_PARAM_TICKS, 10000)
setCombatCondition(combat, disable)

local exhaust = createConditionObject(CONDITION_EXHAUST)
setConditionParam(exhaust, CONDITION_PARAM_SUBID, 1)
setConditionParam(exhaust, CONDITION_PARAM_TICKS, 10000)
setCombatCondition(combat, exhaust)

function onCastSpell(cid, var)
	local ret = doCombat(cid, combat, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not ret or not glyph) then
		return ret
	end

	if(glyph.ward) then
		Glyphs.statBuff(cid, {
			name = "Iron Wall", duration = glyph.ward.duration, subId = WARD_SUBID, effect = CONST_ME_MAGIC_BLUE,
			description = glyph.ward.percent .. "% less damage from every source.",
			params = Glyphs.absorbAll(glyph.ward.percent)
		})
	end

	if(glyph.regen) then
		Glyphs.regen(cid, glyph.regen.percent, glyph.regen.ticks, glyph.regen.interval)
	end

	return ret
end
