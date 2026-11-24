-- Library of boss mechanics (tier II and above). Every boss spell is defined with BossSpell.define(name, function(cid, memory, target) ... end)
-- in the file of its tier (data/lib/395-bosses-tier2.lua...) and the script of the spell (data/spells/scripts/ai/<name>.lua) only calls
-- BossSpell.cast(cid, "Spell Name"). Documentation in doc/sistemas/36-bosses.md.
--
-- All the mechanics are telegraphed (Telegraph, data/lib/392-telegraph.lua). Common options (o): delay (ms between the mark and the hit),
-- combat, min, max (positive), effect, warn, onHit(pid, pos), onLand(tiles) and the shortcuts:
--   slow = {percent (0 to 1), ms}                               slows whoever is hit
--   dot  = {combat, damage, ticks, interval, effect}            damage over time on whoever is hit (a new one replaces the old one)
--
-- Mechanics:
--   rain(cid, o)           count marks (radius, spread, disc) over random players, one after the other (interval)
--   cone(cid, toPos, o)    cone of `length` tiles towards a position; turns = {0, 2} also hits the opposite side, {0, 1, 2, 3} the four sides
--   lanes(cid, toPos, o)   parallel lines towards a position (offsets = {-3, 0, 3}, length)
--   nova(cid, o)           disc of `radius` around the boss with a safe square (`safe` = radius) glued to him
--   waves(cid, o)          bands = {{inner, outer}, ...}: square rings that hit one after the other (reverse = from the outside in)
--   arms(cid, o)           stages = {BossSpell.STRAIGHT, BossSpell.DIAGONAL...}: the lines around the boss hit stage by stage (length, interval)
--   stripes(cid, o)        stripes of `width` tiles with a `gap` lane between them, vertical or horizontal at random
--   bait(cid, o)           the mark FOLLOWS `count` players for `follow` ms and then freezes: run away from your allies
--   chain(cid, o)          hits a player and jumps to the nearest ones (hops, hop = max distance of each jump)
--   leap(cid, toPos, o)    marks the area (radius), jumps next to it and hits; o.after(cid, center) runs when he lands
--   safeSpots(cid, o)      the whole area (radius) is marked EXCEPT `spots` squares 3x3 shown in green: stand inside one
--   summon(cid, list, max, ani) / shield(cid, list, say, ani)    list = {{"Monster", count}, ...}; the shield blocks all the damage until
--                          the AI takes it down (state of the boss)

BossSpell = {defs = {}}
local BS = BossSpell

BS.stacks = {}
BS.STRAIGHT = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}
BS.DIAGONAL = {{1, -1}, {1, 1}, {-1, 1}, {-1, -1}}

local vectors = {[0] = {0, -1}, [1] = {1, 0}, [2] = {0, 1}, [3] = {-1, 0}}

local function alive(cid)
	return cid and isCreature(cid) and getCreatureHealth(cid) > 0
end

local function key(pos)
	return pos.x .. ":" .. pos.y
end

local function shuffle(list)
	for i = #list, 2, -1 do
		local j = math.random(i)
		list[i], list[j] = list[j], list[i]
	end

	return list
end

local function area(center, radius, disc)
	return disc and Telegraph.disc(center, radius) or Telegraph.square(center, radius)
end

function BS.define(name, fn)
	BS.defs[name] = fn
end

-- called by the script of the spell: finds the definition and gives it the current target (or nil)
function BS.cast(cid, name)
	local fn = BS.defs[name]
	if(not fn) then
		return false
	end

	local target = getCreatureTarget(cid)
	if(not target or target == 0 or not isCreature(target)) then
		target = nil
	end

	return fn(cid, MonsterAI.getMemory(cid), target) ~= false
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Effects on the players
-- ---------------------------------------------------------------------------------------------------------------------------
function BS.slow(pid, percent, ms)
	doRemoveCondition(pid, CONDITION_PARALYZE)
	local condition = createConditionObject(CONDITION_PARALYZE)
	setConditionParam(condition, CONDITION_PARAM_TICKS, ms)
	setConditionFormula(condition, -percent, 0, -percent, 0)
	doAddCondition(pid, condition)
end

local dotTokens = {}

-- damage over time: `ticks` hits of `damage`, one every `interval` ms (a new dot of the same kind replaces the old one)
function BS.dot(cid, pid, spec)
	local id = pid .. ":" .. spec.combat
	local token = (dotTokens[id] or 0) + 1
	dotTokens[id] = token
	for i = 1, spec.ticks do
		addEvent(function()
			if(dotTokens[id] == token and isPlayer(pid)) then
				doTargetCombatHealth(alive(cid) and cid or 0, pid, spec.combat, -spec.damage, -spec.damage, spec.effect or CONST_ME_NONE)
			end
		end, i * spec.interval)
	end
end

