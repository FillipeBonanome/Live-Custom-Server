-- Telegraphed attacks for the monster spells: the tiles that will be hit are marked with CONST_ME_TUTORIALSQUARE and the damage only
-- lands some time later, so the players have time to leave (see doc/sistemas/36-bosses.md).
--
-- Shapes (each returns a list of positions; tiles that do not exist are left out):
--   Telegraph.square(center, radius)        filled square (radius 1 = 3x3)
--   Telegraph.ring(center, radius)          only the border of the square
--   Telegraph.disc(center, radius)          filled circle
--   Telegraph.line(from, direction, length[, width = 1])   direction = NORTH/EAST/SOUTH/WEST (0 to 3), starts on the tile in front of `from`
--   Telegraph.cross(center, length)         the four arms
--   Telegraph.cone(from, direction, length) triangle that opens by 1 tile on each side per tile of length
--   Telegraph.merge(a, b, ...)              joins lists without repeating tiles
--
-- Telegraph.strike{...} marks the tiles, waits and hits whoever is still on them:
--   caster   creature id that causes the damage (it does not hit anything if the caster died meanwhile)
--   tiles    list of positions
--   delay    ms between the mark and the hit (default 1500)
--   combat   combat type (COMBAT_FIREDAMAGE...), min, max   positive numbers (the damage); without combat only the visuals happen
--   effect   effect shown on each tile when it lands (default none)
--   warn     warning effect (default CONST_ME_TUTORIALSQUARE); it is sent again every Telegraph.refresh ms while waiting
--   onLand   function(tiles) called when the hit lands (before the damage), e.g. to teleport the caster
--   onHit    function(playerId, position) called for each player hit
-- Returns the number of tiles marked.
--
-- Telegraph.strikes(options, count, getTiles, interval) fires `count` strikes (each with its tiles given by getTiles(index)),
-- one every `interval` ms: ex. a rain of marks over random players.

Telegraph = {
	warn = CONST_ME_TUTORIALSQUARE,
	-- the warning effect is sent again at this interval (ms) so it keeps showing until the hit
	refresh = 1000
}

local function key(pos)
	return pos.x .. ":" .. pos.y .. ":" .. pos.z
end

local function add(list, seen, pos)
	local k = key(pos)
	if(not seen[k] and type(getTileInfo(pos)) == "table") then
		seen[k] = true
		table.insert(list, {x = pos.x, y = pos.y, z = pos.z})
	end
end

function Telegraph.merge(...)
	local list, seen = {}, {}
	for _, tiles in ipairs({...}) do
		for _, pos in ipairs(tiles) do
			add(list, seen, pos)
		end
	end

	return list
end

function Telegraph.square(center, radius)
	local list, seen = {}, {}
	for dx = -radius, radius do
		for dy = -radius, radius do
			add(list, seen, {x = center.x + dx, y = center.y + dy, z = center.z})
		end
	end

	return list
end

function Telegraph.ring(center, radius)
	local list, seen = {}, {}
	for dx = -radius, radius do
		for dy = -radius, radius do
			if(math.max(math.abs(dx), math.abs(dy)) == radius) then
				add(list, seen, {x = center.x + dx, y = center.y + dy, z = center.z})
			end
		end
	end

	return list
end

function Telegraph.disc(center, radius)
	local list, seen = {}, {}
	for dx = -radius, radius do
		for dy = -radius, radius do
			if(dx * dx + dy * dy <= radius * radius + radius * 0.5) then
				add(list, seen, {x = center.x + dx, y = center.y + dy, z = center.z})
			end
		end
	end

	return list
end

local vectors = {[0] = {0, -1}, [1] = {1, 0}, [2] = {0, 1}, [3] = {-1, 0}}

function Telegraph.line(from, direction, length, width)
	width = width or 1
	local v = vectors[direction] or vectors[0]
	local side = {-v[2], v[1]}
	local half = math.floor((width - 1) / 2)
	local list, seen = {}, {}
	for i = 1, length do
		for offset = -half, half do
			add(list, seen, {x = from.x + v[1] * i + side[1] * offset, y = from.y + v[2] * i + side[2] * offset, z = from.z})
		end
	end

	return list
end

function Telegraph.cross(center, length)
	local list, seen = {}, {}
	for i = -length, length do
		add(list, seen, {x = center.x + i, y = center.y, z = center.z})
		add(list, seen, {x = center.x, y = center.y + i, z = center.z})
	end

	return list
end

function Telegraph.cone(from, direction, length)
	local v = vectors[direction] or vectors[0]
	local side = {-v[2], v[1]}
	local list, seen = {}, {}
	for i = 1, length do
		for offset = -(i - 1), i - 1 do
			add(list, seen, {x = from.x + v[1] * i + side[1] * offset, y = from.y + v[2] * i + side[2] * offset, z = from.z})
		end
	end

	return list
end

function Telegraph.strike(options)
	local tiles = options.tiles
	if(not tiles or #tiles == 0) then
		return 0
	end

	local warn = options.warn or Telegraph.warn
	local delay = options.delay or 1500
	local caster = options.caster

	local function mark()
		for _, pos in ipairs(tiles) do
			doSendMagicEffect(pos, warn)
		end
	end

	mark()
	local elapsed = Telegraph.refresh
	while(elapsed < delay) do
		addEvent(function()
			if(not caster or isCreature(caster)) then
				mark()
			end
		end, elapsed)

		elapsed = elapsed + Telegraph.refresh
	end

	addEvent(function()
		if(caster and (not isCreature(caster) or getCreatureHealth(caster) <= 0)) then
			return
		end

		if(options.onLand) then
			options.onLand(tiles)
		end

		local hit = {}
		for _, pos in ipairs(tiles) do
			hit[key(pos)] = true
			if(options.effect) then
				doSendMagicEffect(pos, options.effect)
			end
		end

		if(not options.combat and not options.onHit) then
			return
		end

		for _, pid in ipairs(getPlayersOnline()) do
			local ppos = getCreaturePosition(pid)
			if(hit[key(ppos)] and not getTilePzInfo(ppos)) then
				if(options.combat) then
					doTargetCombatHealth(caster or 0, pid, options.combat, -options.min, -options.max, options.effect or CONST_ME_NONE)
				end

				if(options.onHit) then
					options.onHit(pid, ppos)
				end
			end
		end
	end, delay)

	return #tiles
end

-- `count` strikes, one every `interval` ms. options is the table of Telegraph.strike (without tiles); getTiles(index) returns the tiles of each one.
function Telegraph.strikes(options, count, getTiles, interval)
	local total = 0
	for index = 1, count do
		local tiles = getTiles(index)
		local copy = {}
		for k, v in pairs(options) do
			copy[k] = v
		end

		copy.tiles = tiles
		local offset = (index - 1) * (interval or 450)
		if(offset == 0) then
			total = total + Telegraph.strike(copy)
		else
			addEvent(function()
				if(not options.caster or isCreature(options.caster)) then
					Telegraph.strike(copy)
				end
			end, offset)
			total = total + #tiles
		end
	end

	return total
end
