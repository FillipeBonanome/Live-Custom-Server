-- Shows the main server commands (blue message) every time a character logs in.
-- Edit the list below to add/remove commands.
local commands = {
	{"!bestiary <monster>", "shows what you know about a creature (no name: explains the bestiary)"},
	{"!trackbestiary on/off", "shows your kills progress, e.g. Rotworm [766/1000], on every kill"},
	{"!online", "lists the players online"},
	{"!frags", "shows your frags"},
	{"!serverinfo", "shows the server rates and information"},
	{"!uptime", "shows how long the server has been online"},
	{"/commands", "lists every command available to you"}
}

function onLogin(cid)
	if(getPlayerAccountManager(cid) ~= MANAGER_NONE) then
		return true
	end

	local lines = {"Main commands:"}
	for _, command in ipairs(commands) do
		table.insert(lines, command[1] .. " - " .. command[2])
	end

	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, table.concat(lines, "\n"))

	return true
end
