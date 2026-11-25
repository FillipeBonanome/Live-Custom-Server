-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.damage  multiplier of every hit (applied by SpellBalance)
--   glyph.multi   = {hits, interval}: the strike repeats on the same target (or tile) every `interval` ms
--   glyph.chain   = {bounces, damage, range, delay}: after the hit the lightning jumps to other creatures near the last one
local KEY = "attack/energy strike"

local function build(scale, distance)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_ENERGYAREA)
	if(distance) then
		setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGY)
	end

	setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, -1 * scale, -10 * scale, -1 * scale, -20 * scale, 5, 5, 1.4, 2.1)
	return combat
end

local spell = Glyphs.spellByKey(KEY)
local chainConfig = spell and spell.glyphs.B and spell.glyphs.B.chain or {}

local combat = build(1, true)
-- the ricochets use the same formula scaled to the share of the glyph; the jump is drawn by the script
local chainCombat = build(chainConfig.damage or 0.7, false)

-- repeated hit (glyph A): same target, or the tile that was aimed at when there was no target
local function strike(cid, target, pos, left, interval)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	local var
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
	local target = (glyph and (glyph.multi or glyph.chain)) and Glyphs.aimed(var) or 0
	local pos = target == 0 and glyph and glyph.multi and variantToPosition(var) or nil
	local fromPos = target > 0 and glyph.chain and getCreaturePosition(target) or nil

	local ret = doCombat(cid, combat, var)
	if(not ret or not glyph) then
		return ret
	end

	if(glyph.multi and glyph.multi.hits > 1 and (target > 0 or pos)) then
		addEvent(strike, glyph.multi.interval, cid, target, pos, glyph.multi.hits - 1, glyph.multi.interval)
	end

	if(fromPos and glyph.chain.bounces > 0) then
		addEvent(Glyphs.ricochet, glyph.chain.delay or 150, cid, fromPos, {[target] = true}, glyph.chain.bounces, glyph.chain, chainCombat)
	end

	return ret
end
