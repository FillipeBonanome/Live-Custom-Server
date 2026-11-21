-- Kill tasks given by NPCs (see data/npc/scripts/tasks.lua). A player has only ONE task at a time: taking another
-- one resets the old one. The progress is kept in player storages (saved with the player), so relogging keeps it.
-- Every kill of the creature shows a blue message with the progress; when it is complete the player is told to
-- return to the NPC to get the reward.
--
-- TASK POINTS: finishing a task gives task points (the amount depends on the tier of the task). The total of points
-- unlocks the next tiers (Tasks.tiers[n].required) and gives the player a rank. Tasks are repeatable, so the points
-- can be farmed; the points are never spent.
--
-- To add a task: add an entry to Tasks.list AND append its key at the end of Tasks.order (the position is the
-- numeric id saved in the storage, so never reorder or remove entries). tier = index of Tasks.tiers.
-- reward = {type = "gold"|"experience"|"item", amount = N, itemid = ID, label = "text for items"}

Tasks = {
	-- storages: task id (position in Tasks.order), kills done, whether it is finished (1) and total task points
	storageTask = 54000,
	storageKills = 54001,
	storageDone = 54002,
	storagePoints = 54003,

	-- tiers: required = total task points to unlock the tasks of the tier, points = task points given by each task of it,
	-- rank = title of the player once the tier is unlocked
	tiers = {
		{rank = "Rookie Hunter", required = 0, points = 5},
		{rank = "Apprentice Hunter", required = 20, points = 8},
		{rank = "Adept Hunter", required = 60, points = 12},
		{rank = "Veteran Hunter", required = 120, points = 16},
		{rank = "Elite Hunter", required = 220, points = 22},
		{rank = "Master Hunter", required = 380, points = 30},
		{rank = "Legendary Hunter", required = 600, points = 40}
	},

	order = {"rotworm", "cyclops", "dragon", "giant spider", "bog raider", "demon", "dwarf", "minotaur", "elf scout", "tortoise", "sibang", "lizard templar", "pirate cutthroat", "blue djinn", "quara mantassin", "mutated bat", "vampire bride", "hydra", "dragon lord", "frost dragon", "hellfire fighter", "behemoth", "warlock", "infernalist", "medusa"},

	-- keys are the creature names in lower case
	list = {
		-- tier 1
		["rotworm"] = {name = "Rotworm", tier = 1, kills = 100, reward = {type = "experience", amount = 4000}},
		["dwarf"] = {name = "Dwarf", tier = 1, kills = 200, reward = {type = "gold", amount = 2500}},
		["minotaur"] = {name = "Minotaur", tier = 1, kills = 200, reward = {type = "gold", amount = 3000}},
		["elf scout"] = {name = "Elf Scout", tier = 1, kills = 200, reward = {type = "gold", amount = 4000}},
		-- tier 2
		["tortoise"] = {name = "Tortoise", tier = 2, kills = 200, reward = {type = "experience", amount = 5000}},
		["sibang"] = {name = "Sibang", tier = 2, kills = 200, reward = {type = "gold", amount = 6000}},
		["lizard templar"] = {name = "Lizard Templar", tier = 2, kills = 200, reward = {type = "experience", amount = 6000}},
		["cyclops"] = {name = "Cyclops", tier = 2, kills = 150, reward = {type = "gold", amount = 8000}},
		-- tier 3
		["pirate cutthroat"] = {name = "Pirate Cutthroat", tier = 3, kills = 200, reward = {type = "gold", amount = 9000}},
		["blue djinn"] = {name = "Blue Djinn", tier = 3, kills = 200, reward = {type = "experience", amount = 11000}},
		["giant spider"] = {name = "Giant Spider", tier = 3, kills = 150, reward = {type = "item", itemid = 2268, amount = 100, label = "Sudden Death Runes"}},
		["bog raider"] = {name = "Bog Raider", tier = 3, kills = 200, reward = {type = "gold", amount = 40000}},
		-- tier 4
		["quara mantassin"] = {name = "Quara Mantassin", tier = 4, kills = 150, reward = {type = "gold", amount = 15000}},
		["mutated bat"] = {name = "Mutated Bat", tier = 4, kills = 150, reward = {type = "experience", amount = 25000}},
		["vampire bride"] = {name = "Vampire Bride", tier = 4, kills = 100, reward = {type = "gold", amount = 30000}},
		-- tier 5
		["dragon"] = {name = "Dragon", tier = 5, kills = 200, reward = {type = "experience", amount = 40000}},
		["hydra"] = {name = "Hydra", tier = 5, kills = 100, reward = {type = "experience", amount = 50000}},
		["dragon lord"] = {name = "Dragon Lord", tier = 5, kills = 100, reward = {type = "gold", amount = 60000}},
		["frost dragon"] = {name = "Frost Dragon", tier = 5, kills = 100, reward = {type = "experience", amount = 60000}},
		-- tier 6
		["hellfire fighter"] = {name = "Hellfire Fighter", tier = 6, kills = 100, reward = {type = "gold", amount = 60000}},
		["behemoth"] = {name = "Behemoth", tier = 6, kills = 100, reward = {type = "experience", amount = 70000}},
		["warlock"] = {name = "Warlock", tier = 6, kills = 80, reward = {type = "gold", amount = 80000}},
		["infernalist"] = {name = "Infernalist", tier = 6, kills = 80, reward = {type = "experience", amount = 100000}},
		["medusa"] = {name = "Medusa", tier = 6, kills = 80, reward = {type = "gold", amount = 100000}},
		-- tier 7
		["demon"] = {name = "Demon", tier = 7, kills = 400, reward = {type = "experience", amount = 300000}}
	}
}

-- Task points -----------------------------------------------------------------------------------------------------

function Tasks.getPoints(cid)
	return math.max(0, getPlayerStorageValue(cid, Tasks.storagePoints))
end

-- highest tier unlocked with that amount of points
function Tasks.getTierByPoints(points)
	local tier = 1
	for i, t in ipairs(Tasks.tiers) do
		if(points >= t.required) then
			tier = i
		end
	end

	return tier
end

function Tasks.getRank(cid)
	return Tasks.tiers[Tasks.getTierByPoints(Tasks.getPoints(cid))].rank
end

-- points still missing for the next tier: points needed, name of the next rank (nil when it is the last tier)
function Tasks.getNextTier(cid)
	local next = Tasks.tiers[Tasks.getTierByPoints(Tasks.getPoints(cid)) + 1]
	if(not next) then
		return nil
	end

	return next.required - Tasks.getPoints(cid), next.rank
end

function Tasks.isUnlocked(cid, key)
	return Tasks.getPoints(cid) >= Tasks.tiers[Tasks.list[key].tier].required
end

-- Tasks ------------------------------------------------------------------------------------------------------------

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

-- gives the reward and the task points and ends the task.
-- Returns true, points received, new rank (nil if the rank did not change); or false + reason if it could not be given
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

	local oldTier = Tasks.getTierByPoints(Tasks.getPoints(cid))
	local points = Tasks.tiers[task.tier].points
	doPlayerSetStorageValue(cid, Tasks.storagePoints, Tasks.getPoints(cid) + points)
	Tasks.clear(cid)

	local newTier = Tasks.getTierByPoints(Tasks.getPoints(cid))
	return true, points, newTier > oldTier and Tasks.tiers[newTier].rank or nil
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