local function hitFunction(cid, o)
	if(not o.slow and not o.dot and not o.onHit and not o.stack) then
		return nil
	end

	return function(pid, pos)
		if(o.slow) then
			BS.slow(pid, o.slow[1], o.slow[2])
			doSendMagicEffect(pos, CONST_ME_STUN)
		end

		if(o.dot) then
			BS.dot(cid, pid, o.dot)
		end

		if(o.stack) then
			BS.addStack(cid, pid, pos, o)
		end

		if(o.onHit) then
			o.onHit(pid, pos)
		end
	end
end

-- options of Telegraph.strike without the tiles
local function base(cid, o)
	local delay = o.delay or 1500
	local options = {
		caster = cid, delay = delay, refresh = delay, combat = o.combat, min = o.min, max = o.max, effect = o.effect,
		warn = o.warn, onHit = hitFunction(cid, o), onLand = o.onLand
	}

	-- linger = {ticks, interval, min, max, combat, effect}: the marked tiles stay dangerous (puddles) after the hit
	if(o.linger) then
		local spec, previous = o.linger, options.onLand
		options.onLand = function(tiles)
			if(previous) then
				previous(tiles)
			end

			for i = 1, spec.ticks or 5 do
				BS.later(cid, i * (spec.interval or 1000), function()
					Telegraph.strike({
						caster = cid, tiles = tiles, delay = 400, refresh = 400, combat = spec.combat or o.combat, min = spec.min, max = spec.max,
						effect = spec.effect or o.effect, warn = spec.effect or o.effect
					})
				end)
			end
		end
	end

	return options
end

local function withTiles(options, tiles)
	options.tiles = tiles
	return options
end

-- distance shoot from the boss, `ms` later
function BS.shoot(cid, to, ani, ms)
	addEvent(function()
		if(alive(cid)) then
			doSendDistanceShoot(getCreaturePosition(cid), to, ani)
		end
	end, math.max(0, ms or 0))
end

