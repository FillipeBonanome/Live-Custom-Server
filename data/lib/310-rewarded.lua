-- Rewarded creatures: every time the server starts a percent of the monsters is drawn to give a bonus of
-- experience and another percent to give a loot bonus (a monster can be in both categories, but never twice in the same one).
-- The bonuses are applied by the source (see src/rewarded.cpp); this lib draws the monsters and builds the texts.
-- The monster pool and levels are the ones of the daily quests (data/lib/300-dailyquests.lua).
-- Options (config.lua): rewardedMonstersEnabled, rewardedMonstersPercent, rewardedMonstersExperienceBonus,
-- rewardedMonstersLootBonus.

RewardedMonsters = {
	categories = {"experience", "loot"},
	labels = {experience = "Experience", loot = "Loot"},
	-- max size of each message sent to the player (long lists are split in several messages)
	messageLength = 200
}

local function cfg(key, default)
	local value = getConfigValue(key)
	if(value == nil) then
		return default
	end

	return value
end

function RewardedMonsters.isEnabled()
	return getBooleanFromString(cfg('rewardedMonstersEnabled', true))
end

local function getBonusConfig(category)
	if(category == "experience") then
		return cfg('rewardedMonstersExperienceBonus', 20)
	end

	return cfg('rewardedMonstersLootBonus', 20)
end

-- Draws the monsters of each category (call once, when the server starts)
function RewardedMonsters.roll()
	if(not RewardedMonsters.isEnabled() or not setRewardedMonsters) then
		return false
	end

	math.randomseed(os.time())
	local pool = DailyQuest.getMonsters()
	local count = math.floor(#pool * cfg('rewardedMonstersPercent', 5) / 100)
	if(count < 1 and #pool > 0 and cfg('rewardedMonstersPercent', 5) > 0) then
		count = 1
	end

	for _, category in ipairs(RewardedMonsters.categories) do
		-- partial Fisher-Yates over a copy: each monster can only be drawn once per category
		local copy = {}
		for i, monster in ipairs(pool) do
			copy[i] = monster.name
		end

		local chosen = {}
		for i = 1, math.min(count, #copy) do
			local j = math.random(i, #copy)
			copy[i], copy[j] = copy[j], copy[i]
			table.insert(chosen, copy[i])
		end

		setRewardedMonsters(category, getBonusConfig(category), chosen)
	end

	return true
end

-- {bonus = percent, monsters = {{name = "Dragon", level = 50}, ...}} sorted by level
function RewardedMonsters.getList(category)
	local data = getRewardedMonsters and getRewardedMonsters(category)
	local list = {bonus = data and data.bonus or 0, monsters = {}}
	if(not data) then
		return list
	end

	local levels = {}
	for _, monster in ipairs(DailyQuest.getMonsters()) do
		levels[monster.name:lower()] = {name = monster.name, level = monster.level}
	end

	for _, name in ipairs(data.monsters) do
		table.insert(list.monsters, levels[name:lower()] or {name = name, level = DailyQuest.getMonsterLevel(name, 1)})
	end

	table.sort(list.monsters, function(a, b)
		if(a.level ~= b.level) then
			return a.level < b.level
		end

		return a.name < b.name
	end)

	return list
end

-- messages of a category: "Experience (+20%): Dragon [Lv 50], Demon [Lv 184], ..." (split when too long)
function RewardedMonsters.getMessages(category)
	local list = RewardedMonsters.getList(category)
	local header = RewardedMonsters.labels[category] .. " (+" .. list.bonus .. "%): "
	local messages, current = {}, header
	if(#list.monsters == 0) then
		return {header .. "none"}
	end

	for i, monster in ipairs(list.monsters) do
		local entry = monster.name .. " [Lv " .. monster.level .. "]" .. (i < #list.monsters and ", " or ".")
		if(#current + #entry > RewardedMonsters.messageLength and current ~= "") then
			table.insert(messages, current)
			current = ""
		end

		current = current .. entry
	end

	table.insert(messages, current)
	return messages
end

-- sends the rewarded creatures (blue messages) to the player
function RewardedMonsters.send(cid)
	if(not RewardedMonsters.isEnabled()) then
		return
	end

	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Para ver as criaturas premiadas, use o comando !premiadas")
end

-- full text for the popup of the !rewarded command
function RewardedMonsters.getDescription()
	local text = "Rewarded creatures\n\nEvery time the server starts some creatures are drawn to give a bonus. The list stays the same until the next restart.\n"
	for _, category in ipairs(RewardedMonsters.categories) do
		local list = RewardedMonsters.getList(category)
		text = text .. "\n[" .. RewardedMonsters.labels[category] .. "] +" .. list.bonus .. "% (" .. #list.monsters .. " creatures)\n"
		for _, monster in ipairs(list.monsters) do
			text = text .. "  " .. monster.name .. " [Lv " .. monster.level .. "]\n"
		end
	end

	return text
end
