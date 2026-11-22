-- /vfx <effect> [ani/effect id or element] [option=value ...]   (test command for the VFX lib, data/lib/360-vfx.lua)
-- /vfx list                : lists the effects and the registered profiles
-- /vfx stop                : cancels the effects started by you that are still running
-- /vfx <profile name>      : plays a profile registered with VFX.register (e.g. /vfx fire_meteor)
--
-- Examples:
--   /vfx skyfall 3 count=10 radius=3 effect=6
--   /vfx rain ice radius=4 duration=3000 drops=40
--   /vfx wave fire radius=4
--   /vfx meteor element=fire count=4 radius=3
--   /vfx buff type=mana
--   /vfx orbit 35 duration=10000
-- The second parameter is the CONST_ANI_* number (distance shoot effects) or the CONST_ME_* number (magic effects),
-- or the name of an element (fire, ice, energy, earth, holy, death); without it a default is used.
-- Options are numbers (or true/false/text) as documented in data/lib/360-vfx.lua.

local running = {} -- cid -> list of handles

-- name -> {kind, default id, VFX function, uses the creature id as target}
-- kinds: "ani" (target, ani, options), "me" (target, effect, options), "combo" (target, options), "beam", "teleport"
local effects = {
	skyfall = {"ani", CONST_ANI_FIRE, "SkyFall"},
	rain = {"ani", CONST_ANI_ICE, "Rain"},
	fountain = {"ani", CONST_ANI_SMALLEARTH, "Fountain"},
	spiral = {"ani", CONST_ANI_ENERGY, "Spiral"},
	circle = {"ani", CONST_ANI_HOLY, "Circle"},
	explosion = {"ani", CONST_ANI_FIRE, "Explosion"},
	implosion = {"ani", CONST_ANI_ENERGY, "Implosion"},
	orbit = {"ani", CONST_ANI_ENERGYBALL, "Orbit", true},
	lightning = {"ani", CONST_ANI_ENERGY, "Lightning"},
	tornado = {"ani", CONST_ANI_SMALLEARTH, "Tornado"},
	helix = {"ani", CONST_ANI_ENERGYBALL, "Helix"},
	burst = {"ani", CONST_ANI_HOLY, "Burst"},
	barrage = {"ani", CONST_ANI_ARROW, "Barrage", true},
	comet = {"ani", CONST_ANI_FIRE, "Comet"},
	snow = {"ani", CONST_ANI_SNOWBALL, "Snow"},
	beam = {"beam", CONST_ANI_ENERGY, "Beam"},
	wave = {"me", CONST_ME_MAGIC_BLUE, "Wave"},
	line = {"me", CONST_ME_ENERGYAREA, "Line", true},
	pulse = {"me", CONST_ME_MAGIC_RED, "Pulse", true},
	cross = {"me", CONST_ME_FIREAREA, "Cross"},
	star = {"me", CONST_ME_FIREAREA, "Star"},
	ring = {"me", CONST_ME_MAGIC_RED, "Ring", true},
	meteor = {"combo", nil, "Meteor"},
	summon = {"combo", nil, "Summon"},
	levelup = {"combo", nil, "LevelUp"},
	warning = {"combo", nil, "Warning"},
	death = {"combo", nil, "Death"},
	storm = {"combo", nil, "Storm"},
	buff = {"combo", nil, "Buff"},
	teleport = {"teleport", nil, "Teleport"}
}

local order = {"skyfall", "rain", "fountain", "spiral", "circle", "explosion", "implosion", "orbit", "lightning",
	"tornado", "helix", "burst", "barrage", "comet", "snow", "beam", "wave", "line", "pulse", "cross", "star", "ring",
	"meteor", "summon", "levelup", "warning", "death", "storm", "buff", "teleport"}

local function parseOptions(tokens)
	local options = {}
	for _, token in ipairs(tokens) do
		local key, value = token:match("^(%w+)=(.+)$")
		if(key) then
			if(value == "true") then
				options[key] = true
			elseif(value == "false") then
				options[key] = false
			elseif(tonumber(value)) then
				options[key] = tonumber(value)
			else
				options[key] = value
			end
		end
	end

	return options
end

local function remember(cid, handle)
	if(handle) then
		running[cid] = running[cid] or {}
		table.insert(running[cid], handle)
	end

	return handle
end

local function info(cid, text)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

function onSay(cid, words, param, channel)
	local tokens = {}
	for token in param:gmatch("%S+") do
		table.insert(tokens, token)
	end

	local name = tokens[1] and tokens[1]:lower() or "list"
	if(name == "list") then
		local profiles = {}
		for profile in pairs(VFX.profiles) do
			table.insert(profiles, profile)
		end

		table.sort(profiles)
		info(cid, "VFX effects: " .. table.concat(order, ", ") .. ".")
		info(cid, "VFX profiles: " .. table.concat(profiles, ", ") .. ". Use /vfx stop to cancel.")
		return true
	end

	if(name == "stop") then
		for _, handle in ipairs(running[cid] or {}) do
			VFX.stop(handle)
		end

		running[cid] = nil
		info(cid, "VFX: stopped.")
		return true
	end

	table.remove(tokens, 1)
	local pos = getCreaturePosition(cid)
	local entry = effects[name]

	if(not entry) then
		-- registered profile?
		local handle = VFX.play(name, pos, parseOptions(tokens))
		if(not handle) then
			doPlayerSendCancel(cid, "Unknown effect or profile. Use /vfx list.")
			return true
		end

		remember(cid, handle)
		return true
	end

	local kind, id, fnName, useCid = entry[1], entry[2], entry[3], entry[4]
	if(tokens[1] and not tokens[1]:find("=", 1, true)) then
		local given = table.remove(tokens, 1)
		id = tonumber(given) or given:lower() -- a number or the name of an element
	end

	local options = parseOptions(tokens)
	local fn = VFX[fnName]
	local handle

	if(kind == "ani" or kind == "me") then
		handle = fn(useCid and cid or pos, id, options)
	elseif(kind == "beam") then
		handle = fn(cid, nil, id, options) -- no destination: goes in front of the player
	elseif(kind == "teleport") then
		handle = fn(pos, VFX.lookPosition(cid, 4), options)
	else
		handle = fn(pos, options)
	end

	if(not handle) then
		doPlayerSendCancel(cid, "Invalid parameters for this effect.")
		return true
	end

	remember(cid, handle)
	return true
end
