-- Archer helpers shared by the Archer / Ranger spells (data/spells/scripts/archer/*).
--
-- By default the Archer shoots PHYSICAL arrows. He can pick an ENCHANTMENT (fire, poison, ice or energy) and every spell changes its element and its
-- effect with it; casting the active Enchant again removes it (back to physical). The shots use the arrow animations (CONST_ANI_*ARROW).
--
-- Archer.element(cid)                       current enchantment key ("fire", "poison", "ice", "energy"), "physical" when there is none
-- Archer.setElement(cid, key)               changes the enchantment (saved in a storage, "physical" removes it) and renews the Enchant buff
-- Archer.toggle(cid, key)                   Enchant spells: turns the enchantment on, or off (back to physical) if it is already the active one
-- Archer.bow(cid)                           item info of the bow in the hands (a bow, not a crossbow) or nil
-- Archer.power(cid)                         distance skill + attack of the bow + attack of the arrow
-- Archer.values(cid, fmin, fmax)            min/max damage = level/5 + power * factor
-- Archer.target(cid, maxDistance)           current target if it is valid, within range and in sight (cancels the spell otherwise)
-- Archer.valid(cid, tid)                    true if tid can be hurt by cid: alive, not a friend, not a summon of a friend, not in a protection zone
-- Archer.enemies(cid, pos, radius [, extra]) valid enemies at most `radius` tiles from pos, in sight of pos
-- Archer.hit(cid, target, fmin, fmax, element, multiplier, options)   one damaging arrow with status and reaction, returns the damage or false
-- Archer.areaHit(cid, pos, radius, fmin, fmax, element, options)       hits every enemy in a square
-- Archer.line(cid, length [, direction])    tiles in front of the caster, stopping at walls
-- Archer.lineToward(cid, aim, length)       tiles of the straight line from the caster through `aim`, `length` tiles long (it goes past aim), stopping at walls
-- Archer.zone{...}                          repeating damage on tiles (fire trail, trap): see the function
-- Archer.chain(cid, target, options)        ricochet: the arrow bounces from enemy to enemy (never through walls, never into a protection zone)
-- Archer.burn / poison / chill / shock      the elemental statuses, see "Statuses"
-- Archer.addBuff(cid, key)                  gives one of the Archer buffs (Archer.buffs) with addCreatureBuff
-- Archer.refresh(cid)                       keeps the Enchant buff in place (globalevent archer.lua, once a second)
-- Archer.fx(name, target [, options])       plays a VFX profile (archer_*), never raises an error

Archer = {
	storageElement = 54300,
	reactionWindow = 6, -- seconds a mark stays on the target
	reactionBonus = 1.25,
	vulnerability = 1.15,
	vulnerabilityTime = 5,
	maxPoison = 5,
	maxChill = 3,
	state = {}, -- per target: burn, poison, chill, mark and vuln (see Archer.get)
	statesCreated = 0
}

-- Elements --------------------------------------------------------------------------------------------------------------------

Archer.order = {"fire", "poison", "ice", "energy"}

Archer.elements = {
	fire = {
		name = "Fire", index = 1, combat = COMBAT_FIREDAMAGE, effect = CONST_ME_HITBYFIRE, area = CONST_ME_FIREAREA, big = CONST_ME_FIREATTACK,
		ani = CONST_ANI_FLAMMINGARROW, vfx = "fire", onhit = CONDITION_PARAM_ONHIT_FIRE, words = "utito ignis"
	},
	poison = {
		name = "Poison", index = 2, combat = COMBAT_EARTHDAMAGE, effect = CONST_ME_HITBYPOISON, area = CONST_ME_POISONAREA, big = CONST_ME_GREEN_RINGS,
		ani = CONST_ANI_POISONARROW, vfx = "earth", onhit = CONDITION_PARAM_ONHIT_EARTH, words = "utito toxi"
	},
	ice = {
		name = "Ice", index = 3, combat = COMBAT_ICEDAMAGE, effect = CONST_ME_ICEATTACK, area = CONST_ME_ICEAREA, big = CONST_ME_ICETORNADO,
		ani = CONST_ANI_SHIVERARROW, vfx = "ice", onhit = CONDITION_PARAM_ONHIT_ICE, words = "utito glacies"
	},
	energy = {
		name = "Energy", index = 4, combat = COMBAT_ENERGYDAMAGE, effect = CONST_ME_ENERGYHIT, area = CONST_ME_ENERGYAREA, big = CONST_ME_YELLOWENERGY,
		ani = CONST_ANI_FLASHARROW, vfx = "energy", onhit = CONDITION_PARAM_ONHIT_ENERGY, words = "utito fulmen"
	}
}

-- no enchantment: plain physical arrows (no status, no mark). Not part of Archer.order (it is index 0 in the storage).
Archer.elements.physical = {
	name = "Physical", index = 0, combat = COMBAT_PHYSICALDAMAGE, effect = CONST_ME_HITAREA, area = CONST_ME_BLOCKHIT, big = CONST_ME_HITAREA,
	ani = CONST_ANI_ARROW, vfx = "holy", onhit = CONDITION_PARAM_ONHIT_PHYSICAL
}

-- the element that reacts when a mark of the key is hit by the element of the value (a cycle: poison > fire > ice > energy > poison)
Archer.reactions = {
	poison = {fire = "ignite"},
	fire = {ice = "shatter"},
	ice = {energy = "conduct"},
	energy = {poison = "corrode"}
}

function Archer.element(cid)
	local index = getPlayerStorageValue(cid, Archer.storageElement)
	return Archer.order[index] or "physical"
end

function Archer.def(cid, element)
	return Archer.elements[element or Archer.element(cid)] or Archer.elements.physical
end

-- Buffs ----------------------------------------------------------------------------------------------------------------------
-- Each one is a condition (CONDITION_ATTRIBUTES) with the same duration as the buff, with a unique sub id.
-- The Enchant buff is permanent (duration 0 = no time limit) and is renewed by Archer.refresh.
Archer.buffs = {
	enchant_fire = {
		name = "Enchant: Fire", category = "Enchant", subId = 8700, duration = 0, description = "+30% of the damage of basic attacks as fire. Spells use fire.",
		params = {[CONDITION_PARAM_ONHIT_FIRE] = 30}, silent = true
	},
	enchant_poison = {
		name = "Enchant: Poison", category = "Enchant", subId = 8701, duration = 0, description = "+30% of the damage of basic attacks as poison. Spells use poison.",
		params = {[CONDITION_PARAM_ONHIT_EARTH] = 30}, silent = true
	},
	enchant_ice = {
		name = "Enchant: Ice", category = "Enchant", subId = 8702, duration = 0, description = "+30% of the damage of basic attacks as ice. Spells use ice.",
		params = {[CONDITION_PARAM_ONHIT_ICE] = 30}, silent = true
	},
	enchant_energy = {
		name = "Enchant: Energy", category = "Enchant", subId = 8703, duration = 0, description = "+30% of the damage of basic attacks as energy. Spells use energy.",
		params = {[CONDITION_PARAM_ONHIT_ENERGY] = 30}, silent = true
	},
	surge = {
		name = "Elemental Surge", category = "Elemental Surge", subId = 8704, duration = 10000,
		description = "+40% elemental damage on basic attacks, +15 fist skill (attack speed) and one extra stack of every status.",
		params = {[CONDITION_PARAM_SKILL_FIST] = 15}
	},
	avatar = {
		name = "Elemental Avatar", category = "Elemental Avatar", subId = 8705, duration = 12000,
		description = "Every attack and spell deals fire, poison, ice and energy (25% each) and applies the four statuses.",
		params = {
			[CONDITION_PARAM_ONHIT_FIRE] = 25, [CONDITION_PARAM_ONHIT_EARTH] = 25,
			[CONDITION_PARAM_ONHIT_ICE] = 25, [CONDITION_PARAM_ONHIT_ENERGY] = 25
		}
	},
	falcon = {
		name = "Spirit Falcon", category = "Spirit Falcon", subId = 8706, duration = 15000,
		description = "A falcon strikes your target with the active enchantment every 1.5s.", params = {}, silent = true
	}
}

-- extra: more condition params to add on top of the ones of the buff (e.g. Elemental Surge adds +40% of the current element)
function Archer.addBuff(cid, key, extra)
	local def = Archer.buffs[key]
	if(not def or not isPlayer(cid)) then
		return false
	end

	local ticks = def.duration > 0 and def.duration or -1
	return addCreatureBuff(cid, {
		name = def.name, category = def.category or def.name, duration = def.duration, description = def.description,
		onActivate = function(id, stacks)
			local params = {}
			for param, value in pairs(def.params) do
				params[param] = value
			end

			for param, value in pairs(extra or {}) do
				params[param] = (params[param] or 0) + value
			end

			if(next(params)) then
				local condition = createConditionObject(CONDITION_ATTRIBUTES, ticks, true, def.subId)
				for param, value in pairs(params) do
					setConditionParam(condition, param, value)
				end

				doAddCondition(id, condition)
			end

			if(not def.silent) then
				doSendMagicEffect(getCreaturePosition(id), CONST_ME_MAGIC_BLUE)
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

function Archer.hasBuff(cid, category)
	return hasCreatureBuff(cid, category)
end

function Archer.setElement(cid, element)
	local def = Archer.elements[element]
	if(not def) then
		return false
	end

	doCreatureSetStorage(cid, Archer.storageElement, def.index)
	if(element == "physical") then
		removeCreatureBuff(cid, "Enchant")
	else
		Archer.addBuff(cid, "enchant_" .. element)
	end

	return true
end

-- Enchant spells: the same enchantment twice goes back to physical. Returns the new element.
function Archer.toggle(cid, element)
	local new = Archer.element(cid) == element and "physical" or element
	Archer.setElement(cid, new)
	return new
end

-- keeps the Enchant buff of the current element in place (after login, death...). Called once a second by globalevents/archer.lua.
function Archer.refresh(cid)
	local element = Archer.element(cid)
	if(element == "physical") then
		if(hasCreatureBuff(cid, "Enchant")) then
			removeCreatureBuff(cid, "Enchant")
		end

		return
	end

	local def = Archer.buffs["enchant_" .. element]
	local buff = getCreatureBuffByCategory(cid, "Enchant")
	-- the buff list is saved with the player but the condition is not: check both
	if(type(buff) ~= "table" or buff.name ~= def.name or not getCreatureCondition(cid, CONDITION_ATTRIBUTES, def.subId)) then
		Archer.addBuff(cid, "enchant_" .. element)
	end
end

-- Equipment and power --------------------------------------------------------------------------------------------------------

-- The distance weapon in the hands gives its attack to the power. The spells themselves only need a weapon (needweapon in spells.xml).
function Archer.bow(cid)
	for _, slot in ipairs({CONST_SLOT_LEFT, CONST_SLOT_RIGHT}) do
		local item = getPlayerSlotItem(cid, slot)
		if(item and item.uid ~= 0 and item.itemid ~= 0) then
			local info = getItemInfo(item.itemid)
			if(info and info.weaponType == WEAPON_DIST) then
				return info
			end
		end
	end

	return nil
end

function Archer.power(cid)
	local bow = Archer.bow(cid)
	local attack = bow and ((bow.attack or 0) + (bow.extraAttack or 0)) or 0

	local ammo = getPlayerSlotItem(cid, CONST_SLOT_AMMO)
	if(ammo and ammo.uid ~= 0 and ammo.itemid ~= 0) then
		local info = getItemInfo(ammo.itemid)
		if(info and info.weaponType == WEAPON_AMMO and info.ammoType == 2) then
			attack = attack + (info.attack or 0)
		end
	end

	return getPlayerSkillLevel(cid, SKILL_DISTANCE) + attack
end

function Archer.values(cid, fmin, fmax)
	local power, base = Archer.power(cid), getPlayerLevel(cid) / 5
	return math.floor(base + power * fmin), math.floor(base + power * fmax)
end

-- Targets ---------------------------------------------------------------------------------------------------------------------

local function cancel(cid, text)
	doPlayerSendCancel(cid, text)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
	return nil
end

local function inProtectionZone(pos)
	local info = getTileInfo(pos)
	return type(info) == "table" and info.protection == true
end

function Archer.isAlly(cid, tid)
	if(cid == tid) then
		return true
	end

	local members = isPlayer(tid) and getPartyMembers(cid)
	return type(members) == "table" and isInArray(members, tid)
end

function Archer.valid(cid, tid)
	if(tid == nil or tid == 0 or tid == cid or not isCreature(tid) or getCreatureHealth(tid) <= 0 or isNpc(tid)) then
		return false
	end

	if(isPlayer(tid) and Archer.isAlly(cid, tid)) then
		return false
	end

	-- summons of a friend (or of yourself) are not enemies
	local master = getCreatureMaster(tid)
	if(master and master ~= 0 and master ~= tid and (master == cid or Archer.isAlly(cid, master))) then
		return false
	end

	return not inProtectionZone(getCreaturePosition(tid))
end

function Archer.target(cid, maxDistance)
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

	if(not Archer.valid(cid, target)) then
		return cancel(cid, "You cannot attack this creature.")
	end

	return target
end

function Archer.enemies(cid, pos, radius, extra)
	local list, seen = {}, {}
	local spectators = getSpectators(pos, radius, radius, false)
	if(type(spectators) ~= "table") then
		spectators = {}
	end

	if(extra) then
		table.insert(spectators, extra)
	end

	for _, tid in ipairs(spectators) do
		if(not seen[tid] and isCreature(tid)) then
			seen[tid] = true
			local tpos = getCreaturePosition(tid)
			if(getDistanceBetween(tpos, pos) <= radius and Archer.valid(cid, tid)
				and (getDistanceBetween(tpos, pos) == 0 or isSightClear(pos, tpos, true))) then
				table.insert(list, tid)
			end
		end
	end

	return list
end

-- Direction vectors (same order as the constants NORTH, EAST, SOUTH, WEST, SOUTHWEST, SOUTHEAST, NORTHWEST, NORTHEAST)
local vectors = {
	[NORTH] = {0, -1}, [EAST] = {1, 0}, [SOUTH] = {0, 1}, [WEST] = {-1, 0},
	[SOUTHWEST] = {-1, 1}, [SOUTHEAST] = {1, 1}, [NORTHWEST] = {-1, -1}, [NORTHEAST] = {1, -1}
}

function Archer.vector(direction)
	return vectors[direction] or vectors[NORTH]
end

-- Tiles in a line in front of the caster (`length` tiles), stopping at the first wall. Returns the positions.
function Archer.line(cid, length, direction)
	local from = getCreaturePosition(cid)
	local v = Archer.vector(direction or getCreatureLookDirection(cid))
	local tiles = {}
	for i = 1, length do
		local pos = {x = from.x + v[1] * i, y = from.y + v[2] * i, z = from.z}
		if(not isSightClear(from, pos, true) or type(getTileInfo(pos)) ~= "table") then
			break
		end

		table.insert(tiles, pos)
	end

	return tiles
end

-- Straight line from the caster through the position `aim` (which may be closer than `length`: the line goes on past it). One tile per
-- step on the longest axis. Stops at the first tile that is missing or not in clear sight of the caster (walls).
function Archer.lineToward(cid, aim, length)
	local from = getCreaturePosition(cid)
	local dx, dy = aim.x - from.x, aim.y - from.y
	local steps = math.max(math.abs(dx), math.abs(dy))
	local tiles = {}
	if(steps == 0) then
		return tiles
	end

	for i = 1, length do
		local pos = {x = from.x + math.floor(dx * i / steps + 0.5), y = from.y + math.floor(dy * i / steps + 0.5), z = from.z}
		if(not isSightClear(from, pos, true) or type(getTileInfo(pos)) ~= "table") then
			break
		end

		table.insert(tiles, pos)
	end

	return tiles
end

local function key(pos)
	return pos.x .. "," .. pos.y .. "," .. pos.z
end

-- valid enemies standing on any of the tiles
function Archer.enemiesOn(cid, tiles, center, radius)
	local set = {}
	for _, pos in ipairs(tiles) do
		set[key(pos)] = true
	end

	local list = {}
	local spectators = getSpectators(center, radius, radius, false)
	if(type(spectators) ~= "table") then
		return list
	end

	for _, tid in ipairs(spectators) do
		if(isCreature(tid) and set[key(getCreaturePosition(tid))] and Archer.valid(cid, tid)) then
			table.insert(list, tid)
		end
	end

	return list
end

-- State of a target -----------------------------------------------------------------------------------------------------------

function Archer.get(target)
	local state = Archer.state[target]
	if(not state) then
		Archer.statesCreated = Archer.statesCreated + 1
		if(Archer.statesCreated % 200 == 0) then
			for id in pairs(Archer.state) do
				if(not isCreature(id)) then
					Archer.state[id] = nil
				end
			end
		end

		state = {poison = 0, chill = 0}
		Archer.state[target] = state
	end

	return state
end

local function now()
	return os.time()
end

-- Statuses -------------------------------------------------------------------------------------------------------------------
-- Damage over time uses a Lua timer (one per status and target) that reads the owner and the strength every tick.

local function tickDamage(owner, target, element, amount)
	if(not isCreature(owner) or not isCreature(target) or getCreatureHealth(target) <= 0 or inProtectionZone(getCreaturePosition(target))) then
		return false
	end

	local def = Archer.elements[element]
	doTargetCombatHealth(owner, target, def.combat, -amount, -amount, def.effect)
	return true
end

local function loop(id, target, field, element, amountOf)
	local state = Archer.state[target]
	if(not state or not isCreature(target) or getCreatureHealth(target) <= 0 or now() >= state[field .. "End"]) then
		if(state) then
			state[field .. "Active"] = false
			if(field == "poison") then
				state.poison = 0
			end
		end

		return
	end

	if(not tickDamage(state.owner, target, element, amountOf(state))) then
		state[field .. "Active"] = false
		return
	end

	addEvent(loop, 1000, id, target, field, element, amountOf)
end

local function startLoop(target, field, element, amountOf)
	local state = Archer.get(target)
	if(not state[field .. "Active"]) then
		state[field .. "Active"] = true
		addEvent(loop, 1000, field, target, field, element, amountOf)
	end
end

-- Burn: fire damage once a second for 4s, renewed by every fire hit.
function Archer.burn(cid, target)
	local state = Archer.get(target)
	state.owner = cid
	state.burnEnd = now() + 4
	local tick = math.max(1, math.floor(getPlayerLevel(cid) / 25 + Archer.power(cid) * 0.10))
	state.burnTick = tick
	startLoop(target, "burn", "fire", function(s) return s.burnTick end)
end

-- Venom: stacks up to 5 (+1 per extra stack of Surge), 6s, each stack adds damage; the stacks go when the time runs out.
function Archer.poison(cid, target, stacks)
	local state = Archer.get(target)
	state.owner = cid
	state.poison = math.min(Archer.maxPoison, state.poison + (stacks or 1))
	state.poisonEnd = now() + 6
	state.poisonTick = math.max(1, math.floor(getPlayerLevel(cid) / 30 + Archer.power(cid) * 0.05))
	startLoop(target, "poison", "poison", function(s) return s.poisonTick * math.max(1, s.poison) end)
end

local function slow(target, percent, ms)
	doRemoveCondition(target, CONDITION_PARALYZE)
	local condition = createConditionObject(CONDITION_PARALYZE)
	setConditionParam(condition, CONDITION_PARAM_TICKS, ms)
	setConditionFormula(condition, -percent, 0, -percent, 0)
	doAddCondition(target, condition)
end

-- Freeze/stun: stops the target for `ms`.
function Archer.freeze(target, ms)
	slow(target, 0.95, ms)
	doSendMagicEffect(getCreaturePosition(target), CONST_ME_STUN)
end

-- Frost: -15% speed per stack (max 3, 4s); the third stack freezes the target for 1.5s and the stacks go away.
function Archer.chill(cid, target, stacks)
	local state = Archer.get(target)
	state.owner = cid
	state.chill = math.min(Archer.maxChill, state.chill + (stacks or 1))
	state.chillEnd = now() + 4
	if(state.chill >= Archer.maxChill) then
		state.chill = 0
		Archer.freeze(target, 1500)
	else
		slow(target, 0.15 * state.chill, 4000)
	end
end

-- Shock: a chance to jump to one more enemy (within 3 tiles, in sight, outside protection zones) for 50% of the damage.
function Archer.shock(cid, target, damage, chance)
	if(math.random(100) > (chance or 20)) then
		return false
	end

	local from = getCreaturePosition(target)
	local best, bestDistance
	for _, tid in ipairs(Archer.enemies(cid, from, 3)) do
		if(tid ~= target) then
			local distance = getDistanceBetween(from, getCreaturePosition(tid))
			if(not bestDistance or distance < bestDistance) then
				best, bestDistance = tid, distance
			end
		end
	end

	if(not best) then
		return false
	end

	local def = Archer.elements.energy
	local to = getCreaturePosition(best)
	doSendDistanceShoot(from, to, def.ani)
	doTargetCombatHealth(cid, best, def.combat, -math.floor(damage / 2), -math.floor(damage / 2), CONST_ME_ENERGYAREA)
	return true
end

function Archer.statusCount(target)
	local state = Archer.state[target]
	if(not state) then
		return 0
	end

	local count, t = 0, now()
	if(state.burnEnd and state.burnEnd > t) then count = count + 1 end
	if(state.poison > 0) then count = count + 1 end
	if(state.chill > 0 or (state.chillEnd and state.chillEnd > t)) then count = count + 1 end
	if(state.vuln and state.vuln > t) then count = count + 1 end
	if(state.mark and state.mark.expire > t) then count = count + 1 end
	return count
end

-- Elemental reactions ---------------------------------------------------------------------------------------------------------
-- Every hit leaves a mark of its element for 6s. Hitting a mark with the element that reacts to it consumes the mark,
-- deals +25% damage and triggers an effect (see Archer.reactions):
--   ignite   (poison > fire)   explosion of fire 3x3
--   shatter  (fire > ice)      burst of ice 3x3, puts out the burning
--   conduct  (ice > energy)    the target takes +15% damage from the archer for 5s (supercharged)
--   corrode  (energy > poison) 3 stacks of poison at once

function Archer.peekReaction(target, element)
	local state = Archer.state[target]
	if(state and state.mark and state.mark.expire > now() and state.mark.element ~= element) then
		return Archer.reactions[state.mark.element] and Archer.reactions[state.mark.element][element]
	end

	return nil
end

function Archer.react(cid, target, reaction)
	local pos = getCreaturePosition(target)
	local state = Archer.get(target)
	if(reaction == "ignite") then
		Archer.areaHit(cid, pos, 1, 0.5, 0.8, "fire", {plain = true})
		doSendMagicEffect(pos, CONST_ME_EXPLOSIONAREA)
	elseif(reaction == "shatter") then
		Archer.areaHit(cid, pos, 1, 0.5, 0.8, "ice", {plain = true})
		state.burnEnd = 0
		doSendMagicEffect(pos, CONST_ME_ICETORNADO)
	elseif(reaction == "conduct") then
		state.vuln = now() + Archer.vulnerabilityTime
		doSendMagicEffect(pos, CONST_ME_ENERGYAREA)
	elseif(reaction == "corrode") then
		Archer.poison(cid, target, 3)
		doSendMagicEffect(pos, CONST_ME_POISONAREA)
	end
end

-- Hits -------------------------------------------------------------------------------------------------------------------------
-- options: effect (override of the hit effect), intensity (stacks of the status, default 1 / 2 with Surge, 0 = none),
--          plain (no status, no mark and no reaction), shockChance (chance of the energy jump, default 20),
--          critical (multiplier, e.g. Perfect Shot), noAvatar (do not split the damage in the 4 elements)

function Archer.avatar(cid)
	return isPlayer(cid) and hasCreatureBuff(cid, "Elemental Avatar")
end

function Archer.surge(cid)
	return isPlayer(cid) and hasCreatureBuff(cid, "Elemental Surge")
end

function Archer.applyStatus(cid, target, element, damage, options)
	local intensity = options.intensity
	if(intensity == nil) then
		intensity = 1
	end

	if(intensity <= 0 or not isCreature(target) or getCreatureHealth(target) <= 0) then
		return
	end

	if(Archer.surge(cid)) then
		intensity = intensity + 1
	end

	if(element == "fire") then
		Archer.burn(cid, target)
	elseif(element == "poison") then
		Archer.poison(cid, target, intensity)
	elseif(element == "ice") then
		Archer.chill(cid, target, intensity)
	elseif(element == "energy") then
		Archer.shock(cid, target, damage, options.shockChance or (20 * intensity))
	end
end

function Archer.hit(cid, target, fmin, fmax, element, multiplier, options)
	options = options or {}
	element = element or Archer.element(cid)
	local def = Archer.elements[element]
	if(not def or not isCreature(cid) or not Archer.valid(cid, target)) then
		return false
	end

	local min, max = Archer.values(cid, fmin, fmax)
	local damage = math.random(math.min(min, max), math.max(min, max)) * (multiplier or 1) * (options.critical or 1)

	local state = Archer.state[target]
	if(state and state.vuln and state.vuln > now()) then
		damage = damage * Archer.vulnerability
	end

	local reaction = (not options.plain) and Archer.peekReaction(target, element) or nil
	if(reaction) then
		damage = damage * Archer.reactionBonus
	end

	damage = math.max(1, math.floor(damage))

	-- Elemental Avatar: the damage is split in the four elements and every status is applied
	if(Archer.avatar(cid) and not options.noAvatar and not options.plain) then
		local part = math.max(1, math.floor(damage / 4))
		local dealt = false
		for _, key in ipairs(Archer.order) do
			local d = Archer.elements[key]
			if(doTargetCombatHealth(cid, target, d.combat, -part, -part, d.effect)) then
				dealt = true
				Archer.applyStatus(cid, target, key, part, options)
			end
		end

		return dealt and damage or false
	end

	if(not doTargetCombatHealth(cid, target, def.combat, -damage, -damage, options.effect or def.effect)) then
		return false
	end

	if(element ~= "physical" and not options.plain and isCreature(target) and getCreatureHealth(target) > 0) then
		local mark = Archer.get(target)
		mark.mark = {element = element, expire = now() + Archer.reactionWindow}
		if(reaction) then
			Archer.react(cid, target, reaction)
		end

		Archer.applyStatus(cid, target, element, damage, options)
	end

	return damage
end

function Archer.areaHit(cid, pos, radius, fmin, fmax, element, options, extra)
	local hit = 0
	for _, tid in ipairs(Archer.enemies(cid, pos, radius, extra)) do
		if(Archer.hit(cid, tid, fmin, fmax, element, nil, options)) then
			hit = hit + 1
		end
	end

	return hit
end

-- Zones (fire trail of the Piercing Arrow, Elemental Trap) --------------------------------------------------------------------
-- Archer.zone{cid, tiles, center, radius, element, ticks, interval, damage = {fmin, fmax}, onTick = function(tid, state) end}
-- Repeats `ticks` times, every `interval` ms, a hit on every enemy standing on the tiles.

function Archer.zone(o)
	local function tick(left)
		if(not isCreature(o.cid)) then
			return
		end

		for _, tid in ipairs(Archer.enemiesOn(o.cid, o.tiles, o.center, o.radius)) do
			if(o.onTick) then
				o.onTick(tid)
			end

			Archer.hit(o.cid, tid, o.damage[1], o.damage[2], o.element, nil, o.options)
		end

		if(left > 1) then
			addEvent(tick, o.interval, left - 1)
		end
	end

	tick(o.ticks)
end

-- Chain (Arrow Tempest) ---------------------------------------------------------------------------------------------------------
-- The arrow hits `target` and bounces to the nearest enemy within `jumpRange` tiles, up to `bounces` times. It never goes through walls
-- (needs a clear line from one enemy to the next), never hits the same creature twice and never hurts someone in a protection zone.
-- options: bounces (5), jumpRange (4), damage {fmin, fmax}, falloff (0.9 per bounce, min 0.5), delay ms (180), element

function Archer.chain(cid, target, o)
	local element = o.element or Archer.element(cid)
	local def = Archer.elements[element]
	local hitList = {}
	local falloff = o.falloff or 0.9

	local function bounce(current, lastPos, number)
		if(not isCreature(cid) or not Archer.valid(cid, current)) then
			return
		end

		local pos = getCreaturePosition(current)
		if(number > 1 and not isSightClear(lastPos, pos, true)) then
			return
		end

		hitList[current] = true
		doSendDistanceShoot(lastPos, pos, def.ani)
		Archer.hit(cid, current, o.damage[1], o.damage[2], element, math.max(0.5, falloff ^ (number - 1)), {intensity = o.intensity})

		if(number > o.bounces) then
			return
		end

		local next, nextDistance
		for _, tid in ipairs(Archer.enemies(cid, pos, o.jumpRange)) do
			if(not hitList[tid] and isSightClear(pos, getCreaturePosition(tid), true)) then
				local distance = getDistanceBetween(pos, getCreaturePosition(tid))
				if(not nextDistance or distance < nextDistance) then
					next, nextDistance = tid, distance
				end
			end
		end

		if(next) then
			addEvent(bounce, o.delay or 180, next, pos, number + 1)
		end
	end

	bounce(target, getCreaturePosition(cid), 1)
end

-- VFX profiles ---------------------------------------------------------------------------------------------------------------------
-- Palette: red/orange (fire), green (poison), light blue (ice) and yellow (energy). Registered with VFX.register
-- (data/lib/360-vfx.lua); played with Archer.fx so a bad option never breaks a spell. Test with /vfx archer_<name>.

function Archer.fx(name, target, options)
	local ok = pcall(VFX.play, name, target, options or {})
	return ok
end

local function elementOf(o)
	return Archer.elements[o.element or "physical"] or Archer.elements.physical
end

-- enchantment changed: a helix of the element rising around the archer
VFX.register("archer_enchant", function(target, o)
	local def = elementOf(o)
	VFX.Helix(target, def.ani, {radius = 1, height = 2, turns = 1, points = 8, duration = 800, strands = 2})
	return VFX.Ring(target, def.area, {radius = 1, times = 1})
end)

-- arrow flying from o.from to the target
VFX.register("archer_shot", function(target, o)
	local def = elementOf(o)
	local to = VFX.resolvePosition(target)
	if(not to or not o.from) then
		return false
	end

	return VFX.Beam(o.from, to, def.ani, {mode = "bolt", effect = def.effect})
end)

-- piercing arrow: a single shoot from o.from straight to the last tile of the line (not tile by tile)
VFX.register("archer_pierce", function(target, o)
	local def = elementOf(o)
	local to = VFX.resolvePosition(target)
	if(not to or not o.from) then
		return false
	end

	return VFX.Beam(o.from, to, def.ani, {mode = "bolt", effect = def.area})
end)

-- rain of arrows over an area. The arrows always fall from above (`height` tiles up); only the side they come from changes with the
-- position of the archer (o.from) in relation to the center of the rain: from the left (archer to the left), from the center (archer in
-- the same column, within 1 tile) or from the right (archer to the right), `side` tiles to that side.
-- options: element, from, radius (2), drops (40), duration ms (1500), height (5), side (4)
VFX.register("archer_rain", function(target, o)
	local def = elementOf(o)
	local center = VFX.resolvePosition(target)
	if(not center) then
		return false
	end

	local height, side = o.height or 5, o.side or 4
	local offsetX = 0
	if(o.from) then
		local dx = o.from.x - center.x
		if(dx < -1) then
			offsetX = -side
		elseif(dx > 1) then
			offsetX = side
		end
	end

	local radius, drops, duration = o.radius or 2, o.drops or 40, o.duration or 1500

	for i = 1, drops do
		local landing = VFX.randomInDisc(center, radius)
		if(not VFX.isVoid(landing)) then
			local start = {x = landing.x + offsetX, y = landing.y - height, z = landing.z}
			addEvent(function()
				doSendDistanceShoot(start, landing, def.ani)
				addEvent(doSendMagicEffect, 200, landing, def.effect)
			end, math.random(0, duration))
		end
	end

	return true
end)

-- trap on the ground
VFX.register("archer_trap", function(target, o)
	local def = elementOf(o)
	VFX.Ring(target, def.area, {radius = 1, times = o.times or 6, interval = 1000})
	return VFX.Pulse(target, def.big, {times = o.times or 6, interval = 1000})
end)

-- charging the Overcharge Shot
VFX.register("archer_charge", function(target, o)
	local def = elementOf(o)
	return VFX.Implosion(target, def.ani, {radius = 3, points = 8, flightTime = 300, effect = def.area})
end)

VFX.register("archer_reaction", function(target, o)
	return VFX.Burst(target, CONST_ANI_ENERGY, {radius = 2, points = 8, effect = CONST_ME_ENERGYAREA})
end)

VFX.register("archer_surge", function(target, o)
	VFX.Buff(target, {type = "attack", radius = 1, height = 2, duration = 1000})
	return VFX.Ring(target, CONST_ME_YELLOWENERGY, {radius = 1, times = 2, interval = 400, follow = true})
end)

VFX.register("archer_avatar", function(target, o)
	for index, key in ipairs(Archer.order) do
		VFX.Orbit(target, Archer.elements[key].ani, {radius = 1, points = 4, duration = 2000, step = 200, delay = (index - 1) * 150})
	end

	return VFX.Ring(target, CONST_ME_MAGIC_BLUE, {radius = 2, times = 2, interval = 300})
end)

-- falcon strike: o.from = where the falcon is, target = the victim
VFX.register("archer_falcon", function(target, o)
	local def = elementOf(o)
	local to = VFX.resolvePosition(target)
	if(not to or not o.from) then
		return false
	end

	return VFX.Comet(to, def.ani, {span = 5, rise = 3, flightTime = 350, effect = def.effect})
end)

-- Tempest: the arrow arriving at the first target
VFX.register("archer_tempest", function(target, o)
	local def = elementOf(o)
	return VFX.Wave(target, def.area, {radius = 1, interval = 100})
end)
