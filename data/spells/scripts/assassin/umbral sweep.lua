-- Umbral Sweep: a wave of shadow in front of you (wave, death damage, power x 0.9 to 1.4). Direction spell, the wave turns with where you look.
-- Gives 1 Momentum.
local config = {damage = {0.9, 1.4}}

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_NONE)
setCombatArea(combat, createCombatArea(AREA_WAVE4, AREADIAGONAL_WAVE4))

-- each combat registers its own copy of the callback (the server forgets a global function once it is registered)
Glyphs.setCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, function(cid, level, maglevel)
	local min, max = Assassin.values(cid, config.damage[1], config.damage[2])
	return -min, -max
end)

function onCastSpell(cid, var)
	local result = doCombat(cid, combat, var)
	Assassin.fx("assassin_umbra", cid, {direction = getCreatureLookDirection(cid)})
	Assassin.momentum(cid)
	return result
end
