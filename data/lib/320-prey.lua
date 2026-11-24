-- Prey system: a player picks one monster, a type of bonus (experience, loot, damage or defense) and a strength
-- (weak, strong, ultimate) at the Prey NPC. The bonus is valid against that monster only, for preyDuration seconds
-- (real time, 2 hours by default), and costs gold. Clearing it to pick something else is free.
--
-- The bonus is applied by the source (src/player.h getPreyBonus, used in creature.cpp, monsters.cpp and game.cpp).
-- This lib keeps it in the `player_prey` table (one row per player) and re-applies it to the player on login.
-- Options (config.lua): preyEnabled, preyDuration, preyWeakBonus / preyStrongBonus / preyUltimateBonus (percent),
-- preyWeakPrice / preyStrongPrice / preyUltimatePrice (gold).

Prey = {
	-- bonus types: tag used by the source / database, label shown to the player and what it does
	types = {
		{name = "experience", label = "Experience", text = "more experience from"},
		{name = "loot", label = "Loot", text = "better loot chance from"},
		{name = "damage", label = "Damage", text = "more damage against"},
		{name = "defense", label = "Defense", text = "less damage taken from"}
	},

	strengths = {
		{name = "weak", label = "Weak"},
		{name = "strong", label = "Strong"},
		{name = "ultimate", label = "Ultimate"}
	}
}

local DEFAULTS = {
	preyEnabled = true,
	preyDuration = 7200,
	preyWeakBonus = 10, preyStrongBonus = 25, preyUltimateBonus = 50,
	preyWeakPrice = 50000, preyStrongPrice = 150000, preyUltimatePrice = 500000
}

local function cfg(key)
	local value = getConfigValue(key)
	if(value == nil) then
		return DEFAULTS[key]
	end

	return value
end

function Prey.isEnabled()
	return getBooleanFromString(cfg('preyEnabled'))
end

function Prey.getDuration()
	return math.max(60, tonumber(cfg('preyDuration')) or DEFAULTS.preyDuration)
end

function Prey.getStrength(name)
	name = tostring(name):trim():lower()
	for _, strength in ipairs(Prey.strengths) do
		if(strength.name == name) then
			return strength
		end
	end

	return nil
end

function Prey.getType(name)
	name = tostring(name):trim():lower()
	for _, preyType in ipairs(Prey.types) do
		if(preyType.name == name) then
			return preyType
		end
	end

	return nil
end

-- percent of a strength
function Prey.getBonus(strength)
	return tonumber(cfg('prey' .. strength.label .. 'Bonus')) or 0
end

-- price (gold) of a strength
function Prey.getPrice(strength)
	return tonumber(cfg('prey' .. strength.label .. 'Price')) or 0
end

-- {name = "Dragon", level = 51} or nil. Only monsters that can be hunted (same pool of the daily contracts).
function Prey.findMonster(name)
	name = tostring(name):trim():lower()
	if(name == "") then
		return nil
	end

	for _, monster in ipairs(DailyQuest.getMonsters()) do
		if(monster.name:lower() == name) then
			return monster
		end
	end

	return nil
end

-- "2h 5min" / "35min"
function Prey.formatTime(seconds)
	seconds = math.max(0, seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	if(hours > 0) then
		return hours .. "h " .. minutes .. "min"
	end

	return math.max(1, minutes) .. "min"
end

-- Database --------------------------------------------------------------------------------------------------------

local function save(cid, monster, typeName, bonus, expire)
	db.query("REPLACE INTO `player_prey` (`player_id`, `monster`, `type`, `bonus`, `expire`) VALUES (" ..
		getPlayerGUID(cid) .. ", " .. db.escapeString(monster) .. ", " .. db.escapeString(typeName) .. ", " .. bonus .. ", " .. expire .. ")")
end

local function remove(cid)
	db.query("DELETE FROM `player_prey` WHERE `player_id` = " .. getPlayerGUID(cid))
end

-- Active prey of the player: {monster = "dragon", type = "experience", bonus = 25, expire = timestamp} or nil
function Prey.get(cid)
	local prey = getPlayerPrey and getPlayerPrey(cid)
	if(prey) then
		return prey
	end

	return nil
end

-- Loads the prey of the database into the player (call on login). Expired prey is deleted.
function Prey.load(cid)
	if(not doPlayerSetPrey) then
		return false
	end

	local res = db.storeQuery("SELECT `monster`, `type`, `bonus`, `expire` FROM `player_prey` WHERE `player_id` = " .. getPlayerGUID(cid))
	if(not res) then
		return false
	end

	local monster, typeName = result.getDataString(res, "monster"), result.getDataString(res, "type")
	local bonus, expire = result.getDataInt(res, "bonus"), result.getDataInt(res, "expire")
	result.free(res)

	if(expire <= os.time()) then
		remove(cid)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Your prey bonus against " .. monster .. " has expired. Talk to the Huntmaster Kael to get a new one.")
		return false
	end

	return doPlayerSetPrey(cid, monster, typeName, bonus, expire)
end

-- Buys a prey: takes the gold and starts the timer. Returns true, or false and the reason.
function Prey.set(cid, monsterName, typeName, strengthName)
	if(not Prey.isEnabled()) then
		return false, "The prey system is disabled."
	end

	local monster, preyType, strength = Prey.findMonster(monsterName), Prey.getType(typeName), Prey.getStrength(strengthName)
	if(not monster or not preyType or not strength) then
		return false, "Invalid prey."
	end

	if(Prey.get(cid)) then
		return false, "You already have an active prey. Clear it first."
	end

	local price = Prey.getPrice(strength)
	if(price > 0 and not doPlayerRemoveMoney(cid, price)) then
		return false, "You need " .. price .. " gold coins."
	end

	local bonus, expire = Prey.getBonus(strength), os.time() + Prey.getDuration()
	if(not doPlayerSetPrey(cid, monster.name, preyType.name, bonus, expire)) then
		if(price > 0) then
			doPlayerAddMoney(cid, price)
		end

		return false, "Could not start the prey."
	end

	save(cid, monster.name:lower(), preyType.name, bonus, expire)
	return true
end

-- Removes the active prey (free)
function Prey.clear(cid)
	local had = Prey.get(cid) ~= nil
	doPlayerClearPrey(cid)
	remove(cid)
	return had
end

-- Text of the active prey: "Damage +25% (more damage against Dragon), 1h 20min left."
function Prey.describe(prey)
	local preyType = Prey.getType(prey.type)
	local monster = Prey.findMonster(prey.monster)
	return preyType.label .. " +" .. prey.bonus .. "% (" .. preyType.text .. " " .. (monster and monster.name or prey.monster) ..
		"), " .. Prey.formatTime(prey.expire - os.time()) .. " left."
end
