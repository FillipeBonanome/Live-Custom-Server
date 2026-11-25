-- Death Touch: death damage in 1 target (P x 0.7 to 1.3).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.mana   = {percent}              you recover `percent`% of the average damage of the spell as mana when it hits
--   glyph.resist = {percent, duration}    lowers the death resistance of the monster (before the hit)
local KEY = "necromancer/death touch"

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MORTAREA)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_DEATH)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, Necro.formula(0.7, 1.3))

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph) then
		return doCombat(cid, combat, var)
	end

	local target = Glyphs.aimed(var)
	if(target > 0 and glyph.resist) then
		Glyphs.reduceResistance(target, COMBAT_DEATHDAMAGE, glyph.resist.percent, glyph.resist.duration)
	end

	local ret = doCombat(cid, combat, var)
	if(ret and glyph.mana) then
		local min, max = Necro.values(cid, 0.7, 1.3)
		local average = math.abs(SpellBalance.scale(cid, KEY, -(min + max) / 2))
		doCreatureAddMana(cid, math.max(1, math.floor(average * glyph.mana.percent / 100)))
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
	end

	return ret
end
