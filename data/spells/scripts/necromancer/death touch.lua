-- Death Touch: death damage in 1 target (P x 0.7 to 1.3).
local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MORTAREA)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_DEATH)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, Necro.formula(0.7, 1.3))

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
