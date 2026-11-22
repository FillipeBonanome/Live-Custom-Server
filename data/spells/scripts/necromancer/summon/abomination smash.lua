-- Bone Abomination: Smash, physical hit on everything around it (3x3, P x 1.0 to 1.8).
local combat = createCombatObject()
local area = createCombatArea(AREA_SQUARE1X1)

function onCastSpell(cid, var)
	local min, max = Necro.summonValues(cid, 1.0, 1.8)
	doAreaCombatHealth(cid, COMBAT_PHYSICALDAMAGE, getCreaturePosition(cid), area, -min, -max, CONST_ME_HITAREA)
	return true
end
