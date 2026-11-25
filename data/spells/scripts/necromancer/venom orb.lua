-- Venom Orb: ball of poison on the target, 7x7 circle (P x 0.8 to 1.4) that poisons everything it hits. The area itself draws no
-- effect: the animation is made with the VFX library (data/lib/360-vfx.lua): only an Explosion, rings of poison shots leaving the target.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.cloud  = {ticks, interval, percent}   the spot stays poisoned: `ticks` pulses, `percent`% of the damage of the spell in total
--   glyph.resist = {percent, duration}          monsters hit lose poison resistance
local KEY = "necromancer/venom orb"

local area = createCombatArea(AREA_CIRCLE3X3)

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_NONE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_POISON)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, Necro.formula(0.8, 1.4))
setCombatArea(combat, area)

-- poison over time (10s) on everything that is hit: damage per tick = level/15 + magic level/3
Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, function(cid, target)
	doTargetCombatCondition(cid, target, Necro.poisonCondition(cid), CONST_ME_NONE)

	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.resist) then
		Glyphs.reduceResistance(target, COMBAT_EARTHDAMAGE, glyph.resist.percent, glyph.resist.duration)
	end

	return true
end)

local function animate(pos)
	VFX.Explosion(pos, CONST_ANI_POISON, {radius = 3, points = 12, rings = 2, ringInterval = 120, effect = CONST_ME_POISONAREA, skipVoid = true})
end

-- Toxic Cloud: one pulse of the cloud (the damage is read again at each pulse; SpellBalance applied)
local function cloudPulse(cid, pos, left, interval, share)
	if(left <= 0 or not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	local min, max = Necro.values(cid, 0.8, 1.4)
	doAreaCombatHealth(cid, COMBAT_EARTHDAMAGE, pos, area, SpellBalance.scale(cid, KEY, -min * share),
		SpellBalance.scale(cid, KEY, -max * share), CONST_ME_POISONAREA)
	addEvent(cloudPulse, interval, cid, pos, left - 1, interval, share)
end

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local target = getCreatureTarget(cid)
	local pos = (target ~= 0 and isCreature(target)) and getCreaturePosition(target) or nil
	if(not doCombat(cid, combat, var)) then
		return false
	end

	if(pos) then
		animate(pos)
		if(glyph and glyph.cloud) then
			local cloud = glyph.cloud
			addEvent(cloudPulse, cloud.interval, cid, pos, cloud.ticks, cloud.interval, cloud.percent / 100 / cloud.ticks)
		end
	end

	return true
end
