-- Divine Lance: holy beam (5 tiles) that damages enemies and heals the players in the line.
local damage = createCombatObject()
setCombatParam(damage, COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
setCombatParam(damage, COMBAT_PARAM_EFFECT, CONST_ME_HOLYAREA)
setAttackFormula(damage, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 2.4, 3.6)
setCombatArea(damage, createCombatArea(AREA_BEAM5, AREADIAGONAL_BEAM5))

-- Same beam, but healing: heals the players (and summons) in the line, like Mass Healing.
local heal = createCombatObject()
setCombatParam(heal, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(heal, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(heal, COMBAT_PARAM_AGGRESSIVE, false)
setCombatParam(heal, COMBAT_PARAM_TARGETPLAYERSORSUMMONS, true)
setHealingFormula(heal, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 1.0, 1.5)
setCombatArea(heal, createCombatArea(AREA_BEAM5, AREADIAGONAL_BEAM5))

function onCastSpell(cid, var)
	doCombat(cid, heal, var)
	return doCombat(cid, damage, var)
end
