-- Dragon Skeleton: Death Wave, big wave of death in front of it (P x 1.5 to 2.5).
local combat = createCombatObject()
local area = createCombatArea(AREA_SQUAREWAVE5, AREADIAGONAL_SQUAREWAVE5)

function onCastSpell(cid, var)
	local min, max = Necro.summonValues(cid, 1.5, 2.5)
	doAreaCombatHealth(cid, COMBAT_DEATHDAMAGE, Necro.positionInFront(cid, 1), area, -min, -max, CONST_ME_MORTAREA)
	return true
end
