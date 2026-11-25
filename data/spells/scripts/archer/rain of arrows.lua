-- Rain of Arrows: rain of arrows in an area (radius 2, 5x5) on the target (range 6) for 1.5s: 6 hits (every 0.25s) of power x 0.3 to 0.45
-- on every enemy in the area. The arrows always fall from above; they come from the left, the center or the right depending on where you are in relation to the target.
-- fire: burning | poison: a stack of venom every second hit | ice: a stack of frost every second hit | energy: the last hit deals +40%
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.storm  = {ticks, damage}          more hits in the same 1.5s; `damage` = multiplier of EACH hit (9 hits of 1.3 * 6 / 9 = 130% of the original in total)
--   glyph.pierce = {percent, duration}      monsters in the area lose resistance to physical, fire, earth, ice and energy (first hit)
local config = {damage = {0.3, 0.45}, range = 6, radius = 2, ticks = 6, interval = 250, drops = 40, lastBonus = 1.4}

function onCastSpell(cid, var)
	local target = Archer.target(cid, config.range)
	if(not target) then
		return false
	end

	local glyph = Archer.glyph(cid, "rain of arrows")
	local ticks, interval, damage = config.ticks, config.interval, 1
	if(glyph and glyph.storm) then
		ticks, damage = glyph.storm.ticks, glyph.storm.damage
		interval = math.floor(config.ticks * config.interval / ticks)
	end

	local element = Archer.element(cid)
	local center = getCreaturePosition(target)
	Archer.fx("archer_rain", center, {
		element = element, from = getCreaturePosition(cid), radius = config.radius, drops = config.drops, duration = ticks * interval
	})

	local function tick(number)
		if(not isCreature(cid)) then
			return
		end

		local options = {}
		if(element == "poison" or element == "ice") then
			options.intensity = number % 2 == 0 and 1 or 0
		end

		local multiplier = ((element == "energy" and number == ticks) and config.lastBonus or 1) * damage
		for _, tid in ipairs(Archer.enemies(cid, center, config.radius, target)) do
			if(number == 1 and glyph and glyph.pierce) then
				Archer.weaken(tid, glyph.pierce.percent, glyph.pierce.duration)
			end

			Archer.hit(cid, tid, config.damage[1], config.damage[2], element, multiplier, options)
		end

		if(number < ticks) then
			addEvent(tick, interval, number + 1)
		end
	end

	addEvent(tick, 300, 1)
	return true
end
