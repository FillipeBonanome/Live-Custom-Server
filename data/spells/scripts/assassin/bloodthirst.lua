-- Bloodthirst: +12% life leech and +5% critical chance for 12s (buff "Bloodthirst", Assassin.buffs in data/lib/374-assassin.lua).
-- It is how the Assassin heals, since he cannot drink great or ultimate health potions.
-- Glyphs: glyph.buff = key of the buff in Assassin.buffs that replaces the normal one (bloodthirst_crimson, bloodthirst_predator)
function onCastSpell(cid, var)
	local glyph = Assassin.glyph(cid, "bloodthirst")
	Assassin.fx("assassin_bloodthirst", cid)
	return Assassin.addBuff(cid, glyph and glyph.buff or "bloodthirst")
end
