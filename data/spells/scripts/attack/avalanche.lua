-- Avalanche: ice thrown at the target, 7x7 circle (rune and instant spell share this script).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.roll   = {distance, delay, percent}   a second impact `distance` sqm farther in the direction of the cast (from you to the
--                                               first impact), `delay` ms later, with `percent`% of the damage
--   glyph.resist = {percent, duration}          every monster hit loses that much ice resistance (a condition, Glyphs.reduceResistance)
local KEY = "attack/avalanche"

local spell = Glyphs.spellByKey(KEY)
local rollConfig = spell and spell.glyphs.A and spell.glyphs.A.roll or {}

-- called for every creature the avalanche really hit (after the damage)
local function onTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.resist) then
		Glyphs.reduceResistance(target, COMBAT_ICEDAMAGE, glyph.resist.percent, glyph.resist.duration)
	end

	return true
end

-- setAttackFormula(5, 5, 1.4, 2.8, 40, 70) scaled by `scale` (negative = damage)
local function build(scale, distance)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_ICEAREA)
	if(distance) then
		setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ICE)
	end

	setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, scale, 0, scale, 0, 5, 5, 1.4, 2.8, 40 * scale, 70 * scale)
	setCombatArea(combat, createCombatArea(AREA_CIRCLE3X3))
	Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)
	return combat
end

local combat = build(-1, true)
local rollCombat = build(-(rollConfig.percent or 70) / 100, false)

local function sign(value)
	return value > 0 and 1 or (value < 0 and -1 or 0)
end

local function secondImpact(cid, pos)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	doCombat(cid, rollCombat, positionToVariant(pos))
end

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local pos
	if(glyph and glyph.roll) then
		local target = Glyphs.aimed(var)
		pos = target > 0 and getCreaturePosition(target) or variantToPosition(var)
	end

	local ret = doCombat(cid, combat, var)
	if(ret and pos and pos.x and pos.x > 0) then
		local from = getCreaturePosition(cid)
		local dx, dy = sign(pos.x - from.x), sign(pos.y - from.y)
		if(dx ~= 0 or dy ~= 0) then
			local second = {x = pos.x + dx * glyph.roll.distance, y = pos.y + dy * glyph.roll.distance, z = pos.z}
			if(getTileInfo(second)) then
				addEvent(secondImpact, glyph.roll.delay, cid, second)
			end
		end
	end

	return ret
end
