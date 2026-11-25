-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.poison = {percent, ticks, interval}  poisons the target for a percent of the damage of the hit
--   glyph.resist = {percent, duration}         lowers the earth resistance of the monster (before the hit)
local KEY = "attack/terra strike"

-- with the poison glyph the damage is rolled by Glyphs (so the poison knows how much the hit did); otherwise it is the usual formula
Glyphs.defineRoll("glyphTerraStrikeValues", KEY, "poison")

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_CARNIPHILA)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_EARTH)
setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "glyphTerraStrikeValues")

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local target = (glyph and (glyph.poison or glyph.resist)) and Glyphs.aimed(var) or 0

	if(target > 0 and glyph.resist and Glyphs.reduceResistance(target, COMBAT_EARTHDAMAGE, glyph.resist.percent, glyph.resist.duration)) then
		doSendMagicEffect(getCreaturePosition(target), CONST_ME_HITBYPOISON)
	end

	Glyphs.clearRoll(cid)
	local ret = doCombat(cid, combat, var)

	local dealt = Glyphs.takeRoll(cid, KEY)
	if(ret and target > 0 and glyph.poison and dealt and isCreature(target) and getCreatureHealth(target) > 0) then
		local total = math.max(1, math.floor(dealt * glyph.poison.percent / 100))
		Glyphs.poison(cid, target, total, glyph.poison.ticks, glyph.poison.interval)
	end

	return ret
end
