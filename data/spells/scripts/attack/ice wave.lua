-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.paralyze = {percent, duration}   every enemy hit is slowed (percent 0.4 = 40% slower)
--   glyph.haste    = {duration}            if the wave hit at least one enemy, the caster gets the speed of the Haste spell
local KEY = "attack/ice wave"

local hitsOfCast = {} -- caster -> number of enemies hit, filled by the target callback during doCombat

-- called for every creature the wave really hit (after the damage)
local function onTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph or not Glyphs.isEnemy(cid, target)) then
		return true
	end

	if(hitsOfCast[cid]) then
		hitsOfCast[cid] = hitsOfCast[cid] + 1
	end

	if(glyph.paralyze) then
		Glyphs.paralyze(cid, target, glyph.paralyze.percent, glyph.paralyze.duration)
	end

	return true
end

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_ICEAREA)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ICE)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 1, 2)
setCombatArea(combat, createCombatArea(AREA_WAVE4, AREADIAGONAL_WAVE4))
Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph) then
		return doCombat(cid, combat, var)
	end

	hitsOfCast[cid] = 0
	local ret = doCombat(cid, combat, var)
	local hits = hitsOfCast[cid]
	hitsOfCast[cid] = nil

	if(ret and glyph.haste and hits and hits > 0) then
		Glyphs.haste(cid, glyph.haste.duration)
	end

	return ret
end
