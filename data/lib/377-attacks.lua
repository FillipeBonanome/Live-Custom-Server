-- Attack types shared by the spells. A type only decides WHERE and WHEN something is hit; what the hit does (damage, status, effect) is a callback
-- of the spell, so any vocation can use it. Every type never hurts someone in a protection zone, a party member or a friend's summon, and never
-- goes through walls.
--
-- Attacks.valid(cid, tid)                         true if tid can be hurt by cid: alive, not a friend, not a summon of a friend, not in a protection zone
-- Attacks.enemies(cid, pos, radius [, extra])     valid enemies at most `radius` tiles from pos, in sight of pos
-- Attacks.around(cid, pos, radius)                valid enemies in a square around pos (no line of sight needed: eruptions, roars)
-- Attacks.enemiesOn(cid, tiles, center, radius)   valid enemies standing on any of the tiles (center/radius: where to look for them)
-- Attacks.tileOpen(cid, pos [, ignoreCreatures])  the tile exists, is not a protection zone and nothing solid is on it (and nobody, unless ignoreCreatures)
-- Attacks.vector(direction) / Attacks.sign(from, to) / Attacks.turn(v, steps) / Attacks.ring   direction helpers
-- Attacks.chainLightning(cid, target, o)          the bolt jumps from enemy to enemy
-- Attacks.randomWalk(cid, o)                      a strike that wanders tile by tile in a general direction, hitting each tile after a delay

Attacks = {}

local function key(pos)
	return pos.x .. "," .. pos.y .. "," .. pos.z
end

local function inProtectionZone(pos)
	local info = getTileInfo(pos)
	return type(info) == "table" and info.protection == true
end

Attacks.inProtectionZone = inProtectionZone

-- Directions -----------------------------------------------------------------------------------------------------------------------

-- the 8 directions in clockwise order (index 1 = north); a walk keeps close to one of them
Attacks.ring = {{0, -1}, {1, -1}, {1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}}

local vectors = {
	[NORTH] = {0, -1}, [EAST] = {1, 0}, [SOUTH] = {0, 1}, [WEST] = {-1, 0},
	[SOUTHWEST] = {-1, 1}, [SOUTHEAST] = {1, 1}, [NORTHWEST] = {-1, -1}, [NORTHEAST] = {1, -1}
}

function Attacks.vector(direction)
	return vectors[direction] or vectors[NORTH]
end

local function sign(n)
	return n > 0 and 1 or (n < 0 and -1 or 0)
end

-- direction (as a vector) from one position to another, nil if they are the same tile
function Attacks.sign(from, to)
	local dx, dy = sign(to.x - from.x), sign(to.y - from.y)
	if(dx == 0 and dy == 0) then
		return nil
	end

	return {dx, dy}
end

