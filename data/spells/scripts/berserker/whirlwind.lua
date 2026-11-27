-- Whirlwind: spin and hit everything around you (3x3, power x 0.8 to 1.4). The life leech heals you for each enemy hit.
-- Costs 7% of the max health (healthpercent in spells.xml). Gives 1 Fury.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.wide = true                  the area is a circle of radius 2 (AREA_CIRCLE2X2) instead of 3x3
--   glyph.heal = {percent, targets}    `percent`% of the maximum health back for each enemy hit (up to `targets`)
local config = {damage = {0.8, 1.4}}
local area = createCombatArea(AREA_SQUARE1X1)
local areaWide = createCombatArea(AREA_CIRCLE2X2)

function onCastSpell(cid, var)
	local glyph = Berserker.glyph(cid, "whirlwind")
	local wide = glyph and glyph.wide
	local pos = getCreaturePosition(cid)
	local hit = (glyph and glyph.heal) and #Berserker.enemiesAround(cid, pos, 1) or 0

	Berserker.area(cid, pos, wide and areaWide or area, config.damage[1], config.damage[2], CONST_ME_NONE)
	Berserker.fx("berserker_whirlwind", cid, {wide = wide})
	if(glyph and glyph.heal and hit > 0) then
		local amount = math.floor(getCreatureMaxHealth(cid) * glyph.heal.percent / 100) * math.min(hit, glyph.heal.targets)
		doCreatureAddHealth(cid, amount)
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_RED)
	end

	Berserker.fury(cid)
	return true
end
