-- Reminds the player of the daily login reward (and the current streak) on login.
function onLogin(cid)
	if(getPlayerAccountManager(cid) ~= MANAGER_NONE or not DailyLogin.isEnabled()) then
		return true
	end

	if(DailyLogin.canClaim(cid)) then
		local streak = DailyLogin.getNextStreak(cid)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Daily login available! Use the pillar at the temple to claim day " .. streak ..
			" of your streak: " .. DailyLogin.describeReward(cid, streak) .. ".")
	end

	return true
end
