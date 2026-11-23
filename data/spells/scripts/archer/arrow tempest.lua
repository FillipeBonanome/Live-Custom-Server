-- Arrow Tempest (Ranger): ricocheting arrow. Hits the target (range 7) for power x 1.0 to 1.5 and bounces to the nearest enemy within 4 tiles,
-- up to 5 bounces (6 hits in all), losing 10% of the damage on each bounce (minimum 50%). It never hits the same creature twice, never goes
-- through walls (it needs a clear line between one enemy and the next) and never hurts anyone in a protection zone.
-- Every hit has the element of the enchantment: burning, venom, frost or the energy jump.
local config = {damage = {1.0, 1.5}, range = 7, bounces = 5, jumpRange = 4, falloff = 0.9, delay = 180}

function onCastSpell(cid, var)
	local target = Archer.target(cid, config.range)
	if(not target) then
		return false
	end

	local element = Archer.element(cid)
	Archer.fx("archer_tempest", target, {element = element})
	Archer.chain(cid, target, {
		damage = config.damage, bounces = config.bounces, jumpRange = config.jumpRange, falloff = config.falloff, delay = config.delay, element = element
	})
	return true
end
