-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.pierce  = {length}          the spear goes through the target and hits everything on the line, up to `length` sqm
--   glyph.execute = {below, damage}   the hit deals `damage` times more against a target with `below`% of its health or less
local KEY = "attack/ethereal spear"

local function build(scale, distance)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_BLOCKARMOR, true)
	if(distance) then
		setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ETHEREALSPEAR)
	end

	Glyphs.setCallback(combat, CALLBACK_PARAM_SKILLVALUE, function(cid, level, skill, attack, factor)
		return -(((skill + 25) / 3) + (level / 5)) * scale, -((skill + 25) + (level / 5)) * scale
	end)
	return combat
end

local spell = Glyphs.spellByKey(KEY)
local executeConfig = spell and spell.glyphs.B and spell.glyphs.B.execute or {}

local combat = build(1, true)
local executeCombat = build(executeConfig.damage or 1.5, true)
local lineCombat = build(1, false) -- hits one tile; the shot is drawn once by the script

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.pierce) then
		local from = getCreaturePosition(cid)
		local target = Glyphs.aimed(var)
		local aim = target > 0 and getCreaturePosition(target) or variantToPosition(var)
		if(not aim or not aim.x or aim.x == 0) then
			return false
		end

		local list = Glyphs.linePositions(from, aim, glyph.pierce.length)
		for _, pos in ipairs(list) do
			doCombat(cid, lineCombat, positionToVariant(pos))
		end

		if(#list > 0) then
			doSendDistanceShoot(from, list[#list], CONST_ANI_ETHEREALSPEAR)
		end

		return true
	end

	if(glyph and glyph.execute) then
		local target = Glyphs.aimed(var)
		if(target > 0 and getCreatureHealth(target) * 100 <= getCreatureMaxHealth(target) * glyph.execute.below) then
			return doCombat(cid, executeCombat, var)
		end
	end

	return doCombat(cid, combat, var)
end
