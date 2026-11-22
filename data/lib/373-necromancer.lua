-- Necromancer helpers shared by the Necromancer spells (data/spells/scripts/necromancer/*) and by the attacks of the summons
-- (data/spells/scripts/necromancer/summon/*).
--
-- Necro.power(cid)                    "necromancer power" P = level/5 + magic level*1.4; every damage is P * a factor
-- Necro.values(cid, fmin, fmax)       min and max damage = floor(P * factor)
-- Necro.formula(fmin, fmax)           the same as arguments for setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, Necro.formula(a, b))
-- Necro.summonCap(cid)                2 + 1 per 25 magic level (max 6)
-- Necro.summons(cid, noDragon)        list of summons of the player
-- Necro.summon(cid, key)              summon spell: needs a corpse (3 SQM), 6 soul and a free slot
-- Necro.dragon(cid)                   Summon Dragon Skeleton: consumes every summon (4 or more)
-- Necro.addBuff(cid, key)             gives one of the Necromancer buffs (Necro.buffs)
-- Necro.sacrifice(cid)                consumes the weakest summon (Soul Sacrifice / Bone Shell)
-- Necro.harvest(cid, target)          passive Soul Harvest: chance of getting soul when a monster dies
-- Necro.summonValues(summon, fmin, fmax)  damage of an attack of a summon (uses the level/magic level of the owner, Unholy Frenzy)
-- Necro.hit(summon, target, type, fmin, fmax, effect, shoot)  damage of a summon in a single target

Necro = {}

Necro.soulCost = 6
Necro.soulRefund = 3          -- soul given back by Soul Sacrifice and Bone Shell
Necro.maxSummons = 6
Necro.baseSummons = 2
Necro.summonsPerMagic = 25
Necro.corpseRadius = 3
Necro.dragonMinSummons = 4
Necro.dragonBonusPerExtra = 0.20   -- +20% health for each summon consumed beyond the minimum
Necro.dragonDrainPercent = 1.5     -- % of the max health lost per second (the Dragon Skeleton does not heal)
Necro.frenzyMultiplier = 1.3

-- monster = monster file; hp / speed = {base, per level (hp) or per magic level (speed), limit}  (hp = base + level*a + magic*b)
Necro.defs = {
	skeleton = {monster = "Necro Skeleton", hp = {300, 4, 10}, speed = {180, 1, 300}},
	ghoul = {monster = "Necro Ghoul", hp = {500, 6, 15}, speed = {160, 0.7, 300}},
	banshee = {monster = "Necro Banshee", hp = {200, 2, 5}, speed = {200, 1, 300}},
	phantasm = {monster = "Necro Phantasm", hp = {250, 3, 6}, speed = {220, 1, 300}},
	dragon = {monster = "Necro Dragon Skeleton", hp = {2500, 25, 30}, speed = {200, 0, 200}}
}

local DIRECTION_OFFSET = {[0] = {0, -1}, [1] = {1, 0}, [2] = {0, 1}, [3] = {-1, 0}}

function Necro.positionInFront(cid, steps)
	local pos = getCreaturePosition(cid)
	local offset = DIRECTION_OFFSET[getCreatureLookDirection(cid)] or {0, 1}
	return {x = pos.x + offset[1] * (steps or 1), y = pos.y + offset[2] * (steps or 1), z = pos.z}
end

local function cancel(cid, text)
	doPlayerSendCancel(cid, text)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
	return false
end

-- Damage ---------------------------------------------------------------------------------------------------------------------

function Necro.power(cid)
	return getPlayerLevel(cid) / 5 + getPlayerMagLevel(cid) * 1.4
end

function Necro.values(cid, fmin, fmax)
	local power = Necro.power(cid)
	return math.floor(power * fmin), math.floor(power * fmax)
end

function Necro.formula(fmin, fmax)
	return 5 / fmin, 5 / fmax, 1.4 * fmin, 1.4 * fmax
end

-- Standard poison formula: damage per tick = level/15 + magic level/3 (at least 1)
function Necro.poisonTick(cid)
	return math.max(1, math.floor(getPlayerLevel(cid) / 15 + getPlayerMagLevel(cid) / 3))
end

function Necro.poisonCondition(cid, ticks)
	local condition = createConditionObject(CONDITION_POISON)
	setConditionParam(condition, CONDITION_PARAM_DELAYED, 1)
	addDamageCondition(condition, ticks or 10, 1000, -Necro.poisonTick(cid))
	return condition
end

-- Summons --------------------------------------------------------------------------------------------------------------------

function Necro.summonCap(cid)
	return math.min(Necro.maxSummons, Necro.baseSummons + math.floor(getPlayerMagLevel(cid) / Necro.summonsPerMagic))
end

function Necro.isDragon(cid)
	return getCreatureName(cid) == Necro.defs.dragon.monster
end

function Necro.summons(cid, noDragon)
	local list = {}
	local summons = getCreatureSummons(cid)
	if(type(summons) == 'table') then
		for _, sid in ipairs(summons) do
			if(isCreature(sid) and getCreatureHealth(sid) > 0 and not (noDragon and Necro.isDragon(sid))) then
				table.insert(list, sid)
			end
		end
	end

	return list
end

function Necro.hasDragon(cid)
	for _, sid in ipairs(Necro.summons(cid)) do
		if(Necro.isDragon(sid)) then
			return true
		end
	end

	return false
end

-- Closest corpse (an item the engine sees as a corpse) at most `radius` tiles from the player, in line of sight.
function Necro.findCorpse(cid, radius)
	radius = radius or Necro.corpseRadius
	local from = getCreaturePosition(cid)
	local bestPos, bestUid, bestDistance

	for dx = -radius, radius do
		for dy = -radius, radius do
			local pos = {x = from.x + dx, y = from.y + dy, z = from.z}
			local info = getTileInfo(pos)
			if(type(info) == 'table' and info.items > 0 and not info.protection and isSightClear(from, pos, false)) then
				for stackpos = 1, info.things do
					pos.stackpos = stackpos
					local thing = getThingFromPos(pos)
					if(thing.uid > 0 and not isCreature(thing.uid) and isCorpse(thing.uid) and isMoveable(thing.uid)) then
						local distance = math.max(math.abs(dx), math.abs(dy))
						if(not bestDistance or distance < bestDistance) then
							bestDistance, bestUid = distance, thing.uid
							bestPos = {x = pos.x, y = pos.y, z = pos.z}
						end
						break
					end
				end
			end
		end
	end

	return bestPos, bestUid
end

-- Health and speed of a summon grow with the level and the magic level of the owner.
function Necro.scale(cid, summon, key)
	local def = Necro.defs[key]
	local level, magic = getPlayerLevel(cid), getPlayerMagLevel(cid)

	local hp = math.floor(def.hp[1] + def.hp[2] * level + def.hp[3] * magic)
	if(key == "dragon") then
		hp = math.floor(hp * (1 + Necro.dragonBonusPerExtra * math.max(0, (def.consumed or Necro.dragonMinSummons) - Necro.dragonMinSummons)))
	end

	setCreatureMaxHealth(summon, hp)
	doCreatureAddHealth(summon, hp)

	local speed = math.min(def.speed[3], math.floor(def.speed[1] + def.speed[2] * magic))
	local delta = speed - getCreatureSpeed(summon)
	if(delta ~= 0) then
		doChangeSpeed(summon, delta)
	end
end

function Necro.summon(cid, key)
	local def = Necro.defs[key]
	if(Necro.hasDragon(cid)) then
		return cancel(cid, "No other summon can be raised while the Dragon Skeleton is active.")
	end

	if(#Necro.summons(cid) >= Necro.summonCap(cid)) then
		return cancel(cid, "You cannot control more summons (limit: " .. Necro.summonCap(cid) .. ").")
	end

	if(getPlayerSoul(cid) < Necro.soulCost) then
		return cancel(cid, "You need " .. Necro.soulCost .. " soul.")
	end

	local pos, corpse = Necro.findCorpse(cid)
	if(not pos) then
		return cancel(cid, "You need a corpse near you.")
	end

	local summon = doCreateMonster(def.monster, pos, true, true)
	if(not summon) then
		return cancel(cid, "There is no room for the summon.")
	end

	doRemoveItem(corpse)
	doConvinceCreature(cid, summon)
	doPlayerAddSoul(cid, -Necro.soulCost)
	Necro.scale(cid, summon, key)

	doSendMagicEffect(pos, CONST_ME_MORTAREA)
	doSendMagicEffect(getCreaturePosition(summon), CONST_ME_SMALLCLOUDS)
	return true
end

-- The Dragon Skeleton never heals and loses part of its max health every second until it dies.
function Necro.drain(id)
	if(not isCreature(id) or getCreatureHealth(id) <= 0) then
		return
	end

	local loss = math.max(1, math.floor(getCreatureMaxHealth(id) * Necro.dragonDrainPercent / 100))
	doSendMagicEffect(getCreaturePosition(id), CONST_ME_MORTAREA)
	doCreatureAddHealth(id, -math.min(loss, getCreatureHealth(id)))
	addEvent(Necro.drain, 1000, id)
end

function Necro.dragon(cid)
	if(Necro.hasDragon(cid)) then
		return cancel(cid, "You already have a Dragon Skeleton.")
	end

	local list = Necro.summons(cid, true)
	if(#list < Necro.dragonMinSummons) then
		return cancel(cid, "You need at least " .. Necro.dragonMinSummons .. " summons.")
	end

	local dragon = doCreateMonster(Necro.defs.dragon.monster, Necro.positionInFront(cid, 1), true, true)
	if(not dragon) then
		return cancel(cid, "There is no room for the Dragon Skeleton.")
	end

	for _, sid in ipairs(list) do
		doSendMagicEffect(getCreaturePosition(sid), CONST_ME_MORTAREA)
		doRemoveCreature(sid)
	end

	doConvinceCreature(cid, dragon)
	Necro.defs.dragon.consumed = #list
	Necro.scale(cid, dragon, "dragon")
	doSendMagicEffect(getCreaturePosition(dragon), CONST_ME_MORTAREA)
	addEvent(Necro.drain, 1000, dragon)
	return true
end

-- Consumes the summon with the least health (never the Dragon Skeleton). Returns false when there is none.
function Necro.sacrifice(cid)
	local weakest, weakestHealth
	for _, sid in ipairs(Necro.summons(cid, true)) do
		local health = getCreatureHealth(sid)
		if(not weakestHealth or health < weakestHealth) then
			weakest, weakestHealth = sid, health
		end
	end

	if(not weakest) then
		return cancel(cid, "You have no summon to sacrifice.")
	end

	doSendMagicEffect(getCreaturePosition(weakest), CONST_ME_MORTAREA)
	doRemoveCreature(weakest)
	doPlayerAddSoul(cid, Necro.soulRefund)
	return true
end

-- Heals the summons of the player (not the Dragon Skeleton) around the player.
function Necro.mend(cid, fmin, fmax, radius)
	local min, max = Necro.values(cid, fmin, fmax)
	local from = getCreaturePosition(cid)
	local healed = 0
	for _, sid in ipairs(Necro.summons(cid, true)) do
		if(getDistanceBetween(getCreaturePosition(sid), from) <= radius) then
			doCreatureAddHealth(sid, math.random(min, max))
			doSendMagicEffect(getCreaturePosition(sid), CONST_ME_MAGIC_GREEN)
			healed = healed + 1
		end
	end

	return healed
end

-- Buffs ----------------------------------------------------------------------------------------------------------------------
-- Same format as Cleric.buffs (data/lib/372-cleric.lua). Bone Armor and Unholy Frenzy have no condition: Bone Armor gives
-- physical resistance to the summons (doMonsterSetElementMod) and the attacks of the summons look for Unholy Frenzy.
Necro.buffs = {
	bone_armor = {
		name = "Bone Armor", duration = 20000, description = "+25% physical resistance on the summons.",
		onStart = function(cid)
			for _, sid in ipairs(Necro.summons(cid)) do
				doMonsterSetElementMod(sid, COMBAT_PHYSICALDAMAGE, 25)
				doSendMagicEffect(getCreaturePosition(sid), CONST_ME_MAGIC_BLUE)
			end
		end,
		onEnd = function(cid)
			for _, sid in ipairs(Necro.summons(cid)) do
				doMonsterSetElementMod(sid, COMBAT_PHYSICALDAMAGE, 0)
			end
		end
	},
	unholy_frenzy = {
		name = "Unholy Frenzy", duration = 20000, description = "+30% damage on the summons.",
		onStart = function(cid)
			for _, sid in ipairs(Necro.summons(cid)) do
				doSendMagicEffect(getCreaturePosition(sid), CONST_ME_MAGIC_RED)
			end
		end
	},
	soul_sacrifice = {
		name = "Soul Sacrifice", subId = 8332, duration = 15000, description = "+40% death and poison damage.",
		params = {[CONDITION_PARAM_ELEMENTAL_AMP_DEATH] = 40, [CONDITION_PARAM_ELEMENTAL_AMP_EARTH] = 40}
	},
	bone_shell = {
		name = "Bone Shell", subId = 8333, duration = 15000, description = "+14 armor and +10 defense.",
		params = {[CONDITION_PARAM_ARMOR] = 14, [CONDITION_PARAM_DEFENSE] = 10}
	},
	venom_corrosion = {
		name = "Venom Corrosion", subId = 8334, duration = 10000, description = "+25% poison penetration (ignores part of the poison resistance).",
		params = {[CONDITION_PARAM_PENETRATION_EARTH] = 25}
	}
}

function Necro.addBuff(cid, key)
	local def = Necro.buffs[key]
	if(not def or not isPlayer(cid)) then
		return false
	end

	return addCreatureBuff(cid, {
		name = def.name, category = def.name, duration = def.duration, description = def.description,
		onActivate = function(id)
			if(def.params) then
				local condition = createConditionObject(CONDITION_ATTRIBUTES, def.duration, true, def.subId)
				for param, value in pairs(def.params) do
					setConditionParam(condition, param, value)
				end

				doAddCondition(id, condition)
			end

			if(def.onStart) then
				def.onStart(id)
			end

			doSendMagicEffect(getCreaturePosition(id), CONST_ME_MAGIC_RED)
			doPlayerSendTextMessage(id, MESSAGE_STATUS_CONSOLE_BLUE, def.name .. " activated for " .. Buffs.formatTime(def.duration / 1000) .. ".")
		end,
		onRemove = function(id)
			if(not isCreature(id)) then
				return
			end

			if(def.params) then
				doRemoveCondition(id, CONDITION_ATTRIBUTES, def.subId)
			end

			if(def.onEnd) then
				def.onEnd(id)
			end
		end
	})
end

-- Soul Harvest (passive) -----------------------------------------------------------------------------------------------------
Necro.harvestBase = 20       -- % chance
Necro.harvestPerMagic = 0.25 -- % chance per magic level
Necro.harvestMax = 50
Necro.harvestBigExperience = 1000   -- monsters with this much experience (or more) give 2 soul

function Necro.harvest(cid, target)
	if(not isPlayer(cid) or not isMonster(target) or getCreatureMaster(target)) then
		return false -- not a player, or the target is not a monster / is a summon (getCreatureMaster is nil without an owner)
	end

	local info = getTileInfo(getCreaturePosition(cid))
	if(type(info) == 'table' and info.protection) then
		return false
	end

	local chance = math.min(Necro.harvestMax, Necro.harvestBase + getPlayerMagLevel(cid) * Necro.harvestPerMagic)
	if(math.random(1, 10000) > chance * 100) then
		return false
	end

	local monster = getMonsterInfo(getCreatureName(target))
	local amount = (type(monster) == 'table' and monster.experience and monster.experience >= Necro.harvestBigExperience) and 2 or 1

	doPlayerAddSoul(cid, amount)
	doSendMagicEffect(getCreaturePosition(target), CONST_ME_SMALLCLOUDS)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MORTAREA)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You absorbed " .. amount .. " soul.")
	return true
end

-- Attacks of the summons -----------------------------------------------------------------------------------------------------

function Necro.summonValues(summon, fmin, fmax)
	local master = getCreatureMaster(summon)
	if(not master or master == summon or not isPlayer(master)) then
		return 1, 1
	end

	local min, max = Necro.values(master, fmin, fmax)
	if(hasCreatureBuff(master, "Unholy Frenzy")) then
		min, max = math.floor(min * Necro.frenzyMultiplier), math.floor(max * Necro.frenzyMultiplier)
	end

	return math.max(1, min), math.max(1, max)
end

function Necro.hit(summon, target, combatType, fmin, fmax, effect, shoot)
	if(not isCreature(target)) then
		return false
	end

	local min, max = Necro.summonValues(summon, fmin, fmax)
	if(shoot) then
		doSendDistanceShoot(getCreaturePosition(summon), getCreaturePosition(target), shoot)
	end

	doTargetCombatHealth(summon, target, combatType, -min, -max, effect or CONST_ME_NONE)
	return true
end
