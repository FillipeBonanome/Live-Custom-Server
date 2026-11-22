-- Venom Wave: wave of poison like Vis Hur (P x 1.0 to 1.7) that poisons everything it hits.
local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_POISONAREA)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_POISON)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, Necro.formula(1.0, 1.7))
setCombatArea(combat, createCombatArea(AREA_SQUAREWAVE5, AREADIAGONAL_SQUAREWAVE5))

-- poison over time (10s) on everything that is hit: damage per tick = level/15 + magic level/3
function onTargetCreature(cid, target)
	doTargetCombatCondition(cid, target, Necro.poisonCondition(cid), CONST_ME_NONE)
	return true
end
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
