-- Divine Tempest (Hierophant): diagonal rain of holy around the caster for 5 seconds. The caster is paralyzed while it lasts.
-- `drops` small holy bolts fall at random moments of the duration (they do not fall all at once), each on a random tile of
-- the area (radius 5). Tiles in protection zones, tiles that do not exist and tiles behind walls (no line of sight from the
-- caster) are skipped.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.slow  = percent   the caster is only slowed by `percent` (0.5 = 50%) instead of paralyzed
--   glyph.grace = {percent, ticks, interval, radius}   every `interval` ms the caster and the party within `radius` sqm recover
--                                                       `percent`% of the total average damage of the spell
local KEY = "attack/divine tempest"

local config = {
	radius = 5, drops = 100, duration = 5000,
	flight = 200, -- ms the bolt takes to fall; the damage lands when it arrives
	offset = -4, height = 4, -- the bolt starts 4 tiles to the left and 4 up, so it falls diagonally
	damage = {5, 5, 1.1, 1.7, 5, 15}, -- level divisor (min, max), magic level multiplier (min, max), constants (min, max)
	paralyze = 5500
}

local single = createCombatArea(AREA_BEAM1)

local function validTile(from, pos)
	local info = getTileInfo(pos)
	if(type(info) ~= 'table' or info.protection) then
		return false
	end

	return isSightClear(from, pos, false)
end

local function land(cid, pos)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0 or not validTile(getCreaturePosition(cid), pos)) then
		return
	end

	local min, max = Cleric.values(cid, unpack(config.damage))
	doAreaCombatHealth(cid, COMBAT_HOLYDAMAGE, pos, single, -min, -max, CONST_ME_HOLYDAMAGE)
end

local function drop(cid)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	local from = getCreaturePosition(cid)
	for attempt = 1, 6 do
		local dx, dy = math.random(-config.radius, config.radius), math.random(-config.radius, config.radius)
		if(dx * dx + dy * dy <= config.radius * config.radius + 1) then
			local pos = {x = from.x + dx, y = from.y + dy, z = from.z}
			if(validTile(from, pos)) then
				VFX.SkyFall(pos, CONST_ANI_SMALLHOLY, {offsetX = config.offset, height = config.height})
				addEvent(land, config.flight, cid, pos)
				return
			end
		end
	end
end

-- glyph: healing pulse of the tempest
local function graceTick(cid, amount, left, interval, radius)
	if(left <= 0 or not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	Cleric.heal(cid, Cleric.allies(cid, getCreaturePosition(cid), radius), amount, amount, CONST_ME_MAGIC_BLUE)
	addEvent(graceTick, interval, cid, amount, left - 1, interval, radius)
end

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local condition = createConditionObject(CONDITION_PARALYZE)
	setConditionParam(condition, CONDITION_PARAM_TICKS, config.paralyze)
	local slow = (glyph and glyph.slow) or 0.9
	setConditionFormula(condition, -slow, 0, -slow, 0)
	doAddCondition(cid, condition)

	for i = 1, config.drops do
		addEvent(drop, math.random(0, config.duration), cid)
	end

	if(glyph and glyph.grace) then
		local min, max = Cleric.values(cid, unpack(config.damage))
		local amount = math.max(1, math.floor((min + max) / 2 * config.drops * glyph.grace.percent / 100))
		addEvent(graceTick, glyph.grace.interval, cid, amount, glyph.grace.ticks, glyph.grace.interval, glyph.grace.radius)
	end

	Cleric.faith(cid)
	return true
end
