-- Earthshatter (Warlord): shock wave around you in the same area as the Groundshaker (AREA_CIRCLE3X3, 3 SQM of radius), power x 2.5 to 3.5.
-- Costs 18% of the max health (healthpercent in spells.xml). Gives 1 Fury.
local config = {damage = {2.5, 3.5}}
local area = createCombatArea(AREA_CIRCLE3X3)

function onCastSpell(cid, var)
	Berserker.area(cid, getCreaturePosition(cid), area, config.damage[1], config.damage[2], CONST_ME_GROUNDSHAKER)
	Berserker.fury(cid)
	return true
end
