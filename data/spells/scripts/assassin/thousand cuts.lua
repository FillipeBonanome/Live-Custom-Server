-- Thousand Cuts (Nightblade): 8 cuts in 2.4s in 1 target within 2 SQM (power x 0.35 to 0.55 each).
-- Spends the Momentum stacks: +10% damage for each one.
local config = {damage = {0.35, 0.55}, cuts = 8, interval = 300, perStack = 0.10, range = 2}

function onCastSpell(cid, var)
	local target = Assassin.target(cid, config.range)
	if(not target) then
		return false
	end

	local multiplier = 1 + config.perStack * Assassin.consume(cid)
	Assassin.fx("assassin_cuts", target, {from = getCreaturePosition(cid)})

	local function cut(left)
		if(not isCreature(cid) or not isCreature(target) or getCreatureHealth(target) <= 0) then
			return
		end

		if(getDistanceBetween(getCreaturePosition(cid), getCreaturePosition(target)) <= config.range + 1) then
			Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_HITAREA, multiplier)
		end

		if(left > 1) then
			addEvent(cut, config.interval, left - 1)
		end
	end

	cut(config.cuts)
	return true
end
