-- Daily quests (contracts): every day each player gets one "kill N monsters" contract per category
-- (experience and gold). Finishing one generates a harder one, up to dailyQuestMaxPerCategory per day.
-- Everything is saved in the `player_daily_quests` table, so relogging or restarting the server keeps the progress.
--
-- The numbers (kills, rewards, reset hour...) are in config.lua (dailyQuest* options).
-- The monster "level" does not exist in the monster files, so it is calculated from the health and the damage of the attacks of the
-- monster (data/lib/301-monsterlevel.lua; the old experience formula is only a fallback for monsters without damage information).
-- Use DailyQuest.monsterLevelOverrides to force the level of specific monsters and DailyQuest.blacklist to remove
-- monsters from the contracts.

DailyQuest = {
	-- tags used in the database and in the messages
	categories = {"experience", "gold"},
	labels = {experience = "Experience", gold = "Gold"},

	-- ["monster name"] = level (names in lower case)
	monsterLevelOverrides = {},

	-- Only these monsters (the ones with a respawn in the teleport room, floors 9 and 10) can be chosen for contracts,
	-- rewarded creatures and prey. Names in lower case. Set to nil to use every hostile monster again.
	allowedMonsters = {
		"amazon", "ancient scarab", "behemoth", "blightwalker", "bog raider", "bonebeast", "carrion worm", "crypt warrior", "cyclops",
		"cyclops drone", "cyclops smith", "damaged worker golem", "dark torturer", "dawnfire asura", "defiler", "demon", "destroyer",
		"dragon", "dragon lord", "draken warmaster", "dwarf", "dwarf guard", "dwarf soldier", "elf", "elf arcanist", "elf scout",
		"frost dragon", "ghastly dragon", "ghoul", "giant spider", "grim reaper", "hellhound", "hellspawn", "hero", "hydra",
		"infernalist", "juggernaut", "lich", "lizard legionnaire", "massive earth elemental", "massive energy elemental",
		"massive fire elemental", "medusa", "midnight asura", "minotaur", "minotaur archer", "minotaur guard", "mummy", "orc",
		"orc spearman", "orc warrior", "renegade knight", "rotworm", "sea serpent", "skeleton", "skeleton elite warrior",
		"undead dragon", "undead elite gladiator", "valkyrie", "vampire", "vile grandmaster", "war golem", "werewolf", "witch",
		"worker golem", "wyrm", "wyvern"
	},

	-- ["monster name"] = true (names in lower case): never chosen for a contract
	blacklist = {}
}

local TOLERANCE = 0.15 -- the monster level must be within +-15% of the level wanted for the contract

local function cfg(key, default)
	local value = getConfigValue(key)
	if(value == nil) then
		return default
	end

	return value
end

function DailyQuest.isEnabled()
	return getBooleanFromString(cfg('dailyQuestsEnabled', true))
end

function DailyQuest.getMaxPerCategory()
	return math.max(1, math.floor(cfg('dailyQuestMaxPerCategory', 5)))
end

-- "2026-11-21" style key (as a number, 20261121) of the current daily quest day: it only changes at the reset hour
function DailyQuest.getDayKey()
	return tonumber(os.date("%Y%m%d", os.time() - cfg('dailyQuestResetHour', 5) * 3600))
end

-- seconds until the next reset
function DailyQuest.getSecondsToReset()
	local now = os.time()
	local d = os.date("*t", now)
	local reset = os.time({year = d.year, month = d.month, day = d.day, hour = cfg('dailyQuestResetHour', 5), min = 0, sec = 0})
	if(now >= reset) then
		reset = os.time({year = d.year, month = d.month, day = d.day + 1, hour = cfg('dailyQuestResetHour', 5), min = 0, sec = 0})
	end

	return reset - now
end

function DailyQuest.formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	if(hours > 0) then
		return hours .. "h " .. minutes .. "min"
	end

	return math.max(1, minutes) .. "min"
end

-- Monsters --------------------------------------------------------------------------------------------------------

