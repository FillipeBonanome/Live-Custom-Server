-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.small = true                 smaller area (AREA_CIRCLE2X2 instead of AREA_CIRCLE3X3)
--   glyph.damage                       multiplier of the damage (applied by SpellBalance)
--   glyph.burnBonus = {percent}        creatures that are burning take an extra hit of that % of the damage of the spell
local KEY = "attack/great fireball"

-- setAttackFormula(5, 5, 1.4, 2.8, 40, 70): damage between max(40, level / 5 + magic * 1.4) and max(70, level / 5 + magic * 2.8)
local function formula(cid)
	local level, magic = getPlayerLevel(cid), getPlayerMagLevel(cid)
	return math.max(40, level / 5 + magic * 1.4), math.max(70, level / 5 + magic * 2.8)
end

-- The server forgets a global function once it is registered as a callback, so every combat needs its own copy of it
local callbackCount = 0
local function setCallback(combat, key, handler)
	callbackCount = callbackCount + 1
	local name = "__glyphGreatFireball" .. callbackCount
	_G[name] = handler
	setCombatCallback(combat, key, name)
end

-- called for every creature the fireball really hit (after the damage)
local function onTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph or not glyph.burnBonus or not isCreature(target) or getCreatureHealth(target) <= 0
		or not getCreatureCondition(target, CONDITION_FIRE)) then
		return true
	end

	-- the damage of the target is rolled by the server, so the extra hit is a % of the damage range of the spell
	local min, max = formula(cid)
	local share = glyph.burnBonus.percent / 100
	doTargetCombatHealth(cid, target, COMBAT_FIREDAMAGE, SpellBalance.scale(cid, KEY, -min * share),
		SpellBalance.scale(cid, KEY, -max * share), CONST_ME_HITBYFIRE)
	return true
end

local function build(area)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HITBYFIRE)
	setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FIRE)
	setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 1.4, 2.8, 40, 70)
	setCombatArea(combat, createCombatArea(area))
	setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)
	return combat
end

local combat = build(AREA_CIRCLE3X3)
local combatSmall = build(AREA_CIRCLE2X2)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	return doCombat(cid, (glyph and glyph.small) and combatSmall or combat, var)
end
