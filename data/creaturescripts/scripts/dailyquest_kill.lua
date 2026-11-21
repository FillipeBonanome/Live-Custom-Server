-- Counts the monsters killed for the daily contracts (registered on login as "DailyQuestKill").
-- onKill runs once for each creature that damaged the monster (and for the owner of summons), so a kill is
-- remembered to avoid counting it twice for the same player.
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
	DailyQuest.onMonsterKilled(cid, getCreatureName(target))
	return true
end
