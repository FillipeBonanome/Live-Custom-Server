-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.zone = {chance, ticks, interval, percent}  every tile hit may stay holy: `ticks` hits, one every `interval` ms, that
--                                                     together deal `percent`% of the damage of the spell
--   glyph.push = {chance}                            every creature hit is pushed 1 sqm away from the caster (data/lib/404-push.lua)
local KEY = "attack/divine caldera"

-- setAttackFormula(5, 5, 4, 6): damage between level / 5 + magic * 4 and level / 5 + magic * 6
local function formula(cid)
	local level, magic = getPlayerLevel(cid), getPlayerMagLevel(cid)
	return level / 5 + magic * 4, level / 5 + magic * 6
end

local single = createCombatArea(AREA_BEAM1)
local hitsOfCast = {} -- caster -> creatures hit, filled by the target callback during doCombat

-- every creature the spell really hit (after the damage)
local function onTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.push and hitsOfCast[cid]) then
		table.insert(hitsOfCast[cid], target)
	end

	return true
end

-- the holy ground: a tile that keeps hurting
local function pulse(cid, pos, left, config)
	if(left <= 0 or not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	local info = getTileInfo(pos)
	if(type(info) == "table" and not info.protection) then
		local min, max = formula(cid)
		local share = config.percent / 100 / config.ticks
		doAreaCombatHealth(cid, COMBAT_HOLYDAMAGE, pos, single, SpellBalance.scale(cid, KEY, -min * share),
			SpellBalance.scale(cid, KEY, -max * share), CONST_ME_HOLYDAMAGE)
	end

	addEvent(pulse, config.interval, cid, pos, left - 1, config)
end

-- called for every tile of the area
local function onTile(cid, pos)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.zone and math.random(100) <= glyph.zone.chance) then
		addEvent(pulse, glyph.zone.interval, cid, {x = pos.x, y = pos.y, z = pos.z}, glyph.zone.ticks, glyph.zone)
	end

	return true
end

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HOLYAREA)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 4, 6)
setCombatArea(combat, createCombatArea(AREA_CIRCLE3X3))
Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)
Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETTILE, onTile)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph or not (glyph.push or glyph.zone)) then
		return doCombat(cid, combat, var)
	end

	hitsOfCast[cid] = {}
	local ret = doCombat(cid, combat, var)
	local hits = hitsOfCast[cid]
	hitsOfCast[cid] = nil
	if(not ret or not glyph.push or not hits or #hits == 0) then
		return ret
	end

	-- the farthest first, so the ones behind get out of the way of the ones in front
	local from, entries = getCreaturePosition(cid), {}
	for _, tid in ipairs(hits) do
		if(isCreature(tid) and getCreatureHealth(tid) > 0) then
			table.insert(entries, {id = tid, distance = getDistanceBetween(from, getCreaturePosition(tid))})
		end
	end

	table.sort(entries, function(a, b) return a.distance > b.distance end)
	for _, entry in ipairs(entries) do
		if(isCreature(entry.id)) then
			Push.away(cid, entry.id, glyph.push.chance)
		end
	end

	return ret
end
