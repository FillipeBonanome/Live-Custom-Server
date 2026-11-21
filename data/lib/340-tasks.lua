-- Kill tasks given by NPCs (see data/npc/scripts/tasks.lua). A player has only ONE task at a time: taking another
-- one resets the old one. The progress is kept in player storages (saved with the player), so relogging keeps it.
-- Every kill of the creature shows a blue message with the progress; when it is complete the player is told to
-- return to the NPC to get the reward.
--
-- To add a task: add an entry to Tasks.list AND append its key at the end of Tasks.order (the position is the
-- numeric id saved in the storage, so never reorder or remove entries).
-- reward = {type = "gold"|"experience"|"item", amount = N, itemid = ID, label = "text for items"}

Tasks = {
	-- storages: task id (position in Tasks.order), kills done and whether it is finished (1)
	storageTask = 54000,
	storageKills = 54001,
	storageDone = 54002,

	order = {"rotworm", "cyclops", "dragon", "giant spider", "bog raider", "demon", "dwarf", "minotaur", "elf scout", "tortoise", "sibang", "lizard templar", "pirate cutthroat", "blue djinn", "quara mantassin", "mutated bat", "vampire bride", "hydra", "dragon lord", "frost dragon", "hellfire fighter", "behemoth", "warlock", "infernalist", "medusa"},

	-- keys are the creature names in lower case
	list = {
		["rotworm"] = {name = "Rotworm", kills = 100, reward = {type = "experience", amount = 4000}},
		["cyclops"] = {name = "Cyclops", kills = 150, reward = {type = "gold", amount = 8000}},
		["dragon"] = {name = "Dragon", kills = 200, reward = {type = "experience", amount = 40000}},
		["giant spider"] = {name = "Giant Spider", kills = 150, reward = {type = "item", itemid = 2268, amount = 100, label = "Sudden Death Runes"}},
		["bog raider"] = {name = "Bog Raider", kills = 200, reward = {type = "gold", amount = 40000}},
		["demon"] = {name = "Demon", kills = 400, reward = {type = "experience", amount = 300000}},
		["dwarf"] = {name = "Dwarf", kills = 200, reward = {type = "gold", amount = 2500}},
		["minotaur"] = {name = "Minotaur", kills = 200, reward = {type = "gold", amount = 3000}},
		["elf scout"] = {name = "Elf Scout", kills = 200, reward = {type = "gold", amount = 4000}},
		["tortoise"] = {name = "Tortoise", kills = 200, reward = {type = "experience", amount = 5000}},
		["sibang"] = {name = "Sibang", kills = 200, reward = {type = "gold", amount = 6000}},
		["lizard templar"] = {name = "Lizard Templar", kills = 200, reward = {type = "experience", amount = 6000}},
		["pirate cutthroat"] = {name = "Pirate Cutthroat", kills = 200, reward = {type = "gold", amount = 9000}},
		["blue djinn"] = {name = "Blue Djinn", kills = 200, reward = {type = "experience", amount = 11000}},
		["quara mantassin"] = {name = "Quara Mantassin", kills = 150, reward = {type = "gold", amount = 15000}},
		["mutated bat"] = {name = "Mutated Bat", kills = 150, reward = {type = "experience", amount = 25000}},
		["vampire bride"] = {name = "Vampire Bride", kills = 100, reward = {type = "gold", amount = 30000}},
		["hydra"] = {name = "Hydra", kills = 100, reward = {type = "experience", amount = 50000}},
		["dragon lord"] = {name = "Dragon Lord", kills = 100, reward = {type = "gold", amount = 60000}},
		["frost dragon"] = {name = "Frost Dragon", kills = 100, reward = {type = "experience", amount = 60000}},
		["hellfire fighter"] = {name = "Hellfire Fighter", kills = 100, reward = {type = "gold", amount = 60000}},
		["behemoth"] = {name = "Behemoth", kills = 100, reward = {type = "experience", amount = 70000}},
		["warlock"] = {name = "Warlock", kills = 80, reward = {type = "gold", amount = 80000}},
		["infernalist"] = {name = "Infernalist", kills = 80, reward = {type = "experience", amount = 100000}},
		["medusa"] = {name = "Medusa", kills = 80, reward = {type = "gold", amount = 100000}}
	}
}

-- task by what the player said (case insensitive; the plural "s" is accepted: "rotworms", "dragons")
function Tasks.find(text)
	text = text:lower():trim()
	if(Tasks.list[text]) then
		return text, Tasks.list[text]
	end

	local singular = text:sub(1, -2)
	if(text:sub(-1) == "s" and Tasks.list[singular]) then
		return singular, Tasks.list[singular]
	end

	return nil
end

function Tasks.rewardText(reward)
	if(reward.type == "gold") then
		return reward.amount .. " gold coins"
	elseif(reward.type == "experience") then
		return reward.amount .. " experience points"
	end

	return reward.amount .. "x " .. (reward.label or "items")
end

local function keyToId(key)
	for i, k in ipairs(Tasks.order) do
		if(k == key) then
			return i
		end
	end
end

-- active task of the player: key, task, kills done, finished (boolean); nil if there is none
function Tasks.get(cid)
	local key = Tasks.order[getPlayerStorageValue(cid, Tasks.storageTask)]
	if(not key or not Tasks.list[key]) then
		return nil
	end

	return key, Tasks.list[key], math.max(0, getPlayerStorageValue(cid, Tasks.storageKills)), getPlayerStorageValue(cid, Tasks.storageDone) == 1
end

-- starts a task (the previous one, if any, is lost)
function Tasks.start(cid, key)
	doPlayerSetStorageValue(cid, Tasks.storageTask, keyToId(key))
	doPlayerSetStorageValue(cid, Tasks.storageKills, 0)
	doPlayerSetStorageValue(cid, Tasks.storageDone, 0)
end

function Tasks.clear(cid)
	doPlayerSetStorageValue(cid, Tasks.storageTask, -1)
	doPlayerSetStorageValue(cid, Tasks.storageKills, -1)
	doPlayerSetStorageValue(cid, Tasks.storageDone, -1)
end

-- gives the reward and ends the task; false + reason if it could not be given
function Tasks.finish(cid)
	local key, task, kills, done = Tasks.get(cid)
	if(not key or not done) then
		return false, "You have no finished task."
	end

	local reward = task.reward
	if(reward.type == "gold") then
		doPlayerAddMoney(cid, reward.amount)
	elseif(reward.type == "experience") then
		doPlayerAddExperience(cid, reward.amount)
	else
		local item = doCreateItemEx(reward.itemid, reward.amount)
		if(doPlayerAddItemEx(cid, item, false) ~= RETURNVALUE_NOERROR) then
			return false, "You do not have room (or capacity) for the reward. Make some space and talk to me again."
		end
	end

	Tasks.clear(cid)
	return true
end

-- called for each monster killed by the player
function Tasks.onKill(cid, monsterName)
	local key, task, kills, done = Tasks.get(cid)
	if(not key or done or monsterName:lower() ~= key) then
		return
	end

	kills = kills + 1
	doPlayerSetStorageValue(cid, Tasks.storageKills, kills)
	if(kills >= task.kills) then
		doPlayerSetStorageValue(cid, Tasks.storageDone, 1)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Task completed: " .. task.kills .. "/" .. task.kills ..
			" " .. task.name .. "s killed. Go back to the task NPC to get your reward!")
	else
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Task: " .. kills .. "/" .. task.kills .. " " .. task.name .. "s killed.")
	end
end
