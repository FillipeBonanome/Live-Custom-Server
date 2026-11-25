-- Radiant Strikes (Hierophant): basic attacks deal 15% of the damage as extra holy damage, for 1 minute, on the caster and the
-- party (radius 7) (buff "Radiant Strikes", uses the on hit holy attribute).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.buff   = "key"   another version of the buff from Cleric.buffs (data/lib/372-cleric.lua): 25% instead of 15%, or 2 minutes
--   glyph.radius = n       the party within `n` sqm gets it (7 normally)
local KEY = "support/radiant strikes"

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local buff = (glyph and glyph.buff) or "radiant_strikes"
	local radius = (glyph and glyph.radius) or 7
	for _, tid in ipairs(Cleric.allies(cid, getCreaturePosition(cid), radius)) do
		Cleric.addBuff(tid, buff)
	end

	return true
end
