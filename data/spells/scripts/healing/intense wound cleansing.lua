-- Intense Wound Cleansing: big emergency heal (long cooldown) for Knight, Assassin and Berserker. Heals 35% to 45% of the max health.
local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)

function onGetFormulaValues(cid, level, maglevel)
	local maxHealth = getCreatureMaxHealth(cid)
	return math.floor(maxHealth * 0.35), math.floor(maxHealth * 0.45)
end
setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(cid, var)
	if(doCombat(cid, combat, var)) then
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_HOLYAREA)
		return true
	end

	return false
end
