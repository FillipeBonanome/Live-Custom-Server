-- Sacred Wave (Hierophant): big holy wave (like Energy Wave). Every creature hit loses 10% of its holy resistance for 8
-- seconds (buff "Holy Vulnerability" + creaturescript "HolyResistDown", data/creaturescripts/scripts/holyresist.lua).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.resist   = {percent, duration}   replaces the normal -10% / 8s: monsters lose `percent` holy resistance (a real condition, Glyphs.reduceResistance)
--   glyph.paralyze = {percent, duration}   every enemy hit is slowed (percent 0.4 = 40% slower)
local KEY = "attack/sacred wave"

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HOLYAREA)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_HOLY)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 3.2, 5.2)
setCombatArea(combat, createCombatArea(AREA_SQUAREWAVE5, AREADIAGONAL_SQUAREWAVE5))

local DURATION = 8000

function onTargetCreature(cid, target)
	if(isPlayer(target) and Cleric.isAlly(cid, target)) then
		return true
	end

	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.resist) then
		Glyphs.reduceResistance(target, COMBAT_HOLYDAMAGE, glyph.resist.percent, glyph.resist.duration)
	else
		addCreatureBuff(target, {
			name = "Holy Vulnerability", category = "Holy Vulnerability", duration = DURATION,
			description = "-10% holy resistance."
		})
		registerCreatureEvent(target, "HolyResistDown")
	end

	if(glyph and glyph.paralyze and Glyphs.isEnemy(cid, target)) then
		Glyphs.paralyze(cid, target, glyph.paralyze.percent, glyph.paralyze.duration)
	end

	return true
end
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")

function onCastSpell(cid, var)
	if(doCombat(cid, combat, var)) then
		Cleric.faith(cid)
		return true
	end

	return false
end
