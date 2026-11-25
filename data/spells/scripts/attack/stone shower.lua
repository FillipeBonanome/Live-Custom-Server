-- Stone Shower: stones thrown at the target, 7x7 circle (rune and instant spell share this script).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.stun  = {chance, percent, duration}   every enemy hit has `chance`% to be slowed almost to a stop
--   glyph.armor = {duration, physical, earth}   the caster takes that % less physical / earth damage (buff "Gravel Armor" in !buffs)
local KEY = "attack/stone shower"
local ARMOR_SUBID = 8810

-- called for every creature the shower really hit (after the damage)
local function onTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.stun and Glyphs.isEnemy(cid, target) and math.random(100) <= glyph.stun.chance) then
		if(Glyphs.paralyze(cid, target, glyph.stun.percent, glyph.stun.duration)) then
			doSendMagicEffect(getCreaturePosition(target), CONST_ME_STUN)
		end
	end

	return true
end

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_STONES)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_EARTH)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 1.4, 2.8, 40, 70)
setCombatArea(combat, createCombatArea(AREA_CIRCLE3X3))
Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local ret = doCombat(cid, combat, var)

	if(ret and glyph and glyph.armor) then
		local config = glyph.armor
		Glyphs.statBuff(cid, {
			name = "Gravel Armor", duration = config.duration, subId = ARMOR_SUBID, effect = CONST_ME_STONES,
			description = config.physical .. "% less physical damage and " .. config.earth .. "% less earth damage.",
			params = {[CONDITION_PARAM_ABSORB_PHYSICAL] = config.physical, [CONDITION_PARAM_ABSORB_EARTH] = config.earth}
		})
	end

	return ret
end
