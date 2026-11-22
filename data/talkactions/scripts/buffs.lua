-- !buffs
-- Lists the active buffs of the player: name, category, time left and description.
function onSay(cid, words, param, channel)
	local buffs = Buffs.getAll(cid)
	if(#buffs == 0) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You have no active buffs.")
		return true
	end

	local lines = {}
	for _, buff in ipairs(buffs) do
		table.insert(lines, buff.name .. " [" .. buff.category .. "] - " .. Buffs.formatTime(buff.timeLeft) .. " left")
		if(buff.description ~= "") then
			table.insert(lines, "    " .. buff.description)
		end

		table.insert(lines, "")
	end

	doShowTextDialog(cid, 2160, "Active buffs (" .. #buffs .. "):\n\n" .. table.concat(lines, "\n"))
	return true
end
