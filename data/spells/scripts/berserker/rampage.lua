-- Rampage: 4 fast blows in 1.2s in 1 target within 2 SQM (power x 0.45 to 0.65 each). Costs 8% of the max health (healthpercent in spells.xml). Gives 1 Fury.
local config = {damage = {0.45, 0.65}, blows = 4, interval = 400, range = 2}

function onCastSpell(cid, var)
	local target = Berserker.target(cid, 1)
	if(not target) then
		return false
	end

	local function blow(left)
		if(not isCreature(cid) or not isCreature(target) or getCreatureHealth(target) <= 0) then
			return
		end

		if(getDistanceBetween(getCreaturePosition(cid), getCreaturePosition(target)) <= config.range) then
			Berserker.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_HITAREA)
		end

		if(left > 1) then
			addEvent(blow, config.interval, left - 1)
		end
	end

	blow(config.blows)
	Berserker.fury(cid)
	return true
end
