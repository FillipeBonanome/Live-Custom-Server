-- Venom Touch: poison hit in 1 target (P x 0.4 to 0.8) that also poisons it.
-- Glyphs (data/lib/403-glyphs.lua), applied by Necro.poisonTarget (data/lib/373-necromancer.lua):
--   glyph.poison = {ticks, mult}          longer poison (1 tick per second) / more damage per tick
--   glyph.slow   = {percent, duration}    the poisoned target is slowed
local KEY = "necromancer/venom touch"

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HITBYPOISON)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_POISON)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, Necro.formula(0.4, 0.8))

-- poison over time (10s) on everything that is hit: each tick = 30% of the damage of the spell (Necro.poisonPercent)
Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, function(cid, target)
	Necro.poisonTarget(cid, target, Glyphs.get(cid, KEY), 0.4, 0.8)
	return true
end)

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
