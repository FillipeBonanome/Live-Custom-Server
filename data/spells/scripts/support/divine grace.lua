-- Divine Grace: +10% magic level for 15 seconds on the caster and the party members around (radius 3) (buff "Divine Grace").
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.buff = "key"   another version of the buff from Cleric.buffs (data/lib/372-cleric.lua): +20% magic level, or 25 seconds
--   glyph.mana = n       everyone affected recovers n% of the maximum mana at once
local KEY = "support/divine grace"

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local buff = (glyph and glyph.buff) or "divine_grace"
	for _, tid in ipairs(Cleric.allies(cid, getCreaturePosition(cid), 3)) do
		Cleric.addBuff(tid, buff)
		if(glyph and glyph.mana) then
			doCreatureAddMana(tid, math.floor(getCreatureMaxMana(tid) * glyph.mana / 100))
		end
	end

	return true
end
