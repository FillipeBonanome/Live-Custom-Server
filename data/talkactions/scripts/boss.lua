-- /boss (staff): shows the bosses within 12 sqm: state of the state machine, last ability used and health (read from the creature storage MonsterAI.storage.state).
function onSay(cid, words, param, channel)
	local pos = getCreaturePosition(cid)
	local lines = {}
	for _, uid in ipairs(getSpectators(pos, 12, 12, false) or {}) do
		if(isMonster(uid)) then
			local raw = getCreatureStorage(uid, MonsterAI.storage.state)
			if(type(raw) == "string" and raw:sub(1, 2) == "B:") then
				local state, last = raw:sub(3):match("^([^|]*)|(.*)$")
				table.insert(lines, getCreatureName(uid) .. ": state " .. tostring(state) .. ", last ability " .. tostring(last) .. ", health " .. getCreatureHealth(uid) .. "/" .. getCreatureMaxHealth(uid))
			end
		end
	end

	if(#lines == 0) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "No boss within 12 sqm.")
	else
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, table.concat(lines, "\n"))
	end

	return true
end
