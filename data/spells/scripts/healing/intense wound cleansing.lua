-- Intense Wound Cleansing: big emergency heal (long cooldown) for Knight, Assassin and Berserker. Heals 35% to 45% of the max health.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.lastStand = {bonus}            the heal is up to `bonus`% bigger the lower the health of the caster is
--   glyph.shield    = {duration, percent}  after the heal the caster takes `percent`% less damage for `duration` ms (buff "Unyielding")
local KEY = "healing/intense wound cleansing"
local SHIELD_SUBID = 8823

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)

function onGetFormulaValues(cid, level, maglevel)
	local maxHealth = getCreatureMaxHealth(cid)
	local min, max = math.floor(maxHealth * 0.35), math.floor(maxHealth * 0.45)

	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.lastStand) then
		local missing = 1 - math.min(1, getCreatureHealth(cid) / maxHealth)
		local factor = 1 + glyph.lastStand.bonus / 100 * missing
		return math.floor(min * factor), math.floor(max * factor)
	end

	return min, max
end
setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function onCastSpell(cid, var)
	if(doCombat(cid, combat, var)) then
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_HOLYAREA)

		local glyph = Glyphs.get(cid, KEY)
		if(glyph and glyph.shield) then
			Glyphs.statBuff(cid, {
				name = "Unyielding", duration = glyph.shield.duration, subId = SHIELD_SUBID, effect = CONST_ME_HOLYAREA,
				description = glyph.shield.percent .. "% less damage from every source.",
				params = Glyphs.absorbAll(glyph.shield.percent)
			})
		end

		return true
	end

	return false
end
