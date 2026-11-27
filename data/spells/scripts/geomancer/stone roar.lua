-- Stone Roar: a roar that shakes the ground. Every enemy within 4 tiles takes a little damage (power x 0.3 to 0.5) and every monster is forced
-- to attack you (challenge). Players are not challenged.
local config = {damage = {0.3, 0.5}, radius = 4}

function onCastSpell(cid, var)
	local enemies = Attacks.around(cid, getCreaturePosition(cid), config.radius)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_GROUNDSHAKER)

	for _, tid in ipairs(enemies) do
		if(isMonster(tid)) then
			doChallengeCreature(cid, tid)
		end

		Geomancer.hit(cid, tid, config.damage[1], config.damage[2], {effect = CONST_ME_BLOCKHIT})
	end

	return true
end
