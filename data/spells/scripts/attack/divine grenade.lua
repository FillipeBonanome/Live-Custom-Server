-- Divine Grenade: a grenade of holy light thrown at the target; it explodes 2 seconds later on that spot (3x3), whoever is there.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.twin     = {delay, percent}         a second blast on the same spot `delay` ms after the first, with `percent`% of the damage
--   glyph.paralyze = {percent, duration}      every creature hit is slowed almost to a stop
local KEY = "attack/divine grenade"
local FUSE = 2000

local spell = Glyphs.spellByKey(KEY)
local twinConfig = spell and spell.glyphs.A and spell.glyphs.A.twin or {}

local function onTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.paralyze and Glyphs.isEnemy(cid, target)) then
		Glyphs.paralyze(cid, target, glyph.paralyze.percent, glyph.paralyze.duration)
	end

	return true
end

-- setAttackFormula(5, 5, 5.5, 8) scaled by `scale`
local function build(scale)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HOLYAREA)
	setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, scale, 0, scale, 0, 5, 5, 5.5, 8)
	setCombatArea(combat, createCombatArea(AREA_SQUARE1X1))
	Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)
	return combat
end

local combat = build(-1)
local twinCombat = build(-(twinConfig.percent or 60) / 100)

local function explode(cid, pos, twin)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	doCombat(cid, twin and twinCombat or combat, positionToVariant(pos))
end

function onCastSpell(cid, var)
	local target = Glyphs.aimed(var)
	local pos = target > 0 and getCreaturePosition(target) or variantToPosition(var)
	if(not pos or not pos.x or pos.x == 0) then
		return false
	end

	pos = {x = pos.x, y = pos.y, z = pos.z}
	doSendDistanceShoot(getCreaturePosition(cid), pos, CONST_ANI_HOLY)
	doSendMagicEffect(pos, CONST_ME_HOLYDAMAGE)
	addEvent(explode, FUSE, cid, pos, false)

	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.twin) then
		addEvent(explode, FUSE + glyph.twin.delay, cid, pos, true)
	end

	return true
end
