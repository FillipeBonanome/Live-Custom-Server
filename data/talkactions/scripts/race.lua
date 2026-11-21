-- !race Name (god only)
-- Changes your own race at any time. Example: !race Orc
function onSay(cid, words, param, channel)
	param = param:trim()
	local index = getRaceByName(param)
	if(not index) then
		local names = {}
		for _, race in ipairs(RACES) do
			table.insert(names, race.name)
		end

		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Usage: !race name. Races: " .. table.concat(names, ", ") .. ".")
		return true
	end

	doPlayerSetRace(cid, index)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Your race is now " .. RACES[index].name .. ".")
	return true
end