-- Level of a monster: DailyQuest.monsterLevelOverrides, then the hardcoded table (MonsterLevels, data/lib/302-monsterlevels.lua), then the
-- formula (monster = one entry of getMonsterList(); without it only the experience is used). Prey, rewarded creatures and the contracts use it.
function DailyQuest.getMonsterLevel(name, experience, monster)
	local override = DailyQuest.monsterLevelOverrides[name:lower()]
	if(override) then
		return override
	end

	return MonsterLevel.get(name, monster, experience)
end

-- true if the monster (lower case name) can be used; always true when allowedMonsters is nil
local allowedSet
function DailyQuest.isAllowed(key)
	if(not DailyQuest.allowedMonsters) then
		return true
	end

	if(not allowedSet) then
		allowedSet = {}
		for _, name in ipairs(DailyQuest.allowedMonsters) do
			allowedSet[name] = true
		end
	end

	return allowedSet[key] == true
end

local monsterCache

-- all monsters that can be used in a contract, sorted by level: {{name = "Dragon", level = 51, experience = 700, health = 1000, damagePerSecond = .., burst = .., maxHit = ..}, ...}
-- (hostile, attackable and with experience; cached until the lib is reloaded)
function DailyQuest.getMonsters()
	if(monsterCache) then
		return monsterCache
	end

	monsterCache = {}
	if(not getMonsterList) then
		print("[Warning - DailyQuest] getMonsterList() not found, the server needs to be recompiled.")
		return monsterCache
	end

	local seen = {}
	for _, monster in ipairs(getMonsterList()) do
		local key = monster.name:lower()
		if(monster.hostile and monster.attackable and monster.experience > 0 and not DailyQuest.blacklist[key] and not seen[key] and DailyQuest.isAllowed(key)) then
			seen[key] = true
			table.insert(monsterCache, {name = monster.name, level = DailyQuest.getMonsterLevel(monster.name, monster.experience, monster), experience = monster.experience,
				health = monster.healthMax, damagePerSecond = monster.damagePerSecond, burst = monster.burst, maxHit = monster.maxHit})
		end
	end

	table.sort(monsterCache, function(a, b)
		if(a.level ~= b.level) then
			return a.level < b.level
		end

		return a.name < b.name
	end)

	return monsterCache
end

-- Database --------------------------------------------------------------------------------------------------------

local function loadRow(guid, category)
	local res = db.storeQuery("SELECT `day`, `completed`, `monster`, `monster_level`, `required`, `kills`, `reward` FROM `player_daily_quests` WHERE `player_id` = " .. guid .. " AND `category` = " .. db.escapeString(category))
	if(not res) then
		return nil
	end

	local row = {
		exists = true,
		day = result.getDataInt(res, "day"),
		completed = result.getDataInt(res, "completed"),
		monster = result.getDataString(res, "monster"),
		monsterLevel = result.getDataInt(res, "monster_level"),
		required = result.getDataInt(res, "required"),
		kills = result.getDataInt(res, "kills"),
		reward = result.getDataLong(res, "reward")
	}

	result.free(res)
	return row
end

local function saveRow(guid, category, row)
	local fields = {row.day, row.completed, db.escapeString(row.monster), row.monsterLevel, row.required, row.kills, string.format("%d", row.reward)}
	if(row.exists) then
		db.query("UPDATE `player_daily_quests` SET `day` = " .. fields[1] .. ", `completed` = " .. fields[2] .. ", `monster` = " .. fields[3] .. ", `monster_level` = " .. fields[4] .. ", `required` = " .. fields[5] .. ", `kills` = " .. fields[6] .. ", `reward` = " .. fields[7] .. " WHERE `player_id` = " .. guid .. " AND `category` = " .. db.escapeString(category))
	else
		db.query("INSERT INTO `player_daily_quests` (`player_id`, `category`, `day`, `completed`, `monster`, `monster_level`, `required`, `kills`, `reward`) VALUES (" .. guid .. ", " .. db.escapeString(category) .. ", " .. table.concat(fields, ", ") .. ")")
		row.exists = true
	end
end

-- Generation ------------------------------------------------------------------------------------------------------

local function otherCategory(category)
	return category == "experience" and "gold" or "experience"
