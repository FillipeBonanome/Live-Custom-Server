-- Quick Slash: fast melee cut in 1 adjacent target (power x 0.7 to 1.1). The main (spam) spell of the Assassin; gives 1 Momentum.
local config = {damage = {0.7, 1.1}}

function onCastSpell(cid, var)
	local target = Assassin.target(cid, 1)
	if(not target) then
		return false
	end

	local from, to = getCreaturePosition(cid), getCreaturePosition(target)
	Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE)
	Assassin.fx("assassin_slash", target, {direction = getDirectionTo(from, to)})
	Assassin.momentum(cid)
	return true
end
