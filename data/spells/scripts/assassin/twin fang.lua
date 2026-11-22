-- Twin Fang: two cuts in a row in 1 adjacent target (power x 0.55 to 0.9 each, +25% when dual wielding). Gives 1 Momentum.
local config = {damage = {0.55, 0.9}, dualBonus = 1.25, delay = 300}

function onCastSpell(cid, var)
	local target = Assassin.target(cid, 1)
	if(not target) then
		return false
	end

	local multiplier = Assassin.isDual(cid) and config.dualBonus or 1
	Assassin.fx("assassin_twin", target, {from = getCreaturePosition(cid)})
	Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_HITAREA, multiplier)
	addEvent(function()
		if(isCreature(cid) and isCreature(target) and getDistanceBetween(getCreaturePosition(cid), getCreaturePosition(target)) <= 2) then
			Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_HITAREA, multiplier)
		end
	end, config.delay)

	Assassin.momentum(cid)
	return true
end
