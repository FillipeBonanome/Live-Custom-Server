-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.paralyze = {percent, duration}  slows the target almost to a stop
--   glyph.pierce   = {length}             the strike goes through the target and hits everything on the line, up to `length` sqm
local KEY = "attack/ice strike"

local function build(distance)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_ICEATTACK)
	if(distance) then
		setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_SMALLICE)
	end

	setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, -1, -10, -1, -20, 5, 5, 1.4, 2.1)
	return combat
end

local combat = build(true)
local lineCombat = build(false) -- hits one tile; the shot is drawn once by the script

local function round(value)
	return math.floor(value + 0.5)
end

-- tiles of the line that starts at `from` and goes through `aim`, up to `length` sqm. Stops at walls (blocked sight) and at
-- tiles that do not exist
local function linePositions(from, aim, length)
	local dx, dy = aim.x - from.x, aim.y - from.y
	local steps = math.max(math.abs(dx), math.abs(dy))
	if(steps == 0) then
		return {}
	end

	local list = {}
	for i = 1, length do
		local pos = {x = from.x + round(dx * i / steps), y = from.y + round(dy * i / steps), z = from.z}
		if(not getTileInfo(pos) or not isSightClear(from, pos, false)) then
			break
		end

		table.insert(list, pos)
	end

	return list
end

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.pierce) then
		local from = getCreaturePosition(cid)
		local target = Glyphs.aimed(var)
		local aim = target > 0 and getCreaturePosition(target) or variantToPosition(var)
		if(not aim or not aim.x or aim.x == 0) then
			return false
		end

		local list = linePositions(from, aim, glyph.pierce.length)
		for _, pos in ipairs(list) do
			doCombat(cid, lineCombat, positionToVariant(pos))
		end

		if(#list > 0) then
			doSendDistanceShoot(from, list[#list], CONST_ANI_SMALLICE)
		end

		return true
	end

	local target = (glyph and glyph.paralyze) and Glyphs.aimed(var) or 0
	local ret = doCombat(cid, combat, var)
	if(ret and target > 0 and glyph.paralyze and isCreature(target) and getCreatureHealth(target) > 0) then
		if(Glyphs.paralyze(cid, target, glyph.paralyze.percent, glyph.paralyze.duration)) then
			doSendMagicEffect(getCreaturePosition(target), CONST_ME_ICEAREA)
		end
	end

	return ret
end
