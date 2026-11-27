-- Earthen Mend: the stone closes your wounds. Heals level/5 + power x 1.2 to 1.8 (power = club skill + attack of the club).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.deep    = {heal}                 healing: the heal is `heal` times bigger
--   glyph.purify  = {percent, duration}    utility: removes every harmful condition and you take `percent`% less damage from every element for `duration` ms (buff in !buffs, subId 8910)
local config = {heal = {1.2, 1.8}}

function onCastSpell(cid, var)
	local glyph = Geomancer.glyph(cid, "earthen mend")
	local multiplier = glyph and glyph.deep and glyph.deep.heal or 1
	Geomancer.heal(cid, config.heal[1] * multiplier, config.heal[2] * multiplier)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_STONES)

	if(glyph and glyph.purify) then
		Glyphs.cleanse(cid)
		Geomancer.statBuff(cid, {
			name = "Purifying Stone", subId = 8910, duration = glyph.purify.duration, effect = CONST_ME_MAGIC_GREEN,
			description = glyph.purify.percent .. "% less damage from every element.", params = Geomancer.absorbAll(glyph.purify.percent)
		})
	end

	return true
end
