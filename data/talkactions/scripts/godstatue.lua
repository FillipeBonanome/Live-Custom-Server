-- /godstatue god      places the statue of the god in front of you (saved, recreated on startup)
-- /godstatue remove   removes the statue in front of you
-- /godstatue list     lists the gods
function onSay(cid, words, param, channel)
	param = param:lower():trim()
	if(param == "" or param == "list") then
		local names = {}
		for _, god in ipairs(Gods.list) do
			table.insert(names, god.key .. " (" .. god.domain .. ")")
		end

		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Usage: /godstatue god | remove. Gods: " .. table.concat(names, ", ") .. ".")
		return true
	end

	local pos = getPosByDir(getCreaturePosition(cid), getCreatureLookDirection(cid))
	if(param == "remove") then
		if(Gods.removeStatue(pos)) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Statue removed.")
		else
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "There is no statue of a god in front of you.")
		end

		return true
	end

	local ok, result = Gods.addStatue(param, pos)
	if(ok) then
		doSendMagicEffect(pos, CONST_ME_TELEPORT)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Statue of " .. result.name .. " placed (action id " .. result.actionId .. ").")
	else
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, result)
	end

	return true
end