-- the direction `steps` turns of 45 degrees clockwise from v (negative = counterclockwise)
function Attacks.turn(v, steps)
	local index = 1
	for i, w in ipairs(Attacks.ring) do
		if(w[1] == v[1] and w[2] == v[2]) then
			index = i
			break
		end
	end

	return Attacks.ring[(index - 1 + steps) % #Attacks.ring + 1]
end

local function ringIndex(v)
	for index, w in ipairs(Attacks.ring) do
		if(w[1] == v[1] and w[2] == v[2]) then
			return index
		end
	end

	return nil
end

-- Targets --------------------------------------------------------------------------------------------------------------------------

function Attacks.isAlly(cid, tid)
	if(cid == tid) then
		return true
	end

	local members = isPlayer(tid) and getPartyMembers(cid)
	return type(members) == "table" and isInArray(members, tid)
end

function Attacks.valid(cid, tid)
	if(tid == nil or tid == 0 or tid == cid or not isCreature(tid) or getCreatureHealth(tid) <= 0 or isNpc(tid)) then
		return false
	end

	if(isPlayer(tid) and Attacks.isAlly(cid, tid)) then
		return false
	end

	-- summons of a friend (or of yourself) are not enemies
	local master = getCreatureMaster(tid)
	if(master and master ~= 0 and master ~= tid and (master == cid or Attacks.isAlly(cid, master))) then
		return false
	end

	return not inProtectionZone(getCreaturePosition(tid))
end

local function spectators(pos, radius)
	local list = getSpectators(pos, radius, radius, false)
	return type(list) == "table" and list or {}
end

function Attacks.enemies(cid, pos, radius, extra)
	local list, seen = {}, {}
	local all = spectators(pos, radius)
	if(extra) then
		table.insert(all, extra)
	end

	for _, tid in ipairs(all) do
		if(not seen[tid] and isCreature(tid)) then
			seen[tid] = true
			local tpos = getCreaturePosition(tid)
			local distance = getDistanceBetween(tpos, pos)
			if(distance <= radius and Attacks.valid(cid, tid) and (distance == 0 or isSightClear(pos, tpos, true))) then
				table.insert(list, tid)
			end
		end
	end

	return list
end

function Attacks.around(cid, pos, radius)
	local list = {}
	for _, tid in ipairs(spectators(pos, radius)) do
		if(isCreature(tid) and getDistanceBetween(getCreaturePosition(tid), pos) <= radius and Attacks.valid(cid, tid)) then
			table.insert(list, tid)
		end
	end

	return list
end

function Attacks.enemiesOn(cid, tiles, center, radius)
	local set = {}
	for _, pos in ipairs(tiles) do
		set[key(pos)] = true
	end

	local list = {}
	for _, tid in ipairs(spectators(center, radius)) do
		if(isCreature(tid) and set[key(getCreaturePosition(tid))] and Attacks.valid(cid, tid)) then
			table.insert(list, tid)
		end
	end

	return list
end

-- Tiles ----------------------------------------------------------------------------------------------------------------------------

-- FLAG_IGNOREBLOCKCREATURE (src/cylinder.h) = 4: ask the tile if `cid` could stand there, not counting the creatures that are already on it
function Attacks.tileOpen(cid, pos, ignoreCreatures)
	if(type(getTileInfo(pos)) ~= "table" or inProtectionZone(pos)) then
		return false
	end

	return doTileQueryAdd(cid, pos, ignoreCreatures and 4 or 0, false) == RETURNVALUE_NOERROR
end

-- Chain lightning ------------------------------------------------------------------------------------------------------------------
-- The bolt hits `target` and jumps to the nearest enemy within `jumpRange` tiles, `bounces` times. It needs a clear line from one enemy to the
-- next, never hits the same creature twice.
-- o.onHit(tid, multiplier, number)   what the bolt does to each creature (required); multiplier falls with every jump
-- o.bounces (4), o.jumpRange (4), o.delay ms (180), o.falloff (0.85 per jump), o.minimum (0.4)
-- o.ani (CONST_ANI_ENERGY, nil keeps it), o.effect (CONST_ME_ENERGYHIT), o.from (where the bolt starts, default the caster)

function Attacks.chainLightning(cid, target, o)
	local hitList = {}
	local bounces, jumpRange = o.bounces or 4, o.jumpRange or 4
	local falloff, minimum = o.falloff or 0.85, o.minimum or 0.4
	local ani = o.ani == nil and CONST_ANI_ENERGY or o.ani

	local function jump(current, lastPos, number)
		if(not isCreature(cid) or not Attacks.valid(cid, current)) then
			return
		end

		local pos = getCreaturePosition(current)
		if(number > 1 and not isSightClear(lastPos, pos, true)) then
			return
		end

		hitList[current] = true
		if(ani) then
			doSendDistanceShoot(lastPos, pos, ani)
		end

		doSendMagicEffect(pos, o.effect or CONST_ME_ENERGYHIT)
		o.onHit(current, math.max(minimum, falloff ^ (number - 1)), number)

		if(number > bounces) then
			return
		end

		local nearest, nearestDistance
		for _, tid in ipairs(Attacks.enemies(cid, pos, jumpRange)) do
			if(not hitList[tid]) then
				local distance = getDistanceBetween(pos, getCreaturePosition(tid))
				if(not nearestDistance or distance < nearestDistance) then
					nearest, nearestDistance = tid, distance
				end
			end
		end

		if(nearest) then
			addEvent(jump, o.delay or 180, nearest, pos, number + 1)
		end
	end

	jump(target, o.from or getCreaturePosition(cid), 1)
end

-- Random walk ----------------------------------------------------------------------------------------------------------------------
-- The strike starts at o.from (a position, usually the monster) and moves one tile at a time. Each step picks a random free tile in front of
-- the previous one (the same direction, or one of the two diagonals next to it); the walk never turns more than o.maxTurn steps of 45 degrees (default 1) away from the
-- original direction, never repeats a tile, never enters a protection zone and never crosses a wall (the next tile has to be in clear sight
-- of the current one and not blocked). A step that finds no way ends the walk.
-- o.from (position), o.direction ({dx, dy}, e.g. from Attacks.sign), o.steps (8), o.interval ms between tiles (150)
-- o.onStep(pos, number)       every tile, including the starting one (number 0): effects
-- o.onHit(tid, number, pos)   every valid enemy standing on the tile when it is struck

function Attacks.randomWalk(cid, o)
	local steps, interval = o.steps or 8, o.interval or 150
	local origin = ringIndex(o.direction or {0, 0}) or math.random(#Attacks.ring)
	local visited = {[key(o.from)] = true}

	local function circular(a, b)
		local d = math.abs(a - b) % #Attacks.ring
		return math.min(d, #Attacks.ring - d)
	end

	local function nextTile(current, index)
		-- forward first, then the two diagonals; random order inside the same preference
		local options = {index, index - 1, index + 1}
		for i = #options, 2, -1 do
			local j = math.random(i)
			options[i], options[j] = options[j], options[i]
		end

		for _, candidate in ipairs(options) do
			local wrapped = (candidate - 1) % #Attacks.ring + 1
			if(circular(wrapped, origin) <= (o.maxTurn or 1)) then
				local v = Attacks.ring[wrapped]
				local pos = {x = current.x + v[1], y = current.y + v[2], z = current.z}
				if(not visited[key(pos)] and isSightClear(current, pos, true) and Attacks.tileOpen(cid, pos, true)) then
					return pos, wrapped
				end
			end
		end

		return nil
	end

	local function walk(number, current, index)
		if(not isCreature(cid)) then
			return
		end

		if(o.onStep) then
			o.onStep(current, number)
		end

		if(o.onHit) then
			for _, tid in ipairs(Attacks.enemiesOn(cid, {current}, current, 1)) do
				o.onHit(tid, number, current)
			end
		end

		if(number >= steps) then
			return
		end

		local pos, wrapped = nextTile(current, index)
		if(not pos) then
			return
		end

		visited[key(pos)] = true
		addEvent(walk, interval, number + 1, pos, wrapped)
	end

	walk(0, o.from, origin)
end
