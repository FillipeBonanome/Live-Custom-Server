-- Geomancer helpers shared by the Geomancer / Colossus spells (data/spells/scripts/geomancer/*).
--
-- A tank mage in heavy armor: most of the damage is physical (stone, impact). A GEM in the ammo slot (the slot of the arrows; the gem is never
-- consumed, only weapons that shoot ammunition use it up) turns HALF of the damage of every spell into the element of the gem and the buff
-- Stone Skin gives resistance to that element:
--   violet gem (2153) energy | yellow gem (2154) holy | green gem (2155) poison (earth) | red gem (2156) fire | blue gem (2158) ice
--
-- Geomancer.gem(cid)                         definition of the gem in the ammo slot (Geomancer.gems), nil if none
-- Geomancer.power(cid)                       club skill + attack of the club(s) in the hands
-- Geomancer.values(cid, fmin, fmax)          min/max = level/5 + power * factor
-- Geomancer.target(cid, maxDistance)         current target if it is valid, close enough and in sight (cancels the spell otherwise)
-- Geomancer.hit(cid, target, fmin, fmax [, options])   one hit (physical, or half physical half gem element), returns the damage or false
--                                                      options: multiplier, effect (hit effect of the physical part), physical (ignore the gem)
-- Geomancer.heal(cid, fmin, fmax)            heals the caster, returns the amount
-- Geomancer.crystal(cid, pos, duration [, effect [, onRemove]])     raises a large crystal that blocks the tile and disappears after `duration` ms
-- Geomancer.crystalLine(cid, along, config)            line of crystals that hurt the enemies they rise under (see the function)
-- Geomancer.statBuff(cid, config)            buff made of a CONDITION_ATTRIBUTES (see !buffs)
-- Geomancer.slow(target, percent, ms)        slows (percent 0.95 = almost stopped) with CONDITION_PARALYZE
-- Geomancer.absorbAll(percent)               condition params: `percent` less damage from every element
-- Geomancer.titanChain(cid, target, damage)  Titan's Resonance (Colossus): a stone bolt that jumps from the target to 2 enemies close to it
-- Geomancer.glyph(cid, name)                 the active glyph of the player for a Geomancer spell ("stone strike", "tremor wave"...), nil if none
-- Geomancer.weaken(target, percent, ms)      monsters lose `percent` resistance to physical, fire, earth, ice, energy and holy for `ms`
-- Geomancer.stun(target, ms)                 stops the target for `ms`
-- Geomancer.dot(cid, target, amount, ticks, interval)   damage over time (physical, or the element of the gem)
-- SubIds of the buffs: 8900 Stone Skin, 8901 Gem Resonance, 8902 Titan's Resonance, 8903 Crystal Bulwark, 8910 Purifying Stone, 8911 Sheltering Lane.

Geomancer = {
	gemShare = 0.5, -- part of the damage that becomes the element of the gem
	-- large crystals (8633 to 8636): block players and monsters (solid, not movable). the item itself has no decay (items.xml); only the crystals raised by the Geomancer vanish, through the timer in Geomancer.crystal
	crystalItems = {8633, 8634, 8635, 8636},
	crystalActionId = 54900, -- action id of every crystal: using it removes it (actions.xml)
	skinSubId = 8900,
	resonanceSubId = 8901,
	titanSubId = 8902,
	bulwarkSubId = 8903,
	titan = {bounces = 2, jumpRange = 4, falloff = 0.7, share = 0.35, lockMs = 500}, -- the bolt of Titan's Resonance: share of the damage of the hit
	chainLock = {}
}

Geomancer.gems = {
	[2153] = {
		element = "energy", name = "Energy", combat = COMBAT_ENERGYDAMAGE, effect = CONST_ME_ENERGYHIT, area = CONST_ME_ENERGYAREA,
		ani = CONST_ANI_ENERGY, absorb = CONDITION_PARAM_ABSORB_ENERGY, amp = CONDITION_PARAM_ELEMENTAL_AMP_ENERGY
	},
	[2154] = {
		element = "holy", name = "Holy", combat = COMBAT_HOLYDAMAGE, effect = CONST_ME_HOLYDAMAGE, area = CONST_ME_HOLYAREA,
		ani = CONST_ANI_HOLY, absorb = CONDITION_PARAM_ABSORB_HOLY, amp = CONDITION_PARAM_ELEMENTAL_AMP_HOLY
	},
	[2155] = {
		element = "poison", name = "Poison", combat = COMBAT_EARTHDAMAGE, effect = CONST_ME_HITBYPOISON, area = CONST_ME_POISONAREA,
		ani = CONST_ANI_POISON, absorb = CONDITION_PARAM_ABSORB_EARTH, amp = CONDITION_PARAM_ELEMENTAL_AMP_EARTH
	},
	[2156] = {
		element = "fire", name = "Fire", combat = COMBAT_FIREDAMAGE, effect = CONST_ME_HITBYFIRE, area = CONST_ME_FIREAREA,
		ani = CONST_ANI_FIRE, absorb = CONDITION_PARAM_ABSORB_FIRE, amp = CONDITION_PARAM_ELEMENTAL_AMP_FIRE
	},
	[2158] = {
		element = "ice", name = "Ice", combat = COMBAT_ICEDAMAGE, effect = CONST_ME_ICEATTACK, area = CONST_ME_ICEAREA,
		ani = CONST_ANI_ICE, absorb = CONDITION_PARAM_ABSORB_ICE, amp = CONDITION_PARAM_ELEMENTAL_AMP_ICE
	}
}

-- Equipment and power --------------------------------------------------------------------------------------------------------------

function Geomancer.gem(cid)
	local ammo = getPlayerSlotItem(cid, CONST_SLOT_AMMO)
	if(ammo and ammo.uid ~= 0 and ammo.itemid ~= 0) then
		return Geomancer.gems[ammo.itemid]
	end

	return nil
end

function Geomancer.power(cid)
	local attack = 0
	for _, slot in ipairs({CONST_SLOT_LEFT, CONST_SLOT_RIGHT}) do
		local item = getPlayerSlotItem(cid, slot)
		if(item and item.uid ~= 0 and item.itemid ~= 0) then
			local info = getItemInfo(item.itemid)
			if(info and info.weaponType == WEAPON_CLUB) then
				attack = attack + (info.attack or 0) + (info.extraAttack or 0)
			end
		end
	end

	return getPlayerSkillLevel(cid, SKILL_CLUB) + attack
end

function Geomancer.values(cid, fmin, fmax)
	local power, base = Geomancer.power(cid), getPlayerLevel(cid) / 5
	return math.floor(base + power * fmin), math.floor(base + power * fmax)
end

-- Targets --------------------------------------------------------------------------------------------------------------------------

local function cancel(cid, text)
	doPlayerSendCancel(cid, text)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
	return nil
end

Geomancer.cancel = cancel

function Geomancer.target(cid, maxDistance)
	local target = getCreatureTarget(cid)
	if(target == 0 or target == cid or not isCreature(target) or getCreatureHealth(target) <= 0) then
		return cancel(cid, "You need a target.")
	end

	local from, to = getCreaturePosition(cid), getCreaturePosition(target)
	if(from.z ~= to.z or getDistanceBetween(from, to) > maxDistance) then
		return cancel(cid, "Your target is too far away.")
	end

	if(not isSightClear(from, to, true)) then
		doPlayerSendDefaultCancel(cid, RETURNVALUE_CANNOTTHROW)
		doSendMagicEffect(from, CONST_ME_POFF)
		return nil
	end

	if(not Attacks.valid(cid, target)) then
		return cancel(cid, "You cannot attack this creature.")
	end

	return target
end

-- Glyphs (data/lib/403-glyphs.lua, keys "geomancer/<script name>") ------------------------------------------------------------------
-- The Geomancer spells do not go through the SpellBalance: every script reads the fields of its glyph by itself.

function Geomancer.glyph(cid, name)
	return (Glyphs.get(cid, "geomancer/" .. name))
end

local resisted = {COMBAT_PHYSICALDAMAGE, COMBAT_FIREDAMAGE, COMBAT_EARTHDAMAGE, COMBAT_ICEDAMAGE, COMBAT_ENERGYDAMAGE, COMBAT_HOLYDAMAGE}

function Geomancer.weaken(target, percent, ms)
	for _, combat in ipairs(resisted) do
		Glyphs.reduceResistance(target, combat, percent, ms)
	end
end

function Geomancer.stun(target, ms)
	Geomancer.slow(target, 0.95, ms)
	doSendMagicEffect(getCreaturePosition(target), CONST_ME_STUN)
end

-- `ticks` hits of `amount`, one every `interval` ms, physical or with the element of the gem the caster has at that moment
function Geomancer.dot(cid, target, amount, ticks, interval)
	amount = math.max(1, math.floor(amount))
	local function tick(left)
		if(left <= 0 or not isCreature(cid) or not Attacks.valid(cid, target)) then
			return
		end

		local gem = Geomancer.gem(cid)
		doTargetCombatHealth(cid, target, gem and gem.combat or COMBAT_PHYSICALDAMAGE, -amount, -amount, gem and gem.effect or CONST_ME_HITAREA)
		addEvent(tick, interval, left - 1)
	end

	addEvent(tick, interval, ticks)
end

-- Hits -----------------------------------------------------------------------------------------------------------------------------

function Geomancer.hit(cid, target, fmin, fmax, options)
	options = options or {}
	if(not isCreature(cid) or not Attacks.valid(cid, target)) then
		return false
	end

	local min, max = Geomancer.values(cid, fmin, fmax)
	local damage = math.max(1, math.floor(math.random(math.min(min, max), math.max(min, max)) * (options.multiplier or 1)))
	local effect = options.effect or CONST_ME_HITAREA

	local gem = (not options.physical) and Geomancer.gem(cid) or nil
	local dealt
	if(not gem) then
		dealt = doTargetCombatHealth(cid, target, COMBAT_PHYSICALDAMAGE, -damage, -damage, effect)
	else
		local elemental = math.max(1, math.floor(damage * Geomancer.gemShare))
		local physical = math.max(1, damage - elemental)
		dealt = doTargetCombatHealth(cid, target, COMBAT_PHYSICALDAMAGE, -physical, -physical, effect)
		if(isCreature(target) and getCreatureHealth(target) > 0) then
			dealt = doTargetCombatHealth(cid, target, gem.combat, -elemental, -elemental, gem.effect) or dealt
		end
	end

	if(not dealt) then
		return false
	end

	if(not options.noChain) then
		Geomancer.titanChain(cid, target, damage)
	end

	return damage
end

-- Titan's Resonance (Colossus): every hit sends a bolt of stone from the target to up to 2 enemies close to it, each one taking 35% of the damage
-- of the hit (falling 30% per jump). Only one bolt every half second, or an area spell would fire one per creature.
function Geomancer.titanChain(cid, target, damage)
	if(Geomancer.chainLock[cid] or not hasCreatureBuff(cid, "Titan's Resonance")) then
		return false
	end

	Geomancer.chainLock[cid] = true
	addEvent(function() Geomancer.chainLock[cid] = nil end, Geomancer.titan.lockMs)

	-- glyphs: storm {bounces, share} = more enemies and more damage; ward {percent, heal} = every bolt heals `heal`% of your maximum health
	local glyph = Geomancer.glyph(cid, "titan resonance")
	local bounces = glyph and glyph.storm and glyph.storm.bounces or Geomancer.titan.bounces
	local share = glyph and glyph.storm and glyph.storm.share or Geomancer.titan.share
	local heal = glyph and glyph.ward and glyph.ward.heal

	local gem = Geomancer.gem(cid)
	Attacks.chainLightning(cid, target, {
		bounces = bounces, jumpRange = Geomancer.titan.jumpRange, falloff = Geomancer.titan.falloff, delay = 150,
		ani = CONST_ANI_SMALLSTONE, effect = CONST_ME_STONES,
		onHit = function(tid, multiplier, number)
			if(number > 1) then
				local amount = math.max(1, math.floor(damage * share * multiplier))
				doTargetCombatHealth(cid, tid, gem and gem.combat or COMBAT_PHYSICALDAMAGE, -amount, -amount, gem and gem.effect or CONST_ME_HITAREA)
				if(heal and isCreature(cid)) then
					doCreatureAddHealth(cid, math.max(1, math.floor(getCreatureMaxHealth(cid) * heal / 100)))
					doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
				end
			end
		end
	})

	return true
end

-- slows the target (percent 0.95 = almost stopped) for `ms`; a monster immune to paralysis is not affected
function Geomancer.slow(target, percent, ms)
	doRemoveCondition(target, CONDITION_PARALYZE)
	local condition = createConditionObject(CONDITION_PARALYZE)
	setConditionParam(condition, CONDITION_PARAM_TICKS, ms)
	setConditionFormula(condition, -percent, 0, -percent, 0)
	doAddCondition(target, condition)
end

function Geomancer.absorbAll(percent)
	return {
		[CONDITION_PARAM_ABSORB_PHYSICAL] = percent, [CONDITION_PARAM_ABSORB_ENERGY] = percent,
		[CONDITION_PARAM_ABSORB_EARTH] = percent, [CONDITION_PARAM_ABSORB_FIRE] = percent,
		[CONDITION_PARAM_ABSORB_ICE] = percent, [CONDITION_PARAM_ABSORB_HOLY] = percent,
		[CONDITION_PARAM_ABSORB_DEATH] = percent, [CONDITION_PARAM_ABSORB_DROWN] = percent
	}
end

function Geomancer.heal(cid, fmin, fmax)
	local min, max = Geomancer.values(cid, fmin, fmax)
	local amount = math.max(1, math.random(math.min(min, max), math.max(min, max)))
	doCreatureAddHealth(cid, amount)
	return amount
end

-- Crystals -------------------------------------------------------------------------------------------------------------------------

-- Raises a large crystal on the tile if it is free (nobody on it, nothing solid, not a protection zone). It blocks everyone, players included.
-- onRemove(pos) is called when the crystal vanishes after `duration` (Crystal Bulwark: it explodes). Returns true if it was raised.
function Geomancer.crystal(cid, pos, duration, effect, onRemove)
	if(not Attacks.tileOpen(cid, pos)) then
		return false
	end

	local id = Geomancer.crystalItems[math.random(#Geomancer.crystalItems)]
	local uid = doCreateItem(id, 1, pos)
	if(not uid) then
		return false
	end

	-- clicking the crystal makes it vanish (data/actions/scripts/geomancer_crystal.lua)
	doItemSetAttribute(uid, "aid", Geomancer.crystalActionId)

	doSendMagicEffect(pos, effect or CONST_ME_STONES)
	addEvent(function()
		local item = getTileItemById(pos, id)
		if(item and item.uid > 0) then
			doRemoveItem(item.uid)
			doSendMagicEffect(pos, CONST_ME_BLOCKHIT)
			if(onRemove) then
				onRemove(pos)
			end
		end
	end, duration)

	return true
end

-- A line of crystals that follows the direction the caster is looking at (config: length, distance, duration, growDelay, damage {fmin, fmax},
-- and optionally stun (ms: an enemy under a rising crystal is stunned) and onRemove(pos): called when a crystal vanishes):
--   along = false: a WALL across the view, centered `distance` tiles ahead (perpendicular to the direction)
--   along = true:  a LANE in the direction of the view, starting `distance` tiles ahead
-- The crystals rise one after another (`growDelay` ms apart, from the center / from the nearest). Where one rises under an enemy it hurts him
-- (the tile stays empty, since the enemy is standing there); free tiles get the crystal. Tiles behind a wall or in a protection zone are skipped.
function Geomancer.crystalLine(cid, along, config)
	local from = getCreaturePosition(cid)
	local v = Attacks.vector(getCreatureLookDirection(cid))
	local gem = Geomancer.gem(cid)

	local entries = {}
	local function add(pos, order)
		if(type(getTileInfo(pos)) == "table" and isSightClear(from, pos, true)) then
			table.insert(entries, {pos = pos, order = order})
		end
	end

	if(along) then
		for k = 0, config.length - 1 do
			local n = config.distance + k
			add({x = from.x + v[1] * n, y = from.y + v[2] * n, z = from.z}, k)
		end
	else
		local side = {-v[2], v[1]}
		local center = {x = from.x + v[1] * config.distance, y = from.y + v[2] * config.distance, z = from.z}
		local half = math.floor(config.length / 2)
		for k = -half, half do
			add({x = center.x + side[1] * k, y = center.y + side[2] * k, z = center.z}, math.abs(k))
		end
	end

	if(#entries == 0) then
		cancel(cid, "There is no room for the crystals.")
		return false
	end

	for _, entry in ipairs(entries) do
		addEvent(function()
			if(not isCreature(cid)) then
				return
			end

			for _, tid in ipairs(Attacks.enemiesOn(cid, {entry.pos}, entry.pos, 1)) do
				if(Geomancer.hit(cid, tid, config.damage[1], config.damage[2], {effect = CONST_ME_STONES}) and config.stun and isCreature(tid)) then
					Geomancer.stun(tid, config.stun)
				end
			end

			if(not Geomancer.crystal(cid, entry.pos, config.duration, gem and gem.area, config.onRemove)) then
				doSendMagicEffect(entry.pos, CONST_ME_STONES)
			end
		end, entry.order * config.growDelay)
	end

	return true
end

-- Buffs ----------------------------------------------------------------------------------------------------------------------------
-- config: name, subId, duration (ms), description, params ({[CONDITION_PARAM_*] = value}), effect

function Geomancer.statBuff(cid, config)
	if(not isPlayer(cid)) then
		return false
	end

	return addCreatureBuff(cid, {
		name = config.name, category = config.name, duration = config.duration, description = config.description,
		onActivate = function(id)
			local condition = createConditionObject(CONDITION_ATTRIBUTES, config.duration, true, config.subId)
			for param, value in pairs(config.params) do
				setConditionParam(condition, param, value)
			end

			doAddCondition(id, condition)
			doSendMagicEffect(getCreaturePosition(id), config.effect or CONST_ME_MAGIC_BLUE)
			doPlayerSendTextMessage(id, MESSAGE_STATUS_CONSOLE_BLUE, config.name .. " activated for " .. Buffs.formatTime(config.duration / 1000) .. ".")
		end,
		onRemove = function(id)
			if(isCreature(id)) then
				doRemoveCondition(id, CONDITION_ATTRIBUTES, config.subId)
			end
		end
	})
end
