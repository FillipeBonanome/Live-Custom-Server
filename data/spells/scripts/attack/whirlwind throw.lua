-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.chain    = {bounces, damage, range, delay, animation}   after the hit the weapon ricochets to other creatures near the last one
--   glyph.paralyze = {percent, duration}                          the target is slowed (percent 0.4 = 40% slower)
--   glyph.resist   = {percent, duration}                          lowers the physical resistance of the monster (before the hit)
local KEY = "attack/whirlwind throw"

local function build(scale, distance)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_BLOCKARMOR, true)
	if(distance) then
		setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_WEAPONTYPE)
		setCombatParam(combat, COMBAT_PARAM_USECHARGES, true)
	end

	Glyphs.setCallback(combat, CALLBACK_PARAM_SKILLVALUE, function(cid, level, skill, attack, factor)
		local skillTotal, levelTotal = skill + attack, level / 5
		return -(skillTotal / 3 + levelTotal) * scale, -(skillTotal + levelTotal) * scale
	end)
	return combat
end

local spell = Glyphs.spellByKey(KEY)
local chainConfig = spell and spell.glyphs.A and spell.glyphs.A.chain or {}

local combat = build(1, true)
-- the ricochets use the same formula scaled to the share of the glyph; the jump is drawn by the script
local chainCombat = build(chainConfig.damage or 0.7, false)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph) then
		return doCombat(cid, combat, var)
	end

	local target = Glyphs.aimed(var)
	if(target > 0 and glyph.resist) then
		Glyphs.reduceResistance(target, COMBAT_PHYSICALDAMAGE, glyph.resist.percent, glyph.resist.duration)
	end

	local fromPos = (target > 0 and glyph.chain) and getCreaturePosition(target) or nil
	local ret = doCombat(cid, combat, var)
	if(not ret) then
		return ret
	end

	if(target > 0 and glyph.paralyze and isCreature(target) and getCreatureHealth(target) > 0) then
		Glyphs.paralyze(cid, target, glyph.paralyze.percent, glyph.paralyze.duration)
	end

	if(fromPos and glyph.chain.bounces > 0) then
		addEvent(Glyphs.ricochet, glyph.chain.delay or 150, cid, fromPos, {[target] = true}, glyph.chain.bounces, glyph.chain, chainCombat)
	end

	return ret
end
