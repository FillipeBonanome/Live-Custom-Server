-- Death Wave: wave of death like Vis Hur (P x 1.2 to 2.0).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.wide = true                     bigger wave: 5 sqm wide and 1 sqm longer
--   glyph.reap = {targets, chance, soul}  if the wave hits at least `targets` enemies: `chance`% chance of gaining `soul` soul
local KEY = "necromancer/death wave"

-- wave 5 sqm wide and one row longer than AREA_SQUAREWAVE5 / AREADIAGONAL_SQUAREWAVE5 (data/spells/lib/spells.lua)
local AREA_WAVE_WIDE = {
	{1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1},
	{0, 1, 1, 1, 0},
	{0, 0, 1, 0, 0},
	{0, 0, 3, 0, 0}
}

local AREADIAGONAL_WAVE_WIDE = {
	{1, 1, 1, 1, 0, 0, 0},
	{1, 1, 1, 1, 0, 0, 0},
	{1, 1, 1, 1, 0, 0, 0},
	{1, 1, 1, 1, 0, 0, 0},
	{0, 0, 0, 0, 1, 0, 0},
	{0, 0, 0, 0, 0, 1, 0},
	{0, 0, 0, 0, 0, 0, 3}
}

local hitsOfCast = {} -- caster -> number of enemies hit, filled by the target callback during doCombat

local function build(area, diagonal)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MORTAREA)
	setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_DEATH)
	setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, Necro.formula(1.2, 2.0))
	setCombatArea(combat, createCombatArea(area, diagonal))
	Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, function(cid, target)
		if(hitsOfCast[cid] and Glyphs.isEnemy(cid, target)) then
			hitsOfCast[cid] = hitsOfCast[cid] + 1
		end

		return true
	end)
	return combat
end

local combat = build(AREA_SQUAREWAVE5, AREADIAGONAL_SQUAREWAVE5)
local combatWide = build(AREA_WAVE_WIDE, AREADIAGONAL_WAVE_WIDE)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph) then
		return doCombat(cid, combat, var)
	end

	hitsOfCast[cid] = 0
	local ret = doCombat(cid, (glyph.wide and combatWide) or combat, var)
	local hits = hitsOfCast[cid]
	hitsOfCast[cid] = nil

	if(ret and glyph.reap and hits and hits >= glyph.reap.targets and math.random(100) <= glyph.reap.chance) then
		doPlayerAddSoul(cid, glyph.reap.soul)
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MORTAREA)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You absorbed " .. glyph.reap.soul .. " soul.")
	end

	return ret
end
