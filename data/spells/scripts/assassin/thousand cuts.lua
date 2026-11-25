-- Thousand Cuts (Nightblade): 8 cuts in 2.4s in 1 target within 2 SQM (power x 0.35 to 0.55 each).
-- Spends the Momentum stacks: +10% damage for each one.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.bleed  = {percent, ticks, interval}   every cut makes the target bleed for `percent`% of its average damage
--   glyph.splash = {range, percent}             every cut also hits the other enemies within `range` sqm of the target, with `percent`%
local config = {damage = {0.35, 0.55}, cuts = 8, interval = 300, perStack = 0.10, range = 2}

function onCastSpell(cid, var)
	local target = Assassin.target(cid, config.range)
	if(not target) then
		return false
	end

	local glyph = Assassin.glyph(cid, "thousand cuts")
	local multiplier = 1 + config.perStack * Assassin.consume(cid)
	Assassin.fx("assassin_cuts", target, {from = getCreaturePosition(cid)})

	local function cut(left)
		if(not isCreature(cid) or not isCreature(target) or getCreatureHealth(target) <= 0) then
			return
		end

		if(getDistanceBetween(getCreaturePosition(cid), getCreaturePosition(target)) <= config.range + 1) then
			Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_HITAREA, multiplier)
			if(glyph and glyph.bleed) then
				Glyphs.bleed(cid, target, Assassin.average(cid, config.damage[1], config.damage[2]) * multiplier * glyph.bleed.percent / 100, glyph.bleed.ticks, glyph.bleed.interval)
			end

			if(glyph and glyph.splash and isCreature(target)) then
				for _, tid in ipairs(Assassin.enemiesAround(cid, getCreaturePosition(target), glyph.splash.range, target)) do
					Assassin.hit(cid, tid, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_HITAREA, multiplier * glyph.splash.percent / 100)
				end
			end
		end

		if(left > 1) then
			addEvent(cut, config.interval, left - 1)
		end
	end

	cut(config.cuts)
	return true
end
