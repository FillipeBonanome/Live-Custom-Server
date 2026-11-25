-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.buff  = {duration, amp, critical}   after the blow the caster gets, for `duration` ms, `amp`% physical damage and `critical`% critical chance
--                                             (buff "Savage Fury" in !buffs)
--   glyph.guard = {duration, percent}         after the blow the caster takes `percent`% less damage for `duration` ms (buff "Warlord's Roar")
--   glyph.resist = {percent, duration}        every creature hit loses physical resistance
local KEY = "attack/fierce berserk"
local FURY_SUBID, ROAR_SUBID = 8820, 8821

-- called for every creature the blow really hit (after the damage)
local function onTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.resist and Glyphs.isEnemy(cid, target)) then
		Glyphs.reduceResistance(target, COMBAT_PHYSICALDAMAGE, glyph.resist.percent, glyph.resist.duration)
	end

	return true
end

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)
setCombatParam(combat, COMBAT_PARAM_USECHARGES, true)
setCombatArea(combat, createCombatArea(AREA_SQUARE1X1))
Glyphs.setCallback(combat, CALLBACK_PARAM_SKILLVALUE, function(cid, level, skill, attack, factor)
	local skillTotal, levelTotal = skill + attack * 2, level / 5
	return -(skillTotal * 1.7 + levelTotal), -(skillTotal * 3.3 + levelTotal)
end)
Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)

function onCastSpell(cid, var)
	local ret = doCombat(cid, combat, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not ret or not glyph) then
		return ret
	end

	if(glyph.buff) then
		local config = glyph.buff
		Glyphs.statBuff(cid, {
			name = "Savage Fury", duration = config.duration, subId = FURY_SUBID, effect = CONST_ME_HITAREA,
			description = "+" .. config.amp .. "% physical damage and +" .. config.critical .. "% critical chance.",
			params = {[CONDITION_PARAM_ELEMENTAL_AMP_PHYSICAL] = config.amp, [CONDITION_PARAM_CRITICALCHANCE] = config.critical}
		})
	end

	if(glyph.guard) then
		Glyphs.statBuff(cid, {
			name = "Warlord's Roar", duration = glyph.guard.duration, subId = ROAR_SUBID, effect = CONST_ME_HITAREA,
			description = glyph.guard.percent .. "% less damage from every source.",
			params = Glyphs.absorbAll(glyph.guard.percent)
		})
	end

	return ret
end
