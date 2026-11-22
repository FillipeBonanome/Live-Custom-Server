-- Players lose their buffs when they leave the game or die. The buff list is shared through a creature storage
-- (data/lib/370-buffs.lua), so it is cleaned here; the buffs' own callbacks run in the Lua state of the spell that gave them.
function onLogout(cid)
	clearCreatureBuffs(cid)
	return true
end

function onDeath(cid, corpse, lastHitKiller, mostDamageKiller)
	clearCreatureBuffs(cid)
	return true
end

-- leftovers of a crash (the storage is saved with the player)
function onLogin(cid)
	clearCreatureBuffs(cid)
	return true
end
