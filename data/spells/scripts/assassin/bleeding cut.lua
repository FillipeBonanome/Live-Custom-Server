-- Bleeding Cut: cut in 1 adjacent target (power x 0.5 to 0.8) that makes it bleed for 6s (physical damage once a second:
-- power x 0.08 + level/20, doubled with 3 or more Momentum stacks). Gives 1 Momentum (after reading the stacks).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.cutDamage = multiplier of the cut; glyph.ticks = seconds of bleeding
--   glyph.spread = {range, percent}   the bleeding also starts on the enemies within `range` sqm of the target, with `percent`% per tick
local config = {damage = {0.5, 0.8}, ticks = 6, perPower = 0.08, levelDivisor = 20, doubleAt = 3}

function onCastSpell(cid, var)
	local target = Assassin.target(cid, 1)
	if(not target) then
		return false
	end

	local glyph = Assassin.glyph(cid, "bleeding cut")
	local ticks = glyph and glyph.ticks or config.ticks
	local perTick = math.max(1, math.floor(Assassin.power(cid) * config.perPower + getPlayerLevel(cid) / config.levelDivisor))
	if(Assassin.stacks(cid) >= config.doubleAt) then
		perTick = perTick * 2
	end

	Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_DRAWBLOOD, glyph and glyph.cutDamage)
	Assassin.fx("assassin_blood", target, {times = ticks})
	Assassin.bleed(cid, target, ticks, perTick)
	if(glyph and glyph.spread and isCreature(target)) then
		local spreadTick = math.max(1, math.floor(perTick * glyph.spread.percent / 100))
		for _, tid in ipairs(Assassin.enemiesAround(cid, getCreaturePosition(target), glyph.spread.range, target)) do
			Assassin.fx("assassin_blood", tid, {times = ticks})
			Assassin.bleed(cid, tid, ticks, spreadTick)
		end
	end

	Assassin.momentum(cid)
	return true
end
