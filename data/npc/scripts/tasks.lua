local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- task key the player is being asked to accept
local talks = {}

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end

local function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	msg = msg:lower():trim()
	local key, task, kills, done = Tasks.get(cid)

	-- answering the offer
	if(talks[cid]) then
		local offered = talks[cid]
		if(msg == "yes") then
			talks[cid] = nil
			Tasks.start(cid, offered)
			local t = Tasks.list[offered]
			npcHandler:say("Task accepted! Kill {" .. t.kills .. " " .. t.name .. "s} and come back to receive your reward.", cid)
			return true
		elseif(msg == "no") then
			talks[cid] = nil
			npcHandler:say("Alright, nothing changed.", cid)
			return true
		end
	end

	-- finished task: deliver it
	-- (also when the player says the name of the creature of the finished task)
	if(done and (msg == "task" or msg == "reward" or msg == "finish" or msg == "done" or msg == "complete" or Tasks.find(msg) == key)) then
		talks[cid] = nil
		local ok, reason = Tasks.finish(cid)
		if(ok) then
			doSendMagicEffect(getCreaturePosition(cid), CONST_ME_FIREWORK_YELLOW)
			npcHandler:say("Well done! Here is your reward: " .. Tasks.rewardText(task.reward) .. ". Tell me another creature if you want a new task.", cid)
		else
			npcHandler:say(reason, cid)
		end

		return true
	end

	if(msg == "list" or msg == "tasks" or msg == "creatures" or msg == "monsters") then
		-- built from Tasks.order, split in several messages to keep each one short
		local part = "Available tasks:"
		for _, k in ipairs(Tasks.order) do
			local entry = " {" .. Tasks.list[k].name .. "},"
			if(#part + #entry > 200) then
				npcHandler:say(part, cid)
				part = ""
			end

			part = part .. entry
		end

		npcHandler:say(part:sub(1, -2) .. ".", cid)
		return true
	end

	if(msg == "status" or msg == "progress" or msg == "task") then
		if(not key) then
			npcHandler:say("You have no task. Tell me the name of a creature, or say {list} to see all of them.", cid)
		elseif(done) then
			npcHandler:say("You finished the task of " .. task.name .. "s! Say {reward} to receive " .. Tasks.rewardText(task.reward) .. ".", cid)
		else
			npcHandler:say("Your task: kill " .. task.kills .. " " .. task.name .. "s. Progress: " .. kills .. "/" .. task.kills .. ".", cid)
		end

		return true
	end

	local newKey, newTask = Tasks.find(msg)
	if(not newKey) then
		return false
	end

	if(key == newKey and not done) then
		npcHandler:say("You are already hunting " .. task.name .. "s (" .. kills .. "/" .. task.kills .. ").", cid)
		return true
	end

	talks[cid] = newKey
	local text = "Do you want to start the task: {kill " .. newTask.kills .. " " .. newTask.name .. "s} for the reward of {" .. Tasks.rewardText(newTask.reward) .. "}? {yes} or {no}."
	if(key) then
		text = text .. " WARNING: your current task (" .. task.name .. "s, " .. (done and "finished, reward not delivered" or (kills .. "/" .. task.kills)) .. ") will be reset if you accept this one!"
	end

	npcHandler:say(text, cid)
	return true
end

local function onFarewell(cid)
	talks[cid] = nil
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_FAREWELL, onFarewell)
npcHandler:addModule(FocusModule:new())
