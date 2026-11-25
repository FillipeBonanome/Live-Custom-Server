-- Arrow Tempest (Ranger): ricocheting arrow. Hits the target (range 7) for power x 1.0 to 1.5 and bounces to the nearest enemy within 4 tiles,
-- up to 5 bounces (6 hits in all), losing 10% of the damage on each bounce (minimum 50%). It never hits the same creature twice, never goes
-- through walls (it needs a clear line between one enemy and the next) and never hurts anyone in a protection zone.
-- Every hit has the element of the enchantment: burning, venom, frost or the energy jump.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.relentless = {bounces, falloff}      more bounces and less damage lost on each one
--   glyph.rising     = {amp, critical, duration}   after the cast: +`amp`% damage and +`critical`% critical chance (buff "Rising Gale", subId 8714)
local config = {damage = {1.0, 1.5}, range = 7, bounces = 5, jumpRange = 4, falloff = 0.9, delay = 180}

function onCastSpell(cid, var)
	local target = Archer.target(cid, config.range)
	if(not target) then
		return false
	end

	local glyph = Archer.glyph(cid, "arrow tempest")
	local bounces = (glyph and glyph.relentless and glyph.relentless.bounces) or config.bounces
	local falloff = (glyph and glyph.relentless and glyph.relentless.falloff) or config.falloff

	local element = Archer.element(cid)
	Archer.fx("archer_tempest", target, {element = element})
	Archer.chain(cid, target, {
		damage = config.damage, bounces = bounces, jumpRange = config.jumpRange, falloff = falloff, delay = config.delay, element = element
	})

	if(glyph and glyph.rising) then
		Archer.empower(cid, "Rising Gale", 8714, glyph.rising.amp, glyph.rising.critical, glyph.rising.duration)
	end

	return true
end
