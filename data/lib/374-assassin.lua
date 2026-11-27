-- Assassin helpers shared by the Assassin / Nightblade spells (data/spells/scripts/assassin/*).
--
-- Assassin.power(cid)                       sword skill + attack of the sword(s) in the hands (average of both when dual wielding)
-- Assassin.values(cid, fmin, fmax)          min/max damage = level/5 + power * factor (same shape as the Knight melee formulas)
-- Assassin.target(cid, maxDistance)         current target if it is a valid creature within maxDistance (cancels the spell otherwise)
-- Assassin.hit(cid, target, fmin, fmax, type, effect [, multiplier])   one damaging hit, returns false if the target is gone
-- Assassin.isDual(cid)                      true when both hands hold swords
-- Assassin.momentum(cid [, amount])         passive Momentum: +1 stack (max 5, 6s) per offensive spell, renewed on every cast
-- Assassin.isBehind(cid, target)            true when the player is behind the target (opposite to where it looks) or just used Shadow Step on it
-- Assassin.stacks(cid) / Assassin.consume(cid)   current Momentum stacks / removes them and returns how many there were
-- Assassin.addBuff(cid, key)                gives one of the Assassin buffs (Assassin.buffs) with addCreatureBuff
-- Assassin.poison(cid, ticks)               poison condition (level/20 + power/20 per tick)
-- Assassin.bleed(cid, target, ticks, perTick)   bleeding: physical damage once a second (Lua timer, no condition in this source)
-- Assassin.invisible(cid, ms)               invisibility
-- Assassin.fx(name, target [, options])     plays a VFX profile (assassin_*), never raises an error
-- Assassin.clones(cid [, count, duration, challenge])   Phantom Clones (Nightblade)
-- Assassin.glyph(cid, name)                 active glyph of the player for the assassin spell `name` (data/lib/403-glyphs.lua), nil without one
-- Assassin.enemiesAround(cid, pos, radius [, except])   enemies (Glyphs.isEnemy) within radius sqm of pos
-- Assassin.average(cid, fmin, fmax)         average damage of a formula (used by the glyphs that are a % of the damage)
-- Assassin.lethal[cid]                      Vanish glyph B: {expires, multiplier} for the first spell hit after the Vanish

Assassin = {
	maxMomentum = 5,
	cloneMonster = "Assassin Clone",
	cloneCount = 2,
	cloneDuration = 12000
}

-- Buffs ----------------------------------------------------------------------------------------------------------------------
-- Each one is a condition (CONDITION_ATTRIBUTES) with the same duration as the buff, with a unique sub id.
Assassin.buffs = {
	-- passive: stackable, value multiplied by the stacks. The fist skill is what speeds up the attacks (fistSkillToDoubleAttackSpeed).
	momentum = {
		name = "Momentum", subId = 8400, duration = 6000, description = "+2% critical chance and +2 fist skill (attack speed) per stack.",
		params = {[CONDITION_PARAM_CRITICALCHANCE] = 2, [CONDITION_PARAM_SKILL_FIST] = 2}, stackable = true, maxStacks = 5, silent = true
	},
	shadow_dodge = {
		name = "Shadow Dodge", subId = 8401, duration = 1500, description = "+25% dodge.",
		params = {[CONDITION_PARAM_DODGE] = 25}, silent = true
	},
	venom_blade = {
		name = "Venom Blade", subId = 8402, duration = 8000, description = "Basic attacks deal +12% of the damage as poison.",
		params = {[CONDITION_PARAM_ONHIT_EARTH] = 12}
	},
	bloodthirst = {
		name = "Bloodthirst", subId = 8403, duration = 12000, description = "+12% life leech and +5% critical chance.",
		params = {[CONDITION_PARAM_LIFELEECH] = 12, [CONDITION_PARAM_CRITICALCHANCE] = 5}
	},
	vanish = {
		name = "Vanish", subId = 8404, duration = 4000, description = "Guaranteed critical hits.",
		params = {[CONDITION_PARAM_CRITICALCHANCE] = 100}
	},
	night_veil = {
		name = "Night Veil", subId = 8405, duration = 12000, description = "+25% dodge, +6 armor and +4 defense.",
		params = {[CONDITION_PARAM_DODGE] = 25, [CONDITION_PARAM_ARMOR] = 6, [CONDITION_PARAM_DEFENSE] = 4}
	},

	-- glyph versions (same name and subId as the original, so they replace it instead of stacking)
	shadow_dodge_long = {
		name = "Shadow Dodge", subId = 8401, duration = 3000, description = "+40% dodge.",
		params = {[CONDITION_PARAM_DODGE] = 40}, silent = true
	},
	bloodthirst_crimson = {
		name = "Bloodthirst", subId = 8403, duration = 12000, description = "+20% life leech and +5% critical chance.",
		params = {[CONDITION_PARAM_LIFELEECH] = 20, [CONDITION_PARAM_CRITICALCHANCE] = 5}
	},
	bloodthirst_predator = {
		name = "Bloodthirst", subId = 8403, duration = 15000, description = "+12% life leech, +15% critical chance and +10% physical damage.",
		params = {[CONDITION_PARAM_LIFELEECH] = 12, [CONDITION_PARAM_CRITICALCHANCE] = 15, [CONDITION_PARAM_ELEMENTAL_AMP_PHYSICAL] = 10}
	},
	night_veil_swift = {
		name = "Night Veil", subId = 8405, duration = 15000, description = "+25% dodge, +6 armor and +4 defense.",
		params = {[CONDITION_PARAM_DODGE] = 25, [CONDITION_PARAM_ARMOR] = 6, [CONDITION_PARAM_DEFENSE] = 4}
	},
	-- Backstab glyph A
	assassins_prey = {
		name = "Assassin's Prey", subId = 8406, duration = 6000, description = "+15% critical chance.",
		params = {[CONDITION_PARAM_CRITICALCHANCE] = 15}
	}
}

function Assassin.glyph(cid, name)
	return Glyphs.get(cid, "assassin/" .. name)
end

-- Vanish glyph B (Lethal Shadow): the first spell hit after the Vanish deals more damage
Assassin.lethal = {}

function Assassin.addBuff(cid, key)
	local def = Assassin.buffs[key]
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

-- Damage ---------------------------------------------------------------------------------------------------------------------

local function swordAttack(cid, slot)
	local item = getPlayerSlotItem(cid, slot)
	if(not item or item.uid == 0 or item.itemid == 0) then
		return nil
	end

	local info = getItemInfo(item.itemid)
	if(not info or info.weaponType ~= WEAPON_SWORD) then
		return nil
	end

	return (info.attack or 0) + (info.extraAttack or 0)
end

function Assassin.isDual(cid)
	return swordAttack(cid, CONST_SLOT_LEFT) ~= nil and swordAttack(cid, CONST_SLOT_RIGHT) ~= nil
end

function Assassin.power(cid)
	local left, right = swordAttack(cid, CONST_SLOT_LEFT), swordAttack(cid, CONST_SLOT_RIGHT)
	local attack = 0
	if(left and right) then
		attack = (left + right) / 2
	else
		attack = left or right or 0
	end

	return getPlayerSkillLevel(cid, SKILL_SWORD) + attack
end

function Assassin.values(cid, fmin, fmax)
	local power, base = Assassin.power(cid), getPlayerLevel(cid) / 5
	return math.floor(base + power * fmin), math.floor(base + power * fmax)
end

local function cancel(cid, text)
	doPlayerSendCancel(cid, text)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
	return nil
end

function Assassin.target(cid, maxDistance)
	local target = getCreatureTarget(cid)
	if(target == 0 or target == cid or not isCreature(target) or getCreatureHealth(target) <= 0) then
		return cancel(cid, "You need a target.")
	end

	local from, to = getCreaturePosition(cid), getCreaturePosition(target)
	if(from.z ~= to.z or getDistanceBetween(from, to) > maxDistance) then
		return cancel(cid, "Your target is too far away.")
	end

	return target
end

function Assassin.average(cid, fmin, fmax)
	local min, max = Assassin.values(cid, fmin, fmax)
	return (min + max) / 2
end

function Assassin.enemiesAround(cid, pos, radius, except)
	local list = {}
	for _, tid in ipairs(getSpectators(pos, radius, radius, false) or {}) do
		if(tid ~= except and Glyphs.isEnemy(cid, tid)) then
			table.insert(list, tid)
		end
	end

	return list
end

function Assassin.hit(cid, target, fmin, fmax, combatType, effect, multiplier)
	if(not isCreature(cid) or not isCreature(target) or getCreatureHealth(target) <= 0) then
		return false
	end

	local min, max = Assassin.values(cid, fmin, fmax)
	multiplier = multiplier or 1
	local lethal = Assassin.lethal[cid]
	if(lethal) then
		Assassin.lethal[cid] = nil
		if(os.time() <= lethal.expires) then
			multiplier = multiplier * lethal.multiplier
		end
	end

	min, max = math.floor(min * multiplier), math.floor(max * multiplier)
	doTargetCombatHealth(cid, target, combatType or COMBAT_PHYSICALDAMAGE, -min, -max, effect or CONST_ME_NONE)
	return true
end

-- Backstab: behind = the player is on the opposite side of the direction the target looks to. Shadow Step registers the target in
-- Assassin.stepped, so for 3 seconds after it the player counts as behind it even if the target already turned.
Assassin.stepped = {}
Assassin.stepWindow = 3

local lookVectors = {
	[NORTH] = {0, -1}, [EAST] = {1, 0}, [SOUTH] = {0, 1}, [WEST] = {-1, 0},
	[SOUTHWEST] = {-1, 1}, [SOUTHEAST] = {1, 1}, [NORTHWEST] = {-1, -1}, [NORTHEAST] = {1, -1}
}

-- sideOk (Backstab glyph B): the sides count too, only the front of the target is refused
function Assassin.isBehind(cid, target, sideOk)
	local stepped = Assassin.stepped[cid]
	if(stepped and stepped.target == target and os.time() - stepped.time <= Assassin.stepWindow) then
		return true
	end

	local look = lookVectors[getCreatureLookDirection(target)]
	if(not look) then
		return false
	end

	local from, to = getCreaturePosition(cid), getCreaturePosition(target)
	local dot = (from.x - to.x) * look[1] + (from.y - to.y) * look[2]
	return dot < 0 or (sideOk and dot == 0)
end

-- Momentum (passive) -------------------------------------------------------------------------------------------------------------

function Assassin.stacks(cid)
	return getCreatureBuffStacks(cid, "Momentum")
end

-- No vocation check: only the Assassin spells give it, and a GM (or anyone allowed to cast them) must get it too.
function Assassin.momentum(cid, amount)
	if(not isPlayer(cid)) then
		return
	end

	for i = 1, (amount or 1) do
		Assassin.addBuff(cid, "momentum")
	end

	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_BLOCKHIT)
end

function Assassin.consume(cid)
	local stacks = Assassin.stacks(cid)
	if(stacks > 0) then
		removeCreatureBuff(cid, "Momentum")
	end

	return stacks
end

-- Damage over time -----------------------------------------------------------------------------------------------------------------

function Assassin.poison(cid, ticks, multiplier)
	local tick = math.max(1, math.floor((getPlayerLevel(cid) / 20 + Assassin.power(cid) / 20) * (multiplier or 1)))
	local condition = createConditionObject(CONDITION_POISON)
	setConditionParam(condition, CONDITION_PARAM_DELAYED, 1)
	addDamageCondition(condition, ticks or 8, 1000, -tick)
	return condition
end

function Assassin.bleed(cid, target, ticks, perTick)
	local function tick(left)
		if(not isCreature(cid) or not isCreature(target) or getCreatureHealth(target) <= 0) then
			return
		end

		doTargetCombatHealth(cid, target, COMBAT_PHYSICALDAMAGE, -perTick, -perTick, CONST_ME_DRAWBLOOD)
		if(left > 1) then
			addEvent(tick, 1000, left - 1)
		end
	end

	tick(ticks)
end

function Assassin.invisible(cid, ms)
	doAddCondition(cid, createConditionObject(CONDITION_INVISIBLE, ms))
end

-- Phantom Clones -------------------------------------------------------------------------------------------------------------------

function Assassin.expire(clone)
	if(isCreature(clone)) then
		doSendMagicEffect(getCreaturePosition(clone), CONST_ME_SMOKE)
		doRemoveCreature(clone)
	end
end

-- Raises Assassin.cloneCount clones next to the player (own outfit, no summon slot) for Assassin.cloneDuration ms.
-- The glyphs change the count and the duration; challenge = radius: the clones challenge the monsters within that many sqm.
function Assassin.clones(cid, count, duration, challenge)
	local from = getCreaturePosition(cid)
	local raised = {}
	for i = 1, (count or Assassin.cloneCount) do
		local pos = getClosestFreeTile(cid, from, false, true)
		local clone = pos and doCreateMonster(Assassin.cloneMonster, pos, true, true)
		if(clone) then
			table.insert(raised, clone)
		end
	end

	if(#raised == 0) then
		cancel(cid, "There is no room for the clones.")
		return false
	end

	local level = getPlayerLevel(cid)
	local speed = getCreatureSpeed(cid)
	for _, clone in ipairs(raised) do
		doConvinceCreature(cid, clone)
		local hp = 150 + level * 3
		setCreatureMaxHealth(clone, hp)
		doCreatureAddHealth(clone, hp)
		doCreatureChangeOutfit(clone, getCreatureOutfit(cid))

		local delta = speed - getCreatureSpeed(clone)
		if(delta ~= 0) then
			doChangeSpeed(clone, delta)
		end

		Assassin.fx("assassin_clone", clone)
		addEvent(Assassin.expire, duration or Assassin.cloneDuration, clone)
	end

	if(challenge) then
		for index, tid in ipairs(Assassin.enemiesAround(cid, from, challenge)) do
			doChallengeCreature(raised[(index - 1) % #raised + 1], tid)
		end
	end

	return true
end

-- damage of a clone: same formula as the owner, credited to the clone (its damage is credited to the owner by the source)
function Assassin.cloneHit(clone, target, fmin, fmax, effect)
	local owner = getCreatureMaster(clone)
	if(not owner or owner == 0 or not isPlayer(owner) or not isCreature(target)) then
		return false
	end

	local min, max = Assassin.values(owner, fmin, fmax)
	doTargetCombatHealth(clone, target, COMBAT_PHYSICALDAMAGE, -min, -max, effect or CONST_ME_NONE)
	return true
end

-- VFX profiles ---------------------------------------------------------------------------------------------------------------------
-- Palette: black/purple (shadow), red (blood), green (poison). Short and small effects: the Assassin acts fast.
-- Registered with VFX.register (data/lib/360-vfx.lua); played with Assassin.fx so a bad option never breaks a spell.

function Assassin.fx(name, target, options)
	local ok = pcall(VFX.play, name, target, options)
	return ok
end

-- quick cut: blood hit and a short line of block hits in the direction of the blow
VFX.register("assassin_slash", function(target, o)
	local pos = VFX.resolvePosition(target)
	if(not pos) then
		return false
	end

	doSendMagicEffect(pos, CONST_ME_HITAREA)
	return VFX.Line(target, CONST_ME_BLOCKHIT, {to = o.to, direction = o.direction, length = 2, interval = 60})
end)

-- shadow step: o.from = where the assassin was, target = destination
VFX.register("assassin_step", function(target, o)
	return VFX.Teleport(o.from, target, {ani = CONST_ANI_DEATH, height = 2, travel = 200, outEffect = CONST_ME_SMOKE, inEffect = CONST_ME_SMOKE})
end)

-- twin fang: two knives crossing the target (o.from = attacker)
VFX.register("assassin_twin", function(target, o)
	local to = VFX.resolvePosition(target)
	if(not to or not o.from) then
		return false
	end

	VFX.Beam(o.from, to, CONST_ANI_THROWINGKNIFE, {mode = "bolt", effect = CONST_ME_DRAWBLOOD})
	return VFX.Beam(o.from, to, CONST_ANI_THROWINGKNIFE, {mode = "bolt", effect = CONST_ME_DRAWBLOOD, delay = 120})
end)

VFX.register("assassin_poison", function(target, o)
	VFX.Pulse(target, CONST_ME_HITBYPOISON, {times = 4, interval = 500})
	return VFX.Helix(target, CONST_ANI_POISON, {radius = 1, height = 2, turns = 1, points = 8, duration = 800, strands = 1})
end)

-- one pulse per tick of the bleeding
VFX.register("assassin_blood", function(target, o)
	return VFX.Pulse(target, CONST_ME_DRAWBLOOD, {times = o.times or 6, interval = 1000, follow = true})
end)

VFX.register("assassin_smoke", function(target, o)
	VFX.Explosion(target, CONST_ANI_SMALLSTONE, {radius = 2, points = 8})
	VFX.Wave(target, CONST_ME_SMOKE, {radius = 2, interval = 120})
	doSendMagicEffect(VFX.resolvePosition(target), CONST_ME_BIGCLOUDS)
	return true
end)

VFX.register("assassin_dance", function(target, o)
	VFX.Circle(target, CONST_ANI_THROWINGKNIFE, {radius = 1, points = 8, spin = true, duration = 350})
	return VFX.Star(target, CONST_ME_BLOCKHIT, {size = 1})
end)

VFX.register("assassin_bloodthirst", function(target, o)
	VFX.Buff(target, {type = "attack", radius = 1, height = 2, duration = 1000})
	return VFX.Ring(target, CONST_ME_DRAWBLOOD, {radius = 1, times = 1})
end)

-- execute: o.from = attacker. A short warning on the target and a knife that falls on it
VFX.register("assassin_execute", function(target, o)
	VFX.Warning(target, {radius = 0, warnTime = 400, blink = 200, impact = "none"})
	return VFX.Comet(target, CONST_ANI_THROWINGKNIFE, {span = 5, rise = 3, flightTime = 350, effect = CONST_ME_EXPLOSIONHIT, delay = 400})
end)

VFX.register("assassin_vanish", function(target, o)
	return VFX.Implosion(target, CONST_ANI_DEATH, {radius = 3, points = 8, flightTime = 250, effect = CONST_ME_SMOKE})
end)

-- thousand cuts: o.from = attacker
VFX.register("assassin_cuts", function(target, o)
	local to = VFX.resolvePosition(target)
	if(not to) then
		return false
	end

	VFX.Barrage(target, CONST_ANI_THROWINGKNIFE, {rays = 9, spread = 120, range = 2, waves = 4, interval = 90, to = o.from})
	return VFX.Pulse(target, CONST_ME_DRAWBLOOD, {times = 8, interval = 300, follow = true})
end)

VFX.register("assassin_mark", function(target, o)
	return VFX.Orbit(target, CONST_ANI_DEATH, {radius = 1, points = 6, duration = o.duration or 6000, step = 200})
end)

VFX.register("assassin_mark_blast", function(target, o)
	return VFX.Death(target, {radius = 2})
end)

VFX.register("assassin_clone", function(target, o)
	return VFX.Summon(target, {ani = CONST_ANI_DEATH, radius = 2, points = 8, flightTime = 250, effect = CONST_ME_PURPLEENERGY, waveEffect = false})
end)

VFX.register("assassin_veil", function(target, o)
	VFX.Buff(target, {type = "defense", radius = 1, height = 2, duration = 1000})
	return VFX.Ring(target, CONST_ME_SMOKE, {radius = 1, times = 3, interval = 400, follow = true})
end)

-- Venom Ring: green poison spiral and ring around the assassin
VFX.register("assassin_venom_ring", function(target, o)
	VFX.Spiral(target, CONST_ANI_POISON, {radius = 1, turns = 1, points = 12, duration = 400})
	return VFX.Ring(target, CONST_ME_HITBYPOISON, {radius = 1, times = 1, delay = 200})
end)

-- Umbral Sweep: dark wave running forward (direction = where the assassin looks)
VFX.register("assassin_umbra", function(target, o)
	VFX.Line(target, CONST_ME_MORTAREA, {direction = o.direction, length = 4, interval = 70})
	return VFX.Line(target, CONST_ME_SMOKE, {direction = o.direction, length = 4, interval = 70, delay = 60})
end)
