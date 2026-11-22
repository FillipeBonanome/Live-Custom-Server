-- Buffs are kept in memory only, so they end (running onRemove) when the player leaves the game or dies.
function onLogout(cid)
	Buffs.removeAll(cid, "logout")
	return true
end

function onDeath(cid, corpse, lastHitKiller, mostDamageKiller)
	Buffs.removeAll(cid, "death")
	return true
end
