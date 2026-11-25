-- Elemental Surge: for 10s the basic attacks deal +40% of the damage as the element of the enchantment (on top of the +30% of the Enchant buff),
-- +15 fist skill (attack speed) and every status (burn, venom, frost, shock) gets one extra stack.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.haste = true                   haste (+30%) while the surge lasts
--   glyph.ward  = {percent}              `percent`% less damage from every element while it lasts (buff "Warding Surge", subId 8712)
function onCastSpell(cid, var)
	local glyph = Archer.glyph(cid, "elemental surge")
	Archer.addBuff(cid, "surge", {[Archer.def(cid).onhit] = 40})
	Archer.fx("archer_surge", cid)

	if(glyph and glyph.haste) then
		Glyphs.haste(cid, Archer.buffs.surge.duration)
	end

	if(glyph and glyph.ward) then
		Archer.guard(cid, "Warding Surge", 8712, glyph.ward.percent, Archer.buffs.surge.duration)
	end

	return true
end
