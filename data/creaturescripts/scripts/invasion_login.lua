-- Registers the invasion score counter and warns the player about the running invasion and the server bonuses.
function onLogin(cid)
	if(getPlayerAccountManager(cid) ~= MANAGER_NONE) then
		return true
	end

	registerCreatureEvent(cid, "InvasionKill")

	local status = Invasions.readStatus()
	if(status) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "[Invasion] " .. status.name .. " is in progress! Wave " .. status.wave .. "/" .. status.waves ..
			", " .. status.alive .. " invaders alive, " .. Invasions.formatTime(status.endsAt - os.time()) .. " left. Use !invasion for details.")
	end

	local prelude = Invasions.readPrelude()
	if(prelude) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "[Invasion] An invasion is coming in " .. Invasions.formatTime(prelude.startsAt - os.time()) .. "!")
	end

	for _, line in ipairs(Invasions.getBonusLines()) do
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "[Invasion] Server bonus: " .. line .. ".")
	end

	return true
end
