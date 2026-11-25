-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.zone     = {chance, ticks, interval, percent}   every tile hit may turn into thorns: `ticks` hits, one every `interval` ms,
--                                                         that together deal `percent`% of the damage of the spell
--   glyph.regrowth = {percent, targets, range}            you and your party within `range` sqm recover `percent`% of the average
--                                                         damage of the wave for each enemy hit (up to `targets`)
local KEY = "attack/terra wave"

-- setAttackFormula(5, 5, 3.5, 7): damage between level / 5 + magic * 3.5 and level / 5 + magic * 7
local function formula(cid)
	local level, magic = getPlayerLevel(cid), getPlayerMagLevel(cid)
	return level / 5 + magic * 3.5, level / 5 + magic * 7
end

local single = createCombatArea(AREA_BEAM1)
local hitsOfCast = {} -- caster -> number of enemies hit, filled by the target callback during doCombat

-- every creature the wave really hit (after the damage)
local function onTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.regrowth and hitsOfCast[cid] and Glyphs.isEnemy(cid, target)) then
		hitsOfCast[cid] = hitsOfCast[cid] + 1
	end

	return true
end

-- the thorns: a tile that keeps hurting
local function thorn(cid, pos, left, config)
	if(left <= 0 or not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	local info = getTileInfo(pos)
	if(type(info) == "table" and not info.protection) then
		local min, max = formula(cid)
		local share = config.percent / 100 / config.ticks
		doAreaCombatHealth(cid, COMBAT_EARTHDAMAGE, pos, single, SpellBalance.scale(cid, KEY, -min * share),
			SpellBalance.scale(cid, KEY, -max * share), CONST_ME_SMALLPLANTS)
	end

	addEvent(thorn, config.interval, cid, pos, left - 1, config)
end

-- called for every tile of the area
local function onTile(cid, pos)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.zone and math.random(100) <= glyph.zone.chance) then
		addEvent(thorn, glyph.zone.interval, cid, {x = pos.x, y = pos.y, z = pos.z}, glyph.zone.ticks, glyph.zone)
	end

	return true
end

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_SMALLPLANTS)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_EARTH)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 3.5, 7)
setCombatArea(combat, createCombatArea(AREA_SQUAREWAVE5, AREADIAGONAL_SQUAREWAVE5))
Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)
Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETTILE, onTile)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph or not glyph.regrowth) then
		return doCombat(cid, combat, var)
	end

	hitsOfCast[cid] = 0
	local ret = doCombat(cid, combat, var)
	local hits = math.min(hitsOfCast[cid] or 0, glyph.regrowth.targets)
	hitsOfCast[cid] = nil

	if(ret and hits > 0) then
		local min, max = formula(cid)
		local heal = math.floor(SpellBalance.scale(cid, KEY, -(min + max) / 2) * -1 * glyph.regrowth.percent / 100 * hits)
		if(heal > 0) then
			for _, tid in ipairs(Glyphs.allies(cid, glyph.regrowth.range)) do
				doCreatureAddHealth(tid, heal)
				doSendMagicEffect(getCreaturePosition(tid), CONST_ME_MAGIC_GREEN)
			end
		end
	end

	return ret
end
