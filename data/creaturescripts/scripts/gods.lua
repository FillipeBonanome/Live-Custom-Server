-- Blessings of the gods (data/lib/400-gods.lua): they survive a logout, so they are given back on login (after BuffsLogin cleared the
-- buffs), and they are lost on death.
function onLogin(cid)
	if(getPlayerAccountManager(cid) ~= MANAGER_NONE) then
		return true
	end

	Gods.restore(cid)
	return true
end

function onDeath(cid, corpse, lastHitKiller, mostDamageKiller)
	Gods.clear(cid)
	return true
end
