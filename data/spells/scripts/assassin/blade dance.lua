-- Blade Dance: spin and hit everything around you (3x3, power x 0.7 to 1.2). Spends the Momentum stacks: +15% damage for each one.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.wide = true                     the area is a circle of radius 2 (AREA_CIRCLE2X2)
--   glyph.heal = {percent, targets}       you recover `percent`% of your maximum health per enemy hit (up to `targets`)
local config = {damage = {0.7, 1.2}, perStack = 0.15}
local areas = {normal = createCombatArea(AREA_SQUARE1X1), wide = createCombatArea(AREA_CIRCLE2X2)}

function onCastSpell(cid, var)
	local glyph = Assassin.glyph(cid, "blade dance")
	local wide = glyph and glyph.wide
	local pos = getCreaturePosition(cid)
	local stacks = Assassin.consume(cid)
	local multiplier = 1 + config.perStack * stacks
	local min, max = Assassin.values(cid, config.damage[1], config.damage[2])
	local hit = (glyph and glyph.heal) and #Assassin.enemiesAround(cid, pos, wide and 2 or 1) or 0
	doAreaCombatHealth(cid, COMBAT_PHYSICALDAMAGE, pos, wide and areas.wide or areas.normal, -math.floor(min * multiplier), -math.floor(max * multiplier), CONST_ME_HITAREA)
	Assassin.fx("assassin_dance", cid)
	if(hit > 0) then
		doCreatureAddHealth(cid, math.floor(getCreatureMaxHealth(cid) * glyph.heal.percent / 100 * math.min(hit, glyph.heal.targets)))
	end

	return true
end
