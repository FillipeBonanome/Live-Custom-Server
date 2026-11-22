-- Pillar of the daily login (action id DailyLogin.actionId, see data/lib/380-dailylogin.lua).
function onUse(cid, item, fromPosition, itemEx, toPosition)
	local ok, streak, description = DailyLogin.claim(cid)
	if(not ok) then
		doPlayerSendCancel(cid, streak)
		doSendMagicEffect(getThingPos(cid), CONST_ME_POFF)
		return true
	end

	doSendMagicEffect(getThingPos(cid), CONST_ME_FIREWORK_YELLOW)
	doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "Daily login! Streak: " .. streak .. " day(s). Reward: " .. description .. ".")

	local size = #DailyLogin.rewards
	local nextReward = DailyLogin.describeReward(cid, streak + 1)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Come back tomorrow to keep the streak (day " .. (((streak) % size) + 1) .. "/" .. size .. "): " .. nextReward .. ".")
	return true
end
