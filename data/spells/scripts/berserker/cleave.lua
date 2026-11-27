-- Cleave: swing that hits the tiles beside you and the two behind them (power x 0.6 to 0.9); direction spell, the area turns with where you look:
--   {1, 3, 1}   3 = you
--   {1, 0, 1}
-- The main (spam) spell of the Berserker. Costs 3% of the max health (healthpercent in spells.xml). Gives 1 Fury.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.wide   = true            the swing also hits the 3 tiles in front of you
--   glyph.damage = multiplier      damage multiplier
--   glyph.fury   = {chance}        chance (%) of 1 extra stack of Fury
local config = {damage = {0.6, 0.9}}

local function getValues(cid, level, maglevel)
	local min, max = Berserker.values(cid, config.damage[1], config.damage[2])
	local glyph = Berserker.glyph(cid, "cleave")
	local multiplier = glyph and glyph.damage or 1
	return -math.floor(min * multiplier), -math.floor(max * multiplier)
end

-- each combat registers its own copy of the callback (the server forgets a global function once it is registered)
local function build(area)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_NONE)
	setCombatArea(combat, createCombatArea(area))
	Glyphs.setCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, getValues)
	return combat
end

local combat = build({
	{1, 3, 1},
	{1, 0, 1}
})
local combatWide = build({
	{1, 1, 1},
	{1, 3, 1},
	{1, 0, 1}
})

function onCastSpell(cid, var)
	local glyph = Berserker.glyph(cid, "cleave")
	local result = doCombat(cid, (glyph and glyph.wide) and combatWide or combat, var)
	Berserker.fx("berserker_cleave", cid)
	local stacks = 1
	if(glyph and glyph.fury and math.random(100) <= glyph.fury.chance) then
		stacks = 2
	end

	Berserker.fury(cid, stacks)
	return result
end
