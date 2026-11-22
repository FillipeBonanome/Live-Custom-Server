-- Daily login: the player uses a pillar (action id DailyLogin.actionId, set in the map editor) once per day to get a reward.
-- Claiming on consecutive days raises the streak; skipping a day resets it to 1. The rewards repeat in a cycle of
-- #DailyLogin.rewards days (the last one is the best), the streak itself keeps growing and gives a bonus on top.
--
-- The day changes at dailyLoginResetHour (server time, default 5h like the daily contracts).
-- Storages (saved with the player): storageLastDay (day index of the last claim) and storageStreak.
--
-- Options (config.lua): dailyLoginEnabled, dailyLoginResetHour. See doc/sistemas/26-daily-login.md.

DailyLogin = {
	actionId = 9800,
	itemId = 1514, -- pillar (any item with the action id works)
	storageLastDay = 54200,
	storageStreak = 54201,

	-- reward of each day of the cycle. gold (gp), exp (per player level), items = {{id, count}, ...}
	rewards = {
		{gold = 1000, exp = 20},
		{gold = 1500, exp = 30, items = {{7618, 10}, {7620, 10}}},
		{gold = 2000, exp = 40},
		{gold = 3000, exp = 60, items = {{8472, 10}, {8473, 10}}},
		{gold = 4000, exp = 80},
		{gold = 5000, exp = 100, items = {{2152, 20}}},
		{gold = 10000, exp = 200, items = {{2152, 50}, {8472, 20}, {8473, 20}}}
	},

	-- every full cycle completed adds this fraction to gold and exp (0.1 = +10% per cycle, up to maxCycleBonus)
	cycleBonus = 0.1,
	maxCycleBonus = 1.0
}

local function cfg(key, default)
	local value = getConfigValue(key)
	if(value == nil) then
		return default
	end

	return value
end

function DailyLogin.isEnabled()
	return getBooleanFromString(cfg('dailyLoginEnabled', true))
end

-- index of the current "day" (changes at the reset hour, uses the local date so it follows the server clock)
function DailyLogin.getDay(time)
	local resetHour = math.max(0, math.min(23, math.floor(cfg('dailyLoginResetHour', 5))))
	local d = os.date("*t", (time or os.time()) - resetHour * 3600)
	return math.floor(os.time({year = d.year, month = d.month, day = d.day, hour = 12}) / 86400)
end

-- seconds until the next reset
function DailyLogin.getSecondsToReset()
	local resetHour = math.max(0, math.min(23, math.floor(cfg('dailyLoginResetHour', 5))))
	local now = os.time()
	local d = os.date("*t", now)
	local reset = os.time({year = d.year, month = d.month, day = d.day, hour = resetHour, min = 0, sec = 0})
	if(reset <= now) then
		reset = os.time({year = d.year, month = d.month, day = d.day + 1, hour = resetHour, min = 0, sec = 0})
	end

	return reset - now
end

function DailyLogin.formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	if(hours > 0) then
		return hours .. "h " .. minutes .. "min"
	end

	return math.max(1, minutes) .. "min"
end

function DailyLogin.canClaim(cid)
	return getPlayerStorageValue(cid, DailyLogin.storageLastDay) ~= DailyLogin.getDay()
end

-- streak the player would have if claiming now (1 when the last claim was not yesterday)
function DailyLogin.getNextStreak(cid)
	local last = getPlayerStorageValue(cid, DailyLogin.storageLastDay)
	local streak = math.max(0, getPlayerStorageValue(cid, DailyLogin.storageStreak))
	if(last == DailyLogin.getDay() - 1) then
		return streak + 1
	end

	return 1
end

function DailyLogin.getReward(streak)
	local size = #DailyLogin.rewards
	local cycle = math.floor((streak - 1) / size)
	local bonus = 1 + math.min(DailyLogin.maxCycleBonus, cycle * DailyLogin.cycleBonus)
	return DailyLogin.rewards[((streak - 1) % size) + 1], bonus
end

function DailyLogin.describeReward(cid, streak)
	local reward, bonus = DailyLogin.getReward(streak)
	local parts = {}
	if(reward.gold) then
		table.insert(parts, math.floor(reward.gold * bonus) .. " gold")
	end

	if(reward.exp) then
		table.insert(parts, math.floor(reward.exp * bonus * getPlayerLevel(cid)) .. " experience")
	end

	for _, item in ipairs(reward.items or {}) do
		table.insert(parts, item[2] .. "x " .. ((getItemInfo(item[1]) or {}).name or ("item " .. item[1])))
	end

	return table.concat(parts, ", ")
end

-- gives the reward; returns false (and a reason) when it cannot be claimed
function DailyLogin.claim(cid)
	if(not DailyLogin.isEnabled()) then
		return false, "The daily login is disabled."
	end

	if(not DailyLogin.canClaim(cid)) then
		return false, "You already claimed today's reward. Come back in " .. DailyLogin.formatTime(DailyLogin.getSecondsToReset()) .. "."
	end

	local streak = DailyLogin.getNextStreak(cid)
	local reward, bonus = DailyLogin.getReward(streak)

	-- items first: if the player has no room (or capacity) nothing is consumed
	local items = reward.items or {}
	local given = {}
	for _, item in ipairs(items) do
		local uid = doCreateItemEx(item[1], item[2])
		if(uid and doPlayerAddItemEx(cid, uid, false) == RETURNVALUE_NOERROR) then
			table.insert(given, uid)
		else
			if(uid) then
				doRemoveItem(uid)
			end

			for _, added in ipairs(given) do
				doRemoveItem(added)
			end

			return false, "You do not have room or capacity for the reward. Free some space and try again."
		end
	end

	local gold = reward.gold and math.floor(reward.gold * bonus) or 0
	if(gold > 0) then
		doPlayerAddMoney(cid, gold)
	end

	local exp = reward.exp and math.floor(reward.exp * bonus * getPlayerLevel(cid)) or 0
	if(exp > 0) then
		doPlayerAddExp(cid, exp)
	end

	setPlayerStorageValue(cid, DailyLogin.storageLastDay, DailyLogin.getDay())
	setPlayerStorageValue(cid, DailyLogin.storageStreak, streak)

	return true, streak, DailyLogin.describeReward(cid, streak)
end
