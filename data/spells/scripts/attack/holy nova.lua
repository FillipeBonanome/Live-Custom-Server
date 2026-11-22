-- Holy Nova (signature spell): holy burst around the caster, damages enemies and heals party members in the area.
local area = createCombatArea(AREA_CIRCLE2X2)

local damage = createCombatObject()
setCombatParam(damage, COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
setCombatParam(damage, COMBAT_PARAM_EFFECT, CONST_ME_HOLYAREA)
setAttackFormula(damage, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 2.6, 3.8)
setCombatArea(damage, area)

function onCastSpell(cid, var)
	local ok = doCombat(cid, damage, var)
	if(ok) then
		Cleric.heal(Cleric.allies(cid, getCreaturePosition(cid), 2), Cleric.values(cid, 5, 5, 1.2, 1.8))
	end

	return ok
end
