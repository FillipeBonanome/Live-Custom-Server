-- Phantasm: Haunt, 3x3 area on the target with death or poison (chosen at random each cast), P x 0.6 to 1.1.
local combat = createCombatObject()
local area = createCombatArea(AREA_CIRCLE3X3)

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		return false
	end

	local min, max = Necro.summonValues(cid, 0.6, 1.1)
	local death = math.random(2) == 1
	doSendDistanceShoot(getCreaturePosition(cid), getCreaturePosition(target), death and CONST_ANI_DEATH or CONST_ANI_POISON)
	doAreaCombatHealth(cid, death and COMBAT_DEATHDAMAGE or COMBAT_EARTHDAMAGE, getCreaturePosition(target), area, -min, -max,
		death and CONST_ME_MORTAREA or CONST_ME_POISONAREA)
	return true
end
