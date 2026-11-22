-- Holy Ray: single target holy damage, the Cleric's main (spam) spell.
local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HOLYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_HOLY)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 1.6, 2.4, 5, 15)

function onCastSpell(cid, var)
	if(doCombat(cid, combat, var)) then
		Cleric.faith(cid)
		return true
	end

	return false
end
