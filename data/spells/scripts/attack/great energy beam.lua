-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.long = true                  longer beam (10 sqm instead of 7)
--   glyph.damage                       multiplier of the damage (applied by SpellBalance)
--   glyph.resist = {percent, duration} every monster hit loses that much energy resistance (a condition, see Glyphs.reduceResistance)
local KEY = "attack/great energy beam"

local AREA_BEAM10 = {
	{1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1},
	{3}
}

local AREADIAGONAL_BEAM10 = {
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3}
}

-- called for every creature the beam really hit (after the damage)
local function onTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.resist) then
		Glyphs.reduceResistance(target, COMBAT_ENERGYDAMAGE, glyph.resist.percent, glyph.resist.duration)
	end

	return true
end

local function build(area, diagonal)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_ENERGYHIT)
	setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 4, 7)
	setCombatArea(combat, createCombatArea(area, diagonal))
	Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)
	return combat
end

local combat = build(AREA_BEAM7, AREADIAGONAL_BEAM7)
local combatLong = build(AREA_BEAM10, AREADIAGONAL_BEAM10)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	return doCombat(cid, (glyph and glyph.long) and combatLong or combat, var)
end
