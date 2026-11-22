-- Dragon Skeleton: Front Sweep, physical arc in front of it (P x 1.2 to 2.0).
local combat = createCombatObject()
local area = createCombatArea(AREA_WAVE4, AREADIAGONAL_WAVE4)

function onCastSpell(cid, var)
	local min, max = Necro.summonValues(cid, 1.2, 2.0)
	doAreaCombatHealth(cid, COMBAT_PHYSICALDAMAGE, Necro.positionInFront(cid, 1), area, -min, -max, CONST_ME_HITAREA)
	return true
end
