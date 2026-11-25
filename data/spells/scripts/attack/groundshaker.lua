-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.stun = {chance, percent, duration}   every enemy hit has `chance`% to be slowed almost to a stop
--   glyph.wide = true                          the area is 1 sqm bigger (radius 4 instead of 3)
--   glyph.push = {chance}                      every creature hit is pushed 1 sqm away from the caster (data/lib/404-push.lua)
local KEY = "attack/groundshaker"

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

local hitsOfCast = {} -- caster -> creatures hit, filled by the target callback during doCombat

-- called for every creature the spell really hit (after the damage)
local function onTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph or not Glyphs.isEnemy(cid, target)) then
		return true
	end

	if(glyph.stun and math.random(100) <= glyph.stun.chance) then
		if(Glyphs.paralyze(cid, target, glyph.stun.percent, glyph.stun.duration)) then
			doSendMagicEffect(getCreaturePosition(target), CONST_ME_STUN)
		end
	end

	if(glyph.push and hitsOfCast[cid]) then
		table.insert(hitsOfCast[cid], target)
	end

	return true
end

local function build(area)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_GROUNDSHAKER)
	setCombatParam(combat, COMBAT_PARAM_USECHARGES, true)
	setCombatArea(combat, createCombatArea(area))

	Glyphs.setCallback(combat, CALLBACK_PARAM_SKILLVALUE, function(cid, level, skill, attack, factor)
		local skillTotal, levelTotal = skill + attack, level / 5
		return -(skillTotal * 0.5 + levelTotal), -(skillTotal * 1.1 + levelTotal)
	end)
	Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)
	return combat
end

local combat = build(AREA_CIRCLE3X3)
local combatWide = build(AREA_CIRCLE4X4)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph) then
		return doCombat(cid, combat, var)
	end

	hitsOfCast[cid] = {}
	local ret = doCombat(cid, glyph.wide and combatWide or combat, var)
	local hits = hitsOfCast[cid]
	hitsOfCast[cid] = nil

	if(ret and glyph.push and hits and #hits > 0) then
		Glyphs.pushAll(cid, hits, glyph.push.chance)
	end

	return ret
end
