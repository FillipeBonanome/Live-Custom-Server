-- VFX: library of custom visual effects / animations (distance shoots + magic effects) for the server.
--
-- Every effect is a function of the VFX table, receives a target (position table or creature id) and an optional
-- table of options. Effects only draw things (no damage, no conditions), so they are safe to call from anywhere.
-- Every effect returns a handle id (or false when the arguments are invalid): VFX.stop(handle) cancels whatever
-- is still pending (useful for long effects like Orbit and Pulse).
--
-- Options shared by all effects:
--   delay    : milliseconds to wait before the effect starts (default 0)
--   skipVoid : do not draw on tiles that do not exist / have no ground (default false). Note: the server logs
--              "Tile not found" in the console for tiles that do not exist, so use it only when needed.
--   handle   : (advanced) reuse the handle of another effect, so VFX.stop cancels both
--
-- Distance shoots (CONST_ANI):
--   VFX.SkyFall(target, ani, options)    ani falling from the sky onto the target
--   VFX.Rain(target, ani, options)       many SkyFalls in an area during some time
--   VFX.Fountain(target, ani, options)   ani going up and falling around the target (reverse of SkyFall)
--   VFX.Spiral(target, ani, options)     ani leaving the center in a spiral
--   VFX.Circle(target, ani, options)     ani drawing a circle around the target
--   VFX.Explosion(target, ani, options)  ani leaving the center to every direction
--   VFX.Implosion(target, ani, options)  ani coming from the borders to the center
--   VFX.Beam(from, to, ani, options)     ani chain (or single bolt) between two points
--   VFX.Orbit(creature, ani, options)    ani orbiting a creature for some time
--   VFX.Lightning(target, ani, options)  zigzag bolt from the sky onto the target
--   VFX.Tornado(target, ani, options)    funnel of ani rising in a spiral
--   VFX.Helix(target, ani, options)      two (or more) strands of ani rising, like DNA
--   VFX.Burst(target, ani, options)      ani going out to a ring and coming back
--   VFX.Barrage(target, ani, options)    fan of ani leaving the target in a direction
--   VFX.Comet(target, ani, options)      ani crossing the screen diagonally with a trail
--   VFX.Snow(target, ani, options)       slow, drifting fall over an area
--
-- Magic effects (CONST_ME):
--   VFX.Wave(target, effect, options)    concentric rings spreading from the target
--   VFX.Line(target, effect, options)    effect walking in a line (direction, or to another point)
--   VFX.Pulse(target, effect, options)   same effect repeated on the target (follows creatures)
--   VFX.Cross(target, effect, options)   cross shape (4 directions)
--   VFX.Star(target, effect, options)    star shape (8 directions)
--   VFX.Ring(target, effect, options)    fixed ring of an effect around the target (optionally repeated)
--
-- Combined:
--   VFX.Meteor(target, options)          diagonal SkyFall + impact + shards
--   VFX.Summon(target, options)          Implosion + effect on the center (boss/npc spawn)
--   VFX.LevelUp(target, options)         spiral around the target + fireworks
--   VFX.Teleport(from, to, options)      leaving effect, sky fall and arrival effect (visual only, does not move anything)
--   VFX.Warning(target, options)         blinking mark on the ground, then an impact (boss mechanics)
--   VFX.Death(target, options)           big death effect: rings of ani, waves and fireworks
--   VFX.Storm(target, options)           rain + lightning + waves during some time
--   VFX.Buff(target, options)            colored helix: type = attack (red), mana (blue), defense (green), heal
--
-- Beam: when `to` is nil and `from` is a creature, the beam goes in front of the creature (options.range, default 5).
--
-- Library features:
--   VFX.Sequence(steps, options)         runs several effects in order inside one handle (see the function)
--   VFX.register(name, profile) / VFX.play(name, target, options)   named, reusable combinations
--   Elements: any effect that takes an ani/effect accepts "fire", "ice", "energy", "earth", "holy" or "death"
--             instead (VFX.Rain(cid, "ice")); Meteor/Warning/Death accept options.element
--
-- Helpers:
--   VFX.resolvePosition(target), VFX.isPosition(value), VFX.isVoid(pos), VFX.lookPosition(creature, distance)
--   VFX.circlePoints(pos, radius, points, startAngle), VFX.linePoints(from, to), VFX.ringTiles(pos, radius)
--   VFX.randomInDisc(pos, radius), VFX.stop(handle)
--
-- To add a new effect: create VFX.MyEffect(target, ...) in this file, resolve the target with
-- VFX.resolvePosition, create a handle with begin(options) and schedule every step with shoot/fx/VFX.at.

VFX = {
	-- the client only shows distance shoots inside its view range (about 8 tiles horizontally, 6 vertically)
	maxHeight = 5,
	maxRadius = 5,
	maxCount = 50,
	maxPoints = 64,

	-- direction (DIRECTION_*, 0 to 7) -> x, y step
	directions = {
		[0] = {0, -1}, -- north
		[1] = {1, 0}, -- east
		[2] = {0, 1}, -- south
		[3] = {-1, 0}, -- west
		[4] = {-1, 1}, -- south west
		[5] = {1, 1}, -- south east
		[6] = {-1, -1}, -- north west
		[7] = {1, -1} -- north east
	}
}

-- ---------------------------------------------------------------------------------------------------------------
-- internals: options, handles, scheduling
-- ---------------------------------------------------------------------------------------------------------------

local handles = {}
local nextHandle = 0

local function opt(options, key, default)
	if(options == nil or options[key] == nil) then
		return default
	end

	return options[key]
end

local function clamp(value, low, high)
	return math.min(math.max(value, low), high)
end

local function round(value)
	return math.floor(value + 0.5)
end

local function copyPos(pos)
	return {x = pos.x, y = pos.y, z = pos.z}
end

local function samePos(a, b)
	return a.x == b.x and a.y == b.y and a.z == b.z
end

-- creates (or reuses, with options.handle) a handle; the second value is true when this call owns the handle
local function begin(options)
	local shared = opt(options, "handle", nil)
	if(shared and handles[shared]) then
		return shared, false
	end

	nextHandle = nextHandle + 1
	handles[nextHandle] = {events = {}, last = 0, stopped = false}
	return nextHandle, true
end

-- called by the owner at the end of the effect: forgets the handle after the last scheduled step
local function finish(id, owned)
	local handle = handles[id]
	if(owned and handle) then
		addEvent(function()
			handles[id] = nil
		end, handle.last + 100)
	end

	return id
end

-- schedules fn(...) after delay ms inside the handle; returns false when the handle does not exist anymore
function VFX.at(id, delay, fn, ...)
	local handle = handles[id]
	if(not handle) then
		return false
	end

	delay = math.max(1, math.floor(delay or 0))
	if(delay > handle.last) then
		handle.last = delay
	end

	local args = {...}
	local event
	event = addEvent(function()
		handle.events[event] = nil
		if(not handle.stopped) then
			fn(unpack(args))
		end
	end, delay)

	handle.events[event] = true
	return true
end

-- cancels everything that is still pending in the handle
function VFX.stop(id)
	local handle = handles[id]
	if(not handle) then
		return false
	end

	handle.stopped = true
	for event in pairs(handle.events) do
		stopEvent(event)
	end

	handle.events = {}
	handles[id] = nil
	return true
end

