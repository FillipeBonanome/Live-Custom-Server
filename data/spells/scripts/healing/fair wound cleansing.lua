-- Fair Wound Cleansing: stronger melee heal (Knight, Assassin, Berserker). Scales with level and the best melee skill.
local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)

function onGetFormulaValues(cid, level, maglevel)
	local skill = math.max(getPlayerSkillLevel(cid, SKILL_SWORD), getPlayerSkillLevel(cid, SKILL_CLUB), getPlayerSkillLevel(cid, SKILL_AXE))
	return math.floor(level / 3 + skill * 3.0 + 20), math.floor(level / 3 + skill * 4.0 + 35)
end
setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
