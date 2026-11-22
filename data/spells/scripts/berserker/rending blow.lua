-- Rending Blow: heavy hit in 1 adjacent target (power x 1.2 to 1.8) that makes it bleed for 6s (physical damage once a second:
-- power x 0.08 + level/20). Costs 5% of the max health (healthpercent in spells.xml). Gives 1 Fury.
local config = {damage = {1.2, 1.8}, ticks = 6, perPower = 0.08, levelDivisor = 20}

function onCastSpell(cid, var)
	local target = Berserker.target(cid, 1)
	if(not target) then
		return false
	end

	local perTick = math.max(1, math.floor(Berserker.power(cid) * config.perPower + getPlayerLevel(cid) / config.levelDivisor))
	Berserker.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_DRAWBLOOD)
	Berserker.bleed(cid, target, config.ticks, perTick)
	Berserker.fury(cid)
	return true
end
