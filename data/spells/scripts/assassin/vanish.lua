-- Vanish: invisible for 5s; for 4s every hit is a critical (buff "Vanish"). Gives 1 Momentum.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.haste  = ms                       haste (+30%) for that long
--   glyph.lethal = {damage, duration}       the first spell hit within `duration` ms deals `damage` times more (Assassin.lethal)
local config = {invisible = 5000}

function onCastSpell(cid, var)
	local glyph = Assassin.glyph(cid, "vanish")
	Assassin.fx("assassin_vanish", cid)
	Assassin.invisible(cid, config.invisible)
	Assassin.addBuff(cid, "vanish")
	if(glyph and glyph.haste) then
		Glyphs.haste(cid, glyph.haste)
	end

	if(glyph and glyph.lethal) then
		Assassin.lethal[cid] = {expires = os.time() + glyph.lethal.duration / 1000, multiplier = glyph.lethal.damage}
	end

	Assassin.momentum(cid)
	return true
end
