-- Ground Slam: shock wave in front of you (wave, power x 1.1 to 1.7) that also slows the monsters hit (-60% speed for 3s).
-- Costs 8% of the max health (healthpercent in spells.xml). Gives 1 Fury.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.long = true                         a bigger wave (one more sqm of range, two more of width at the far end)
--   glyph.stun = {chance, percent, duration, slow = {percent, duration}}   the slow lasts longer and each creature hit has `chance`% to be stunned
local config = {damage = {1.1, 1.7}}

-- wave with one more row and a wider end than AREA_WAVE4 / AREADIAGONAL_WAVE4 (same as the Fire Wave glyph)
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

-- called for every creature the wave really hit (after the damage): the glyph slow and stun
local function onTarget(cid, target)
	local glyph = Berserker.glyph(cid, "ground slam")
	if(not glyph or not glyph.stun or not Glyphs.isEnemy(cid, target)) then
		return true
	end

	Glyphs.paralyze(cid, target, glyph.stun.slow.percent, glyph.stun.slow.duration)
	if(math.random(100) <= glyph.stun.chance and Glyphs.paralyze(cid, target, glyph.stun.percent, glyph.stun.duration)) then
		doSendMagicEffect(getCreaturePosition(target), CONST_ME_STUN)
	end

	return true
end

-- withSlow: the normal -60% for 3s (the stun glyph does its own slow in onTarget instead)
local function build(area, diagonal, withSlow)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_GROUNDSHAKER)
	setCombatArea(combat, createCombatArea(area, diagonal))

	if(withSlow) then
		local slow = createConditionObject(CONDITION_PARALYZE)
		setConditionParam(slow, CONDITION_PARAM_TICKS, 3000)
		setConditionFormula(slow, -0.6, 0, -0.6, 0)
		setCombatCondition(combat, slow)
	else
		Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)
	end

	-- each combat registers its own copy of the callback (the server forgets a global function once it is registered)
	Glyphs.setCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, function(cid, level, maglevel)
		local min, max = Berserker.values(cid, config.damage[1], config.damage[2])
		return -min, -max
	end)
	return combat
end

local combat = build(AREA_WAVE4, AREADIAGONAL_WAVE4, true)
local combatLong = build(AREA_WAVE_WIDE, AREADIAGONAL_WAVE_WIDE, true)
local combatStun = build(AREA_WAVE4, AREADIAGONAL_WAVE4, false)

function onCastSpell(cid, var)
	local glyph = Berserker.glyph(cid, "ground slam")
	local used = combat
	if(glyph and glyph.long) then
		used = combatLong
	elseif(glyph and glyph.stun) then
		used = combatStun
	end

	local result = doCombat(cid, used, var)
	Berserker.fury(cid)
	return result
end
