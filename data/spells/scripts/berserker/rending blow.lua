-- Rending Blow: heavy hit in 1 adjacent target (power x 1.2 to 1.8) that makes it bleed for 6s (physical damage once a second:
-- power x 0.08 + level/20). Costs 5% of the max health (healthpercent in spells.xml). Gives 1 Fury.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.bleed  = {ticks, multiplier}  longer bleeding (ticks of 1s) and the damage of each tick times `multiplier`
--   glyph.resist = {percent, duration}  the monster loses physical resistance before the hit
local config = {damage = {1.2, 1.8}, ticks = 6, perPower = 0.08, levelDivisor = 20}

function onCastSpell(cid, var)
	local target = Berserker.target(cid, 1)
	if(not target) then
		return false
	end

	local glyph = Berserker.glyph(cid, "rending blow")
	local ticks = (glyph and glyph.bleed and glyph.bleed.ticks) or config.ticks
	local multiplier = (glyph and glyph.bleed and glyph.bleed.multiplier) or 1
	local perTick = math.max(1, math.floor((Berserker.power(cid) * config.perPower + getPlayerLevel(cid) / config.levelDivisor) * multiplier))

	if(glyph and glyph.resist) then
		Glyphs.reduceResistance(target, COMBAT_PHYSICALDAMAGE, glyph.resist.percent, glyph.resist.duration)
	end

	Berserker.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_DRAWBLOOD)
	Berserker.bleed(cid, target, ticks, perTick)
	Berserker.fury(cid)
	return true
end
