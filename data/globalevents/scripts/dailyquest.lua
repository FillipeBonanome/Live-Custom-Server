-- Warns the online players when the daily contracts are reset (the contracts themselves are renewed
-- the first time they are read after the reset hour, see data/lib/300-dailyquests.lua).
local lastDay

function onThink(interval, lastExecution)
	local today = DailyQuest.getDayKey()
	if(lastDay and lastDay ~= today and DailyQuest.isEnabled()) then
		for _, cid in ipairs(getPlayersOnline()) do
			local lines = {"Your daily contracts were renewed:"}
			for _, line in ipairs(DailyQuest.getSummaryLines(cid)) do
				table.insert(lines, line)
			end

			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, table.concat(lines, "\n"))
		end
	end

	lastDay = today
	return true
end
