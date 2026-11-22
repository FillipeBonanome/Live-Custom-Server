-- Deathblow: huge cut (power x 4.5 to 6.0) that only works on a target with less than 25% of its health.
-- Spends the Momentum stacks: +20% damage for each one.
local config = {damage = {4.5, 6.0}, maxHealth = 0.25, perStack = 0.20}

function onCastSpell(cid, var)
	local target = Assassin.target(cid, 1)
	if(not target) then
		return false
	end

	if(getCreatureHealth(target) >= getCreatureMaxHealth(target) * config.maxHealth) then
		doPlayerSendCancel(cid, "Your target must have less than 25% of its health.")
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
		return false
	end

	local multiplier = 1 + config.perStack * Assassin.consume(cid)
	Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_MORTAREA, multiplier)
	return true
end
