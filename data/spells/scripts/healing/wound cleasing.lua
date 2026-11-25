-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.cleanse = true            removes every harmful condition of the caster
--   glyph.haste   = {duration}      the caster gets the speed of the Haste spell for `duration` ms
--   glyph.immune  = {duration}      the caster cannot be paralyzed for `duration` ms
local KEY = "healing/wound cleasing"

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)
setHealingFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 11, 15)

function onCastSpell(cid, var)
	local ret = doCombat(cid, combat, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not ret or not glyph) then
		return ret
	end

	if(glyph.cleanse) then
		Glyphs.cleanse(cid)
	end

	if(glyph.haste) then
		Glyphs.haste(cid, glyph.haste.duration)
	end

	if(glyph.immune) then
		Glyphs.paralysisImmunity(cid, glyph.immune.duration)
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
	end

	return ret
end
