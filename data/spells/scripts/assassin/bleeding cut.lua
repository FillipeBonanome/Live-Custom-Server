-- Bleeding Cut: cut in 1 adjacent target (power x 0.5 to 0.8) that makes it bleed for 6s (physical damage once a second:
-- power x 0.08 + level/20, doubled with 3 or more Momentum stacks). Gives 1 Momentum (after reading the stacks).
local config = {damage = {0.5, 0.8}, ticks = 6, perPower = 0.08, levelDivisor = 20, doubleAt = 3}

function onCastSpell(cid, var)
	local target = Assassin.target(cid, 1)
	if(not target) then
		return false
	end

	local perTick = math.max(1, math.floor(Assassin.power(cid) * config.perPower + getPlayerLevel(cid) / config.levelDivisor))
	if(Assassin.stacks(cid) >= config.doubleAt) then
		perTick = perTick * 2
	end

	Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_DRAWBLOOD)
	Assassin.fx("assassin_blood", target, {times = config.ticks})
	Assassin.bleed(cid, target, config.ticks, perTick)
	Assassin.momentum(cid)
	return true
end
