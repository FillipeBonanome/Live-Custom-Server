-- Stone Strike: the basic attack of the Geomancer. A stone hits one target (range 3), power x 0.9 to 1.3.
-- With a gem in the ammo slot half of the damage becomes the element of the gem (see data/lib/378-geomancer.lua).
local config = {damage = {0.9, 1.3}, range = 3}

function onCastSpell(cid, var)
	local target = Geomancer.target(cid, config.range)
	if(not target) then
		return false
	end

	local to = getCreaturePosition(target)
	doSendDistanceShoot(getCreaturePosition(cid), to, CONST_ANI_SMALLSTONE)
	doSendMagicEffect(to, CONST_ME_STONES)
	Geomancer.hit(cid, target, config.damage[1], config.damage[2])
	return true
end
