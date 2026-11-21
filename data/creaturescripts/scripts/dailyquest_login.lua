-- Registers the daily quest kill counter and shows the player's daily contracts on login.
function onLogin(cid)
	if(getPlayerAccountManager(cid) ~= MANAGER_NONE) then
		return true
	end

	registerCreatureEvent(cid, "DailyQuestKill")

	if(DailyQuest.isEnabled()) then
		local lines = {"Daily contracts (use !daily for details):"}
		for _, line in ipairs(DailyQuest.getSummaryLines(cid)) do
			table.insert(lines, line)
		end

		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, table.concat(lines, "\n"))
	end

	return true
end
