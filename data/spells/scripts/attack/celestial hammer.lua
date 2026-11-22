-- Celestial Hammer: heavy holy hit on one target that also paralyzes it for 2 seconds (stun).
local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HOLYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_HOLY)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 3.2, 4.6, 10, 25)

local stun = createConditionObject(CONDITION_PARALYZE)
setConditionParam(stun, CONDITION_PARAM_TICKS, 2000)
setConditionFormula(stun, -0.9, 0, -0.9, 0)
setCombatCondition(combat, stun)

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
