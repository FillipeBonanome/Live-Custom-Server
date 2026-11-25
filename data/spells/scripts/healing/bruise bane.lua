-- Bruise Bane: basic melee heal (Knight, Assassin, Berserker). Scales with level and the best melee skill.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.hot   = {percent, ticks, interval}   you heal `percent`% of the average healing of the spell again, in `ticks` heals
--   glyph.armor = {duration, physical}         you take `physical`% less physical damage for `duration` ms (buff "Hardened Skin")
local KEY = "healing/bruise bane"
local ARMOR_SUBID = 8822

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)

local function values(cid, level)
	local skill = math.max(getPlayerSkillLevel(cid, SKILL_SWORD), getPlayerSkillLevel(cid, SKILL_CLUB), getPlayerSkillLevel(cid, SKILL_AXE))
	return math.floor(level / 5 + skill * 1.2 + 5), math.floor(level / 5 + skill * 1.8 + 10)
end

function onGetFormulaValues(cid, level, maglevel)
	return values(cid, level)
end
setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(cid, var)
	local ret = doCombat(cid, combat, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not ret or not glyph) then
		return ret
	end

	if(glyph.hot) then
		local min, max = values(cid, getPlayerLevel(cid))
		local total = SpellBalance.scale(cid, KEY, (min + max) / 2 * glyph.hot.percent / 100)
		Glyphs.healOverTime(cid, total, glyph.hot.ticks, glyph.hot.interval, CONST_ME_MAGIC_GREEN)
	end

	if(glyph.armor) then
		Glyphs.statBuff(cid, {
			name = "Hardened Skin", duration = glyph.armor.duration, subId = ARMOR_SUBID, effect = CONST_ME_MAGIC_GREEN,
			description = glyph.armor.physical .. "% less physical damage.",
			params = {[CONDITION_PARAM_ABSORB_PHYSICAL] = glyph.armor.physical}
		})
	end

	return ret
end
