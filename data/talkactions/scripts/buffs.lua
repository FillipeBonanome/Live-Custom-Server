-- !buffs
-- Lists the active buffs of the player: name, stacks, time left and description.
function onSay(cid, words, param, channel)
	local buffs = getCreatureBuffs(cid)
	if(not buffs) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You have no active buffs.")
		return true
	end

	local list = {}
	for _, buff in pairs(buffs) do
		table.insert(list, buff)
	end

	table.sort(list, function(a, b) return a.timeLeft < b.timeLeft end)

	local lines = {}
	for _, buff in ipairs(list) do
		table.insert(lines, buff.name .. (buff.stacks > 1 and " x" .. buff.stacks or "") .. " - " .. Buffs.formatTime(buff.timeLeft) .. " left")
		if(buff.description ~= "") then
			table.insert(lines, "    " .. buff.description)
		end

		table.insert(lines, "")
	end

	doShowTextDialog(cid, 2160, "Active buffs (" .. #list .. "):\n\n" .. table.concat(lines, "\n"))
	return true
end
