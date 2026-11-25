-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.damage                             multiplier of the damage (applied by SpellBalance)
--   glyph.haste = {chance, duration}         chance (%) of getting the speed of the Haste spell (+30%) for `duration` ms on each cast
local KEY = "attack/energy beam"

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_ENERGYHIT)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 2.5, 4)

local area = createCombatArea(AREA_BEAM5, AREADIAGONAL_BEAM5)
setCombatArea(combat, area)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local ret = doCombat(cid, combat, var)

	-- a haste that is already running (Haste, Strong Haste or this one) is never replaced, so the glyph cannot make it worse
	if(ret and glyph and glyph.haste and math.random(100) <= glyph.haste.chance and not getCreatureCondition(cid, CONDITION_HASTE)) then
		local condition = createConditionObject(CONDITION_HASTE)
		setConditionParam(condition, CONDITION_PARAM_TICKS, glyph.haste.duration)
		setConditionFormula(condition, 0.3, -24, 0.3, -24)
		doAddCondition(cid, condition)
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
	end

	return ret
end
