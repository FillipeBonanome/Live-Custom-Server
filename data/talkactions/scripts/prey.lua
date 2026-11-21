-- !prey: shows the active prey and how much time is left. Everything else is done with the Prey Master NPC.
function onSay(cid, words, param, channel)
	if(not Prey.isEnabled()) then
		doPlayerSendCancel(cid, "The prey system is disabled.")
		return true
	end

	local prey = Prey.get(cid)
	if(prey) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Prey: " .. Prey.describe(prey))
	else
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You have no active prey. Talk to the Prey Master to get one.")
	end

	return true
end
