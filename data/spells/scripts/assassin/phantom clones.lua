-- Phantom Clones (Nightblade): 2 clones with your outfit fight at your side for 12s. They use no summon slot.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.count = clones; glyph.duration = ms; glyph.challenge = radius (the clones challenge the monsters within that many sqm)
function onCastSpell(cid, var)
	local glyph = Assassin.glyph(cid, "phantom clones")
	if(not glyph) then
		return Assassin.clones(cid)
	end

	return Assassin.clones(cid, glyph.count, glyph.duration, glyph.challenge)
end
