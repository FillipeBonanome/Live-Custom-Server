-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.small = true                              smaller area (AREA_CIRCLE2X2 instead of AREA_CIRCLE3X3)
--   glyph.chain = {bounces, damage, range, delay}   every enemy hit throws a chain lightning to creatures that were not hit yet
--   glyph.zone = {chance, ticks, interval, percent} every tile hit may keep zapping: `ticks` hits, one every `interval` ms, that
--                                                    together deal `percent`% of the damage of the spell
local KEY = "attack/thunderstorm"

-- setAttackFormula(5, 5, 1.4, 2.8, 40, 70): damage between max(40, level / 5 + magic * 1.4) and max(70, level / 5 + magic * 2.8)
local function formula(cid)
	local level, magic = getPlayerLevel(cid), getPlayerMagLevel(cid)
	return math.max(40, level / 5 + magic * 1.4), math.max(70, level / 5 + magic * 2.8)
end

local single = createCombatArea(AREA_BEAM1)
local chainConfig = Glyphs.spellByKey(KEY).glyphs.A.chain or {}
local hitsOfCast = {} -- caster -> {{id, pos}} filled by the target callback during doCombat

-- The server forgets a global function once it is registered as a callback, so every combat needs its own copy of it
local callbackCount = 0
local function setCallback(combat, key, handler)
	callbackCount = callbackCount + 1
	local name = "__glyphThunderstorm" .. callbackCount
	_G[name] = handler
	setCombatCallback(combat, key, name)
end

-- every creature the spell really hit (after the damage)
local function onTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.chain and hitsOfCast[cid] and Glyphs.isEnemy(cid, target)) then
		table.insert(hitsOfCast[cid], {id = target, pos = getCreaturePosition(target)})
	end

	return true
end

-- the zone: a tile that keeps zapping
local function zap(cid, pos, left, config)
	if(left <= 0 or not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	local info = getTileInfo(pos)
	if(type(info) == "table" and not info.protection) then
		local min, max = formula(cid)
		local share = config.percent / 100 / config.ticks
		doAreaCombatHealth(cid, COMBAT_ENERGYDAMAGE, pos, single, SpellBalance.scale(cid, KEY, -min * share),
			SpellBalance.scale(cid, KEY, -max * share), CONST_ME_ENERGYHIT)
	end

	addEvent(zap, config.interval, cid, pos, left - 1, config)
end

-- called for every tile of the area
local function onTile(cid, pos)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.zone and math.random(100) <= glyph.zone.chance) then
		addEvent(zap, glyph.zone.interval, cid, {x = pos.x, y = pos.y, z = pos.z}, glyph.zone.ticks, glyph.zone)
	end

	return true
end

local function build(area, scale)
	scale = scale or 1
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_ENERGYHIT)
	if(area) then
		setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGYBALL)
		setCombatArea(combat, createCombatArea(area))
		setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)
		setCallback(combat, CALLBACK_PARAM_TARGETTILE, onTile)
	end

	-- same formula as setAttackFormula(5, 5, 1.4, 2.8, 40, 70), scaled for the ricochets
	setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, -scale, 0, -scale, 0, 5, 5, 1.4, 2.8, -40 * scale, -70 * scale)
	return combat
end

local combat = build(AREA_CIRCLE3X3)
local combatSmall = build(AREA_CIRCLE2X2)
local chainCombat = build(nil, chainConfig.damage or 0.5) -- one tile (the target), the jump is drawn by Glyphs.ricochet

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph) then
		return doCombat(cid, combat, var)
	end

	hitsOfCast[cid] = {}
	local ret = doCombat(cid, glyph.small and combatSmall or combat, var)
	local hits = hitsOfCast[cid]
	hitsOfCast[cid] = nil

	if(ret and glyph.chain and hits and #hits > 0 and glyph.chain.bounces > 0) then
		-- the creatures that were already hit are not hit again by any of the chains
		local hit = {}
		for _, entry in ipairs(hits) do
			hit[entry.id] = true
		end

		for _, entry in ipairs(hits) do
			addEvent(Glyphs.ricochet, glyph.chain.delay or 150, cid, entry.pos, hit, glyph.chain.bounces, glyph.chain, chainCombat)
		end
	end

	return ret
end
