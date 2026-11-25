-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.damage  multiplier of every hit (applied by SpellBalance)
--   glyph.heal    = {percent, targets}    the caster recovers `percent`% of its maximum health for each enemy hit (up to `targets`)
--   glyph.multi   = {hits, interval}      the blow repeats around the caster every `interval` ms
local KEY = "attack/berserk"

local hitsOfCast = {} -- caster -> number of enemies hit, filled by the target callback during doCombat

-- called for every creature the blow really hit (after the damage)
local function onTarget(cid, target)
	if(hitsOfCast[cid] and Glyphs.isEnemy(cid, target)) then
		hitsOfCast[cid] = hitsOfCast[cid] + 1
	end

	return true
end

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)
setCombatParam(combat, COMBAT_PARAM_USECHARGES, true)
setCombatArea(combat, createCombatArea(AREA_SQUARE1X1))
Glyphs.setCallback(combat, CALLBACK_PARAM_SKILLVALUE, function(cid, level, skill, attack, factor)
	local skillTotal, levelTotal = skill + attack, level / 5
	return -(skillTotal * 0.9 + levelTotal), -(skillTotal * 2.5 + levelTotal)
end)
Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)

-- repeated blow (glyph B): around the caster, where it is now
local function strike(cid, left, interval)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	doCombat(cid, combat, positionToVariant(getCreaturePosition(cid)))
	if(left > 1) then
		addEvent(strike, interval, cid, left - 1, interval)
	end
end

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph) then
		return doCombat(cid, combat, var)
	end

	hitsOfCast[cid] = 0
	local ret = doCombat(cid, combat, var)
	local hits = hitsOfCast[cid] or 0
	hitsOfCast[cid] = nil
	if(not ret) then
		return ret
	end

	if(glyph.heal and hits > 0) then
		local count = math.min(hits, glyph.heal.targets)
		doCreatureAddHealth(cid, math.max(1, math.floor(getCreatureMaxHealth(cid) * glyph.heal.percent * count / 100)))
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
	end

	if(glyph.multi and glyph.multi.hits > 1) then
		addEvent(strike, glyph.multi.interval, cid, glyph.multi.hits - 1, glyph.multi.interval)
	end

	return ret
end
