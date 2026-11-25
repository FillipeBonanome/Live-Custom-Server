-- Wall of Light: +armor and +defense for 10 seconds on the caster and the party members around (radius 3) (buff "Wall of Light").
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.buff = "key"                 another version of the buff from Cleric.buffs (data/lib/372-cleric.lua): armor and defense doubled
--   glyph.ward = {percent, duration}   also `percent`% less damage from every element (buff "Wall of Reflection", subId 8834)
local KEY = "support/wall of light"

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local buff = (glyph and glyph.buff) or "wall_of_light"
	for _, tid in ipairs(Cleric.allies(cid, getCreaturePosition(cid), 3)) do
		Cleric.addBuff(tid, buff)
		if(glyph and glyph.ward) then
			Glyphs.statBuff(tid, {
				name = "Wall of Reflection", duration = glyph.ward.duration, subId = 8834, effect = CONST_ME_HOLYAREA,
				description = glyph.ward.percent .. "% less damage from every element.", params = Glyphs.absorbAll(glyph.ward.percent)
			})
		end
	end

	return true
end
