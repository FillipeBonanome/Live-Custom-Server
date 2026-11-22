-- Whirlwind: spin and hit everything around you (3x3, power x 0.8 to 1.4). The life leech heals you for each enemy hit.
-- Costs 7% of the max health (healthpercent in spells.xml). Gives 1 Fury.
local config = {damage = {0.8, 1.4}}
local area = createCombatArea(AREA_SQUARE1X1)

function onCastSpell(cid, var)
	Berserker.area(cid, getCreaturePosition(cid), area, config.damage[1], config.damage[2], CONST_ME_HITAREA)
	Berserker.fury(cid)
	return true
end
