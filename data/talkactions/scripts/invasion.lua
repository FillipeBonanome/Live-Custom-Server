-- !invasion: shows the running invasion (or when the next ones come), the ranking, the server bonuses and the invasions available.
-- /invasion start [key|number|name] [boss], /invasion stop, /invasion list (staff). With no key /invasion start picks the invasion
-- of the average level of the players online. "boss" forces the boss wave. The commands are executed by the owner of the invasion within 2 seconds.
function onSay(cid, words, param, channel)
	if(not Invasions.isEnabled()) then
		doPlayerSendCancel(cid, "Invasions are disabled.")
		return true
	end

	if(words == "!invasion") then
		doPlayerPopupFYI(cid, Invasions.getStatusText(cid))
		return true
	end

	local command, argument = param:match("^(%S*)%s*(.-)%s*$")
	command = command:lower()

	if(command == "stop") then
		Invasions.sendCommand("stop", "", getCreatureName(cid))
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Command sent.")
		return true
	end

	if(command == "list") then
		local lines = {"Invasions (use /invasion start <key> [boss]):"}
		for index, def in ipairs(Invasions.list) do
			table.insert(lines, index .. ". " .. def.key .. " - " .. def.name .. " (tier " .. def.tierName .. ", level " .. def.minLevel .. "+, " .. #def.waves .. " waves, boss " .. (def.boss and def.boss.name or "none") .. ")")
		end

		doPlayerPopupFYI(cid, table.concat(lines, "\n"))
		return true
	end

	if(command == "start" or command == "") then
		local boss = ""
		local key = argument
		if(key:lower() == "boss") then
			boss, key = "boss", ""
		elseif(key:lower():match("%sboss$")) then
			boss, key = "boss", key:sub(1, #key - 5):gsub("%s+$", "")
		end

		Invasions.sendCommand("start", key, getCreatureName(cid), boss)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Command sent, the result comes in a few seconds.")
		return true
	end

	doPlayerSendCancel(cid, "Usage: /invasion start [key] [boss], /invasion stop, /invasion list.")
	return true
end
