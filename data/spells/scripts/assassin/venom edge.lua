-- Venom Edge: poison cut in 1 adjacent target (power x 0.5 to 0.8) that poisons it for 8s (12% of the damage of the cut per second) and
-- gives the Venom Blade buff (basic attacks deal +12% extra poison damage for 8s). Gives 1 Momentum.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.poison   = {multiplier, ticks}   the poison hits `multiplier` times harder and lasts `ticks` seconds
--   glyph.paralyze = {percent, duration}   slows the target
--   glyph.resist   = {percent, duration}   lowers the earth resistance of the monster (before the hit)
local config = {damage = {0.5, 0.8}, ticks = 8}

function onCastSpell(cid, var)
	local target = Assassin.target(cid, 1)
	if(not target) then
		return false
	end

	local glyph = Assassin.glyph(cid, "venom edge")
	if(glyph and glyph.resist) then
		Glyphs.reduceResistance(target, COMBAT_EARTHDAMAGE, glyph.resist.percent, glyph.resist.duration)
	end

	Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_EARTHDAMAGE, CONST_ME_HITBYPOISON)
	if(isCreature(target)) then
		local poison = glyph and glyph.poison
		doTargetCombatCondition(cid, target, Assassin.poison(cid, poison and poison.ticks or config.ticks, poison and poison.multiplier, config.damage[1], config.damage[2]), CONST_ME_NONE)
		Assassin.fx("assassin_poison", target)
		if(glyph and glyph.paralyze) then
			Glyphs.paralyze(cid, target, glyph.paralyze.percent, glyph.paralyze.duration)
		end
	end

	Assassin.addBuff(cid, "venom_blade")
	Assassin.momentum(cid)
	return true
end
