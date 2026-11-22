-- Blade Dance: spin and hit everything around you (3x3, power x 0.7 to 1.2). Spends the Momentum stacks: +15% damage for each one.
local config = {damage = {0.7, 1.2}, perStack = 0.15}
local area = createCombatArea(AREA_SQUARE1X1)

function onCastSpell(cid, var)
	local stacks = Assassin.consume(cid)
	local multiplier = 1 + config.perStack * stacks
	local min, max = Assassin.values(cid, config.damage[1], config.damage[2])
	doAreaCombatHealth(cid, COMBAT_PHYSICALDAMAGE, getCreaturePosition(cid), area, -math.floor(min * multiplier), -math.floor(max * multiplier), CONST_ME_HITAREA)
	Assassin.fx("assassin_dance", cid)
	return true
end