-- adds to onLand a shower of distance shoots from the boss to (half of) the tiles
local function shootOnLand(cid, options, tiles, ani)
	if(not ani) then
		return
	end

	local previous = options.onLand
	options.onLand = function(marked)
		if(alive(cid)) then
			local from = getCreaturePosition(cid)
			for i = 1, #tiles, 2 do
				doSendDistanceShoot(from, tiles[i], ani)
			end
		end

		if(previous) then
			previous(marked)
		end
	end
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Mechanics
-- ---------------------------------------------------------------------------------------------------------------------------
function BS.rain(cid, o)
	local players = MonsterAI.playersAround(cid, o.range or 9)
	if(#players == 0) then
		return false
	end

	local options, interval = base(cid, o), o.interval or 450
	Telegraph.strikes(options, o.count or 4, function(index)
		local pos = getCreaturePosition(players[math.random(#players)])
		local spread = o.spread or 1
		local center = {x = pos.x + math.random(-spread, spread), y = pos.y + math.random(-spread, spread), z = pos.z}
		if(o.ani) then
			BS.shoot(cid, center, o.ani, (index - 1) * interval + options.delay - 600)
		end

		return area(center, o.radius or 1, o.disc)
	end, interval)

	return true
end

function BS.cone(cid, toPos, o)
	local from = getCreaturePosition(cid)
	local direction = Telegraph.directionTo(from, toPos)
	local tiles = {}
	for _, turn in ipairs(o.turns or {0}) do
		tiles = Telegraph.merge(tiles, Telegraph.cone(from, (direction + turn) % 4, o.length or 5))
	end

	local options = withTiles(base(cid, o), tiles)
	shootOnLand(cid, options, tiles, o.ani)
	Telegraph.strike(options)
	return true
end

function BS.lanes(cid, toPos, o)
	local from = getCreaturePosition(cid)
	local v = vectors[Telegraph.directionTo(from, toPos)]
	local side = {-v[2], v[1]}
	local tiles = {}
	for _, offset in ipairs(o.offsets or {0}) do
		for i = 1, o.length or 8 do
			table.insert(tiles, {x = from.x + v[1] * i + side[1] * offset, y = from.y + v[2] * i + side[2] * offset, z = from.z})
		end
	end

	tiles = Telegraph.merge(tiles)
	local options = withTiles(base(cid, o), tiles)
	shootOnLand(cid, options, tiles, o.ani)
	Telegraph.strike(options)
	return true
end

function BS.nova(cid, o)
	local from = getCreaturePosition(cid)
	local safe = {}
	if(o.safe) then
		for _, tile in ipairs(Telegraph.square(from, o.safe)) do
			safe[key(tile)] = true
		end
	end

	local tiles = {}
	for _, tile in ipairs(Telegraph.disc(from, o.radius or 5)) do
		if(not safe[key(tile)]) then
			table.insert(tiles, tile)
		end
	end

	local options = withTiles(base(cid, o), tiles)
	local previous = options.onLand
	options.onLand = function(marked)
		if(alive(cid)) then
			doSendMagicEffect(getCreaturePosition(cid), o.effect or CONST_ME_HITAREA)
		end

		if(previous) then
			previous(marked)
		end
	end

	Telegraph.strike(options)
	return true
end

function BS.waves(cid, o)
	local center = getCreaturePosition(cid)
	local bands = {}
	for i, band in ipairs(o.bands) do
		bands[i] = band
	end

	if(o.reverse) then
		for i = 1, math.floor(#bands / 2) do
			bands[i], bands[#bands + 1 - i] = bands[#bands + 1 - i], bands[i]
		end
	end

	Telegraph.strikes(base(cid, o), #bands, function(index)
		local inner = {}
		for _, tile in ipairs(Telegraph.square(center, bands[index][1])) do
			inner[key(tile)] = true
		end

		local tiles = {}
		for _, tile in ipairs(Telegraph.square(center, bands[index][2])) do
			if(not inner[key(tile)]) then
				table.insert(tiles, tile)
			end
		end

		return tiles
	end, o.interval or 650)

	return true
end

function BS.arms(cid, o)
	local from = getCreaturePosition(cid)
	Telegraph.strikes(base(cid, o), #o.stages, function(index)
		local tiles = {}
		for _, arm in ipairs(o.stages[index]) do
			for i = 1, o.length or 7 do
				table.insert(tiles, {x = from.x + arm[1] * i, y = from.y + arm[2] * i, z = from.z})
			end
		end

		return Telegraph.merge(tiles)
	end, o.interval or 800)

	return true
end

function BS.stripes(cid, o)
	local from = getCreaturePosition(cid)
	local width, gap, n, span = o.width or 2, o.gap or 1, o.n or 2, o.span or 7
	local vertical, shift = math.random(2) == 1, math.random(0, width + gap - 1)
	local tiles = {}
	for k = -n, n do
		for w = 0, width - 1 do
			local offset = k * (width + gap) + w + shift
			for along = -span, span do
				if(vertical) then
					table.insert(tiles, {x = from.x + offset, y = from.y + along, z = from.z})
				else
					table.insert(tiles, {x = from.x + along, y = from.y + offset, z = from.z})
				end
			end
		end
	end

	Telegraph.strike(withTiles(base(cid, o), Telegraph.merge(tiles)))
	return true
end

-- the mark follows `count` players (a red effect on their tile) for `follow` ms and then freezes on the area (radius) where they are
function BS.bait(cid, o)
	local players = MonsterAI.playersAround(cid, o.range or 9)
	if(#players == 0) then
		return false
	end

	shuffle(players)
	local follow, tick = o.follow or 2200, 500
	for index = 1, math.min(o.count or 1, #players) do
		local pid = players[index]
		for t = 0, follow - tick, tick do
			addEvent(function()
				if(alive(cid) and isPlayer(pid)) then
					doSendMagicEffect(getCreaturePosition(pid), CONST_ME_MAGIC_RED)
				end
			end, t)
		end

		addEvent(function()
			if(alive(cid) and isPlayer(pid)) then
				Telegraph.strike(withTiles(base(cid, o), area(getCreaturePosition(pid), o.radius or 2, o.disc)))
			end
		end, follow)
	end

	return true
end

-- hits a player and jumps to the nearest player that was not hit yet (up to `hop` tiles away) `hops` times
function BS.chain(cid, o)
	local players = MonsterAI.playersAround(cid, o.range or 9)
	if(#players == 0) then
		return false
	end

	local used, delay = {}, o.delay or 800
	local function hop(left, current)
		if(left <= 0 or not alive(cid) or not isPlayer(current)) then
			return
		end

		used[current] = true
		local center = getCreaturePosition(current)
		Telegraph.strike(withTiles(base(cid, o), area(center, o.radius or 1, o.disc)))
		addEvent(function()
			if(not alive(cid)) then
				return
			end

			local best, bestDistance, any
			for _, pid in ipairs(MonsterAI.playersAround(cid, o.range or 9)) do
				if(pid ~= current) then
					any = any or pid
					local pos = getCreaturePosition(pid)
					local distance = math.max(math.abs(pos.x - center.x), math.abs(pos.y - center.y))
					if(not used[pid] and distance <= (o.hop or 5) and (not bestDistance or distance < bestDistance)) then
						best, bestDistance = pid, distance
					end
				end
			end

			best = best or any or current
			if(o.ani and isPlayer(best)) then
				doSendDistanceShoot(center, getCreaturePosition(best), o.ani)
			end

			hop(left - 1, best)
		end, delay)
	end

	hop(o.hops or 4, players[math.random(#players)])
	return true
end

function BS.leap(cid, toPos, o)
	local center = {x = toPos.x, y = toPos.y, z = toPos.z}
	local options = withTiles(base(cid, o), area(center, o.radius or 1, o.disc))
	options.onLand = function()
		local from = getCreaturePosition(cid)
		local offsets = shuffle({{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}})
		for _, offset in ipairs(offsets) do
			local landing = {x = center.x + offset[1], y = center.y + offset[2], z = center.z}
			if(doTeleportThing(cid, landing, false)) then
				doSendMagicEffect(from, CONST_ME_POFF)
				doSendMagicEffect(landing, CONST_ME_GROUNDSHAKER)
				break
			end
		end

		if(o.after) then
			o.after(cid, center)
		end
	end

	if(o.ani) then
		BS.shoot(cid, center, o.ani, 0)
	end

	Telegraph.strike(options)
	return true
end

-- the area (radius) is marked except `spots` squares 3x3 (green) that the players must reach before the hit
function BS.safeSpots(cid, o)
	local center = getCreaturePosition(cid)
	local radius, count = o.radius or 7, o.spots or 3
	local players = MonsterAI.playersAround(cid, radius + 2)
	local spots, safe, tries = {}, {}, 0
	while(#spots < count and tries < 60) do
		tries = tries + 1
		local anchor = center
		if(#players > 0 and tries % 2 == 0) then
			anchor = getCreaturePosition(players[math.random(#players)])
		end

		local spot = {x = anchor.x + math.random(-3, 3), y = anchor.y + math.random(-3, 3), z = center.z}
		local ok = math.max(math.abs(spot.x - center.x), math.abs(spot.y - center.y)) <= radius - 1 and type(getTileInfo(spot)) == "table"
		for _, other in ipairs(spots) do
			if(math.max(math.abs(spot.x - other.x), math.abs(spot.y - other.y)) < 4) then
				ok = false
			end
		end

		if(ok) then
			table.insert(spots, spot)
		end
	end

	if(#spots == 0) then
		table.insert(spots, {x = center.x + 2, y = center.y, z = center.z})
	end

	local shown = {}
	for _, spot in ipairs(spots) do
		for _, tile in ipairs(Telegraph.square(spot, 1)) do
			safe[key(tile)] = true
			table.insert(shown, tile)
		end
	end

	local tiles = {}
	for _, tile in ipairs(Telegraph.disc(center, radius)) do
		if(not safe[key(tile)]) then
			table.insert(tiles, tile)
		end
	end

	local delay = o.delay or 2500
	for t = 0, delay - 300, 600 do
		addEvent(function()
			if(alive(cid)) then
				for _, tile in ipairs(shown) do
					doSendMagicEffect(tile, CONST_ME_MAGIC_GREEN)
				end
			end
		end, t)
	end

	Telegraph.strike(withTiles(base(cid, o), tiles))
	return true
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Summons and shield
-- ---------------------------------------------------------------------------------------------------------------------------
function BS.summon(cid, list, max, ani)
	local pos = getCreaturePosition(cid)
	doSendMagicEffect(pos, CONST_ME_BLOCKHIT)
	if(ani) then
		for _, tile in ipairs(Telegraph.ring(pos, 2)) do
			doSendDistanceShoot(pos, tile, ani)
		end
	end

	local created = 0
	for _, entry in ipairs(list) do
		created = created + MonsterAI.summon(cid, entry[1], entry[2], max)
	end

	return created > 0
end

-- shield (takes no damage) + guards; the state of the boss takes the shield down when the guards die (see shieldState in the tier files)
function BS.shield(cid, list, say, ani)
	MonsterAI.setImmune(cid, true)
	if(say) then
		MonsterAI.say(cid, say)
	end

	BS.summon(cid, list, nil, ani)
	return true
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Tier III mechanics (they make the players depend on each other and on the arena)
--   tether(cid, o)    links `pairs` pairs of players with a beam for `time` ms; mode "together": they must be at most `distance` tiles
--                     from each other when it ends; mode "apart": at least `distance` tiles. Whoever breaks the rule takes damage
--   stack(cid, o)     like bait, but the area is meant to be SHARED: `total` damage divided by the players inside (up to `maxEach`
--                     each), so stack with your allies instead of running away
--   cleanse(cid, o)   marks `count` players (red) and shows `spots` cleansing squares (green); when `time` ends, the marked players that
--                     are not inside a green square take the damage (combat, min, max, dot)
--   field(cid, o)     hazard that stays: `ticks` strikes, one every `interval` ms, on the square ring inner..outer around the boss
--                     (without `inner` it is the whole square): "outside" hazards push the players in, "inside" ones push them out
--   beam(cid, o)      beams that ROTATE around the boss (`arms` = 1, 2 or 4 beams, `steps` steps of `interval` ms, `reverse`, `width` 1 or 3)
--   siphon(cid, o)    for `ticks` seconds each living summon heals the boss `percent`% of his health per tick: kill the adds
--   pull(cid, o)      drags every player to the ring of radius `to` around the boss (combine with a nova right after)
--   later(cid, ms, fn) runs fn after ms if the boss is still alive (chain strikes: echoes, second hits)
-- ---------------------------------------------------------------------------------------------------------------------------
function BS.later(cid, ms, fn)
	addEvent(function()
		if(alive(cid)) then
			fn()
		end
	end, ms)
end

local marks = {CONST_ME_MAGIC_BLUE, CONST_ME_MAGIC_RED, CONST_ME_MAGIC_BLUE, CONST_ME_MAGIC_RED}

function BS.tether(cid, o)
	local players = MonsterAI.playersAround(cid, o.range or 9)
	local amount = math.min(o.pairs or 1, math.floor(#players / 2))
	if(amount < 1) then
		return false
	end

	shuffle(players)
	local time, tick = o.time or 5000, 500
	local apart, distance = o.mode == "apart", o.distance or (o.mode == "apart" and 5 or 4)
	for index = 1, amount do
		local a, b = players[index * 2 - 1], players[index * 2]
		for t = 0, time - tick, tick do
			addEvent(function()
				if(alive(cid) and isPlayer(a) and isPlayer(b)) then
					local pa, pb = getCreaturePosition(a), getCreaturePosition(b)
					doSendDistanceShoot(pa, pb, o.ani or CONST_ANI_ENERGY)
					doSendMagicEffect(pa, marks[index])
					doSendMagicEffect(pb, marks[index])
				end
			end, t)
		end

		addEvent(function()
			if(not alive(cid) or not isPlayer(a) or not isPlayer(b)) then
				return
			end

			local pa, pb = getCreaturePosition(a), getCreaturePosition(b)
			local far = math.max(math.abs(pa.x - pb.x), math.abs(pa.y - pb.y))
			local broken = (apart and far < distance) or (not apart and far > distance)
			for _, pid in ipairs({a, b}) do
				local pos = getCreaturePosition(pid)
				if(broken and not getTilePzInfo(pos)) then
					doTargetCombatHealth(cid, pid, o.combat, -o.min, -o.max, o.effect or CONST_ME_NONE)
				else
					doSendMagicEffect(pos, CONST_ME_MAGIC_GREEN)
				end
			end
		end, time)
	end

	return true
end

function BS.stack(cid, o)
	local players = MonsterAI.playersAround(cid, o.range or 9)
	if(#players == 0) then
		return false
	end

	shuffle(players)
	local follow, tick = o.follow or 2500, 500
	for index = 1, math.min(o.count or 1, #players) do
		local pid = players[index]
		for t = 0, follow - tick, tick do
			addEvent(function()
				if(alive(cid) and isPlayer(pid)) then
					doSendMagicEffect(getCreaturePosition(pid), CONST_ME_MAGIC_GREEN)
				end
			end, t)
		end

		addEvent(function()
			if(not alive(cid) or not isPlayer(pid)) then
				return
			end

			local options = withTiles(base(cid, {delay = o.delay or 1000, effect = o.effect, warn = o.warn}), area(getCreaturePosition(pid), o.radius or 2, o.disc))
			options.onLand = function(marked)
				local set = {}
				for _, tile in ipairs(marked) do
					set[key(tile)] = true
				end

				local hit = {}
				for _, other in ipairs(MonsterAI.playersAround(cid, 14)) do
					local pos = getCreaturePosition(other)
					if(set[key(pos)] and not getTilePzInfo(pos)) then
						table.insert(hit, other)
					end
				end

				if(#hit > 0) then
					local share = math.min(o.maxEach or o.total, math.floor(o.total / #hit))
					for _, other in ipairs(hit) do
						doTargetCombatHealth(cid, other, o.combat, -share, -share, o.effect or CONST_ME_NONE)
					end
				end
			end

			Telegraph.strike(options)
		end, follow)
	end

	return true
end

function BS.cleanse(cid, o)
	local players = MonsterAI.playersAround(cid, o.range or 9)
	if(#players == 0) then
		return false
	end

	shuffle(players)
	local center = getCreaturePosition(cid)
	local radius, count = o.radius or 6, o.spots or 3
	local spots, tries = {}, 0
	while(#spots < count and tries < 60) do
		tries = tries + 1
		local anchor = center
		if(tries % 2 == 0) then
			anchor = getCreaturePosition(players[math.random(#players)])
		end

		local spot = {x = anchor.x + math.random(-3, 3), y = anchor.y + math.random(-3, 3), z = center.z}
		local ok = math.max(math.abs(spot.x - center.x), math.abs(spot.y - center.y)) <= radius and type(getTileInfo(spot)) == "table"
		for _, other in ipairs(spots) do
			if(math.max(math.abs(spot.x - other.x), math.abs(spot.y - other.y)) < 4) then
				ok = false
			end
		end

		if(ok) then
			table.insert(spots, spot)
		end
	end

	if(#spots == 0) then
		table.insert(spots, {x = center.x + 2, y = center.y, z = center.z})
	end

	local safe, shown = {}, {}
	for _, spot in ipairs(spots) do
		for _, tile in ipairs(Telegraph.square(spot, 1)) do
			safe[key(tile)] = true
			table.insert(shown, tile)
		end
	end

	local marked = {}
	for index = 1, math.min(o.count or 1, #players) do
		table.insert(marked, players[index])
	end

	local time, tick = o.time or 5000, 500
	for t = 0, time - tick, tick do
		addEvent(function()
			if(alive(cid)) then
				for _, tile in ipairs(shown) do
					doSendMagicEffect(tile, CONST_ME_MAGIC_GREEN)
				end

				for _, pid in ipairs(marked) do
					if(isPlayer(pid)) then
						doSendMagicEffect(getCreaturePosition(pid), CONST_ME_MAGIC_RED)
					end
				end
			end
		end, t)
	end

	addEvent(function()
		if(not alive(cid)) then
			return
		end

		for _, pid in ipairs(marked) do
			if(isPlayer(pid)) then
				local pos = getCreaturePosition(pid)
				if(safe[key(pos)] or getTilePzInfo(pos)) then
					doSendMagicEffect(pos, CONST_ME_MAGIC_GREEN)
				else
					doTargetCombatHealth(cid, pid, o.combat, -o.min, -o.max, o.effect or CONST_ME_NONE)
					if(o.dot) then
						BS.dot(cid, pid, o.dot)
					end
				end
			end
		end
	end, time)

	return true
end

function BS.field(cid, o)
	local center = getCreaturePosition(cid)
	local excluded = {}
	if(o.inner) then
		for _, tile in ipairs(Telegraph.square(center, o.inner)) do
			excluded[key(tile)] = true
		end
	end

	local tiles = {}
	for _, tile in ipairs(Telegraph.square(center, o.outer or 3)) do
		if(not excluded[key(tile)]) then
			table.insert(tiles, tile)
		end
	end

	for i = 1, o.ticks or 6 do
		BS.later(cid, (i - 1) * (o.interval or 1000), function()
			Telegraph.strike(withTiles(base(cid, o), tiles))
		end)
	end

	return true
end

local ring8 = {{0, -1}, {1, -1}, {1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}}

function BS.beam(cid, o)
	local from = getCreaturePosition(cid)
	local steps, arms, length = o.steps or 8, o.arms or 1, o.length or 9
	local half = math.floor((o.width or 1) / 2)
	local direction, start = o.reverse and -1 or 1, math.random(0, 7)
	Telegraph.strikes(base(cid, o), steps, function(index)
		local tiles = {}
		local step = (start + direction * (index - 1)) % 8
		for a = 0, arms - 1 do
			local arm = ring8[(step + a * math.floor(8 / arms)) % 8 + 1]
			local side = {-arm[2], arm[1]}
			for i = 1, length do
				for w = -half, half do
					table.insert(tiles, {x = from.x + arm[1] * i + side[1] * w, y = from.y + arm[2] * i + side[2] * w, z = from.z})
				end
			end
		end

		return Telegraph.merge(tiles)
	end, o.interval or 450)

	return true
end

function BS.siphon(cid, o)
	for i = 1, o.ticks or 10 do
		BS.later(cid, i * (o.interval or 1000), function()
			local adds = MonsterAI.summonCount(cid)
			if(adds > 0) then
				MonsterAI.heal(cid, adds * (o.percent or 0.5))
			end
		end)
	end
end

function BS.pull(cid, o)
	local players = MonsterAI.playersAround(cid, o.range or 9)
	if(#players == 0) then
		return false
	end

	local center = getCreaturePosition(cid)
	local ring = shuffle(Telegraph.ring(center, o.to or 2))
	for _, pid in ipairs(players) do
		doSendDistanceShoot(center, getCreaturePosition(pid), o.ani or CONST_ANI_ENERGY)
		for _, tile in ipairs(ring) do
			if(not tile.taken and doTeleportThing(pid, tile, false)) then
				tile.taken = true
				doSendMagicEffect(tile, CONST_ME_POFF)
				break
			end
		end
	end

	return true
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Tier IV mechanics (they last: debuffs that pile up, puddles, timed bombs, matching colors)
--   stack = {extra, max, ms, name, effect}   option of any strike: every hit adds a stack to the player (up to `max`, for `ms`) and
--                     every hit he takes while having stacks causes `extra` more damage per stack (BossSpell.stackCount(pid))
--   linger = {ticks, interval, min, max, combat, effect}   option of any strike: the marked tiles stay dangerous (puddles)
--   polarity(cid, o)  the players are split in two colors (red and blue effect over them) and two zones (red and blue) are shown:
--                     when `time` ends whoever is NOT inside the zone of his color takes the damage
--   bombs(cid, o)     summons `count` bombs (o.monster) with a countdown over their heads; the ones still alive after `time` ms
--                     explode (radius, combat, min, max) and heal the boss `heal`% each: kill them before
-- ---------------------------------------------------------------------------------------------------------------------------
function BS.stackCount(pid)
	local entry = BS.stacks[pid]
	if(entry and entry.expires > os.mtime()) then
		return entry.count
	end

	return 0
end

function BS.addStack(cid, pid, pos, o)
	local spec = o.stack
	local before = BS.stackCount(pid)
	if(before > 0 and spec.extra) then
		local extra = before * spec.extra
		doTargetCombatHealth(alive(cid) and cid or 0, pid, o.combat or COMBAT_PHYSICALDAMAGE, -extra, -extra, CONST_ME_NONE)
	end

	local count = math.min(spec.max or 5, before + 1)
	BS.stacks[pid] = {count = count, expires = os.mtime() + (spec.ms or 20000)}
	doSendMagicEffect(pos, spec.effect or CONST_ME_MAGIC_RED)
	if(MESSAGE_STATUS_SMALL) then
		doPlayerSendTextMessage(pid, MESSAGE_STATUS_SMALL, (spec.name or "Stacks") .. ": " .. count .. "/" .. (spec.max or 5))
	end
end

local function pickSpots(center, radius, count, players, gap)
	local spots, tries = {}, 0
	while(#spots < count and tries < 80) do
		tries = tries + 1
		local anchor = center
		if(#players > 0 and tries % 2 == 0) then
			anchor = getCreaturePosition(players[math.random(#players)])
		end

		local spot = {x = anchor.x + math.random(-3, 3), y = anchor.y + math.random(-3, 3), z = center.z}
		local ok = math.max(math.abs(spot.x - center.x), math.abs(spot.y - center.y)) <= radius and type(getTileInfo(spot)) == "table"
		for _, other in ipairs(spots) do
			if(math.max(math.abs(spot.x - other.x), math.abs(spot.y - other.y)) < gap) then
				ok = false
			end
		end

		if(ok) then
			table.insert(spots, spot)
		end
	end

	return spots
end

function BS.polarity(cid, o)
	local players = MonsterAI.playersAround(cid, o.range or 10)
	if(#players == 0) then
		return false
	end

	shuffle(players)
	local center = getCreaturePosition(cid)
	local spots = pickSpots(center, o.radius or 7, 2, players, 6)
	if(#spots < 2) then
		spots = {{x = center.x - 4, y = center.y, z = center.z}, {x = center.x + 4, y = center.y, z = center.z}}
	end

	local effects, zones, tiles, group = {CONST_ME_MAGIC_RED, CONST_ME_MAGIC_BLUE}, {}, {}, {}
	for g = 1, 2 do
		zones[g], tiles[g] = {}, Telegraph.square(spots[g], o.zone or 2)
		for _, tile in ipairs(tiles[g]) do
			zones[g][key(tile)] = true
		end
	end

	for i, pid in ipairs(players) do
		group[pid] = i % 2 + 1
	end

	local time, tick = o.time or 6000, 500
	for t = 0, time - tick, tick do
		addEvent(function()
			if(not alive(cid)) then
				return
			end

			for g = 1, 2 do
				for _, tile in ipairs(tiles[g]) do
					doSendMagicEffect(tile, effects[g])
				end
			end

			for _, pid in ipairs(players) do
				if(isPlayer(pid)) then
					doSendMagicEffect(getCreaturePosition(pid), effects[group[pid]])
				end
			end
		end, t)
	end

	addEvent(function()
		if(not alive(cid)) then
			return
		end

		for _, pid in ipairs(players) do
			if(isPlayer(pid)) then
				local pos = getCreaturePosition(pid)
				if(zones[group[pid]][key(pos)] or getTilePzInfo(pos)) then
					doSendMagicEffect(pos, CONST_ME_MAGIC_GREEN)
				else
					doTargetCombatHealth(cid, pid, o.combat, -o.min, -o.max, o.effect or CONST_ME_NONE)
					if(o.dot) then
						BS.dot(cid, pid, o.dot)
					end
				end
			end
		end
	end, time)

	return true
end

function BS.bombs(cid, o)
	local before = {}
	for _, id in ipairs(getCreatureSummons(cid) or {}) do
		before[id] = true
	end

	MonsterAI.summon(cid, o.monster, o.count or 2)
	local fresh = {}
	for _, id in ipairs(getCreatureSummons(cid) or {}) do
		if(not before[id]) then
			table.insert(fresh, id)
		end
	end

	if(#fresh == 0) then
		return false
	end

	local time = o.time or 9000
	for _, bomb in ipairs(fresh) do
		-- countdown over the head of the bomb
		for second = 1, math.floor(time / 1000) do
			addEvent(function()
				if(isCreature(bomb) and alive(cid)) then
					doCreatureSay(bomb, tostring(math.floor(time / 1000) - second + 1), TALKTYPE_MONSTER)
				end
			end, (second - 1) * 1000)
		end

		-- the blast: marked 1 s before, the bomb is removed and the boss heals
		addEvent(function()
			if(not isCreature(bomb) or not alive(cid)) then
				return
			end

			local pos = getCreaturePosition(bomb)
			Telegraph.strike({
				caster = cid, tiles = area(pos, o.radius or 4, true), delay = 1000, refresh = 1000, combat = o.combat, min = o.min, max = o.max, effect = o.effect,
				onLand = function()
					if(isCreature(bomb)) then
						doRemoveCreature(bomb)
					end

					if(alive(cid) and o.heal) then
						MonsterAI.heal(cid, o.heal)
					end
				end
			})
		end, time - 1000)
	end

	return true
end

-- ---------------------------------------------------------------------------------------------------------------------------
-- Tier V mechanics (the fight is a sequence of checks: where you stand, who stands near you, how much damage the group does)
--   sectors(cid, o)   the arena (radius) is cut in `slices` slices like a pie; `count` slices are marked and hit; with `complement` the
--                     slices that were safe are hit `gap` ms later (so you have to cross the arena between the two hits)
--   seeker(cid, o)    `count` marks leave the boss, walk `steps` tiles (one per `interval` ms) towards the CURRENT position of a player each
--                     and explode where they stop (radius): kite them away from the group
--   channel(cid, o)   DPS CHECK: the boss channels for `time` ms (a countdown with the progress shows over him); if the players do not take
--                     `percent`% of his total health meanwhile, everybody in range takes the (huge) damage; otherwise he is interrupted
--   (pull with a big `to` throws the players to the edge of the arena: pull(cid, {to = 7}) and then pull(cid, {to = 2}) = gravity)
-- ---------------------------------------------------------------------------------------------------------------------------
local atan2 = math.atan2 or math.atan

function BS.sectors(cid, o)
	local center = getCreaturePosition(cid)
	local slices = o.slices or 8
	local bySlice = {}
	for i = 0, slices - 1 do
		bySlice[i] = {}
	end

	for _, tile in ipairs(Telegraph.disc(center, o.radius or 9)) do
		local angle = atan2(tile.y - center.y, tile.x - center.x)
		local index = math.floor((angle + math.pi) / (2 * math.pi) * slices) % slices
		table.insert(bySlice[index], tile)
	end

	local order = {}
	for i = 0, slices - 1 do
		table.insert(order, i)
	end

	shuffle(order)
	local first, second = {}, {}
	for position, index in ipairs(order) do
		local target = position <= (o.count or math.floor(slices / 2)) and first or second
		for _, tile in ipairs(bySlice[index]) do
			table.insert(target, tile)
		end
	end

	Telegraph.strike(withTiles(base(cid, o), first))
	if(o.complement) then
		local again = {}
		for k, v in pairs(o) do
			again[k] = v
		end

		again.delay = o.delay2 or 1300
		again.linger, again.stack = nil, nil
		BS.later(cid, o.gap or 1500, function()
			Telegraph.strike(withTiles(base(cid, again), second))
		end)
	end

	return true
end

local function sign(n)
	return n > 0 and 1 or (n < 0 and -1 or 0)
end

function BS.seeker(cid, o)
	local players = MonsterAI.playersAround(cid, o.range or 10)
	if(#players == 0) then
		return false
	end

	shuffle(players)
	local steps, interval = o.steps or 7, o.interval or 450
	for index = 1, o.count or 2 do
		local pid = players[(index - 1) % #players + 1]
		local current = getCreaturePosition(cid)
		for step = 1, steps do
			BS.later(cid, (index - 1) * 500 + step * interval, function()
				if(not isPlayer(pid)) then
					return
				end

				local target = getCreaturePosition(pid)
				current = {x = current.x + sign(target.x - current.x), y = current.y + sign(target.y - current.y), z = current.z}
				doSendMagicEffect(current, o.trail or CONST_ME_MAGIC_RED)
				if(step == steps) then
					Telegraph.strike(withTiles(base(cid, o), area(current, o.radius or 1, o.disc)))
				end
			end)
		end
	end

	return true
end

function BS.channel(cid, o)
	local max = getCreatureMaxHealth(cid)
	local start = getCreatureHealth(cid)
	local need = math.max(1, math.floor(max * (o.percent or 1.5) / 100))
	local time = o.time or 12000
	local seconds = math.floor(time / 1000)
	for second = 0, seconds - 1 do
		BS.later(cid, second * 1000, function()
			doSendMagicEffect(getCreaturePosition(cid), o.effect or CONST_ME_MAGIC_RED)
			local dealt = math.max(0, start - getCreatureHealth(cid))
			if(second % 3 == 0 or seconds - second <= 3) then
				MonsterAI.say(cid, (o.text or "Channeling") .. "... " .. (seconds - second) .. "s [" .. math.min(100, math.floor(dealt * 100 / need)) .. "%]", TALKTYPE_MONSTER)
			end
		end)
	end

	BS.later(cid, time, function()
		local dealt = math.max(0, start - getCreatureHealth(cid))
		if(dealt >= need) then
			MonsterAI.say(cid, "NO!", TALKTYPE_MONSTER_YELL)
			doSendMagicEffect(getCreaturePosition(cid), CONST_ME_STUN)
			if(o.onInterrupt) then
				o.onInterrupt(cid)
			end

			return
		end

		MonsterAI.say(cid, o.failText or "TOO LATE!", TALKTYPE_MONSTER_YELL)
		for _, pid in ipairs(MonsterAI.playersAround(cid, o.range or 16)) do
			local pos = getCreaturePosition(pid)
			if(not getTilePzInfo(pos)) then
				doTargetCombatHealth(cid, pid, o.combat, -o.min, -o.max, o.effect or CONST_ME_NONE)
			end
		end
	end)

	return true
end
