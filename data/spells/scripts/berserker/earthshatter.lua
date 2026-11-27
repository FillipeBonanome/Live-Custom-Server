-- Earthshatter (Warlord): shock wave around you in the same area as the Groundshaker (AREA_CIRCLE3X3, 3 SQM of radius), power x 2.5 to 3.5.
-- Costs 18% of the max health (healthpercent in spells.xml). Gives 1 Fury.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.echo  = {delay, share}        a second wave `delay` ms later, around where you are, with `share` of the damage
--   glyph.guard = {percent, duration}   after the blow you take `percent`% less damage from every element (buff "Stonehide", subId 8451)
local config = {damage = {2.5, 3.5}}
local area = createCombatArea(AREA_CIRCLE3X3)

function onCastSpell(cid, var)
	local glyph = Berserker.glyph(cid, "earthshatter")
	Berserker.area(cid, getCreaturePosition(cid), area, config.damage[1], config.damage[2], CONST_ME_NONE)
	Berserker.fx("berserker_earthshatter", getCreaturePosition(cid))

	if(glyph and glyph.echo) then
		addEvent(function()
			if(isCreature(cid) and getCreatureHealth(cid) > 0) then
				Berserker.area(cid, getCreaturePosition(cid), area, config.damage[1], config.damage[2], CONST_ME_GROUNDSHAKER, glyph.echo.share)
				Berserker.fx("berserker_earthshatter", getCreaturePosition(cid))
			end
		end, glyph.echo.delay)
	end

	if(glyph and glyph.guard) then
		Berserker.guard(cid, "Stonehide", 8451, glyph.guard.percent, glyph.guard.duration)
	end

	Berserker.fury(cid)
	return true
end
