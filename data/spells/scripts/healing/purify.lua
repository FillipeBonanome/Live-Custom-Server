-- Purify: removes poison, fire, energy, cursed and paralysis from the caster and the party around (radius 2)
-- and deals a little holy damage to enemies in the same area.
local area = createCombatArea(AREA_CIRCLE2X2)
local conditions = {CONDITION_POISON, CONDITION_FIRE, CONDITION_ENERGY, CONDITION_CURSED, CONDITION_PARALYZE}

function onCastSpell(cid, var)
	local pos = getCreaturePosition(cid)
	for _, tid in ipairs(Cleric.allies(cid, pos, 2)) do
		for _, condition in ipairs(conditions) do
			if(hasCondition(tid, condition)) then
				doRemoveCondition(tid, condition)
			end
		end

		doSendMagicEffect(getCreaturePosition(tid), CONST_ME_MAGIC_GREEN)
	end

	local min, max = Cleric.values(cid, 5, 5, 0.8, 1.3)
	doAreaCombatHealth(cid, COMBAT_HOLYDAMAGE, pos, area, -min, -max, CONST_ME_HOLYAREA)
	return true
end
