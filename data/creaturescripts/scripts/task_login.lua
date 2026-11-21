-- Registers the task kill counter and reminds the player of the active task.
function onLogin(cid)
	if(getPlayerAccountManager(cid) ~= MANAGER_NONE) then
		return true
	end

	registerCreatureEvent(cid, "TaskKill")

	local key, task, kills, done = Tasks.get(cid)
	if(key) then
		if(done) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Task: " .. task.name .. "s finished! Go back to the task NPC to get your reward.")
		else
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Task: " .. kills .. "/" .. task.kills .. " " .. task.name .. "s killed.")
		end
	end

	return true
end
