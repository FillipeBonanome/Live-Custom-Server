-- Cleave: swing that hits the tiles beside you and the two behind them (power x 0.7 to 1.1); direction spell, the area turns with where you look:
--   {1, 3, 1}   3 = you
--   {1, 0, 1}
-- The main (spam) spell of the Berserker. Costs 3% of the max health (healthpercent in spells.xml). Gives 1 Fury.
local config = {damage = {0.7, 1.1}}

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)
setCombatArea(combat, createCombatArea({
	{1, 3, 1},
	{1, 0, 1}
}))

function onGetPlayerMinMaxValues(cid, level, maglevel)
	local min, max = Berserker.values(cid, config.damage[1], config.damage[2])
	return -min, -max
end
setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetPlayerMinMaxValues")

function onCastSpell(cid, var)
	local result = doCombat(cid, combat, var)
	Berserker.fury(cid)
	return result
end
