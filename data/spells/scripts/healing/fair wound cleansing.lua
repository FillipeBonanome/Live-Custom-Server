-- Fair Wound Cleansing: stronger melee heal (Knight, Assassin, Berserker). Scales with level and the best melee skill.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.healing  multiplier of the healing (applied by SpellBalance)
--   glyph.cleanse = true   removes every harmful condition of the caster
local KEY = "healing/fair wound cleansing"

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)

function onGetFormulaValues(cid, level, maglevel)
	local skill = math.max(getPlayerSkillLevel(cid, SKILL_SWORD), getPlayerSkillLevel(cid, SKILL_CLUB), getPlayerSkillLevel(cid, SKILL_AXE))
	return math.floor(level / 3 + skill * 3.0 + 20), math.floor(level / 3 + skill * 4.0 + 35)
end
setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(cid, var)
	local ret = doCombat(cid, combat, var)
	local glyph = Glyphs.get(cid, KEY)
	if(ret and glyph and glyph.cleanse) then
		Glyphs.cleanse(cid)
	end

	return ret
end
