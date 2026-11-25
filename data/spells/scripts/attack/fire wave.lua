-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.wide = true                          bigger wave (one more sqm of range, two more of width at the far end)
--   glyph.burn = {percent, ticks, interval}    every creature hit burns: a percent of the average damage of the spell
local KEY = "attack/fire wave"

-- wave with one more row and a wider end than AREA_WAVE4 / AREADIAGONAL_WAVE4 (data/spells/lib/spells.lua)
local AREA_WAVE_WIDE = {
	{1, 1, 1, 1, 1, 1, 1},
	{0, 1, 1, 1, 1, 1, 0},
	{0, 1, 1, 1, 1, 1, 0},
	{0, 0, 1, 1, 1, 0, 0},
	{0, 0, 0, 3, 0, 0, 0}
}

local AREADIAGONAL_WAVE_WIDE = {
	{0, 0, 0, 0, 0, 1, 0},
	{0, 0, 0, 0, 1, 1, 0},
	{0, 0, 0, 1, 1, 1, 0},
	{0, 0, 1, 1, 1, 1, 0},
	{0, 1, 1, 1, 1, 1, 0},
	{1, 1, 1, 1, 1, 1, 0},
	{0, 0, 0, 0, 0, 0, 3}
}

-- The server forgets a global function once it is registered as a callback, so every combat needs its own copy of it
local callbackCount = 0
local function setCallback(combat, key, handler)
	callbackCount = callbackCount + 1
	local name = "__glyphFireWave" .. callbackCount
	_G[name] = handler
	setCombatCallback(combat, key, name)
end

-- called for every creature the wave really hit (after the damage)
local function onTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph or not glyph.burn or not Glyphs.isEnemy(cid, target)) then
		return true
	end

	-- average of the damage of the spell: setAttackFormula(5, 5, 1.2, 2)
	local level, magic = getPlayerLevel(cid), getPlayerMagLevel(cid)
	local average = (level / 5 + magic * 1.2 + level / 5 + magic * 2) / 2
	local dealt = math.abs(SpellBalance and SpellBalance.scale(cid, KEY, -average) or -average)
	Glyphs.dot(cid, target, CONDITION_FIRE, math.max(1, math.floor(dealt * glyph.burn.percent / 100)), glyph.burn.ticks, glyph.burn.interval)
	return true
end

local function build(area, diagonal)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HITBYFIRE)
	setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FIRE)
	setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 1.2, 2)
	setCombatArea(combat, createCombatArea(area, diagonal))
	setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)
	return combat
end

local combat = build(AREA_WAVE4, AREADIAGONAL_WAVE4)
local combatWide = build(AREA_WAVE_WIDE, AREADIAGONAL_WAVE_WIDE)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	return doCombat(cid, (glyph and glyph.wide) and combatWide or combat, var)
end
