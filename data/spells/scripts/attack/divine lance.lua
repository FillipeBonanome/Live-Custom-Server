-- Divine Lance: holy beam (5 tiles) that damages enemies and heals the players in the line.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.long  = true        the beam reaches 7 sqm instead of 5
--   glyph.haste = {duration}  every player the beam heals gets the speed of Haste for `duration` ms
--   glyph.damage / glyph.healing  multipliers (applied by SpellBalance)
local KEY = "attack/divine lance"

-- called for every creature the healing beam really healed
local function onHealed(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.haste and isPlayer(target)) then
		Glyphs.haste(target, glyph.haste.duration)
	end

	return true
end

-- same callback of the healing combat for both lengths: heal = level / 5 + magic * (1.0 to 1.5), plus Faith
function onGetFormulaValues(cid, level, maglevel)
	local multiplier = Cleric.faithMultiplier(cid)
	return math.floor((level / 5 + maglevel * 1.0) * multiplier), math.floor((level / 5 + maglevel * 1.5) * multiplier)
end

local function build(area, diagonal)
	local damage = createCombatObject()
	setCombatParam(damage, COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
	setCombatParam(damage, COMBAT_PARAM_EFFECT, CONST_ME_HOLYAREA)
	setAttackFormula(damage, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 2.4, 3.6)
	setCombatArea(damage, createCombatArea(area, diagonal))

	-- Same beam, but healing: heals the players (and summons) in the line, like Mass Healing.
	local heal = createCombatObject()
	setCombatParam(heal, COMBAT_PARAM_TYPE, COMBAT_HEALING)
	setCombatParam(heal, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
	setCombatParam(heal, COMBAT_PARAM_AGGRESSIVE, false)
	setCombatParam(heal, COMBAT_PARAM_TARGETPLAYERSORSUMMONS, true)
	setCombatCallback(heal, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")
	setCombatArea(heal, createCombatArea(area, diagonal))
	Glyphs.setCallback(heal, CALLBACK_PARAM_TARGETCREATURE, onHealed)
	return damage, heal
end

local damage, heal = build(AREA_BEAM5, AREADIAGONAL_BEAM5)
local damageLong, healLong = build(AREA_BEAM7, AREADIAGONAL_BEAM7)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local long = glyph and glyph.long
	doCombat(cid, long and healLong or heal, var)
	if(doCombat(cid, long and damageLong or damage, var)) then
		Cleric.faith(cid)
		return true
	end

	return false
end
