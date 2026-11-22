-- Backstab: heavy cut (power x 2.6 to 3.6) that only works when you are behind the target (it must be looking away from you).
-- Shadow Step puts you behind the target and makes it look away for about 3s, so the two spells combo. Gives 1 Momentum.
local config = {damage = {2.6, 3.6}}

function onCastSpell(cid, var)
	local target = Assassin.target(cid, 1)
	if(not target) then
		return false
	end

	if(not Assassin.isBehind(cid, target)) then
		doPlayerSendCancel(cid, "You must be behind your target.")
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
		return false
	end

	Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_DRAWBLOOD)
	Assassin.momentum(cid)
	return true
end
