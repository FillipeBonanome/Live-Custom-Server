-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.damage  multiplier of every hit (applied by SpellBalance)
--   glyph.multi   = {hits, interval}: the missile repeats on the same target (or tile) every `interval` ms
--   glyph.resist  = {percent, duration}: lowers the holy resistance of the monster (before the hit)
local KEY = "attack/divine missile"

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HOLYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_SMALLHOLY)
setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, -1, -10, -1, -20, 5, 5, 1.4, 2.1)

-- repeated missile: same target, or the tile that was aimed at when there was no target
local function strike(cid, target, pos, left, interval)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	if(target > 0) then
		if(not isCreature(target) or getCreatureHealth(target) <= 0) then
			return
		end

		local from, to = getCreaturePosition(cid), getCreaturePosition(target)
		if(from.z ~= to.z or getDistanceBetween(from, to) > 6) then
			return
		end

		if(isSightClear(from, to, true)) then
			doCombat(cid, combat, numberToVariant(target))
		end
	else
		doCombat(cid, combat, positionToVariant(pos))
	end

	if(left > 1) then
		addEvent(strike, interval, cid, target, pos, left - 1, interval)
	end
end

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph) then
		return doCombat(cid, combat, var)
	end

	local target = (glyph.multi or glyph.resist) and Glyphs.aimed(var) or 0
	local pos = target == 0 and glyph.multi and variantToPosition(var) or nil

	if(target > 0 and glyph.resist and Glyphs.reduceResistance(target, COMBAT_HOLYDAMAGE, glyph.resist.percent, glyph.resist.duration)) then
		doSendMagicEffect(getCreaturePosition(target), CONST_ME_HOLYAREA)
	end

	local ret = doCombat(cid, combat, var)
	if(ret and glyph.multi and glyph.multi.hits > 1 and (target > 0 or pos)) then
		addEvent(strike, glyph.multi.interval, cid, target, pos, glyph.multi.hits - 1, glyph.multi.interval)
	end

	return ret
end
