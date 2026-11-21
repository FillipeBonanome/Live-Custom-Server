-- !tasks: shows the active task, its progress, the task points and the rank of the player.
-- Everything else is done with the Task Master NPC.
function onSay(cid, words, param, channel)
	local lines = {}
	local key, task, kills, done = Tasks.get(cid)
	if(not key) then
		table.insert(lines, "Task: none. Talk to the Task Master to get one.")
	elseif(done) then
		table.insert(lines, "Task: " .. task.name .. "s - FINISHED! Go back to the Task Master to get " .. Tasks.rewardText(task.reward) .. " and " .. Tasks.tiers[task.tier].points .. " task points.")
	else
		table.insert(lines, "Task: kill " .. task.kills .. " " .. task.name .. "s - progress " .. kills .. "/" .. task.kills .. ". Reward: " ..
			Tasks.rewardText(task.reward) .. " and " .. Tasks.tiers[task.tier].points .. " task points.")
	end

	table.insert(lines, "Task points: " .. Tasks.getPoints(cid) .. " (rank: " .. Tasks.getRank(cid) .. ").")
	local missing, nextRank = Tasks.getNextTier(cid)
	if(missing) then
		table.insert(lines, "Next rank: " .. nextRank .. " in " .. missing .. " more points (unlocks new tasks).")
	else
		table.insert(lines, "You reached the highest rank!")
	end

	local unlocked = 0
	for _, k in ipairs(Tasks.order) do
		if(Tasks.isUnlocked(cid, k)) then
			unlocked = unlocked + 1
		end
	end

	table.insert(lines, "Unlocked tasks: " .. unlocked .. "/" .. #Tasks.order .. ".")
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, table.concat(lines, "\n"))
	return true
end
