-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.summon = {duration, max, tiers}   every enemy hit gets an infernal creature next to it for `duration` ms; the kind of
--                                           creature depends on the level of the caster (the blast still happens)
--   glyph.rain = {radius, drops, ...}       replaces the blast by a rain of meteors that fall around the caster (Glyphs.rain)
local KEY = "attack/hells core"

-- setAttackFormula(7, 9, 11, 13): damage between level / 7 + magic * 11 and level / 9 + magic * 13
local function values(cid)
	local level, magic = getPlayerLevel(cid), getPlayerMagLevel(cid)
	return level / 7 + magic * 11, level / 9 + magic * 13
end

local meteorArea = createCombatArea(AREA_CROSS1X1)
local hitsOfCast = {} -- caster -> positions of the enemies hit, filled by the target callback during doCombat

-- every creature the blast really hit (after the damage)
function glyphHellsCoreTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.summon and hitsOfCast[cid] and Glyphs.isEnemy(cid, target)) then
		table.insert(hitsOfCast[cid], getCreaturePosition(target))
	end

	return true
end

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_FIREAREA)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 7, 9, 11, 13)
setCombatArea(combat, createCombatArea(AREA_CROSS5X5))
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "glyphHellsCoreTarget")

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.rain) then
		Glyphs.rain(cid, KEY, values, glyph.rain, meteorArea)
		return true
	end

	if(not glyph or not glyph.summon) then
		return doCombat(cid, combat, var)
	end

	hitsOfCast[cid] = {}
	local ret = doCombat(cid, combat, var)
	local positions = hitsOfCast[cid]
	hitsOfCast[cid] = nil

	if(ret and positions and #positions > 0) then
		Glyphs.summonAt(cid, positions, glyph.summon)
	end

	return ret
end
