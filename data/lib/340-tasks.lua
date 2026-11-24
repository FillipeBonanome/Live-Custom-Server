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

	order = {"rotworm", "cyclops", "dragon", "giant spider", "bog raider", "demon", "dwarf", "minotaur", "elf scout", "tortoise", "sibang", "lizard templar", "pirate cutthroat", "blue djinn", "quara mantassin", "mutated bat", "vampire bride", "hydra", "dragon lord", "frost dragon", "hellfire fighter", "behemoth", "warlock", "infernalist", "medusa", "carrion worm", "skeleton", "orc", "orc spearman", "orc warrior", "elf", "dwarf soldier", "dwarf guard", "minotaur archer", "minotaur guard", "amazon", "valkyrie", "witch", "ghoul", "cyclops drone", "cyclops smith", "elf arcanist", "crypt warrior", "bonebeast", "mummy", "ancient scarab", "damaged worker golem", "worker golem", "renegade knight", "lizard legionnaire", "skeleton elite warrior", "vampire", "werewolf", "lich", "war golem", "hero", "undead elite gladiator", "wyvern", "midnight asura", "blightwalker", "dark torturer", "hellspawn", "sea serpent", "wyrm", "massive earth elemental", "massive energy elemental", "massive fire elemental", "dawnfire asura", "vile grandmaster", "undead dragon", "ghastly dragon", "defiler", "destroyer", "draken warmaster", "grim reaper", "hellhound", "juggernaut", "trainer rotworm", "trainer minotaur", "trainer amazon", "trainer orc"},

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
		["giant spider"] = {name = "Giant Spider", tier = 3, kills = 150, reward = {type = "gold", amount = 25000}},
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
		["demon"] = {name = "Demon", tier = 7, kills = 400, reward = {type = "experience", amount = 300000}},
		-- Old Garrick's tasks (monsters of the Garrick hunting grounds, only offered by him)
		["carrion worm"] = {name = "Carrion Worm", tier = 1, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 3000}},
		["skeleton"] = {name = "Skeleton", tier = 1, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 4000}},
		["orc"] = {name = "Orc", tier = 1, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 3000}},
		["orc spearman"] = {name = "Orc Spearman", tier = 1, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 4000}},
		["orc warrior"] = {name = "Orc Warrior", tier = 1, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 3000}},
		["elf"] = {name = "Elf", tier = 1, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 4000}},
		["dwarf soldier"] = {name = "Dwarf Soldier", tier = 1, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 3000}},
		["dwarf guard"] = {name = "Dwarf Guard", tier = 1, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 4000}},
		["minotaur archer"] = {name = "Minotaur Archer", tier = 1, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 3000}},
		["minotaur guard"] = {name = "Minotaur Guard", tier = 1, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 4000}},
		["amazon"] = {name = "Amazon", tier = 1, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 3000}},
		["valkyrie"] = {name = "Valkyrie", tier = 1, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 4000}},
		["witch"] = {name = "Witch", tier = 1, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 3000}},
		["ghoul"] = {name = "Ghoul", tier = 1, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 4000}},
		["cyclops drone"] = {name = "Cyclops Drone", tier = 2, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 7000}},
		["cyclops smith"] = {name = "Cyclops Smith", tier = 2, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 8000}},
		["elf arcanist"] = {name = "Elf Arcanist", tier = 2, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 7000}},
		["crypt warrior"] = {name = "Crypt Warrior", tier = 2, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 8000}},
		["bonebeast"] = {name = "Bonebeast", tier = 2, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 7000}},
		["mummy"] = {name = "Mummy", tier = 2, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 8000}},
		["ancient scarab"] = {name = "Ancient Scarab", tier = 2, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 7000}},
		["damaged worker golem"] = {name = "Damaged Worker Golem", tier = 2, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 8000}},
		["worker golem"] = {name = "Worker Golem", tier = 2, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 7000}},
		["renegade knight"] = {name = "Renegade Knight", tier = 2, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 8000}},
		["lizard legionnaire"] = {name = "Lizard Legionnaire", tier = 2, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 7000}},
		["skeleton elite warrior"] = {name = "Skeleton Elite Warrior", tier = 2, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 8000}},
		["vampire"] = {name = "Vampire", tier = 3, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 12000}},
		["werewolf"] = {name = "Werewolf", tier = 3, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 16000}},
		["lich"] = {name = "Lich", tier = 3, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 12000}},
		["war golem"] = {name = "War Golem", tier = 3, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 16000}},
		["hero"] = {name = "Hero", tier = 3, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 12000}},
		["undead elite gladiator"] = {name = "Undead Elite Gladiator", tier = 3, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 16000}},
		["wyvern"] = {name = "Wyvern", tier = 3, kills = 150, exclusive = "garrick", reward = {type = "gold", amount = 12000}},
		["midnight asura"] = {name = "Midnight Asura", tier = 3, kills = 150, exclusive = "garrick", reward = {type = "experience", amount = 16000}},
		["blightwalker"] = {name = "Blightwalker", tier = 4, kills = 100, exclusive = "garrick", reward = {type = "gold", amount = 25000}},
		["dark torturer"] = {name = "Dark Torturer", tier = 4, kills = 100, exclusive = "garrick", reward = {type = "experience", amount = 35000}},
		["hellspawn"] = {name = "Hellspawn", tier = 4, kills = 100, exclusive = "garrick", reward = {type = "gold", amount = 25000}},
		["sea serpent"] = {name = "Sea Serpent", tier = 4, kills = 100, exclusive = "garrick", reward = {type = "experience", amount = 35000}},
		["wyrm"] = {name = "Wyrm", tier = 4, kills = 100, exclusive = "garrick", reward = {type = "gold", amount = 25000}},
		["massive earth elemental"] = {name = "Massive Earth Elemental", tier = 4, kills = 100, exclusive = "garrick", reward = {type = "experience", amount = 35000}},
		["massive energy elemental"] = {name = "Massive Energy Elemental", tier = 4, kills = 100, exclusive = "garrick", reward = {type = "gold", amount = 25000}},
		["massive fire elemental"] = {name = "Massive Fire Elemental", tier = 4, kills = 100, exclusive = "garrick", reward = {type = "experience", amount = 35000}},
		["dawnfire asura"] = {name = "Dawnfire Asura", tier = 4, kills = 100, exclusive = "garrick", reward = {type = "gold", amount = 25000}},
		["vile grandmaster"] = {name = "Vile Grandmaster", tier = 4, kills = 100, exclusive = "garrick", reward = {type = "experience", amount = 35000}},
		["undead dragon"] = {name = "Undead Dragon", tier = 5, kills = 100, exclusive = "garrick", reward = {type = "gold", amount = 50000}},
		["ghastly dragon"] = {name = "Ghastly Dragon", tier = 5, kills = 100, exclusive = "garrick", reward = {type = "experience", amount = 60000}},
		["defiler"] = {name = "Defiler", tier = 5, kills = 100, exclusive = "garrick", reward = {type = "gold", amount = 50000}},
		["destroyer"] = {name = "Destroyer", tier = 5, kills = 100, exclusive = "garrick", reward = {type = "experience", amount = 60000}},
		["draken warmaster"] = {name = "Draken Warmaster", tier = 5, kills = 100, exclusive = "garrick", reward = {type = "gold", amount = 50000}},
		["grim reaper"] = {name = "Grim Reaper", tier = 5, kills = 100, exclusive = "garrick", reward = {type = "experience", amount = 60000}},
		["hellhound"] = {name = "Hellhound", tier = 5, kills = 100, exclusive = "garrick", reward = {type = "gold", amount = 50000}},
		["juggernaut"] = {name = "Juggernaut", tier = 6, kills = 80, exclusive = "garrick", reward = {type = "gold", amount = 90000}},
		-- Training tasks of the Drillmaster NPC (see lib/341-training.lua). "monster" = creature that counts for the task,
		-- "once" = can be done only one time, reward "training" = minutes of training time
		["trainer rotworm"] = {name = "Rotworm", monster = "rotworm", tier = 1, kills = 100, exclusive = "trainer", once = true, reward = {type = "training", minutes = 15}},
		["trainer minotaur"] = {name = "Minotaur", monster = "minotaur", tier = 1, kills = 100, exclusive = "trainer", once = true, reward = {type = "training", minutes = 15}},
		["trainer amazon"] = {name = "Amazon", monster = "amazon", tier = 1, kills = 100, exclusive = "trainer", once = true, reward = {type = "training", minutes = 15}},
		["trainer orc"] = {name = "Orc", monster = "orc", tier = 1, kills = 100, exclusive = "trainer", once = true, reward = {type = "training", minutes = 15}}
	}
}

-- NPC that can offer the task (tasks with "exclusive" are offered only by that NPC; the others are offered by everyone
-- who lists them, see Tasks.npcShared)
Tasks.npcShared = {
	garrick = {"rotworm", "cyclops", "dragon", "giant spider", "bog raider", "demon", "dwarf", "minotaur", "elf scout", "hydra",
		"dragon lord", "frost dragon", "behemoth", "infernalist", "medusa"}
}

function Tasks.offeredBy(npc, key)
	local t = Tasks.list[key]
	if(t.exclusive) then
		return t.exclusive == npc
	end

	if(not npc) then
		return true
	end

	for _, k in ipairs(Tasks.npcShared[npc] or {}) do
		if(k == key) then
			return true
		end
	end

	return false
end

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
	elseif(reward.type == "training") then
		return reward.minutes .. " minutes of training time"
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
	elseif(reward.type == "training") then
		Training.addTime(cid, reward.minutes * 60)
		if(task.once) then
			doPlayerSetStorageValue(cid, Training.storageDone + keyToId(key), 1)
		end
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
	if(not key or done or monsterName:lower() ~= (task.monster or key)) then
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
