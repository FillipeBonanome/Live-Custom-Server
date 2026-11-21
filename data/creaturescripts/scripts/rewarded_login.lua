-- Sends the rewarded creatures to the player on login (after the welcome message and the daily quests).
function onLogin(cid)
	if(getPlayerAccountManager(cid) ~= MANAGER_NONE) then
		return true
	end

	RewardedMonsters.send(cid)
	return true
end
