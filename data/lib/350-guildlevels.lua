-- Guild levels: the members of a guild donate gold (Guild Treasurer NPC or !guilddonate) and the total donated gold
-- decides the level of the guild (1 to #GuildLevels.levels). Each level gives attribute bonuses to every online member
-- (CONDITION_ATTRIBUTES, like the race system but with another sub id).
--
-- Anti abuse: the bonus only works after the player stayed guildLevelJoinWait seconds in the current guild
-- (so entering a high level guild, taking the bonus and leaving does not work). The guild id and the time the player
-- joined it are kept in player storages and checked every 30 seconds (globalevent) and on login.
--
-- Tables (created automatically on startup, also in schemas/): guild_levels (total gold of each guild) and
-- guild_donations (gold donated by each player to each guild: used for the ranking of donors).
--
-- Options (config.lua): guildLevelsEnabled, guildLevelMinDonation, guildLevelJoinWait.

GuildLevels = {
	conditionSubId = 8201,
	storageGuild = 54100, -- guild the player was seen in
	storageSince = 54101, -- os.time() when the player was seen joining it

	-- gold needed to go from the previous level to this one; bonuses are the TOTAL bonus of the level (not cumulative).
	-- Bonus fields: experience (%), loot (%), health, mana, armor, defense, critical (% chance), leech (% life leech)
	levels = {
		{cost = 0, bonus = {}},
		{cost = 1000000, bonus = {experience = 2, health = 50}},
		{cost = 2000000, bonus = {experience = 3, loot = 2, health = 100, mana = 100}},
		{cost = 4000000, bonus = {experience = 4, loot = 3, health = 150, mana = 150, armor = 1}},
		{cost = 8000000, bonus = {experience = 5, loot = 4, health = 250, mana = 250, armor = 2, defense = 1}},
		{cost = 16000000, bonus = {experience = 6, loot = 5, health = 350, mana = 350, armor = 2, defense = 2, critical = 2}},
		{cost = 32000000, bonus = {experience = 7, loot = 6, health = 450, mana = 450, armor = 3, defense = 2, critical = 3}},
		{cost = 64000000, bonus = {experience = 8, loot = 7, health = 600, mana = 600, armor = 3, defense = 3, critical = 4, leech = 1}},
		{cost = 128000000, bonus = {experience = 9, loot = 8, health = 750, mana = 750, armor = 4, defense = 3, critical = 5, leech = 2}},
		{cost = 256000000, bonus = {experience = 10, loot = 10, health = 1000, mana = 1000, armor = 5, defense = 4, critical = 6, leech = 3}}
	},

	-- bonus field -> condition param, label
	fields = {
		{key = "experience", param = CONDITION_PARAM_EXPERIENCE, label = "% experience"},
		{key = "loot", param = CONDITION_PARAM_LOOT, label = "% loot"},
		{key = "health", param = CONDITION_PARAM_STAT_MAXHEALTH, label = " max health"},
		{key = "mana", param = CONDITION_PARAM_STAT_MAXMANA, label = " max mana"},
		{key = "armor", param = CONDITION_PARAM_ARMOR, label = " armor"},
		{key = "defense", param = CONDITION_PARAM_DEFENSE, label = " defense"},
		{key = "critical", param = CONDITION_PARAM_CRITICALCHANCE, label = "% critical chance"},
		{key = "leech", param = CONDITION_PARAM_LIFELEECH, label = "% life leech"}
	}
}

local function cfg(key, default)
	local value = getConfigValue(key)
	if(value == nil) then
		return default
	end

	return value
end

function GuildLevels.isEnabled()
	return getBooleanFromString(cfg('guildLevelsEnabled', true))
end

function GuildLevels.getMinDonation()
	return math.max(1, math.floor(cfg('guildLevelMinDonation', 10000)))
end

function GuildLevels.getJoinWait()
	return math.max(0, math.floor(cfg('guildLevelJoinWait', 86400)))
end

function GuildLevels.formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	if(hours > 0) then
		return hours .. "h " .. minutes .. "min"
	end

	return math.max(1, minutes) .. "min"
end

-- Database --------------------------------------------------------------------------------------------------------

local tablesReady = false

function GuildLevels.createTables()
	if(tablesReady) then
		return true
	end

	if(getConfigValue('sqlType') == "sqlite") then
		db.query("CREATE TABLE IF NOT EXISTS `guild_levels` (`guild_id` INTEGER NOT NULL PRIMARY KEY, `gold` BIGINT NOT NULL DEFAULT 0)")
		db.query("CREATE TABLE IF NOT EXISTS `guild_donations` (`guild_id` INTEGER NOT NULL, `player_id` INTEGER NOT NULL, `amount` BIGINT NOT NULL DEFAULT 0, UNIQUE (`guild_id`, `player_id`))")
	else
		db.query("CREATE TABLE IF NOT EXISTS `guild_levels` (`guild_id` INT UNSIGNED NOT NULL, `gold` BIGINT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY (`guild_id`)) ENGINE = InnoDB")
		db.query("CREATE TABLE IF NOT EXISTS `guild_donations` (`guild_id` INT UNSIGNED NOT NULL, `player_id` INT UNSIGNED NOT NULL, `amount` BIGINT UNSIGNED NOT NULL DEFAULT 0, UNIQUE (`guild_id`, `player_id`)) ENGINE = InnoDB")
	end

	tablesReady = true
	return true
end

-- total gold donated to the guild
function GuildLevels.getGold(guildId)
	GuildLevels.createTables()
	local res = db.storeQuery("SELECT `gold` FROM `guild_levels` WHERE `guild_id` = " .. guildId)
	if(not res) then
		return 0
	end

	local gold = result.getDataLong(res, "gold")
	result.free(res)
	return gold
end

-- gold donated by the player to the guild
function GuildLevels.getDonated(guildId, guid)
	GuildLevels.createTables()
	local res = db.storeQuery("SELECT `amount` FROM `guild_donations` WHERE `guild_id` = " .. guildId .. " AND `player_id` = " .. guid)
	if(not res) then
		return 0
	end

	local amount = result.getDataLong(res, "amount")
	result.free(res)
	return amount
end

-- {{name = "Player", amount = 123}, ...} sorted by amount
function GuildLevels.getTopDonors(guildId, limit)
	GuildLevels.createTables()
	local donors = {}
	local res = db.storeQuery("SELECT `p`.`name` AS `name`, `d`.`amount` AS `amount` FROM `guild_donations` `d` INNER JOIN `players` `p` ON `p`.`id` = `d`.`player_id` WHERE `d`.`guild_id` = " ..
		guildId .. " ORDER BY `d`.`amount` DESC LIMIT " .. (limit or 5))
	if(res) then
		repeat
			table.insert(donors, {name = result.getDataString(res, "name"), amount = result.getDataLong(res, "amount")})
		until not result.next(res)
		result.free(res)
	end

	return donors
end

local function addGold(guildId, guid, amount)
	GuildLevels.createTables()
	local res = db.storeQuery("SELECT `gold` FROM `guild_levels` WHERE `guild_id` = " .. guildId)
	if(res) then
		result.free(res)
		db.query("UPDATE `guild_levels` SET `gold` = `gold` + " .. amount .. " WHERE `guild_id` = " .. guildId)
	else
		db.query("INSERT INTO `guild_levels` (`guild_id`, `gold`) VALUES (" .. guildId .. ", " .. amount .. ")")
	end

	res = db.storeQuery("SELECT `amount` FROM `guild_donations` WHERE `guild_id` = " .. guildId .. " AND `player_id` = " .. guid)
	if(res) then
		result.free(res)
		db.query("UPDATE `guild_donations` SET `amount` = `amount` + " .. amount .. " WHERE `guild_id` = " .. guildId .. " AND `player_id` = " .. guid)
	else
		db.query("INSERT INTO `guild_donations` (`guild_id`, `player_id`, `amount`) VALUES (" .. guildId .. ", " .. guid .. ", " .. amount .. ")")
	end
end

-- Levels ----------------------------------------------------------------------------------------------------------

-- level of a guild with that total of gold donated
function GuildLevels.getLevelByGold(gold)
	local level, needed = 1, 0
	for i = 2, #GuildLevels.levels do
		needed = needed + GuildLevels.levels[i].cost
		if(gold >= needed) then
			level = i
		else
			break
		end
	end

	return level
end

-- gold still missing for the next level (nil if the guild is already at the maximum level)
function GuildLevels.getMissingGold(gold)
	local level = GuildLevels.getLevelByGold(gold)
	if(level >= #GuildLevels.levels) then
		return nil
	end

	local needed = 0
	for i = 2, level + 1 do
		needed = needed + GuildLevels.levels[i].cost
	end

	return needed - gold
end

function GuildLevels.getLevel(guildId)
	return GuildLevels.getLevelByGold(GuildLevels.getGold(guildId))
end

function GuildLevels.describeBonus(level)
	local bonus = GuildLevels.levels[level] and GuildLevels.levels[level].bonus or {}
	local parts = {}
	for _, field in ipairs(GuildLevels.fields) do
		if(bonus[field.key]) then
			table.insert(parts, "+" .. bonus[field.key] .. field.label)
		end
	end

	return #parts > 0 and table.concat(parts, ", ") or "no bonus"
end

-- Bonus ------------------------------------------------------------------------------------------------------------

-- state already applied to each player (cid): avoids re-adding the condition every check
local applied = {}

-- seconds the player still has to wait in the guild to get the bonus (0 = already active)
function GuildLevels.getWaitLeft(cid)
	local since = tonumber(getPlayerStorageValue(cid, GuildLevels.storageSince)) or 0
	return math.max(0, since + GuildLevels.getJoinWait() - os.time())
end

local function removeBonus(cid)
	doRemoveCondition(cid, CONDITION_ATTRIBUTES, GuildLevels.conditionSubId)
end

local function addBonus(cid, level)
	local bonus = GuildLevels.levels[level] and GuildLevels.levels[level].bonus
	if(not bonus or next(bonus) == nil) then
		return
	end

	local condition = createConditionObject(CONDITION_ATTRIBUTES)
	setConditionParam(condition, CONDITION_PARAM_TICKS, -1)
	setConditionParam(condition, CONDITION_PARAM_SUBID, GuildLevels.conditionSubId)
	for _, field in ipairs(GuildLevels.fields) do
		if(bonus[field.key]) then
			setConditionParam(condition, field.param, bonus[field.key])
		end
	end

	doAddCondition(cid, condition)
end

-- Keeps the guild/join time storages up to date and applies or removes the bonus of a player. Returns the level
-- the bonus applied is for (0 when there is no bonus: no guild, disabled or still waiting).
function GuildLevels.sync(cid)
	local guildId = getPlayerGuildId(cid)
	if(not GuildLevels.isEnabled()) then
		guildId = 0
	end

	-- join time
	if(guildId ~= (tonumber(getPlayerStorageValue(cid, GuildLevels.storageGuild)) or 0)) then
		doPlayerSetStorageValue(cid, GuildLevels.storageGuild, guildId)
		doPlayerSetStorageValue(cid, GuildLevels.storageSince, os.time())
	end

	local level = 0
	if(guildId > 0 and GuildLevels.getWaitLeft(cid) == 0) then
		level = GuildLevels.getLevel(guildId)
	end

	local state = guildId .. ":" .. level
	if(applied[cid] ~= state) then
		removeBonus(cid)
		if(level > 1) then
			addBonus(cid, level)
		end

		applied[cid] = state
	end

	return level
end

-- forgets the players that are not online anymore
function GuildLevels.cleanup()
	local online = {}
	for _, cid in ipairs(getPlayersOnline()) do
		online[cid] = true
	end

	for cid in pairs(applied) do
		if(not online[cid]) then
			applied[cid] = nil
		end
	end
end

function GuildLevels.syncAll()
	GuildLevels.cleanup()
	for _, cid in ipairs(getPlayersOnline()) do
		GuildLevels.sync(cid)
	end
end

-- Donations -------------------------------------------------------------------------------------------------------

local function messageGuild(guildId, text)
	for _, cid in ipairs(getPlayersOnline()) do
		if(getPlayerGuildId(cid) == guildId) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
		end
	end
end

-- donates gold of the player to his guild: true + new level, or false + reason
function GuildLevels.donate(cid, amount)
	if(not GuildLevels.isEnabled()) then
		return false, "The guild levels are disabled."
	end

	local guildId = getPlayerGuildId(cid)
	if(guildId == 0) then
		return false, "You are not in a guild."
	end

	amount = math.floor(tonumber(amount) or 0)
	if(amount < GuildLevels.getMinDonation()) then
		return false, "The minimum donation is " .. GuildLevels.getMinDonation() .. " gold coins."
	end

	local gold = GuildLevels.getGold(guildId)
	local maxLevel = #GuildLevels.levels
	local oldLevel = GuildLevels.getLevelByGold(gold)
	if(oldLevel >= maxLevel) then
		return false, "Your guild is already at the maximum level."
	end

	-- never take more gold than what is needed to reach the maximum level
	local missingTotal = 0
	for i = 2, maxLevel do
		missingTotal = missingTotal + GuildLevels.levels[i].cost
	end

	amount = math.min(amount, missingTotal - gold)
	if(getPlayerMoney(cid) < amount) then
		return false, "You do not have " .. amount .. " gold coins."
	end

	if(not doPlayerRemoveMoney(cid, amount)) then
		return false, "You do not have " .. amount .. " gold coins."
	end

	addGold(guildId, getPlayerGUID(cid), amount)
	local newLevel = GuildLevels.getLevelByGold(gold + amount)

	messageGuild(guildId, getCreatureName(cid) .. " donated " .. amount .. " gold coins to the guild.")
	if(newLevel > oldLevel) then
		messageGuild(guildId, "Your guild reached level " .. newLevel .. "! Bonus: " .. GuildLevels.describeBonus(newLevel) ..
			((GuildLevels.getJoinWait() > 0) and (" (members who joined less than " .. GuildLevels.formatTime(GuildLevels.getJoinWait()) .. " ago get it later)") or ""))
		GuildLevels.syncAll()
	end

	return true, newLevel, amount
end

-- Info ------------------------------------------------------------------------------------------------------------

-- text lines about the guild of the player
function GuildLevels.getInfoLines(cid)
	local guildId = getPlayerGuildId(cid)
	if(guildId == 0) then
		return {"You are not in a guild."}
	end

	local gold = GuildLevels.getGold(guildId)
	local level = GuildLevels.getLevelByGold(gold)
	local maxLevel = #GuildLevels.levels
	local lines = {"Guild " .. getPlayerGuildName(cid) .. ": level " .. level .. "/" .. maxLevel .. " (" .. gold .. " gold donated)."}
	table.insert(lines, "Bonus of the level: " .. GuildLevels.describeBonus(level) .. ".")

	local missing = GuildLevels.getMissingGold(gold)
	if(missing) then
		table.insert(lines, "Next level: " .. missing .. " gold missing. It gives " .. GuildLevels.describeBonus(level + 1) .. ".")
	else
		table.insert(lines, "The guild reached the maximum level!")
	end

	local wait = GuildLevels.getWaitLeft(cid)
	if(level > 1 and wait > 0) then
		table.insert(lines, "Your bonus starts in " .. GuildLevels.formatTime(wait) .. " (time needed in the guild).")
	end

	local donors = GuildLevels.getTopDonors(guildId, 5)
	if(#donors > 0) then
		local entries = {}
		for i, donor in ipairs(donors) do
			table.insert(entries, i .. ". " .. donor.name .. " (" .. donor.amount .. ")")
		end

		table.insert(lines, "Top donors: " .. table.concat(entries, ", ") .. ".")
	end

	table.insert(lines, "You donated " .. GuildLevels.getDonated(guildId, getPlayerGUID(cid)) .. " gold. Use !guilddonate amount or talk to the Guild Treasurer.")
	return lines
end
