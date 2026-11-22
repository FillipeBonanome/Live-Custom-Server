-- Smoke Bomb: smoke around you (radius 2) that hurts the enemies (power x 0.4 to 0.7) and makes you invisible for 3s. Gives 1 Momentum.
local config = {damage = {0.4, 0.7}, invisible = 3000}
local area = createCombatArea(AREA_CIRCLE2X2)

function onCastSpell(cid, var)
	local pos = getCreaturePosition(cid)
	local min, max = Assassin.values(cid, config.damage[1], config.damage[2])
	doAreaCombatHealth(cid, COMBAT_PHYSICALDAMAGE, pos, area, -min, -max, CONST_ME_NONE)
	Assassin.fx("assassin_smoke", pos)
	Assassin.invisible(cid, config.invisible)
	Assassin.momentum(cid)
	return true
end
