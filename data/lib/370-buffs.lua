-- Buff system (port of the buff system of the old 8.6 server, data/lib/060-buffs.lua, itself from the WoL Canary system).
--
-- A buff is a table built on the spot and given to addCreatureBuff(cid, buff):
--   name        name shown in !buffs (default: the category)
--   category    only 1 buff per category is active; a new one replaces the old one (default "Primary")
--   duration    in MILLISECONDS (default 15000); the buff is removed when it ends
--   description shown in !buffs
--   stackable   (optional) calling addCreatureBuff again on the same category adds 1 stack instead of only renewing it
--   maxStacks   (optional, with stackable) stack limit (no limit when omitted)
--   attributes  (optional) free table, only stored: see calculateCreatureBuffsAttributes
--   onActivate  function(cid, stacks)  runs when the buff starts (also when renewed or stacked)
--   onRemove    function(cid)          runs when the buff ends: it expired, was replaced or was removed (use it to undo what onActivate did)
--
-- Example (Fist Fury, a spell that no longer exists; kept as a model):
--   addCreatureBuff(cid, {
--       name = "Fist Fury", category = "Fist Fury", duration = 10000, description = "+20 fist fighting.",
--       onActivate = function(id, stacks)
--           local condition = createConditionObject(CONDITION_ATTRIBUTES, 10000, true, 8306)
--           setConditionParam(condition, CONDITION_PARAM_SKILL_FIST, 20)
--           doAddCondition(id, condition)
--       end,
--       onRemove = function(id) if isCreature(id) then doRemoveCondition(id, CONDITION_ATTRIBUTES, 8306) end end
--   })
--
-- Functions (all take the creature id first; the old system's creature:method() became a global function):
--   addCreatureBuff(cid, buff)                   gives the buff (false if cid is not a creature)
--   removeCreatureBuff(cid, category)            removes the buff of that category (runs its onRemove)
--   clearCreatureBuffs(cid)                      removes every buff of the creature
--   getCreatureBuffs(cid)                        table category -> info, or false when there are none
--   getCreatureBuffByCategory(cid, category)     info of the buff, or false
--   getCreatureBuffStacks(cid, category)         stacks (0 when there is no buff in that category)
--   hasCreatureBuff(cid, category)               true when the category has an active buff
--   calculateCreatureBuffsAttributes(cid [, base])  sums the `attributes` (times the stacks) of the buffs given from this Lua state
-- info = {category, name, description, duration (s), expires (os.time), timeLeft (s), stacks}
--
-- IMPORTANT: every script type (spells, talkactions, creaturescripts...) runs in its own Lua state, and a table such as
-- CreatureBuffs is NOT shared between them. So the callbacks (onActivate/onRemove) and the timer live in the state of the script that
-- gave the buff (CreatureBuffs below), but the list of active buffs (category, name, time, stacks) is also written in a creature
-- storage (Buffs.storage), which every state sees. The functions that only read (getCreatureBuffs, ...ByCategory, ...Stacks,
-- hasCreatureBuff) read that storage, so !buffs and creaturescripts see the buffs given by spells.
-- Limits: a buff replaced or removed from ANOTHER state than the one that gave it does not run its onRemove (the conditions
-- created with a duration end on their own). Players lose their buffs on logout and on death (clearCreatureBuffs without callbacks).

Buffs = {
	storage = 52400 -- creature storage with the list of active buffs ("Ids de storage reservados")
}

CreatureBuffs = {} -- this Lua state only: cid -> category -> buff table (with the callbacks and the timer event)

local nextBuffId = 0

-- Mirror of the active buffs in the creature storage: "B:category|name|expires|duration|stacks|description;..." (the B: keeps
-- the engine from reading the text as a number).
local function clean(text)
	return (tostring(text or ""):gsub("[|;]", " "))
end

local function readMirror(cid)
	local list = {}
	local raw = getCreatureStorage(cid, Buffs.storage)
	if(type(raw) ~= "string" or raw:sub(1, 2) ~= "B:") then
		return list
	end

	local now = os.time()
	for entry in string.gmatch(raw:sub(3), "[^;]+") do
		local category, name, expires, duration, stacks, description = string.match(entry, "^([^|]*)|([^|]*)|(%d+)|(%d+)|(%d+)|(.*)$")
		expires = tonumber(expires)
		if(category and expires > now) then
			list[category] = {
				category = category, name = name, description = description,
				expires = expires, duration = tonumber(duration), timeLeft = expires - now, stacks = tonumber(stacks)
			}
		end
	end

	return list
end

local function writeMirror(cid, list)
	local parts = {}
	for category, info in pairs(list) do
		table.insert(parts, table.concat({clean(category), clean(info.name), info.expires, info.duration, info.stacks, clean(info.description)}, "|"))
	end

	if(#parts == 0) then
		doCreatureSetStorage(cid, Buffs.storage) -- erases it
	else
		doCreatureSetStorage(cid, Buffs.storage, "B:" .. table.concat(parts, ";"))
	end
end

function getCreatureBuffs(cid)
	if(not isCreature(cid)) then
		return false
	end

	local list = readMirror(cid)
	return next(list) and list or false
end

function getCreatureBuffByCategory(cid, category)
	local buffs = getCreatureBuffs(cid)
	return buffs and buffs[category] or false
end

-- Stacks of the buff in the category (0 if there is no active buff in it).
function getCreatureBuffStacks(cid, category)
	local buff = getCreatureBuffByCategory(cid, category)
	return buff and buff.stacks or 0
end

function hasCreatureBuff(cid, category)
	return getCreatureBuffByCategory(cid, category) ~= false
end

-- skipStopEvent (internal): true when the caller is already inside the expiry timer of this buff (see addCreatureBuff). stopEvent
-- must not be called from inside the event itself: the engine keeps an iterator to the event while the callback runs and erases
-- it afterwards, so stopping the running event would invalidate that iterator and crash the server.
function removeCreatureBuff(cid, category, skipStopEvent)
	if(isCreature(cid)) then
		local mirror = readMirror(cid)
		if(mirror[category]) then
			mirror[category] = nil
			writeMirror(cid, mirror)
		end
	end

	local buff = CreatureBuffs[cid] and CreatureBuffs[cid][category]
	if(not buff) then
		return true
	end

	CreatureBuffs[cid][category] = nil -- first, so onRemove can give the buff again safely
	if(buff.onRemove) then
		local ok, err = pcall(buff.onRemove, cid)
		if(not ok) then
			print("[Error - Buffs] onRemove of '" .. tostring(category) .. "': " .. tostring(err))
		end
	end

	if(buff.event and not skipStopEvent) then
		stopEvent(buff.event)
	end

	return true
end

-- Removes every buff of the creature (logout, death).
function clearCreatureBuffs(cid)
	if(CreatureBuffs[cid]) then
		local categories = {}
		for category in pairs(CreatureBuffs[cid]) do
			table.insert(categories, category)
		end

		for _, category in ipairs(categories) do
			removeCreatureBuff(cid, category)
		end

		CreatureBuffs[cid] = nil
	end

	if(isCreature(cid)) then
		doCreatureSetStorage(cid, Buffs.storage)
	end
end

-- Sums the `attributes` of the buffs given from this Lua state (value * stacks). The attributes are free data: nothing applies
-- them by itself, use them in your own systems.
function calculateCreatureBuffsAttributes(cid, preAttributes)
	local attributes = preAttributes or {}
	local buffs = CreatureBuffs[cid]
	if(not buffs) then
		return attributes
	end

	for category, buff in pairs(buffs) do
		if(buff.attributes) then
			local multiplier = buff.stacks or 1
			for attribute, value in pairs(buff.attributes) do
				attributes[attribute] = (attributes[attribute] or 0) + value * multiplier
			end
		end
	end

	return attributes
end

function addCreatureBuff(cid, buff)
	if(not isCreature(cid)) then
		return false
	end

	buff.category = buff.category or "Primary"
	buff.name = buff.name or buff.category

	if(buff.stackable) then
		buff.stacks = math.min(getCreatureBuffStacks(cid, buff.category) + 1, buff.maxStacks or math.huge)
	else
		buff.stacks = buff.stacks or 1
	end

	removeCreatureBuff(cid, buff.category)
	nextBuffId = nextBuffId + 1
	buff.id = nextBuffId

	local duration = buff.duration or 15000
	local seconds = duration > 0 and math.ceil(duration / 1000) or 0

	-- the list first (so onActivate can already read it), then the callbacks and the timer
	local mirror = readMirror(cid)
	mirror[buff.category] = {
		category = buff.category, name = buff.name, description = buff.description or "",
		expires = duration > 0 and (os.time() + seconds) or 2147483000, duration = seconds, stacks = buff.stacks
	}
	writeMirror(cid, mirror)

	CreatureBuffs[cid] = CreatureBuffs[cid] or {}
	CreatureBuffs[cid][buff.category] = buff

	if(buff.onActivate) then
		local ok, err = pcall(buff.onActivate, cid, buff.stacks)
		if(not ok) then
			print("[Error - Buffs] onActivate of '" .. tostring(buff.category) .. "': " .. tostring(err))
		end
	end

	if(duration > 0) then
		buff.event = addEvent(function(id, buffId, category)
			if(not isCreature(id)) then
				CreatureBuffs[id] = nil
				return true
			end

			local active = CreatureBuffs[id] and CreatureBuffs[id][category]
			if(active and active.id == buffId) then
				removeCreatureBuff(id, category, true)
			end
		end, duration, cid, buff.id, buff.category)
	end

	return true
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