-- ---------------------------------------------------------------------------------------------------------------
-- helpers: positions and geometry
-- ---------------------------------------------------------------------------------------------------------------

function VFX.isPosition(value)
	return type(value) == "table" and value.x ~= nil and value.y ~= nil and value.z ~= nil
end

-- target can be a position ({x=, y=, z=}) or a creature id; returns a new position table or nil
function VFX.resolvePosition(target)
	if(VFX.isPosition(target)) then
		return copyPos(target)
	end

	if(type(target) == "number" and isCreature(target)) then
		return copyPos(getCreaturePosition(target))
	end

	return nil
end

-- true when the tile does not exist or has no ground
function VFX.isVoid(pos)
	local info = getTileInfo(pos)
	return type(info) ~= "table" or not info.itemid or info.itemid == 0
end

function VFX.randomInDisc(pos, radius)
	radius = math.floor(radius or 0)
	if(radius > 0) then
		for i = 1, 10 do
			local dx, dy = math.random(-radius, radius), math.random(-radius, radius)
			if(dx * dx + dy * dy <= radius * radius) then
				return {x = pos.x + dx, y = pos.y + dy, z = pos.z}
			end
		end
	end

	return copyPos(pos)
end

local function pointAt(pos, radius, angle)
	return {x = pos.x + round(math.cos(angle) * radius), y = pos.y + round(math.sin(angle) * radius), z = pos.z}
end

-- points of a circle (angle in radians, 0 = east, growing clockwise on the screen); repeated tiles are removed
function VFX.circlePoints(pos, radius, points, startAngle)
	points = clamp(math.floor(points or 12), 1, VFX.maxPoints)
	startAngle = startAngle or 0

	local list, seen = {}, {}
	for i = 0, points - 1 do
		local p = pointAt(pos, radius, startAngle + (2 * math.pi * i) / points)
		local key = p.x .. "," .. p.y
		if(not seen[key]) then
			seen[key] = true
			table.insert(list, p)
		end
	end

	return list
end

-- tiles between two positions (Bresenham), including both of them
function VFX.linePoints(from, to)
	local list = {}
	local x, y = from.x, from.y
	local dx, dy = math.abs(to.x - x), math.abs(to.y - y)
	local sx, sy = (x < to.x) and 1 or -1, (y < to.y) and 1 or -1
	local err = dx - dy

	while(true) do
		table.insert(list, {x = x, y = y, z = from.z})
		if(x == to.x and y == to.y) then
			break
		end

		local e2 = 2 * err
		if(e2 > -dy) then
			err = err - dy
			x = x + sx
		end

		if(e2 < dx) then
			err = err + dx
			y = y + sy
		end
	end

	return list
end

-- tiles whose distance to the center is (rounded) equal to radius: the ring of a circle
function VFX.ringTiles(pos, radius)
	if(radius <= 0) then
		return {copyPos(pos)}
	end

	local list = {}
	for dx = -radius - 1, radius + 1 do
		for dy = -radius - 1, radius + 1 do
			if(round(math.sqrt(dx * dx + dy * dy)) == radius) then
				table.insert(list, {x = pos.x + dx, y = pos.y + dy, z = pos.z})
			end
		end
	end

	return list
end

-- ---------------------------------------------------------------------------------------------------------------
-- internals: drawing steps
-- ---------------------------------------------------------------------------------------------------------------

local function shoot(id, delay, from, to, ani, skipVoid)
	if(ani == nil or ani == CONST_ANI_NONE or samePos(from, to)) then
		return
	end

	if(skipVoid and VFX.isVoid(to)) then
		return
	end

	VFX.at(id, delay, doSendDistanceShoot, from, to, ani)
end

local function fx(id, delay, pos, effect, skipVoid)
	if(effect == nil) then
		return
	end

	if(skipVoid and VFX.isVoid(pos)) then
		return
	end

	VFX.at(id, delay, doSendMagicEffect, pos, effect)
end

-- one ani falling from (height tiles above, offsetX tiles aside) to landing, with an optional effect when it lands
local function drop(id, delay, landing, ani, height, offsetX, effect, effectDelay, skipVoid)
	if(skipVoid and VFX.isVoid(landing)) then
		return
	end

	shoot(id, delay, {x = landing.x + offsetX, y = landing.y - height, z = landing.z}, landing, ani)
	fx(id, delay + effectDelay, landing, effect)
end

local function getHeight(options, default)
	return clamp(math.floor(opt(options, "height", default or 5)), 1, VFX.maxHeight)
end

local function getRadius(options, default)
	return clamp(math.floor(opt(options, "radius", default)), 0, VFX.maxRadius)
end

-- ---------------------------------------------------------------------------------------------------------------
-- distance shoots
-- ---------------------------------------------------------------------------------------------------------------

