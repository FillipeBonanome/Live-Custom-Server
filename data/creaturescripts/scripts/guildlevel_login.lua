-- Applies the guild bonus on login (the condition is not saved) and shows the guild level.
function onLogin(cid)
	if(getPlayerAccountManager(cid) ~= MANAGER_NONE or not GuildLevels.isEnabled()) then
		return true
	end

	local guildId = getPlayerGuildId(cid)
	local level = GuildLevels.sync(cid)
	if(guildId > 0) then
		local guildLevel = GuildLevels.getLevel(guildId)
		local text = "Guild " .. getPlayerGuildName(cid) .. " is level " .. guildLevel .. ". Use !guildinfo for details."
		if(guildLevel > 1 and level < 2) then
			text = text .. " Your bonus starts in " .. GuildLevels.formatTime(GuildLevels.getWaitLeft(cid)) .. "."
		end

		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
	end

	return true
end
