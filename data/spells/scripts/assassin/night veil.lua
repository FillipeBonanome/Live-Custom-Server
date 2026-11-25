-- Night Veil (Nightblade): +25% dodge, +6 armor and +4 defense for 12s (buff "Night Veil").
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.swift = true   buff night_veil_swift (15s) and haste (+30%) for the same time
--   glyph.guard = {percent, duration}   besides the buff: that % less damage of every element for `duration` ms
function onCastSpell(cid, var)
	local glyph = Assassin.glyph(cid, "night veil")
	Assassin.fx("assassin_veil", cid)
	if(glyph and glyph.swift) then
		Glyphs.haste(cid, Assassin.buffs.night_veil_swift.duration)
		return Assassin.addBuff(cid, "night_veil_swift")
	end

	if(glyph and glyph.guard) then
		Glyphs.statBuff(cid, {
			name = "Veil of Reflection", duration = glyph.guard.duration, subId = 8407, effect = CONST_ME_MAGIC_BLUE,
			description = glyph.guard.percent .. "% less damage from every element.",
			params = Glyphs.absorbAll(glyph.guard.percent)
		})
	end

	return Assassin.addBuff(cid, "night_veil")
end
