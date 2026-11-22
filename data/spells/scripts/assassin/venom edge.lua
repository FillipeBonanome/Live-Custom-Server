-- Venom Edge: poison cut in 1 adjacent target (power x 0.5 to 0.8) that poisons it for 8s (level/20 + power/20 per second) and
-- gives the Venom Blade buff (basic attacks deal +12% extra poison damage for 8s). Gives 1 Momentum.
local config = {damage = {0.5, 0.8}, ticks = 8}

function onCastSpell(cid, var)
	local target = Assassin.target(cid, 1)
	if(not target) then
		return false
	end

	Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_EARTHDAMAGE, CONST_ME_HITBYPOISON)
	if(isCreature(target)) then
		doTargetCombatCondition(cid, target, Assassin.poison(cid, config.ticks), CONST_ME_NONE)
		Assassin.fx("assassin_poison", target)
	end

	Assassin.addBuff(cid, "venom_blade")
	Assassin.momentum(cid)
	return true
end
