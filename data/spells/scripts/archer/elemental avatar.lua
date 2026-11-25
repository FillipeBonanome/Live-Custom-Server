-- Elemental Avatar (Ranger): for 12s every attack and spell deals fire, poison, ice and energy (25% of the damage each) and applies the
-- four statuses; the basic attacks also deal +25% of each element. The elemental reactions do not trigger while it lasts.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.radiant = {amp, critical}     +`amp`% damage and +`critical`% critical chance while it lasts (buff "Radiant Avatar", subId 8715)
--   glyph.regen   = {percent}           `percent`% of the maximum health back every second while it lasts
function onCastSpell(cid, var)
	local glyph = Archer.glyph(cid, "elemental avatar")
	local duration = Archer.buffs.avatar.duration
	Archer.addBuff(cid, "avatar")
	Archer.fx("archer_avatar", cid)

	if(glyph and glyph.radiant) then
		Archer.empower(cid, "Radiant Avatar", 8715, glyph.radiant.amp, glyph.radiant.critical, duration)
	end

	if(glyph and glyph.regen) then
		Glyphs.regen(cid, glyph.regen.percent, duration / 1000, 1000)
	end

	return true
end
