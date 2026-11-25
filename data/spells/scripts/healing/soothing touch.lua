-- Soothing Touch: medium heal on one ally ("exura lux sio" "name", or on the current target).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.twin    = {percent}              when you heal someone else, you recover `percent`% of the average healing too
--   glyph.cleanse = true                   removes every harmful condition of the target
--   glyph.ward    = {percent, duration}    the target takes `percent`% less damage from every element for `duration` ms (buff, subId 8831)
local KEY = "healing/soothing touch"
local WARD_SUBID = 8831

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)

-- heal formula: level/5 + magic level * 6 (min) or 8.4 (max), plus the Faith bonus
function onGetFormulaValues(cid, level, maglevel)
	local multiplier = Cleric.faithMultiplier(cid)
	return math.floor((level / 5 + maglevel * 6) * multiplier), math.floor((level / 5 + maglevel * 8.4) * multiplier)
end
setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local target = glyph and Glyphs.aimed(var) or 0
	if(not doCombat(cid, combat, var)) then
		return false
	end

	Cleric.faith(cid)
	if(target == 0 or not isCreature(target) or getCreatureHealth(target) <= 0) then
		return true
	end

	if(glyph.twin and target ~= cid) then
		local average = getPlayerLevel(cid) / 5 + getPlayerMagLevel(cid) * 7.2
		local amount = math.floor(average * glyph.twin.percent / 100 * Cleric.faithMultiplier(cid) * Glyphs.multiplier(cid, KEY, "healing"))
		Cleric.heal(cid, {cid}, amount, amount, CONST_ME_MAGIC_BLUE)
	end

	if(glyph.cleanse) then
		Glyphs.cleanse(target)
	end

	if(glyph.ward and isPlayer(target)) then
		Glyphs.statBuff(target, {
			name = "Absolving Touch", duration = glyph.ward.duration, subId = WARD_SUBID,
			description = glyph.ward.percent .. "% less damage from every element.", params = Glyphs.absorbAll(glyph.ward.percent)
		})
	end

	return true
end
