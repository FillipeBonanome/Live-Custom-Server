-- Re-applies the active prey of the player on login (it is kept in the player_prey table).
function onLogin(cid)
	if(getPlayerAccountManager(cid) ~= MANAGER_NONE) then
		return true
	end

	if(Prey.isEnabled() and Prey.load(cid)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Prey: " .. Prey.describe(Prey.get(cid)))
	end

	return true
end
