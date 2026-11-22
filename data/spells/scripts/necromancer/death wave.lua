-- Death Wave: wave of death like Vis Hur (P x 1.2 to 2.0).
local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MORTAREA)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_DEATH)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, Necro.formula(1.2, 2.0))
setCombatArea(combat, createCombatArea(AREA_SQUAREWAVE5, AREADIAGONAL_SQUAREWAVE5))

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
