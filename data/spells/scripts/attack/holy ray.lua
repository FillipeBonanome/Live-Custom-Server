-- Holy Ray: single target holy damage, the Cleric's main (spam) spell.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.mend  = {percent, radius}   the ally (caster or party) with the lowest health within `radius` sqm is healed `percent`% of the average damage
--   glyph.faith = n                   stacks of Faith given by each cast (1 normally)
local KEY = "attack/holy ray"

-- setAttackFormula(5, 5, 1.6, 2.4, 5, 15): average of the formula, used by the glyph that heals
local function average(cid)
	return getPlayerLevel(cid) / 5 + getPlayerMagLevel(cid) * 2.0 + 10
end

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HOLYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_HOLY)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 1.6, 2.4, 5, 15)

function onCastSpell(cid, var)
	if(not doCombat(cid, combat, var)) then
		return false
	end

	local glyph = Glyphs.get(cid, KEY)
	Cleric.faith(cid)
	if(not glyph) then
		return true
	end

	for i = 2, (glyph.faith or 1) do
		Cleric.faith(cid)
	end

	if(glyph.mend) then
		local lowest, ratio
		for _, tid in ipairs(Cleric.allies(cid, getCreaturePosition(cid), glyph.mend.radius)) do
			local current = getCreatureHealth(tid) / getCreatureMaxHealth(tid)
			if(getCreatureHealth(tid) < getCreatureMaxHealth(tid) and (not ratio or current < ratio)) then
				lowest, ratio = tid, current
			end
		end

		if(lowest) then
			local amount = math.floor(average(cid) * glyph.mend.percent / 100 * Cleric.faithMultiplier(cid))
			Cleric.heal(cid, {lowest}, amount, amount, CONST_ME_MAGIC_BLUE)
		end
	end

	return true
end