-- A distance shoot (ani) that falls from the sky and hits the target position, optionally repeated.
--
-- options (all optional):
--   height     : how many tiles above the target the animation starts, 1 to VFX.maxHeight (default 5)
--   offsetX    : horizontal tiles of the start point; 0 falls straight down, a value makes it fall diagonally
--                (default -4: starts 4 tiles to the left)
--   count      : how many times it falls (default 1, max VFX.maxCount)
--   interval   : milliseconds between each fall when count > 1 (default 150)
--   radius     : each fall lands on a random tile inside this radius of the target (default 0)
--   effect     : CONST_ME_* sent on the tile when the animation lands (default none)
--   effectDelay: milliseconds after the shoot starts for the effect to show (default 200, about the flight time)
--
-- Examples:
--   VFX.SkyFall(getCreaturePosition(cid), CONST_ANI_FIRE)
--   VFX.SkyFall(cid, CONST_ANI_LARGEROCK, {count = 12, radius = 3, interval = 100, effect = CONST_ME_FIREAREA})
function VFX.SkyFall(target, ani, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(ani) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local height = getHeight(options)
	local offsetX = math.floor(opt(options, "offsetX", -4))
	local count = clamp(math.floor(opt(options, "count", 1)), 1, VFX.maxCount)
	local interval = opt(options, "interval", 150)
	local base = opt(options, "delay", 0)
	local radius = getRadius(options, 0)
	local effect = opt(options, "effect", nil)
	local effectDelay = opt(options, "effectDelay", 200)
	local skipVoid = opt(options, "skipVoid", false)

	for i = 1, count do
		local landing = VFX.randomInDisc(pos, radius)
		drop(id, base + (i - 1) * interval, landing, ani, height, offsetX, effect, effectDelay, skipVoid)
	end

	return finish(id, owned)
end

-- Many ani falling at random moments and tiles of an area (rain of fire, ice, arrows...).
-- options: radius (3), duration ms (2000), drops (20), height (5), offsetX (0), effect, effectDelay (200)
function VFX.Rain(target, ani, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(ani) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local radius = getRadius(options, 3)
	local duration = opt(options, "duration", 2000)
	local drops = clamp(math.floor(opt(options, "drops", 20)), 1, VFX.maxCount * 4)
	local height = getHeight(options)
	local offsetX = math.floor(opt(options, "offsetX", 0))
	local base = opt(options, "delay", 0)
	local effect = opt(options, "effect", nil)
	local effectDelay = opt(options, "effectDelay", 200)
	local skipVoid = opt(options, "skipVoid", false)

	for i = 1, drops do
		local landing = VFX.randomInDisc(pos, radius)
		drop(id, base + math.random(0, duration), landing, ani, height, offsetX, effect, effectDelay, skipVoid)
	end

	return finish(id, owned)
end

-- Ani that goes up from the target and falls around it, like a geyser.
-- options: height (4), count (1), interval ms (150), radius where it lands (1), riseTime ms (250), effect,
-- effectDelay (200, counted from the moment it starts to fall)
function VFX.Fountain(target, ani, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(ani) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local height = getHeight(options, 4)
	local count = clamp(math.floor(opt(options, "count", 1)), 1, VFX.maxCount)
	local interval = opt(options, "interval", 150)
	local base = opt(options, "delay", 0)
	local radius = getRadius(options, 1)
	local riseTime = opt(options, "riseTime", 250)
	local effect = opt(options, "effect", nil)
	local effectDelay = opt(options, "effectDelay", 200)
	local skipVoid = opt(options, "skipVoid", false)

	for i = 1, count do
		local when = base + (i - 1) * interval
		local top = {x = pos.x, y = pos.y - height, z = pos.z}
		local landing = VFX.randomInDisc(pos, radius)

		shoot(id, when, pos, top, ani)
		shoot(id, when + riseTime, top, landing, ani, skipVoid)
		if(not (skipVoid and VFX.isVoid(landing))) then
			fx(id, when + riseTime + effectDelay, landing, effect)
		end
	end

	return finish(id, owned)
end

-- Ani leaving the center in a spiral.
-- options: radius (4), turns (2), points (24), duration ms (1200), clockwise (true)
function VFX.Spiral(target, ani, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(ani) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local radius = getRadius(options, 4)
	local turns = opt(options, "turns", 2)
	local points = clamp(math.floor(opt(options, "points", 24)), 1, VFX.maxPoints)
	local duration = opt(options, "duration", 1200)
	local base = opt(options, "delay", 0)
	local sign = opt(options, "clockwise", true) and 1 or -1
	local skipVoid = opt(options, "skipVoid", false)

	for i = 1, points do
		local t = i / points
		local p = pointAt(pos, radius * t, sign * turns * 2 * math.pi * t)
		shoot(id, base + duration * (i - 1) / points, pos, p, ani, skipVoid)
	end

	return finish(id, owned)
end

-- Ani drawing a circle around the target (each ani goes from a point to the next one).
-- options: radius (3), points (12), spin (false: all at once; true: one after another), duration ms of the spin (600),
-- fromCenter (false: each ani leaves the center instead of drawing the circle line)
function VFX.Circle(target, ani, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(ani) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local radius = math.max(getRadius(options, 3), 1)
	local points = clamp(math.floor(opt(options, "points", 12)), 2, VFX.maxPoints)
	local base = opt(options, "delay", 0)
	local duration = opt(options, "duration", 600)
	local spin = opt(options, "spin", false)
	local fromCenter = opt(options, "fromCenter", false)
	local skipVoid = opt(options, "skipVoid", false)

	for i = 0, points - 1 do
		local current = pointAt(pos, radius, (2 * math.pi * i) / points)
		local nextPoint = pointAt(pos, radius, (2 * math.pi * (i + 1)) / points)
		local when = base + (spin and (duration * i / points) or 0)

		if(fromCenter) then
			shoot(id, when, pos, current, ani, skipVoid)
		else
			shoot(id, when, current, nextPoint, ani, skipVoid)
		end
	end

	return finish(id, owned)
end

-- Ani leaving the center to every direction.
-- options: radius (4), points (12), rings (1: how many waves of ani), ringInterval ms (150), effect (on the center)
function VFX.Explosion(target, ani, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(ani) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local radius = math.max(getRadius(options, 4), 1)
	local points = clamp(math.floor(opt(options, "points", 12)), 1, VFX.maxPoints)
	local rings = clamp(math.floor(opt(options, "rings", 1)), 1, 5)
	local ringInterval = opt(options, "ringInterval", 150)
	local base = opt(options, "delay", 0)
	local skipVoid = opt(options, "skipVoid", false)

	fx(id, base, pos, opt(options, "effect", nil))

	for k = 1, rings do
		local ringRadius = math.max(round(radius * k / rings), 1)
		local when = base + (k - 1) * ringInterval
		for _, p in ipairs(VFX.circlePoints(pos, ringRadius, points, 0)) do
			shoot(id, when, pos, p, ani, skipVoid)
		end
	end

	return finish(id, owned)
end

-- Ani coming from the borders to the center (charging an attack).
-- options: radius (4), points (12), flightTime ms (200), effect (on the center when they arrive)
function VFX.Implosion(target, ani, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(ani) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local radius = math.max(getRadius(options, 4), 1)
	local points = clamp(math.floor(opt(options, "points", 12)), 1, VFX.maxPoints)
	local flightTime = opt(options, "flightTime", 200)
	local base = opt(options, "delay", 0)

	for _, p in ipairs(VFX.circlePoints(pos, radius, points, 0)) do
		shoot(id, base, p, pos, ani)
	end

	fx(id, base + flightTime, pos, opt(options, "effect", nil))
	return finish(id, owned)
end

-- Ani between two points (positions or creature ids), like a ray or a chain.
-- options: mode ("chain": tile by tile, "bolt": a single shoot), interval ms between the chain steps (60),
-- effect (shown on every tile of the chain, or on the end for "bolt")
function VFX.Beam(from, to, ani, options)
	local a, b = VFX.resolvePosition(from), VFX.resolvePosition(to)
	if(to == nil and a and type(from) == "number") then
		-- no destination: the beam goes in front of the creature (options.range tiles, default 5)
		b = VFX.lookPosition(from, clamp(math.floor(opt(options, "range", 5)), 1, VFX.maxRadius + 2))
	end

	if(not a or not b or a.z ~= b.z or type(ani) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local base = opt(options, "delay", 0)
	local effect = opt(options, "effect", nil)
	local skipVoid = opt(options, "skipVoid", false)

	if(opt(options, "mode", "chain") == "bolt") then
		shoot(id, base, a, b, ani, skipVoid)
		fx(id, base + 200, b, effect, skipVoid)
	else
		local interval = opt(options, "interval", 60)
		local points = VFX.linePoints(a, b)
		for i = 1, #points - 1 do
			local when = base + (i - 1) * interval
			shoot(id, when, points[i], points[i + 1], ani, skipVoid)
			fx(id, when, points[i + 1], effect, skipVoid)
		end
	end

	return finish(id, owned)
end

-- Ani orbiting a creature for some time; it follows the creature and stops when it disappears.
-- options: radius (2), points (8: ani positions on the orbit), duration ms (5000), step ms (150), clockwise (true)
function VFX.Orbit(creature, ani, options)
	if(type(creature) ~= "number" or not isCreature(creature) or type(ani) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local radius = math.max(getRadius(options, 2), 1)
	local points = clamp(math.floor(opt(options, "points", 8)), 3, VFX.maxPoints)
	local duration = opt(options, "duration", 5000)
	local step = math.max(opt(options, "step", 150), 50)
	local base = opt(options, "delay", 0)
	local sign = opt(options, "clockwise", true) and 1 or -1
	local angleStep = (2 * math.pi) / points

	for i = 0, math.floor(duration / step) - 1 do
		VFX.at(id, base + i * step, function()
			if(not isCreature(creature)) then
				VFX.stop(id)
				return
			end

			local center = getCreaturePosition(creature)
			local from = pointAt(center, radius, sign * i * angleStep)
			local to = pointAt(center, radius, sign * (i + 1) * angleStep)
			if(not samePos(from, to)) then
				doSendDistanceShoot(from, to, ani)
			end
		end)
	end

	return finish(id, owned)
end

-- ---------------------------------------------------------------------------------------------------------------
-- magic effects
-- ---------------------------------------------------------------------------------------------------------------

-- Concentric rings of an effect spreading from the target.
-- options: radius (4), startRadius (0), interval ms between rings (150), inward (false: rings go to the center)
function VFX.Wave(target, effect, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(effect) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local radius = getRadius(options, 4)
	local startRadius = clamp(math.floor(opt(options, "startRadius", 0)), 0, radius)
	local interval = opt(options, "interval", 150)
	local base = opt(options, "delay", 0)
	local inward = opt(options, "inward", false)
	local skipVoid = opt(options, "skipVoid", false)

	for r = startRadius, radius do
		local step = inward and (radius - r) or (r - startRadius)
		for _, p in ipairs(VFX.ringTiles(pos, r)) do
			fx(id, base + step * interval, p, effect, skipVoid)
		end
	end

	return finish(id, owned)
end

-- Effect walking in a line. Use options.to (position or creature) or options.direction (0 to 7, the DIRECTION_*
-- values); with a creature as target and none of them, it follows the direction the creature is looking.
-- options: length (5), interval ms between tiles (80), includeStart (false)
function VFX.Line(target, effect, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(effect) ~= "number") then
		return false
	end

	local points
	local destination = opt(options, "to", nil)
	if(destination ~= nil) then
		destination = VFX.resolvePosition(destination)
		if(not destination or destination.z ~= pos.z) then
			return false
		end

		points = VFX.linePoints(pos, destination)
		table.remove(points, 1)
	else
		local direction = opt(options, "direction", nil)
		if(direction == nil and type(target) == "number") then
			direction = getCreatureLookDirection(target)
		end

		local step = VFX.directions[direction or 0]
		if(not step) then
			return false
		end

		points = {}
		for i = 1, clamp(math.floor(opt(options, "length", 5)), 1, 20) do
			table.insert(points, {x = pos.x + step[1] * i, y = pos.y + step[2] * i, z = pos.z})
		end
	end

	local id, owned = begin(options)
	local interval = opt(options, "interval", 80)
	local base = opt(options, "delay", 0)
	local skipVoid = opt(options, "skipVoid", false)

	if(opt(options, "includeStart", false)) then
		fx(id, base, pos, effect, skipVoid)
	end

	for i, p in ipairs(points) do
		fx(id, base + (i - 1) * interval, p, effect, skipVoid)
	end

	return finish(id, owned)
end

-- The same effect repeated on the target; when the target is a creature id it follows the creature.
-- options: times (5), interval ms (500), follow (true)
function VFX.Pulse(target, effect, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(effect) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local times = clamp(math.floor(opt(options, "times", 5)), 1, 200)
	local interval = opt(options, "interval", 500)
	local base = opt(options, "delay", 0)
	local follow = opt(options, "follow", true) and type(target) == "number"
	local skipVoid = opt(options, "skipVoid", false)

	for i = 0, times - 1 do
		VFX.at(id, base + i * interval, function()
			local p = pos
			if(follow) then
				if(not isCreature(target)) then
					VFX.stop(id)
					return
				end

				p = getCreaturePosition(target)
			end

			if(not (skipVoid and VFX.isVoid(p))) then
				doSendMagicEffect(p, effect)
			end
		end)
	end

	return finish(id, owned)
end

-- Effect in the shape of a cross (4 directions), or a star when options.diagonal is true (8 directions).
-- options: size (3), interval ms between each distance from the center (0: all at once), includeCenter (true)
function VFX.Cross(target, effect, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(effect) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local size = getRadius(options, 3) -- "size" is also accepted below
	size = clamp(math.floor(opt(options, "size", size)), 1, VFX.maxRadius)
	local interval = opt(options, "interval", 0)
	local base = opt(options, "delay", 0)
	local lastDirection = opt(options, "diagonal", false) and 7 or 3
	local skipVoid = opt(options, "skipVoid", false)

	if(opt(options, "includeCenter", true)) then
		fx(id, base, pos, effect, skipVoid)
	end

	for distance = 1, size do
		for direction = 0, lastDirection do
			local step = VFX.directions[direction]
			local p = {x = pos.x + step[1] * distance, y = pos.y + step[2] * distance, z = pos.z}
			fx(id, base + (distance - 1) * interval, p, effect, skipVoid)
		end
	end

	return finish(id, owned)
end

-- Same as Cross, but with the 8 directions.
function VFX.Star(target, effect, options)
	local copy = {}
	for key, value in pairs(options or {}) do
		copy[key] = value
	end

	copy.diagonal = true
	return VFX.Cross(target, effect, copy)
end

-- ---------------------------------------------------------------------------------------------------------------
-- combined effects
-- ---------------------------------------------------------------------------------------------------------------

-- One (or more) meteors falling diagonally, with an impact effect and shards flying around.
-- options: ani (CONST_ANI_FIRE), height (5), offsetX (4), flightTime ms (250), count (1), interval ms (300),
-- radius where they land (0), effect (CONST_ME_FIREAREA), impactEffect (CONST_ME_EXPLOSIONHIT),
-- shardAni (CONST_ANI_SMALLSTONE, false for none), shardRadius (2)
function VFX.Meteor(target, options)
	local pos = VFX.resolvePosition(target)
	if(not pos) then
		return false
	end

	local id, owned = begin(options)
	local ani = opt(options, "ani", CONST_ANI_FIRE)
	local height = getHeight(options)
	local offsetX = clamp(math.floor(opt(options, "offsetX", 4)), -VFX.maxRadius - 2, VFX.maxRadius + 2)
	local flightTime = opt(options, "flightTime", 250)
	local count = clamp(math.floor(opt(options, "count", 1)), 1, VFX.maxCount)
	local interval = opt(options, "interval", 300)
	local radius = getRadius(options, 0)
	local base = opt(options, "delay", 0)
	local effect = opt(options, "effect", CONST_ME_FIREAREA)
	local impactEffect = opt(options, "impactEffect", CONST_ME_EXPLOSIONHIT)
	local shardAni = opt(options, "shardAni", CONST_ANI_SMALLSTONE)
	local shardRadius = clamp(math.floor(opt(options, "shardRadius", 2)), 1, VFX.maxRadius)
	local skipVoid = opt(options, "skipVoid", false)

	for i = 1, count do
		local landing = VFX.randomInDisc(pos, radius)
		local when = base + (i - 1) * interval
		if(not (skipVoid and VFX.isVoid(landing))) then
			shoot(id, when, {x = landing.x + offsetX, y = landing.y - height, z = landing.z}, landing, ani)
			fx(id, when + flightTime, landing, impactEffect)
			fx(id, when + flightTime, landing, effect)

			if(shardAni) then
				VFX.Explosion(landing, shardAni, {handle = id, delay = when + flightTime, radius = shardRadius, points = 8, skipVoid = skipVoid})
			end
		end
	end

	return finish(id, owned)
end

-- Spawn effect for bosses/npcs: ani converge to the target and a final effect shows on it.
-- options: ani (CONST_ANI_ENERGY), radius (4), points (12), flightTime ms (300), effect (CONST_ME_TELEPORT),
-- waveEffect (CONST_ME_MAGIC_BLUE, false for none)
function VFX.Summon(target, options)
	local pos = VFX.resolvePosition(target)
	if(not pos) then
		return false
	end

	local id, owned = begin(options)
	local flightTime = opt(options, "flightTime", 300)
	local base = opt(options, "delay", 0)
	local skipVoid = opt(options, "skipVoid", false)

	VFX.Implosion(pos, opt(options, "ani", CONST_ANI_ENERGY), {
		handle = id, delay = base, radius = opt(options, "radius", 4), points = opt(options, "points", 12),
		flightTime = flightTime, effect = opt(options, "effect", CONST_ME_TELEPORT)
	})

	local waveEffect = opt(options, "waveEffect", CONST_ME_MAGIC_BLUE)
	if(waveEffect) then
		VFX.Wave(pos, waveEffect, {handle = id, delay = base + flightTime, radius = 2, interval = 120, skipVoid = skipVoid})
	end

	return finish(id, owned)
end

-- Celebration around a player: spiral of ani, holy effect on the player and fireworks at the end.
-- options: ani (CONST_ANI_SMALLHOLY), radius (3), duration ms (1000)
function VFX.LevelUp(target, options)
	local pos = VFX.resolvePosition(target)
	if(not pos) then
		return false
	end

	local id, owned = begin(options)
	local duration = opt(options, "duration", 1000)
	local base = opt(options, "delay", 0)
	local skipVoid = opt(options, "skipVoid", false)

	fx(id, base, pos, CONST_ME_HOLYAREA)
	VFX.Spiral(pos, opt(options, "ani", CONST_ANI_SMALLHOLY), {
		handle = id, delay = base, radius = opt(options, "radius", 3), turns = 2, points = 20,
		duration = duration, skipVoid = skipVoid
	})

	VFX.Wave(pos, CONST_ME_FIREWORK_YELLOW, {handle = id, delay = base + duration, radius = 2, interval = 150, skipVoid = skipVoid})
	fx(id, base + duration + 450, pos, CONST_ME_FIREWORK_RED)
	return finish(id, owned)
end

-- Visual teleport between two points (positions or creature ids): an effect on the origin, an ani falling on the
-- destination and an effect when it arrives. It does not move anything: call doTeleportThing yourself.
-- options: ani (CONST_ANI_ENERGY), height (3), travel ms between leaving and falling (300),
-- outEffect / inEffect (CONST_ME_TELEPORT, false for none)
function VFX.Teleport(from, to, options)
	local a, b = VFX.resolvePosition(from), VFX.resolvePosition(to)
	if(not a or not b) then
		return false
	end

	local id, owned = begin(options)
	local base = opt(options, "delay", 0)
	local travel = opt(options, "travel", 300)
	local height = getHeight(options, 3)
	local outEffect = opt(options, "outEffect", CONST_ME_TELEPORT)
	local inEffect = opt(options, "inEffect", CONST_ME_TELEPORT)

	fx(id, base, a, outEffect or nil)
	drop(id, base + travel, b, opt(options, "ani", CONST_ANI_ENERGY), height, 0, inEffect or nil, 200)
	return finish(id, owned)
end

-- ---------------------------------------------------------------------------------------------------------------
-- more distance shoots
-- ---------------------------------------------------------------------------------------------------------------

-- a zigzag bolt: segments from the sky down to landing, each one with a small random sideways deviation
local function strike(id, when, landing, ani, height, offsetX, segments, jitter, segDelay, effect, skipVoid)
	if(skipVoid and VFX.isVoid(landing)) then
		return
	end

	local previous = {x = landing.x + offsetX, y = landing.y - height, z = landing.z}
	for i = 1, segments do
		local current
		if(i == segments) then
			current = copyPos(landing)
		else
			local left = 1 - i / segments
			current = {
				x = landing.x + round(offsetX * left) + math.random(-jitter, jitter),
				y = landing.y - round(height * left),
				z = landing.z
			}
		end

		shoot(id, when + (i - 1) * segDelay, previous, current, ani)
		previous = current
	end

	fx(id, when + segments * segDelay, landing, effect)
end

-- Lightning bolt falling from the sky onto the target.
-- options: height (5), offsetX (0), segments (4), jitter tiles of sideways deviation (1), segDelay ms (40),
-- count (1), interval ms (200), radius where they land (0), effect (CONST_ME_ENERGYAREA, false for none)
function VFX.Lightning(target, ani, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(ani) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local height = getHeight(options)
	local offsetX = math.floor(opt(options, "offsetX", 0))
	local segments = clamp(math.floor(opt(options, "segments", 4)), 1, 10)
	local jitter = clamp(math.floor(opt(options, "jitter", 1)), 0, 3)
	local segDelay = opt(options, "segDelay", 40)
	local count = clamp(math.floor(opt(options, "count", 1)), 1, VFX.maxCount)
	local interval = opt(options, "interval", 200)
	local radius = getRadius(options, 0)
	local base = opt(options, "delay", 0)
	local effect = opt(options, "effect", CONST_ME_ENERGYAREA) or nil
	local skipVoid = opt(options, "skipVoid", false)

	for i = 1, count do
		local landing = VFX.randomInDisc(pos, radius)
		strike(id, base + (i - 1) * interval, landing, ani, height, offsetX, segments, jitter, segDelay, effect, skipVoid)
	end

	return finish(id, owned)
end

-- strands of ani rising around the center: each ani goes from one point of the strand to the next one
local function helixChain(id, base, pos, ani, strands, radiusAt, height, turns, points, duration, skipVoid)
	for s = 0, strands - 1 do
		local phase = (2 * math.pi * s) / strands
		local previous
		for i = 0, points do
			local t = i / points
			local p = pointAt(pos, radiusAt(t), phase + turns * 2 * math.pi * t)
			p.y = p.y - round(height * t)

			if(previous) then
				shoot(id, base + duration * (i - 1) / points, previous, p, ani, skipVoid)
			end

			previous = p
		end
	end
end

-- Funnel of ani rising in a spiral (narrow at the bottom, wide at the top).
-- options: radius of the top (3), height (4), turns (3), points (30), duration ms (1500), strands (1)
function VFX.Tornado(target, ani, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(ani) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local radius = getRadius(options, 3)
	local height = getHeight(options, 4)
	local turns = opt(options, "turns", 3)
	local points = clamp(math.floor(opt(options, "points", 30)), 2, VFX.maxPoints)
	local duration = opt(options, "duration", 1500)
	local strands = clamp(math.floor(opt(options, "strands", 1)), 1, 4)
	local base = opt(options, "delay", 0)

	helixChain(id, base, pos, ani, strands, function(t) return radius * (0.3 + 0.7 * t) end,
		height, turns, points, duration, opt(options, "skipVoid", false))
	return finish(id, owned)
end

-- Strands of ani rising around the target, like a DNA helix (same radius all the way up).
-- options: radius (2), height (4), turns (2), points (24), duration ms (1500), strands (2)
function VFX.Helix(target, ani, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(ani) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local radius = math.max(getRadius(options, 2), 1)
	local height = getHeight(options, 4)
	local turns = opt(options, "turns", 2)
	local points = clamp(math.floor(opt(options, "points", 24)), 2, VFX.maxPoints)
	local duration = opt(options, "duration", 1500)
	local strands = clamp(math.floor(opt(options, "strands", 2)), 1, 4)
	local base = opt(options, "delay", 0)

	helixChain(id, base, pos, ani, strands, function() return radius end,
		height, turns, points, duration, opt(options, "skipVoid", false))
	return finish(id, owned)
end

-- Ani going from the center to a ring and coming back (a breathing shield).
-- options: radius (3), points (12), flightTime ms of each way (250), pulses (1), interval ms between pulses
-- (default 2 * flightTime + 100), effect (on the center when they come back)
function VFX.Burst(target, ani, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(ani) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local radius = math.max(getRadius(options, 3), 1)
	local points = clamp(math.floor(opt(options, "points", 12)), 1, VFX.maxPoints)
	local flightTime = opt(options, "flightTime", 250)
	local pulses = clamp(math.floor(opt(options, "pulses", 1)), 1, 10)
	local interval = opt(options, "interval", 2 * flightTime + 100)
	local base = opt(options, "delay", 0)
	local effect = opt(options, "effect", nil)
	local skipVoid = opt(options, "skipVoid", false)
	local ring = VFX.circlePoints(pos, radius, points, 0)

	for pulse = 0, pulses - 1 do
		local when = base + pulse * interval
		for _, p in ipairs(ring) do
			shoot(id, when, pos, p, ani, skipVoid)
			shoot(id, when + flightTime, p, pos, ani)
		end

		fx(id, when + 2 * flightTime, pos, effect)
	end

	return finish(id, owned)
end

-- Fan of ani leaving the target. The direction is options.to (position/creature), options.direction (0 to 7) or,
-- for a creature, the way it is looking.
-- options: rays (7), spread degrees of the fan (60), range tiles (5), waves (1), interval ms between waves (150),
-- effect (on the tile where each ani lands)
function VFX.Barrage(target, ani, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(ani) ~= "number") then
		return false
	end

	local angle
	local aim = opt(options, "to", nil)
	if(aim ~= nil) then
		aim = VFX.resolvePosition(aim)
		if(not aim) then
			return false
		end

		angle = math.atan2(aim.y - pos.y, aim.x - pos.x)
	else
		local direction = opt(options, "direction", nil)
		if(direction == nil and type(target) == "number") then
			direction = getCreatureLookDirection(target)
		end

		local step = VFX.directions[direction or 0]
		if(not step) then
			return false
		end

		angle = math.atan2(step[2], step[1])
	end

	local id, owned = begin(options)
	local rays = clamp(math.floor(opt(options, "rays", 7)), 1, 15)
	local spread = math.rad(clamp(opt(options, "spread", 60), 0, 360))
	local range = clamp(math.floor(opt(options, "range", 5)), 1, VFX.maxRadius + 2)
	local waves = clamp(math.floor(opt(options, "waves", 1)), 1, 10)
	local interval = opt(options, "interval", 150)
	local base = opt(options, "delay", 0)
	local effect = opt(options, "effect", nil)
	local skipVoid = opt(options, "skipVoid", false)

	local tiles, seen = {}, {}
	for i = 1, rays do
		local offset = 0
		if(rays > 1) then
			offset = -spread / 2 + spread * (i - 1) / (rays - 1)
		end

		local p = pointAt(pos, range, angle + offset)
		local key = p.x .. "," .. p.y
		if(not seen[key]) then
			seen[key] = true
			table.insert(tiles, p)
		end
	end

	for wave = 0, waves - 1 do
		local when = base + wave * interval
		for _, p in ipairs(tiles) do
			shoot(id, when, pos, p, ani, skipVoid)
			if(not (skipVoid and VFX.isVoid(p))) then
				fx(id, when + 200, p, effect)
			end
		end
	end

	return finish(id, owned)
end

-- Ani crossing the screen diagonally and hitting the target, leaving a trail of effects.
-- options: span horizontal tiles of the start (7), rise vertical tiles above the target of the start (3),
-- fromRight (false: comes from the left), flightTime ms (500), trail (CONST_ME_POFF, false for none),
-- effect on impact (CONST_ME_EXPLOSIONHIT, false for none)
function VFX.Comet(target, ani, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(ani) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local span = clamp(math.floor(opt(options, "span", 7)), 1, 7)
	local rise = clamp(math.floor(opt(options, "rise", 3)), 0, VFX.maxHeight)
	local sign = opt(options, "fromRight", false) and 1 or -1
	local flightTime = opt(options, "flightTime", 500)
	local trail = opt(options, "trail", CONST_ME_POFF) or nil
	local impact = opt(options, "effect", CONST_ME_EXPLOSIONHIT) or nil
	local base = opt(options, "delay", 0)
	local skipVoid = opt(options, "skipVoid", false)

	local points = VFX.linePoints({x = pos.x + sign * span, y = pos.y - rise, z = pos.z}, pos)
	local segments = #points - 1
	for i = 1, segments do
		local when = base + flightTime * (i - 1) / segments
		shoot(id, when, points[i], points[i + 1], ani)
		fx(id, when, points[i], trail, skipVoid)
	end

	if(not (skipVoid and VFX.isVoid(pos))) then
		fx(id, base + flightTime + 50, pos, impact)
	end

	return finish(id, owned)
end

-- Slow, drifting fall over an area (snow, ashes, petals): every flake falls in two steps with a pause between them.
-- options: radius (4), duration ms (4000), flakes (30), height (5), drift tiles of random sideways start (2),
-- stepTime ms between the two steps (250), effect on the ground (none)
function VFX.Snow(target, ani, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(ani) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local radius = getRadius(options, 4)
	local duration = opt(options, "duration", 4000)
	local flakes = clamp(math.floor(opt(options, "flakes", 30)), 1, VFX.maxCount * 4)
	local height = getHeight(options)
	local drift = clamp(math.floor(opt(options, "drift", 2)), 0, 4)
	local stepTime = opt(options, "stepTime", 250)
	local base = opt(options, "delay", 0)
	local effect = opt(options, "effect", nil)
	local skipVoid = opt(options, "skipVoid", false)

	for i = 1, flakes do
		local landing = VFX.randomInDisc(pos, radius)
		if(not (skipVoid and VFX.isVoid(landing))) then
			local when = base + math.random(0, duration)
			local top = {x = landing.x + math.random(-drift, drift), y = landing.y - height, z = landing.z}
			local middle = {x = round((top.x + landing.x) / 2), y = round((top.y + landing.y) / 2), z = landing.z}

			shoot(id, when, top, middle, ani)
			shoot(id, when + stepTime, middle, landing, ani)
			fx(id, when + stepTime + 200, landing, effect)
		end
	end

	return finish(id, owned)
end

-- ---------------------------------------------------------------------------------------------------------------
-- more magic effects
-- ---------------------------------------------------------------------------------------------------------------

-- A fixed ring of an effect around the target (marking an area), optionally repeated; follows a creature id.
-- options: radius (3), times (1), interval ms (500), follow (true)
function VFX.Ring(target, effect, options)
	local pos = VFX.resolvePosition(target)
	if(not pos or type(effect) ~= "number") then
		return false
	end

	local id, owned = begin(options)
	local radius = math.max(getRadius(options, 3), 1)
	local times = clamp(math.floor(opt(options, "times", 1)), 1, 200)
	local interval = opt(options, "interval", 500)
	local base = opt(options, "delay", 0)
	local follow = opt(options, "follow", true) and type(target) == "number"
	local skipVoid = opt(options, "skipVoid", false)

	for i = 0, times - 1 do
		VFX.at(id, base + i * interval, function()
			local center = pos
			if(follow) then
				if(not isCreature(target)) then
					VFX.stop(id)
					return
				end

				center = getCreaturePosition(target)
			end

			for _, p in ipairs(VFX.ringTiles(center, radius)) do
				if(not (skipVoid and VFX.isVoid(p))) then
					doSendMagicEffect(p, effect)
				end
			end
		end)
	end

	return finish(id, owned)
end

-- ---------------------------------------------------------------------------------------------------------------
-- more combined effects
-- ---------------------------------------------------------------------------------------------------------------

-- Boss mechanic: a blinking ring marks the area on the ground, then the impact happens.
-- options: radius (2), warnTime ms (1500), blink ms (300), markEffect (CONST_ME_MAGIC_RED),
-- impact ("explosion", "meteor" or "none"), ani (CONST_ANI_FIRE), effect (CONST_ME_EXPLOSIONAREA)
function VFX.Warning(target, options)
	local pos = VFX.resolvePosition(target)
	if(not pos) then
		return false
	end

	local id, owned = begin(options)
	local radius = math.max(getRadius(options, 2), 1)
	local warnTime = opt(options, "warnTime", 1500)
	local blink = math.max(opt(options, "blink", 300), 100)
	local ani = opt(options, "ani", CONST_ANI_FIRE)
	local effect = opt(options, "effect", CONST_ME_EXPLOSIONAREA)
	local impact = opt(options, "impact", "explosion")
	local base = opt(options, "delay", 0)
	local skipVoid = opt(options, "skipVoid", false)
	local when = base + warnTime

	VFX.Ring(pos, opt(options, "markEffect", CONST_ME_MAGIC_RED), {
		handle = id, delay = base, radius = radius, times = math.max(1, math.floor(warnTime / blink)),
		interval = blink, follow = false, skipVoid = skipVoid
	})

	if(impact == "explosion") then
		VFX.Explosion(pos, ani, {handle = id, delay = when, radius = radius, points = 12, rings = 2, skipVoid = skipVoid})
		VFX.Wave(pos, effect, {handle = id, delay = when, radius = radius, interval = 70, skipVoid = skipVoid})
	elseif(impact == "meteor") then
		VFX.Meteor(pos, {handle = id, delay = math.max(base, when - 250), ani = ani, effect = effect, shardRadius = radius, skipVoid = skipVoid})
	end

	return finish(id, owned)
end

-- Big death effect (bosses): central blast, rings of ani, a wave and a fireworks finale.
-- options: radius (4), ani (CONST_ANI_DEATH), effect of the wave (CONST_ME_MORTAREA), finale (true)
function VFX.Death(target, options)
	local pos = VFX.resolvePosition(target)
	if(not pos) then
		return false
	end

	local id, owned = begin(options)
	local radius = math.max(getRadius(options, 4), 1)
	local base = opt(options, "delay", 0)
	local skipVoid = opt(options, "skipVoid", false)

	fx(id, base, pos, CONST_ME_EXPLOSIONAREA)
	VFX.Explosion(pos, opt(options, "ani", CONST_ANI_DEATH), {
		handle = id, delay = base, radius = radius, points = 16, rings = 3, ringInterval = 150, skipVoid = skipVoid
	})

	local waveEffect = opt(options, "effect", CONST_ME_MORTAREA)
	if(waveEffect) then
		VFX.Wave(pos, waveEffect, {handle = id, delay = base + 100, radius = radius, interval = 120, skipVoid = skipVoid})
	end

	if(opt(options, "finale", true)) then
		local fireworks = {CONST_ME_FIREWORK_YELLOW, CONST_ME_FIREWORK_RED, CONST_ME_FIREWORK_BLUE}
		for i = 1, 8 do
			fx(id, base + 700 + i * 80, VFX.randomInDisc(pos, radius), fireworks[math.random(1, #fireworks)], skipVoid)
		end
	end

	return finish(id, owned)
end

-- Storm over an area: rain, random lightning strikes and from time to time a wave on the ground.
-- options: radius (4), duration ms (6000), rainAni (CONST_ANI_SMALLICE), drops (duration / 100),
-- lightningAni (CONST_ANI_ENERGY), strikes (duration / 1500), waveEffect (CONST_ME_MAGIC_BLUE, false for none),
-- waveInterval ms (2500)
function VFX.Storm(target, options)
	local pos = VFX.resolvePosition(target)
	if(not pos) then
		return false
	end

	local id, owned = begin(options)
	local radius = getRadius(options, 4)
	local duration = opt(options, "duration", 6000)
	local base = opt(options, "delay", 0)
	local skipVoid = opt(options, "skipVoid", false)
	local strikes = clamp(math.floor(opt(options, "strikes", duration / 1500)), 0, 30)

	VFX.Rain(pos, opt(options, "rainAni", CONST_ANI_SMALLICE), {
		handle = id, delay = base, radius = radius, duration = duration, offsetX = -2,
		drops = opt(options, "drops", math.floor(duration / 100)), skipVoid = skipVoid
	})

	local lightningAni = opt(options, "lightningAni", CONST_ANI_ENERGY)
	for i = 1, strikes do
		VFX.Lightning(VFX.randomInDisc(pos, radius), lightningAni, {
			handle = id, delay = base + math.random(0, duration), skipVoid = skipVoid
		})
	end

	local waveEffect = opt(options, "waveEffect", CONST_ME_MAGIC_BLUE)
	if(waveEffect) then
		local waveInterval = math.max(opt(options, "waveInterval", 2500), 500)
		for k = 1, math.min(20, math.floor(duration / waveInterval)) do
			VFX.Wave(pos, waveEffect, {
				handle = id, delay = base + k * waveInterval, radius = math.min(radius, 3), interval = 100, skipVoid = skipVoid
			})
		end
	end

	return finish(id, owned)
end

local buffTypes = {
	attack = {ani = CONST_ANI_FIRE, effect = CONST_ME_MAGIC_RED, finish = CONST_ME_FIREWORK_RED},
	mana = {ani = CONST_ANI_ENERGYBALL, effect = CONST_ME_MAGIC_BLUE, finish = CONST_ME_FIREWORK_BLUE},
	defense = {ani = CONST_ANI_SMALLEARTH, effect = CONST_ME_MAGIC_GREEN, finish = CONST_ME_MAGIC_GREEN},
	heal = {ani = CONST_ANI_SMALLHOLY, effect = CONST_ME_HOLYAREA, finish = CONST_ME_FIREWORK_YELLOW}
}

-- Colored helix around the target for buffs.
-- options: type ("attack" red, "mana" blue, "defense" green, "heal" holy; default "attack"), radius (2), height (3),
-- duration ms (1200)
function VFX.Buff(target, options)
	local pos = VFX.resolvePosition(target)
	local style = buffTypes[opt(options, "type", "attack")]
	if(not pos or not style) then
		return false
	end

	local id, owned = begin(options)
	local base = opt(options, "delay", 0)
	local duration = opt(options, "duration", 1200)
	local skipVoid = opt(options, "skipVoid", false)

	fx(id, base, pos, style.effect)
	VFX.Helix(pos, style.ani, {
		handle = id, delay = base, radius = opt(options, "radius", 2), height = opt(options, "height", 3),
		duration = duration, skipVoid = skipVoid
	})

	fx(id, base + duration, pos, style.finish)
	return finish(id, owned)
end

-- ---------------------------------------------------------------------------------------------------------------
-- library improvements: caster direction, sequences, named profiles and elements
-- ---------------------------------------------------------------------------------------------------------------

-- position `distance` tiles in front of a creature (the way it is looking)
function VFX.lookPosition(creature, distance)
	if(type(creature) ~= "number" or not isCreature(creature)) then
		return nil
	end

	local pos = getCreaturePosition(creature)
	local step = VFX.directions[getCreatureLookDirection(creature)] or VFX.directions[0]
	distance = distance or 1
	return {x = pos.x + step[1] * distance, y = pos.y + step[2] * distance, z = pos.z}
end

-- Runs several effects in order inside one handle (VFX.stop cancels the whole sequence).
-- steps is a list of {fn = "Wave" (name in VFX, or a function), args = {...the arguments of the effect...},
-- wait = ms after the previous step, at = ms from the start (instead of wait)}. Do not put the options table of the
-- effect with delay/handle: the sequence adds them; the options table is optional.
-- Targets given as creature ids are read when VFX.Sequence is called, not when each step starts.
--
-- VFX.Sequence({
--	{fn = "Warning", args = {pos, {impact = "none"}}},
--	{fn = "Meteor", args = {pos, {count = 3, radius = 2}}, wait = 1500},
--	{fn = "Wave", args = {pos, CONST_ME_FIREAREA, {radius = 3}}, wait = 600}
-- })
function VFX.Sequence(steps, options)
	if(type(steps) ~= "table" or #steps == 0) then
		return false
	end

	local id, owned = begin(options)
	local base = opt(options, "delay", 0)
	local clock = 0

	for _, step in ipairs(steps) do
		clock = clock + (step.wait or 0)

		local fn = step.fn
		if(type(fn) == "string") then
			fn = VFX[fn]
		end

		if(type(fn) == "function") then
			local args, count = {}, 0
			for key, value in pairs(step.args or {}) do
				if(type(key) == "number") then
					args[key] = value
					count = math.max(count, key)
				end
			end

			local stepOptions = {}
			local last = args[count]
			if(type(last) == "table" and not VFX.isPosition(last)) then
				for key, value in pairs(last) do
					stepOptions[key] = value
				end
			else
				count = count + 1
			end

			stepOptions.handle = id
			stepOptions.delay = (stepOptions.delay or 0) + base + (step.at or clock)
			args[count] = stepOptions
			fn(unpack(args, 1, count))
		end
	end

	return finish(id, owned)
end

-- Named profiles: register a combination once and play it by name (spells, monsters, scripts).
-- profile is a function(target, options) or a table {effect = "Rain", id = CONST_ANI_FIRE, options = {...}}
-- (id is the ani/effect argument of the effect; leave it out for effects that do not take one, like Meteor).
-- Options passed to VFX.play override the ones of the profile.
--
-- VFX.register("fire_rain", {effect = "Rain", id = CONST_ANI_FIRE, options = {radius = 4, effect = CONST_ME_FIREAREA}})
-- VFX.play("fire_rain", getCreaturePosition(cid))
VFX.profiles = {}

function VFX.register(name, profile)
	if(type(name) ~= "string" or (type(profile) ~= "function" and type(profile) ~= "table")) then
		return false
	end

	VFX.profiles[name] = profile
	return true
end

function VFX.play(name, target, options)
	local profile = VFX.profiles[name]
	if(not profile) then
		return false
	end

	local merged = {}
	if(type(profile) == "table") then
		for key, value in pairs(profile.options or {}) do
			merged[key] = value
		end
	end

	for key, value in pairs(options or {}) do
		merged[key] = value
	end

	if(type(profile) == "function") then
		return profile(target, merged)
	end

	local fn = VFX[profile.effect]
	if(type(fn) ~= "function") then
		return false
	end

	if(profile.id ~= nil) then
		return fn(target, profile.id, merged)
	end

	return fn(target, merged)
end

VFX.register("fire_meteor", {effect = "Meteor", options = {count = 3, radius = 2}})
VFX.register("ice_storm", {effect = "Storm", options = {rainAni = CONST_ANI_SMALLICE, lightningAni = CONST_ANI_ICE, waveEffect = CONST_ME_ICEAREA}})
VFX.register("holy_buff", {effect = "Buff", options = {type = "heal"}})
VFX.register("boss_death", {effect = "Death", options = {radius = 4}})
VFX.register("boss_warning", {effect = "Warning", options = {radius = 2, warnTime = 2000}})

-- Elements: instead of a CONST_ANI_* / CONST_ME_* number, effects accept the name of an element ("fire", "ice",
-- "energy", "earth", "holy", "death") and use the matching ani or effect: VFX.Rain(cid, "ice"), VFX.Wave(cid, "fire").
-- Combined effects (Meteor, Warning, Death) accept options.element and fill ani/effect when they are not given.
VFX.elements = {
	fire = {ani = CONST_ANI_FIRE, effect = CONST_ME_FIREAREA},
	ice = {ani = CONST_ANI_ICE, effect = CONST_ME_ICEAREA},
	energy = {ani = CONST_ANI_ENERGY, effect = CONST_ME_ENERGYAREA},
	earth = {ani = CONST_ANI_EARTH, effect = CONST_ME_STONES},
	holy = {ani = CONST_ANI_HOLY, effect = CONST_ME_HOLYAREA},
	death = {ani = CONST_ANI_DEATH, effect = CONST_ME_MORTAREA}
}

local function wrapElement(name, index, field)
	local original = VFX[name]
	VFX[name] = function(...)
		local count = select("#", ...)
		local args = {...}
		if(type(args[index]) == "string") then
			local element = VFX.elements[args[index]]
			if(not element) then
				return false
			end

			args[index] = element[field]
		end

		return original(unpack(args, 1, math.max(count, index)))
	end
end

local function wrapElementOption(name, index)
	local original = VFX[name]
	VFX[name] = function(...)
		local count = select("#", ...)
		local args = {...}
		local options = args[index]
		if(type(options) == "table" and options.element ~= nil) then
			local element = VFX.elements[options.element]
			if(not element) then
				return false
			end

			local copy = {}
			for key, value in pairs(options) do
				copy[key] = value
			end

			if(copy.ani == nil) then
				copy.ani = element.ani
			end

			if(copy.effect == nil) then
				copy.effect = element.effect
			end

			args[index] = copy
		end

		return original(unpack(args, 1, math.max(count, index)))
	end
end

for _, name in ipairs({"SkyFall", "Rain", "Fountain", "Spiral", "Circle", "Explosion", "Implosion", "Orbit",
	"Lightning", "Tornado", "Helix", "Burst", "Barrage", "Comet", "Snow"}) do
	wrapElement(name, 2, "ani")
end

wrapElement("Beam", 3, "ani")
for _, name in ipairs({"Wave", "Line", "Pulse", "Cross", "Star", "Ring"}) do
	wrapElement(name, 2, "effect")
end

for _, name in ipairs({"Meteor", "Warning", "Death"}) do
	wrapElementOption(name, 2)
end
