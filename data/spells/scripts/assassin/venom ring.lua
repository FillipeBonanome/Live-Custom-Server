-- Venom Ring: you slash in a circle with poisoned blades: everything around you (3x3) takes poison (earth) damage (power x 0.5 to 0.8)
-- and is poisoned for 6s (12% of the damage per second, same as Venom Edge). Short cooldown: the Assassin's spam area spell. Gives 1 Momentum.
local config = {damage = {0.5, 0.8}, ticks = 6}
local area = createCombatArea(AREA_SQUARE1X1)

function onCastSpell(cid, var)
	local pos = getCreaturePosition(cid)
	local min, max = Assassin.values(cid, config.damage[1], config.damage[2])
	doAreaCombatHealth(cid, COMBAT_EARTHDAMAGE, pos, area, -min, -max, CONST_ME_NONE)
	doAreaCombatCondition(cid, pos, area, Assassin.poison(cid, config.ticks, nil, config.damage[1], config.damage[2]), CONST_ME_NONE)
	Assassin.fx("assassin_venom_ring", cid)
	Assassin.momentum(cid)
	return true
end
