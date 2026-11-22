-- Execute: finisher in 1 adjacent target (power x 1.6 to 2.4), x1.75 when the target has less than 30% of its health.
-- Spends the Momentum stacks: +20% damage for each one. The knife lands 0.4s after the cast.
local config = {damage = {1.6, 2.4}, lowHealth = 0.30, lowHealthBonus = 1.75, perStack = 0.20, delay = 400}

function onCastSpell(cid, var)
	local target = Assassin.target(cid, 1)
	if(not target) then
		return false
	end

	local multiplier = 1 + config.perStack * Assassin.consume(cid)
	Assassin.fx("assassin_execute", target, {from = getCreaturePosition(cid)})
	addEvent(function()
		if(isCreature(cid) and isCreature(target)) then
			local finisher = multiplier
			if(getCreatureHealth(target) < getCreatureMaxHealth(target) * config.lowHealth) then
				finisher = finisher * config.lowHealthBonus
			end

			Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_EXPLOSIONHIT, finisher)
		end
	end, config.delay)

	return true
end
