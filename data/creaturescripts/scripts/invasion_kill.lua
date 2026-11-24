-- Sends the damage the player dealt to an invader to the invasion (registered on login as "InvasionKill").
-- onKill runs once for each creature that damaged the monster, with the damage it dealt. The invasion lives in the Lua state of the
-- globalevent, so the damage goes through the shared storage (see data/lib/390-invasions.lua).
function onKill(cid, target, damage, flags, war)
	if(damage > 0 and isPlayer(cid) and isMonster(target) and Invasions.isInvader(target)) then
		Invasions.push("D," .. getPlayerGUID(cid) .. "," .. getCreatureName(cid) .. "," .. target .. "," .. damage)
	end

	return true
end
