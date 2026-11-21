-- Counts the kills of the player's active NPC task (registered on login as "TaskKill").
-- onKill runs once for each creature that damaged the monster, so a kill is remembered to avoid counting it twice.
local lastTarget = {}

function onKill(cid, target, damage, flags, war)
	if(not isPlayer(cid) or not isMonster(target) or lastTarget[cid] == target) then
		return true
	end

	-- summons of players do not count
	local master = getCreatureMaster(target)
	if(master and master ~= target) then
		return true
	end

	lastTarget[cid] = target
	Tasks.onKill(cid, getCreatureName(target))
	return true
end
