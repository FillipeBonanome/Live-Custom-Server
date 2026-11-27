-- Berserker helpers shared by the Berserker / Warlord spells (data/spells/scripts/berserker/*).
--
-- Passives (applied once a second by the globalevent "berserker", see Berserker.refresh):
--   * life leech: Berserker.leech (8%, Warlord 10%)
--   * Rage: +0.4% physical damage for every 1% of missing health, at most Berserker.maxAmp (30%)
-- Fury: every spell gives 1 stack (max 10, 12s, renewed): +2 axe skill per stack.
--
-- (the spells cost health, not mana: healthpercent in spells.xml, handled by the source)
-- Berserker.target(cid, maxDistance)        current target if it is valid and close enough (cancels the spell otherwise)
-- Berserker.power(cid)                      axe skill (with Fury) + attack of the axe(s) in the hands; x1.15 with a two-handed weapon
-- Berserker.values(cid, fmin, fmax)         min/max damage = level/5 + power * factor
-- Berserker.hit(cid, target, fmin, fmax, type, effect [, multiplier])   one damaging hit
-- Berserker.area(cid, pos, area, fmin, fmax, effect [, multiplier])      area hit
-- Berserker.fury(cid [, stacks]) / Berserker.furyStacks(cid)
-- Berserker.addBuff(cid, key)               gives one of the Berserker buffs (Berserker.buffs)
-- Berserker.bleed(cid, target, ticks, perTick)  bleeding (Lua timer, physical damage once a second)
-- Berserker.refresh(cid)                    applies the passive condition (leech + Rage) to one player
-- Berserker.rage(cid)                       current Rage bonus (percent)
-- Berserker.glyph(cid, name)                active glyph of a spell; enemiesAround, slowAll, guard and vengeance: helpers of the glyphs (below)

Berserker = {
	maxFury = 10,
	furySkill = 2,
	leech = 8,
	warlordLeech = 10,
	maxAmp = 30,
	ampPerMissing = 0.4, -- percent of physical damage for each 1% of missing health
	twoHandBonus = 1.15,
	conditionSubId = 8450
}

-- Buffs ----------------------------------------------------------------------------------------------------------------------
Berserker.buffs = {
	fury = {
		name = "Fury", subId = 8440, duration = 12000, description = "+2 axe skill per stack.",
		params = {[CONDITION_PARAM_SKILL_AXE] = 2}, stackable = true, maxStacks = 10, silent = true
	},
	blood_pact = {
		name = "Blood Pact", subId = 8441, duration = 12000, description = "+8% life leech (doubles the passive leech).",
		params = {[CONDITION_PARAM_LIFELEECH] = 8}
	},
	warcry = {
		name = "Warcry", subId = 8442, duration = 8000, description = "+5 armor and +3 defense.",
		params = {[CONDITION_PARAM_ARMOR] = 5, [CONDITION_PARAM_DEFENSE] = 3}
	},
	blood_frenzy = {
		name = "Blood Frenzy", subId = 8443, duration = 10000, description = "+10% life leech, +25 fist skill (attack speed) and +1 Fury every second.",
		params = {[CONDITION_PARAM_LIFELEECH] = 10, [CONDITION_PARAM_SKILL_FIST] = 25}
	},
	undying_rage = {
		name = "Undying Rage", subId = 8444, duration = 6000, description = "Damage cannot kill you (you stay at 1 health) and +10% life leech.",
		params = {[CONDITION_PARAM_LIFELEECH] = 10}
	},
	-- glyph version of Blood Pact (same name and subId as blood_pact, so it replaces it instead of stacking)
	blood_pact_flesh = {
		name = "Blood Pact", subId = 8441, duration = 12000, description = "+14% life leech.",
		params = {[CONDITION_PARAM_LIFELEECH] = 14}
	}
}

function Berserker.addBuff(cid, key)
	local def = Berserker.buffs[key]
	if(not def or not isPlayer(cid)) then
		return false
	end

	return addCreatureBuff(cid, {
		name = def.name, category = def.name, duration = def.duration, description = def.description,
		stackable = def.stackable, maxStacks = def.maxStacks,
		onActivate = function(id, stacks)
			local condition = createConditionObject(CONDITION_ATTRIBUTES, def.duration, true, def.subId)
			for param, value in pairs(def.params) do
				setConditionParam(condition, param, value * stacks)
			end

			doAddCondition(id, condition)
			if(not def.silent) then
				doSendMagicEffect(getCreaturePosition(id), CONST_ME_MAGIC_RED)
				doPlayerSendTextMessage(id, MESSAGE_STATUS_CONSOLE_BLUE, def.name .. " activated for " .. Buffs.formatTime(def.duration / 1000) .. ".")
			end
		end,
		onRemove = function(id)
			if(isCreature(id)) then
				doRemoveCondition(id, CONDITION_ATTRIBUTES, def.subId)
			end
		end
	})
end

-- Fury (passive) -------------------------------------------------------------------------------------------------------------------

function Berserker.furyStacks(cid)
	return getCreatureBuffStacks(cid, "Fury")
end

-- No vocation check: only the Berserker spells give it, and a GM (or anyone allowed to cast them) must get it too.
function Berserker.fury(cid, stacks)
	if(not isPlayer(cid)) then
		return
	end

	for i = 1, (stacks or 1) do
		Berserker.addBuff(cid, "fury")
	end
end

-- Passive: leech and Rage ----------------------------------------------------------------------------------------------------------

function Berserker.rage(cid)
	local maxHealth = getCreatureMaxHealth(cid)
	if(maxHealth <= 0) then
		return 0
	end

	local missing = (1 - getCreatureHealth(cid) / maxHealth) * 100
	return math.max(0, math.min(Berserker.maxAmp, math.floor(missing * Berserker.ampPerMissing)))
end

-- One condition (sub id Berserker.conditionSubId) with the leech and the Rage bonus. It lasts a few seconds and the globalevent
-- renews it every second, so it disappears by itself if the player stops being a Berserker.
function Berserker.refresh(cid)
	local leech = (getPlayerVocation(cid) == 16) and Berserker.warlordLeech or Berserker.leech
	local condition = createConditionObject(CONDITION_ATTRIBUTES, 3000, false, Berserker.conditionSubId)
	setConditionParam(condition, CONDITION_PARAM_LIFELEECH, leech)
	setConditionParam(condition, CONDITION_PARAM_ELEMENTAL_AMP_PHYSICAL, Berserker.rage(cid))
	doAddCondition(cid, condition)
end

-- Target checks ---------------------------------------------------------------------------------------------------------------------

local function cancel(cid, text)
	doPlayerSendCancel(cid, text)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
	return false
end

-- Damage ---------------------------------------------------------------------------------------------------------------------------

local function axeInfo(cid, slot)
	local item = getPlayerSlotItem(cid, slot)
	if(not item or item.uid == 0 or item.itemid == 0) then
		return nil
	end

	local info = getItemInfo(item.itemid)
	if(not info or info.weaponType ~= WEAPON_AXE) then
		return nil
	end

	-- slotPosition has the two-handed flag in bit 11 (2048)
	local twoHanded = math.floor((info.slotPosition or 0) / 2048) % 2 == 1
	return (info.attack or 0) + (info.extraAttack or 0), twoHanded
end

function Berserker.power(cid)
	local attack, twoHanded = axeInfo(cid, CONST_SLOT_LEFT)
	if(not attack) then
		attack, twoHanded = axeInfo(cid, CONST_SLOT_RIGHT)
	end

	local skill = getPlayerSkillLevel(cid, SKILL_AXE) + Berserker.furySkill * Berserker.furyStacks(cid)
	return (skill + (attack or 0)) * (twoHanded and Berserker.twoHandBonus or 1)
end

function Berserker.values(cid, fmin, fmax)
	local power, base = Berserker.power(cid), getPlayerLevel(cid) / 5
	return math.floor(base + power * fmin), math.floor(base + power * fmax)
end

function Berserker.target(cid, maxDistance)
	local target = getCreatureTarget(cid)
	if(target == 0 or target == cid or not isCreature(target) or getCreatureHealth(target) <= 0) then
		cancel(cid, "You need a target.")
		return nil
	end

	local from, to = getCreaturePosition(cid), getCreaturePosition(target)
	if(from.z ~= to.z or getDistanceBetween(from, to) > maxDistance) then
		cancel(cid, "Your target is too far away.")
		return nil
	end

	return target
end

function Berserker.hit(cid, target, fmin, fmax, combatType, effect, multiplier)
	if(not isCreature(cid) or not isCreature(target) or getCreatureHealth(target) <= 0) then
		return false
	end

	local min, max = Berserker.values(cid, fmin, fmax)
	multiplier = multiplier or 1
	doTargetCombatHealth(cid, target, combatType or COMBAT_PHYSICALDAMAGE, -math.floor(min * multiplier), -math.floor(max * multiplier), effect or CONST_ME_NONE)
	return true
end

function Berserker.area(cid, pos, area, fmin, fmax, effect, multiplier)
	if(not isCreature(cid)) then
		return false
	end

	local min, max = Berserker.values(cid, fmin, fmax)
	multiplier = multiplier or 1
	doAreaCombatHealth(cid, COMBAT_PHYSICALDAMAGE, pos, area, -math.floor(min * multiplier), -math.floor(max * multiplier), effect or CONST_ME_NONE)
	return true
end

-- Glyphs (data/lib/403-glyphs.lua, keys "berserker/<script name>") -----------------------------------------------------------------
-- The Berserker spells do not go through the SpellBalance: every script reads the fields of its glyph by itself.
-- SubIds of the glyph buffs: 8451 Stonehide, 8452 Iron Cry, 8453 Unbroken Frenzy, 8454 Pact of Vengeance, 8455 Vengeful Rage.

-- the active glyph of the player for a Berserker spell ("cleave", "savage leap"...), nil if none
function Berserker.glyph(cid, name)
	return (Glyphs.get(cid, "berserker/" .. name))
end

-- enemies of the caster within `radius` sqm of `pos` (no npcs, party members, own summons or protection zones)
function Berserker.enemiesAround(cid, pos, radius, except)
	local list = {}
	for _, tid in ipairs(getSpectators(pos, radius, radius, false) or {}) do
		if(tid ~= except and Glyphs.isEnemy(cid, tid)) then
			table.insert(list, tid)
		end
	end

	return list
end

-- slows (percent 0.4 = 40%, 0.95 = stunned) every enemy of the list for `ms`
function Berserker.slowAll(cid, list, percent, ms)
	for _, tid in ipairs(list) do
		if(Glyphs.paralyze(cid, tid, percent, ms)) then
			doSendMagicEffect(getCreaturePosition(tid), CONST_ME_STUN)
		end
	end
end

-- `percent`% less damage from every element for `ms` (buff `name` in !buffs)
function Berserker.guard(cid, name, subId, percent, ms)
	return Glyphs.statBuff(cid, {
		name = name, duration = ms, subId = subId, effect = CONST_ME_MAGIC_RED,
		description = percent .. "% less damage from every element.",
		params = Glyphs.absorbAll(percent)
	})
end

-- +`amp`% physical damage and +`critical`% critical chance for `ms` (buff `name` in !buffs)
function Berserker.vengeance(cid, name, subId, amp, critical, ms)
	return Glyphs.statBuff(cid, {
		name = name, duration = ms, subId = subId, effect = CONST_ME_MAGIC_RED,
		description = "+" .. amp .. "% physical damage and +" .. critical .. "% critical chance.",
		params = {[CONDITION_PARAM_ELEMENTAL_AMP_PHYSICAL] = amp, [CONDITION_PARAM_CRITICALCHANCE] = critical}
	})
end

function Berserker.bleed(cid, target, ticks, perTick)
	doTargetBleed(cid, target, perTick, ticks, 1000)
end

-- VFX profiles ---------------------------------------------------------------------------------------------------------------------
-- Palette: red (blood/fury), stone (earth), fire and spinning axes. The area spells use CONST_ME_NONE in the damage and draw
-- these profiles instead, so each one looks different (and different from the Assassin: knives, smoke, purple/black).
-- Registered with VFX.register (data/lib/360-vfx.lua); played with Berserker.fx so a bad option never breaks a spell.

function Berserker.fx(name, target, options)
	local ok = pcall(VFX.play, name, target, options)
	return ok
end

-- swing at the sides: a quick half-turn of axes and blood on the tiles beside the berserker
VFX.register("berserker_cleave", function(target, o)
	VFX.Circle(target, CONST_ANI_WHIRLWINDAXE, {radius = 1, points = 6, spin = true, duration = 250})
	return VFX.Ring(target, CONST_ME_DRAWBLOOD, {radius = 1, times = 1})
end)

-- spin: a funnel of axes rising around the berserker and a red ring
VFX.register("berserker_whirlwind", function(target, o)
	local radius = o.wide and 2 or 1
	VFX.Tornado(target, CONST_ANI_WHIRLWINDAXE, {radius = radius, height = 2, turns = 2, points = 16, duration = 600, strands = 2})
	return VFX.Ring(target, CONST_ME_BLOCKHIT, {radius = radius, times = 2, interval = 250})
end)

-- shock wave: rocks bursting along the wave, direction = where the berserker looks
VFX.register("berserker_slam", function(target, o)
	VFX.Line(target, CONST_ME_STONES, {direction = o.direction, length = o.long and 5 or 4, interval = 70})
	return VFX.Line(target, CONST_ME_GROUNDSHAKER, {direction = o.direction, length = o.long and 5 or 4, interval = 70, delay = 60})
end)

-- landing: rocks thrown up and falling, and a small shock wave
VFX.register("berserker_leap", function(target, o)
	VFX.Fountain(target, CONST_ANI_SMALLSTONE, {radius = 1, height = 3, count = 6})
	return VFX.Wave(target, CONST_ME_GROUNDSHAKER, {radius = 1, interval = 120})
end)

-- earthquake: boulders falling over the whole area and rings of shock waves
VFX.register("berserker_earthshatter", function(target, o)
	VFX.Rain(target, CONST_ANI_LARGEROCK, {radius = 3, duration = 700, drops = 14, effect = CONST_ME_STONES})
	return VFX.Wave(target, CONST_ME_GROUNDSHAKER, {radius = 3, interval = 130})
end)

-- titan's blows: fire coming in and exploding; the last one is a meteor
VFX.register("berserker_titan", function(target, o)
	if(o.last) then
		VFX.Meteor(target, {element = "fire"})
		return VFX.Wave(target, CONST_ME_GROUNDSHAKER, {radius = o.wide and 2 or 1, interval = 120, delay = 250})
	end

	VFX.Implosion(target, CONST_ANI_FIRE, {radius = 2, points = 8, flightTime = 250, effect = CONST_ME_FIREAREA})
	return VFX.Ring(target, CONST_ME_EXPLOSIONHIT, {radius = 1, times = 1, delay = 250})
end)
