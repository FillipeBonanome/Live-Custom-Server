-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.ward    = {percent, duration}   every player healed takes `percent`% less damage for `duration` ms (buff "Verdant Ward")
--   glyph.wide    = true                  the area is 1 sqm bigger (radius 4 instead of 3)
--   glyph.healing                         multiplier of the healing (applied by SpellBalance)
local KEY = "healing/mass healing"
local WARD_SUBID = 8811

-- circle of radius 4 (AREA_CIRCLE3X3 has radius 3)
local AREA_CIRCLE4X4 = {
	{0, 0, 0, 1, 1, 1, 0, 0, 0},
	{0, 0, 1, 1, 1, 1, 1, 0, 0},
	{0, 1, 1, 1, 1, 1, 1, 1, 0},
	{1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 3, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1},
	{0, 1, 1, 1, 1, 1, 1, 1, 0},
	{0, 0, 1, 1, 1, 1, 1, 0, 0},
	{0, 0, 0, 1, 1, 1, 0, 0, 0}
}

-- called for every creature the spell really healed
local function onTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.ward and isPlayer(target)) then
		local percent = glyph.ward.percent
		Glyphs.statBuff(target, {
			name = "Verdant Ward", duration = glyph.ward.duration, subId = WARD_SUBID, effect = CONST_ME_MAGIC_GREEN,
			description = percent .. "% less damage from every source.",
			params = {
				[CONDITION_PARAM_ABSORB_PHYSICAL] = percent, [CONDITION_PARAM_ABSORB_ENERGY] = percent,
				[CONDITION_PARAM_ABSORB_EARTH] = percent, [CONDITION_PARAM_ABSORB_FIRE] = percent,
				[CONDITION_PARAM_ABSORB_ICE] = percent, [CONDITION_PARAM_ABSORB_HOLY] = percent,
				[CONDITION_PARAM_ABSORB_DEATH] = percent, [CONDITION_PARAM_ABSORB_DROWN] = percent
			}
		})
	end

	return true
end

local function build(area)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
	setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
	setCombatParam(combat, COMBAT_PARAM_TARGETPLAYERSORSUMMONS, true)
	setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)
	setHealingFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 10, 12)
	setCombatArea(combat, createCombatArea(area))
	Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)
	return combat
end

local combat = build(AREA_CIRCLE3X3)
local combatWide = build(AREA_CIRCLE4X4)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	return doCombat(cid, (glyph and glyph.wide) and combatWide or combat, var)
end
