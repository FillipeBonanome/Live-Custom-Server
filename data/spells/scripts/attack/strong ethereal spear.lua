-- Strong Ethereal Spear: a heavier Ethereal Spear (longer range, longer cooldown, about twice the damage).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.damage  multiplier of the hit (applied by SpellBalance)
--   glyph.pierce  = {length}           the spear goes through the target and hits everything on the line, up to `length` sqm
--   glyph.resist  = {percent, duration} lowers the physical resistance of the monster (before the hit)
local KEY = "attack/strong ethereal spear"

local function build(distance)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_BLOCKARMOR, true)
	if(distance) then
		setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ETHEREALSPEAR)
	end

	Glyphs.setCallback(combat, CALLBACK_PARAM_SKILLVALUE, function(cid, level, skill, attack, factor)
		return -(((skill + 25) * 0.6) + (level / 5)), -(((skill + 25) * 1.8) + (level / 5))
	end)
	return combat
end

local combat = build(true)
local lineCombat = build(false) -- hits one tile; the shot is drawn once by the script

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

	if(glyph and glyph.resist) then
		local target = Glyphs.aimed(var)
		if(target > 0 and Glyphs.reduceResistance(target, COMBAT_PHYSICALDAMAGE, glyph.resist.percent, glyph.resist.duration)) then
			doSendMagicEffect(getCreaturePosition(target), CONST_ME_BLOCKHIT)
		end
	end

	return doCombat(cid, combat, var)
end
