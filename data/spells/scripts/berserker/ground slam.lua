-- Ground Slam: shock wave in front of you (wave, power x 1.1 to 1.7) that also slows the monsters hit (-60% speed for 3s).
-- Costs 8% of the max health (healthpercent in spells.xml). Gives 1 Fury.
local config = {damage = {1.1, 1.7}}

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_GROUNDSHAKER)
setCombatArea(combat, createCombatArea(AREA_WAVE4, AREADIAGONAL_WAVE4))

local slow = createConditionObject(CONDITION_PARALYZE)
setConditionParam(slow, CONDITION_PARAM_TICKS, 3000)
setConditionFormula(slow, -0.6, 0, -0.6, 0)
setCombatCondition(combat, slow)

function onGetPlayerMinMaxValues(cid, level, maglevel)
	local min, max = Berserker.values(cid, config.damage[1], config.damage[2])
	return -min, -max
end
setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetPlayerMinMaxValues")

function onCastSpell(cid, var)
	local result = doCombat(cid, combat, var)
	Berserker.fury(cid)
	return result
end
