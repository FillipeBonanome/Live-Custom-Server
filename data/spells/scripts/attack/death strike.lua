-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.resist = {percent, duration}         lowers the death resistance of the monster (before the hit)
--   glyph.curse  = {percent, ticks, interval}  curses the target: darkness damage over time, a percent of the damage of the hit
local KEY = "attack/death strike"

-- with the curse glyph the damage is rolled by Glyphs (so the curse knows how much the hit did); otherwise it is the usual formula
Glyphs.defineRoll("glyphDeathStrikeValues", KEY, "curse")

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MORTAREA)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_SUDDENDEATH)
setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "glyphDeathStrikeValues")

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local target = (glyph and (glyph.resist or glyph.curse)) and Glyphs.aimed(var) or 0

	if(target > 0 and glyph.resist and Glyphs.reduceResistance(target, COMBAT_DEATHDAMAGE, glyph.resist.percent, glyph.resist.duration)) then
		doSendMagicEffect(getCreaturePosition(target), CONST_ME_SMALLCLOUDS)
	end

	Glyphs.clearRoll(cid)
	local ret = doCombat(cid, combat, var)

	local dealt = Glyphs.takeRoll(cid, KEY)
	if(ret and target > 0 and glyph.curse and dealt and isCreature(target) and getCreatureHealth(target) > 0) then
		local total = math.max(1, math.floor(dealt * glyph.curse.percent / 100))
		Glyphs.curse(cid, target, total, glyph.curse.ticks, glyph.curse.interval)
	end

	return ret
end
