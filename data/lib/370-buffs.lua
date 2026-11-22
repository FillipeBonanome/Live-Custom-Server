-- Buff system. Every buff is registered once with Buffs.register and applied to players with Buffs.add.
--
-- Buffs.register{
--     id = "haste",                  -- unique text id
--     name = "Haste",                -- name shown in !buffs (default: the id)
--     category = "speed",            -- buffs of the same category overwrite each other (only 1 active per category)
--     duration = 60,                 -- default duration in seconds
--     description = "Moves faster.", -- shown in !buffs
--     onActivate = function(cid, buff) end,         -- buff started
--     onExpire = function(cid, buff) end,           -- the duration ended
--     onRemove = function(cid, buff, reason) end    -- the buff ended in ANY way (cleanup goes here)
-- }
--
-- Events:
--   onActivate: when the buff starts (also when it is refreshed or replaces another one).
--   onExpire:   only when the time runs out. Runs before onRemove.
--   onRemove:   whenever the buff stops, so it is the place to undo what onActivate did. reason is one of:
--               "expire" (time ran out), "remove" (Buffs.remove), "replace" (same id refreshed or another buff of the
--               same category took its place), "logout" (the player left) or "death".
--   buff is {id, name, category, description, duration, expires (os.time), definition}.
--
-- Buffs live in memory only: they end on logout and on death (onRemove still runs, with that reason).
--
-- API: Buffs.add(cid, id [, seconds]), Buffs.remove(cid, idOrCategory [, reason]), Buffs.removeAll(cid [, reason]),
--      Buffs.has(cid, id), Buffs.get(cid, idOrCategory), Buffs.getAll(cid), Buffs.getTimeLeft(cid, id).

Buffs = {
	definitions = {}, -- id -> definition
	active = {}, -- cid -> {category -> {def, expires, duration, token}}
	token = 0
}

function Buffs.register(def)
	if(type(def) ~= "table" or type(def.id) ~= "string" or def.id == "") then
		error("Buffs.register: the buff needs a text id.", 2)
	end

	if(Buffs.definitions[def.id]) then
		print("[Warning - Buffs] Buff '" .. def.id .. "' registered twice, the last one is used.")
	end

	local duration = tonumber(def.duration) or 0
	if(duration <= 0) then
		error("Buffs.register: buff '" .. def.id .. "' needs a duration in seconds greater than 0.", 2)
	end

	Buffs.definitions[def.id] = {
		id = def.id,
		name = def.name or def.id,
		category = def.category or def.id, -- without a category the buff only overwrites itself
		duration = duration,
		description = def.description or "",
		onActivate = def.onActivate,
		onExpire = def.onExpire,
		onRemove = def.onRemove
	}

	return true
end

-- Snapshot given to the event callbacks.
local function snapshot(entry)
	local def = entry.def
	return {
		id = def.id,
		name = def.name,
		category = def.category,
		description = def.description,
		duration = entry.duration,
		expires = entry.expires,
		definition = def
	}
end

-- A broken callback must not break the other buffs or the player's session.
local function fire(callback, ...)
	if(type(callback) ~= "function") then
		return
	end

	local ok, err = pcall(callback, ...)
	if(not ok) then
		print("[Error - Buffs] " .. tostring(err))
	end
end

function Buffs.getTimeLeft(cid, id)
	local entry = Buffs.active[cid] and Buffs.active[cid][Buffs.definitions[id] and Buffs.definitions[id].category or ""]
	if(not entry or entry.def.id ~= id) then
		return 0
	end

	return math.max(0, entry.expires - os.time())
end

function Buffs.has(cid, id)
	return Buffs.getTimeLeft(cid, id) > 0
end

-- Finds the active buff by buff id or by category.
local function find(cid, idOrCategory)
	local list = Buffs.active[cid]
	if(not list) then
		return nil
	end

	local def = Buffs.definitions[idOrCategory]
	if(def) then
		local entry = list[def.category]
		if(entry and entry.def.id == def.id) then
			return entry
		end

		return nil
	end

	return list[idOrCategory]
end

function Buffs.get(cid, idOrCategory)
	local entry = find(cid, idOrCategory)
	if(not entry) then
		return nil
	end

	local buff = snapshot(entry)
	buff.timeLeft = math.max(0, entry.expires - os.time())
	return buff
end

-- Active buffs of the player, ordered by the time left.
function Buffs.getAll(cid)
	local result = {}
	for _, entry in pairs(Buffs.active[cid] or {}) do
		local buff = snapshot(entry)
		buff.timeLeft = math.max(0, entry.expires - os.time())
		table.insert(result, buff)
	end

	table.sort(result, function(a, b) return a.timeLeft < b.timeLeft end)
	return result
end

-- Ends the buff of that category: calls onExpire (only when it ran out) and onRemove.
local function finish(cid, category, reason)
	local list = Buffs.active[cid]
	local entry = list and list[category]
	if(not entry) then
		return false
	end

	list[category] = nil -- first, so callbacks can add another buff of the category safely
	if(next(list) == nil) then
		Buffs.active[cid] = nil
	end

	local buff = snapshot(entry)
	if(reason == "expire") then
		fire(entry.def.onExpire, cid, buff)
	end

	fire(entry.def.onRemove, cid, buff, reason)
	return true
end

-- Called by the timer: the token ignores timers of buffs that were already replaced or refreshed.
function Buffs.expire(cid, category, token)
	local entry = Buffs.active[cid] and Buffs.active[cid][category]
	if(not entry or entry.token ~= token) then
		return
	end

	if(not isPlayer(cid)) then
		Buffs.active[cid] = nil
		return
	end

	finish(cid, category, "expire")
end

function Buffs.add(cid, id, seconds)
	local def = Buffs.definitions[id]
	if(not def) then
		print("[Warning - Buffs] Unknown buff '" .. tostring(id) .. "'.")
		return false
	end

	if(not isPlayer(cid)) then
		return false
	end

	seconds = tonumber(seconds) or def.duration
	if(seconds <= 0) then
		return false
	end

	-- same category (or the same buff again): the old one goes away first
	finish(cid, def.category, "replace")

	Buffs.token = Buffs.token + 1
	local entry = {def = def, duration = seconds, expires = os.time() + seconds, token = Buffs.token}
	Buffs.active[cid] = Buffs.active[cid] or {}
	Buffs.active[cid][def.category] = entry
	addEvent(Buffs.expire, seconds * 1000, cid, def.category, entry.token)

	fire(def.onActivate, cid, snapshot(entry))
	return true
end

-- idOrCategory: a buff id or a category name. Returns false when there was nothing to remove.
function Buffs.remove(cid, idOrCategory, reason)
	local entry = find(cid, idOrCategory)
	if(not entry) then
		return false
	end

	return finish(cid, entry.def.category, reason or "remove")
end

function Buffs.removeAll(cid, reason)
	local categories = {}
	for category in pairs(Buffs.active[cid] or {}) do
		table.insert(categories, category)
	end

	for _, category in ipairs(categories) do
		finish(cid, category, reason or "remove")
	end
end

function Buffs.formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	if(hours > 0) then
		return string.format("%dh %02dmin", hours, minutes)
	elseif(minutes > 0) then
		return string.format("%dmin %02ds", minutes, secs)
	end

	return secs .. "s"
end
