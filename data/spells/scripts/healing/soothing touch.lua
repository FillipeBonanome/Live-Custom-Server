-- Soothing Touch: medium heal on one ally ("exura lux sio" "name", or on the current target).
local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)

-- heal formula: level/5 + magic level * 6 (min) or 8.4 (max), plus the Faith bonus
function onGetFormulaValues(cid, level, maglevel)
	local multiplier = Cleric.faithMultiplier(cid)
	return math.floor((level / 5 + maglevel * 6) * multiplier), math.floor((level / 5 + maglevel * 8.4) * multiplier)
end
setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(cid, var)
	if(doCombat(cid, combat, var)) then
		Cleric.faith(cid)
		return true
	end

	return false
end
