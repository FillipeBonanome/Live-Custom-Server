-- Front Sweep (Knight line, like the global one): sweeps the tiles in front of you (3 wide, 2 deep). Direction spell, the area turns with where you look.
-- Physical damage a bit above Berserk (skill + attack, no glyphs of its own).
local KEY = "attack/front sweep"

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)
setCombatParam(combat, COMBAT_PARAM_USECHARGES, true)
setCombatArea(combat, createCombatArea({
	{1, 1, 1},
	{1, 1, 1},
	{0, 3, 0}
}, {
	{0, 1, 1},
	{1, 1, 1},
	{1, 1, 3}
}))

Glyphs.setCallback(combat, CALLBACK_PARAM_SKILLVALUE, function(cid, level, skill, attack, factor)
	local skillTotal, levelTotal = skill + attack, level / 5
	return -(skillTotal * 1.1 + levelTotal), -(skillTotal * 2.7 + levelTotal)
end)

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
