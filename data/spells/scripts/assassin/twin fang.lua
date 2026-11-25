-- Twin Fang: two cuts in a row in 1 adjacent target (power x 0.55 to 0.9 each, +25% when dual wielding). Gives 1 Momentum.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.bleed = {percent, ticks, interval}   every cut makes the target bleed for `percent`% of its average damage, in `ticks` hits
--   glyph.leech = {percent}                    every cut that hits heals `percent`% of your maximum health
local config = {damage = {0.55, 0.9}, dualBonus = 1.25, delay = 300}

local function cut(cid, target, multiplier, glyph)
	if(not Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_HITAREA, multiplier)) then
		return
	end

	if(glyph and glyph.bleed) then
		Glyphs.bleed(cid, target, Assassin.average(cid, config.damage[1], config.damage[2]) * multiplier * glyph.bleed.percent / 100, glyph.bleed.ticks, glyph.bleed.interval)
	end

	if(glyph and glyph.leech) then
		doCreatureAddHealth(cid, math.floor(getCreatureMaxHealth(cid) * glyph.leech.percent / 100))
	end
end

function onCastSpell(cid, var)
	local target = Assassin.target(cid, 1)
	if(not target) then
		return false
	end

	local glyph = Assassin.glyph(cid, "twin fang")
	local multiplier = Assassin.isDual(cid) and config.dualBonus or 1
	Assassin.fx("assassin_twin", target, {from = getCreaturePosition(cid)})
	cut(cid, target, multiplier, glyph)
	addEvent(function()
		if(isCreature(cid) and isCreature(target) and getDistanceBetween(getCreaturePosition(cid), getCreaturePosition(target)) <= 2) then
			cut(cid, target, multiplier, glyph)
		end
	end, config.delay)

	Assassin.momentum(cid)
	return true
end
