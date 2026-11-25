-- Holy Nova (signature spell): holy burst around the caster, damages enemies and heals party members in the area.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.wide    = true               radius 3 instead of 2 (damage area and healing radius)
--   glyph.echo    = {delay, share}     a second pulse `delay` ms later with `share` of the damage and of the healing
--   glyph.healing                      multiplier of the healing (applied here: the healing does not go through SpellBalance)
local KEY = "attack/holy nova"

local function build(area)
	local damage = createCombatObject()
	setCombatParam(damage, COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
	setCombatParam(damage, COMBAT_PARAM_EFFECT, CONST_ME_HOLYAREA)
	setAttackFormula(damage, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 2.6, 3.8)
	setCombatArea(damage, createCombatArea(area))
	return damage
end

local damage = build(AREA_CIRCLE2X2)
local damageWide = build(AREA_CIRCLE3X3)
local echoAreas = {[2] = createCombatArea(AREA_CIRCLE2X2), [3] = createCombatArea(AREA_CIRCLE3X3)}

-- the second pulse (glyph): damage and healing scaled by `share`, around the caster where it is now
local function echo(cid, radius, share)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	local pos = getCreaturePosition(cid)
	local min, max = Cleric.values(cid, 5, 5, 2.6, 3.8)
	doAreaCombatHealth(cid, COMBAT_HOLYDAMAGE, pos, echoAreas[radius], SpellBalance.scale(cid, KEY, -min * share),
		SpellBalance.scale(cid, KEY, -max * share), CONST_ME_HOLYAREA)

	local hmin, hmax = Cleric.values(cid, 5, 5, 1.2, 1.8)
	local multiplier = Glyphs.multiplier(cid, KEY, "healing") * share
	Cleric.heal(cid, Cleric.allies(cid, pos, radius), math.floor(hmin * multiplier), math.floor(hmax * multiplier))
end

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local radius = (glyph and glyph.wide) and 3 or 2
	local ok = doCombat(cid, radius == 3 and damageWide or damage, var)
	if(ok) then
		Cleric.faith(cid)
		local min, max = Cleric.values(cid, 5, 5, 1.2, 1.8)
		local multiplier = Glyphs.multiplier(cid, KEY, "healing")
		Cleric.heal(cid, Cleric.allies(cid, getCreaturePosition(cid), radius), math.floor(min * multiplier), math.floor(max * multiplier))

		if(glyph and glyph.echo) then
			addEvent(echo, glyph.echo.delay, cid, radius, glyph.echo.share)
		end
	end

	return ok
end
