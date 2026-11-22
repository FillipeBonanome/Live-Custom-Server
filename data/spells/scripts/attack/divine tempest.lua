-- Divine Tempest (Hierophant): diagonal rain of holy around the caster for 5 seconds. The caster is paralyzed while it lasts.
-- `drops` small holy bolts fall at random moments of the duration (they do not fall all at once), each on a random tile of
-- the area (radius 5). Tiles in protection zones, tiles that do not exist and tiles behind walls (no line of sight from the
-- caster) are skipped.
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

function onCastSpell(cid, var)
	local condition = createConditionObject(CONDITION_PARALYZE)
	setConditionParam(condition, CONDITION_PARAM_TICKS, config.paralyze)
	setConditionFormula(condition, -0.9, 0, -0.9, 0)
	doAddCondition(cid, condition)

	for i = 1, config.drops do
		addEvent(drop, math.random(0, config.duration), cid)
	end

	Cleric.faith(cid)
	return true
end