end

-- Creates the contract number (row.completed + 1) of the category; row.monster is "" when there is no monster to use.
-- The monster is never the one of the contract in progress in the other category, and it must be stronger than the
-- one of the previous contract.
local function generate(cid, guid, category, row)
	local previousLevel = row.monsterLevel
	local previousName = row.monster

	local exclude = {}
	if(previousName ~= "") then
		exclude[previousName:lower()] = true
	end

	local other = loadRow(guid, otherCategory(category))
	if(other and other.day == DailyQuest.getDayKey() and other.monster ~= "") then
		exclude[other.monster:lower()] = true
	end

	local target = getPlayerLevel(cid) * (cfg('dailyQuestBaseLevelFactor', 0.5) + row.completed * cfg('dailyQuestLevelStep', 0.1))

	local pool = {}
	for _, monster in ipairs(DailyQuest.getMonsters()) do
		if(not exclude[monster.name:lower()]) then
			table.insert(pool, monster)
		end
	end

	-- it has to be harder than the last one (when row.completed is 0 there is no previous level)
	local harder = {}
	for _, monster in ipairs(pool) do
		if(row.completed == 0 or monster.level > previousLevel) then
			table.insert(harder, monster)
		end
	end

	if(#harder > 0) then
		pool = harder
	end

	local candidates = {}
	for _, monster in ipairs(pool) do
		if(monster.level >= target * (1 - TOLERANCE) and monster.level <= target * (1 + TOLERANCE)) then
			table.insert(candidates, monster)
		end
	end

	if(#candidates == 0) then
		-- nothing in range: the 3 monsters closest to the wanted level
		table.sort(pool, function(a, b) return math.abs(a.level - target) < math.abs(b.level - target) end)
		for i = 1, math.min(3, #pool) do
			table.insert(candidates, pool[i])
		end
	end

	row.kills = 0
	if(#candidates == 0) then
		row.monster, row.monsterLevel, row.required, row.reward = "", 0, 0, 0
		return
	end

	local monster = candidates[math.random(#candidates)]
	local minKills = math.max(1, math.floor(cfg('dailyQuestMinKills', 50)))
	local maxKills = math.max(minKills, math.floor(cfg('dailyQuestMaxKills', 100)))
	local perLevel = category == "experience" and cfg('dailyQuestExpPerKillLevel', 5) or cfg('dailyQuestGoldPerKillLevel', 10)

	row.monster = monster.name
	row.monsterLevel = monster.level
	row.required = math.random(minKills, maxKills)
	row.reward = math.floor(row.required * monster.level * perLevel * (1 + row.completed * cfg('dailyQuestTierBonus', 0.25)))
end

-- Returns the contract of the player in the category, resetting/generating it when needed:
-- {completed, monster ("" = nothing left today), monsterLevel, required, kills, reward}
function DailyQuest.getContract(cid, category)
	local guid = getPlayerGUID(cid)
	local today = DailyQuest.getDayKey()
	local row = loadRow(guid, category)
	local changed = false

	if(not row) then
		row = {exists = false, day = today, completed = 0, monster = "", monsterLevel = 0, required = 0, kills = 0, reward = 0}
		changed = true
	elseif(row.day ~= today) then
		row.day, row.completed, row.monster, row.monsterLevel, row.required, row.kills, row.reward = today, 0, "", 0, 0, 0, 0
		changed = true
	end

	if(row.completed < DailyQuest.getMaxPerCategory() and row.monster == "") then
		generate(cid, guid, category, row)
		changed = true
	end

	if(changed) then
		saveRow(guid, category, row)
	end

	return row
end

-- Adds a kill of `monsterName` to the contracts of the player. Returns true when any contract was updated.
function DailyQuest.onMonsterKilled(cid, monsterName)
	if(not DailyQuest.isEnabled()) then
		return false
	end

	local guid, updated = getPlayerGUID(cid), false
	for _, category in ipairs(DailyQuest.categories) do
		local row = DailyQuest.getContract(cid, category)
		if(row.monster ~= "" and row.monster:lower() == monsterName:lower()) then
			updated = true
			row.kills = row.kills + 1
			if(row.kills < row.required) then
				saveRow(guid, category, row)
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "[Daily Quest] " .. row.monster .. ": " .. row.kills .. "/" .. row.required .. " killed, " .. (row.required - row.kills) .. " remaining.")
			else
				DailyQuest.complete(cid, guid, category, row)
			end
		end
	end

	return updated
end

function DailyQuest.complete(cid, guid, category, row)
	local reward, monster = row.reward, row.monster
	local text
	if(category == "experience") then
		doPlayerAddExperience(cid, reward)
		text = reward .. " experience"
	else
		doPlayerAddMoney(cid, reward)
		text = reward .. " gold coins"
	end

	row.completed = row.completed + 1
	if(row.completed < DailyQuest.getMaxPerCategory()) then
		-- generate() reads the monster/level of the finished contract to make the next one different and harder
		generate(cid, guid, category, row)
	else
		row.monster, row.monsterLevel, row.required, row.kills, row.reward = "", 0, 0, 0, 0
	end

	saveRow(guid, category, row)

	local max = DailyQuest.getMaxPerCategory()
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "[Daily Quest] " .. DailyQuest.labels[category] .. " contract completed (" .. monster .. ")! Reward: " .. text .. ". Contracts done today: " .. row.completed .. "/" .. max .. ".")
	if(row.monster ~= "") then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "[Daily Quest] New " .. DailyQuest.labels[category]:lower() .. " contract: kill " .. row.required .. " " .. row.monster .. " (level " .. row.monsterLevel .. ", reward " .. row.reward .. (category == "experience" and " experience" or " gold coins") .. ").")
	else
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "[Daily Quest] You finished all " .. DailyQuest.labels[category]:lower() .. " contracts of today. New ones in " .. DailyQuest.formatTime(DailyQuest.getSecondsToReset()) .. ".")
	end

	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_FIREWORK_YELLOW)
end

-- Text -------------------------------------------------------------------------------------------------------------

-- one line per category, e.g. "Experience (1/5): Dragon (lv 51) 12/75 - reward 19125 experience"
function DailyQuest.getSummaryLines(cid)
	local lines, max = {}, DailyQuest.getMaxPerCategory()
	for _, category in ipairs(DailyQuest.categories) do
		local row = DailyQuest.getContract(cid, category)
		local line = DailyQuest.labels[category] .. " (" .. row.completed .. "/" .. max .. " done): "
		if(row.monster ~= "") then
			line = line .. row.monster .. " (level " .. row.monsterLevel .. ") " .. row.kills .. "/" .. row.required .. " - reward " .. row.reward .. (category == "experience" and " experience" or " gold coins")
		else
			line = line .. "all contracts finished today"
		end

		table.insert(lines, line)
	end

	return lines
end

-- the complete text of the !daily command
function DailyQuest.getDescription(cid)
	local max = DailyQuest.getMaxPerCategory()
	local text = "Daily contracts\n\nKill the monster of the contract the amount of times shown to receive the reward. Finishing a contract generates a harder one (up to " .. max .. " per category each day). A monster is never used by both categories at the same time.\n"
	for _, category in ipairs(DailyQuest.categories) do
		local row = DailyQuest.getContract(cid, category)
		text = text .. "\n[" .. DailyQuest.labels[category] .. "] done today: " .. row.completed .. "/" .. max .. "\n"
		if(row.monster ~= "") then
			text = text .. "  Monster: " .. row.monster .. " (level " .. row.monsterLevel .. ")\n"
			text = text .. "  Progress: " .. row.kills .. "/" .. row.required .. " (" .. (row.required - row.kills) .. " remaining)\n"
			text = text .. "  Reward: " .. row.reward .. (category == "experience" and " experience" or " gold coins") .. "\n"
		else
			text = text .. "  All contracts of today are finished.\n"
		end
	end

	return text .. "\nNew contracts in " .. DailyQuest.formatTime(DailyQuest.getSecondsToReset()) .. " (reset at " .. string.format("%02d", cfg('dailyQuestResetHour', 5)) .. ":00)."
end
