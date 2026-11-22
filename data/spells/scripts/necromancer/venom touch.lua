-- Venom Touch: poison hit in 1 target (P x 0.4 to 0.8) that also poisons it.
local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HITBYPOISON)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_POISON)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, Necro.formula(0.4, 0.8))

-- poison over time (10s) on everything that is hit: damage per tick = level/15 + magic level/3
function onTargetCreature(cid, target)
	doTargetCombatCondition(cid, target, Necro.poisonCondition(cid), CONST_ME_NONE)
	return true
end
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
