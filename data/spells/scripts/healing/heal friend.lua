-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.hot     = {percent, ticks, interval}   the target heals `percent`% of the average healing of the spell again, in `ticks` heals
--   glyph.cleanse = true                         removes every harmful condition of the target
--   glyph.haste   = {duration}                   the target gets the speed of the Haste spell for `duration` ms
local KEY = "healing/heal friend"

-- setHealingFormula(5, 5, 10, 14): healing between level / 5 + magic * 10 and level / 5 + magic * 14
local function average(cid)
	local level, magic = getPlayerLevel(cid), getPlayerMagLevel(cid)
	return level / 5 + magic * 12
end

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)
setHealingFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 10, 14)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph) then
		return doCombat(cid, combat, var)
	end

	local target = Glyphs.aimed(var)
	local ret = doCombat(cid, combat, var)
	if(not ret or target == 0 or not isCreature(target) or getCreatureHealth(target) <= 0) then
		return ret
	end

	if(glyph.hot) then
		local total = SpellBalance.scale(cid, KEY, average(cid) * glyph.hot.percent / 100)
		Glyphs.healOverTime(target, total, glyph.hot.ticks, glyph.hot.interval, CONST_ME_MAGIC_GREEN)
	end

	if(glyph.cleanse) then
		Glyphs.cleanse(target)
	end

	if(glyph.haste) then
		Glyphs.haste(target, glyph.haste.duration)
	end

	return ret
end
