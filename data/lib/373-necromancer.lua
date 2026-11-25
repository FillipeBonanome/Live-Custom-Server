-- Necromancer helpers shared by the Necromancer spells (data/spells/scripts/necromancer/*) and by the attacks of the summons
-- (data/spells/scripts/necromancer/summon/*).
--
-- Necro.power(cid)                    "necromancer power" P = level/5 + magic level*1.4; every damage is P * a factor
-- Necro.values(cid, fmin, fmax)       min and max damage = floor(P * factor)
-- Necro.formula(fmin, fmax)           the same as arguments for setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, Necro.formula(a, b))
-- Necro.summonCap(cid)                2 + 1 per 25 magic level (max 6)
-- Necro.summons(cid, noDragon, temporary)  list of summons of the player (the temporary ones of Army of the Dead only with `temporary`)
-- Necro.summon(cid, key)              summon spell: needs a corpse (3 SQM), 6 soul and a free slot
-- Necro.dragon(cid)                   Summon Dragon Skeleton: consumes every summon (4 or more)
-- Necro.army(cid)                     Army of the Dead (Lich): 3 temporary skeletons, 12 soul, no slot
-- Necro.addBuff(cid, key)             gives one of the Necromancer buffs (Necro.buffs)
-- Necro.sacrifice(cid)                consumes the weakest summon (Soul Sacrifice / Bone Shell)
-- Necro.harvest(cid, target)          passive Soul Harvest: chance of getting soul when a monster dies
-- Necro.summonValues(summon, fmin, fmax)  damage of an attack of a summon (uses the level/magic level of the owner, Unholy Frenzy)
-- Necro.hit(summon, target, type, fmin, fmax, effect, shoot)  damage of a summon in a single target
-- Glyphs (data/lib/403-glyphs.lua, doc/sistemas/42-glifos.md): Necro.glyph(cid, "name") is the active glyph of the spell "necromancer/<name>";
--   Necro.ownerGlyph(summon, "name") is the one of the owner of a summon (used by the attacks of the summons)

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
Necro.armySoul = 12                -- Army of the Dead (Lich)
Necro.armyCount = 3
Necro.armyDuration = 20000         -- ms the temporary skeletons last

-- monster = monster file; hp / speed = {base, per level (hp) or per magic level (speed), limit}  (hp = base + level*a + magic*b)
Necro.defs = {
	skeleton = {monster = "Necro Skeleton", hp = {300, 4, 10}, speed = {180, 1, 300}},
	ghoul = {monster = "Necro Ghoul", hp = {500, 6, 15}, speed = {160, 0.7, 300}},
	banshee = {monster = "Necro Banshee", hp = {200, 2, 5}, speed = {200, 1, 300}},
	phantasm = {monster = "Necro Phantasm", hp = {250, 3, 6}, speed = {220, 1, 300}},
	dragon = {monster = "Necro Dragon Skeleton", hp = {2500, 25, 30}, speed = {200, 0, 200}},
	-- Lich
	abomination = {monster = "Necro Bone Abomination", hp = {1000, 12, 30}, speed = {130, 0.5, 220}},
	-- temporary skeletons of Army of the Dead: they do not use a summon slot
	soldier = {monster = "Necro Bone Soldier", hp = {150, 2, 5}, speed = {200, 1, 300}, temporary = true}
}

-- Glyph helpers -------------------------------------------------------------------------------------------------------------
-- glyph of the spell "necromancer/<name>" of a player (nil without glyph)
function Necro.glyph(cid, name)
	return Glyphs.get(cid, "necromancer/" .. name)
end

-- summon monster name -> spell that raised it (the glyphs of that spell change the summon)
Necro.summonSpells = {
	["Necro Skeleton"] = "summon skeleton", ["Necro Ghoul"] = "summon ghoul", ["Necro Banshee"] = "summon banshee",
	["Necro Phantasm"] = "summon phantasm", ["Necro Dragon Skeleton"] = "summon dragon skeleton",
	["Necro Bone Abomination"] = "summon bone abomination", ["Necro Bone Soldier"] = "army of the dead"
}

-- the glyph that the owner of `summon` carved on the spell that raised it (nil when it is not a summon of a player)
function Necro.ownerGlyph(summon, name)
	local master = getCreatureMaster(summon)
	if(not master or master == summon or not isPlayer(master)) then
		return nil, nil
	end

	return Necro.glyph(master, name or Necro.summonSpells[getCreatureName(summon)] or ""), master
end

-- same damage type list for effects that touch every element
Necro.allTypes = {COMBAT_PHYSICALDAMAGE, COMBAT_ENERGYDAMAGE, COMBAT_EARTHDAMAGE, COMBAT_FIREDAMAGE, COMBAT_ICEDAMAGE, COMBAT_HOLYDAMAGE, COMBAT_DEATHDAMAGE, COMBAT_DROWNDAMAGE}

-- `percent`% less damage of every element on a summon for `ms` (CONDITION_ATTRIBUTES with positive CONDITION_PARAM_ABSORB_*, which
-- Monster::blockHit reads like the resistance of the xml)
function Necro.guard(summon, percent, ms, subId)
	if(not isCreature(summon)) then
		return false
	end

	local condition = createConditionObject(CONDITION_ATTRIBUTES, ms, true, subId or 8335)
	for param, value in pairs(Glyphs.absorbAll(percent)) do
		setConditionParam(condition, param, value)
	end

	return doAddCondition(summon, condition)
end

-- the enemies (monsters that are not summons) around a position
function Necro.enemiesAround(pos, radius)
	local list = {}
	for _, tid in ipairs(getSpectators(pos, radius, radius, false) or {}) do
		if(isCreature(tid) and isMonster(tid) and not getCreatureMaster(tid) and getCreatureHealth(tid) > 0
			and getDistanceBetween(pos, getCreaturePosition(tid)) <= radius) then
			table.insert(list, tid)
		end
	end

	return list
end

-- poison of the spells of the Necromancer (Venom Touch/Orb/Wave) with the glyph: glyph.poison = {ticks, mult} (longer / stronger
-- poison) and glyph.slow = {percent, duration} (the poisoned creature is slowed)
function Necro.poisonTarget(cid, target, glyph)
	local ticks, mult = 10, 1
	if(glyph and glyph.poison) then
		ticks, mult = glyph.poison.ticks or 10, glyph.poison.mult or 1
	end

	local condition = createConditionObject(CONDITION_POISON)
	setConditionParam(condition, CONDITION_PARAM_DELAYED, 1)
	addDamageCondition(condition, ticks, 1000, -math.max(1, math.floor(Necro.poisonTick(cid) * mult)))
	doTargetCombatCondition(cid, target, condition, CONST_ME_NONE)

	if(glyph and glyph.slow) then
		Glyphs.paralyze(cid, target, glyph.slow.percent, glyph.slow.duration)
	end
end

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

function Necro.isTemporary(cid)
	return getCreatureName(cid) == Necro.defs.soldier.monster
end

function Necro.summons(cid, noDragon, temporary)
	local list = {}
	local summons = getCreatureSummons(cid)
	if(type(summons) == 'table') then
		for _, sid in ipairs(summons) do
			if(isCreature(sid) and getCreatureHealth(sid) > 0 and not (noDragon and Necro.isDragon(sid))
				and (temporary or not Necro.isTemporary(sid))) then
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
-- With `near` (a position) it picks the corpse closest to that position instead.
function Necro.findCorpse(cid, radius, near)
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
						local distance = near and math.max(math.abs(pos.x - near.x), math.abs(pos.y - near.y)) or math.max(math.abs(dx), math.abs(dy))
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

	Necro.applyGlyph(cid, summon, key)
end

-- the spell that raises each kind of summon (Necro.defs key -> spell name)
local KEY_SPELL = {skeleton = "summon skeleton", ghoul = "summon ghoul", banshee = "summon banshee", phantasm = "summon phantasm",
	dragon = "summon dragon skeleton", abomination = "summon bone abomination", soldier = "army of the dead"}
Necro.keySpell = KEY_SPELL

-- glyph.vitality = x         the summon has x times the health   (Skeleton A, Ghoul A)
-- glyph.regen = n            the summon recovers n% of its health per second (Ghoul A)
-- Bone Armor glyphs: glyph.later = true gives the armor to the summons raised while the buff lasts, glyph.spikes = percent sets the
-- thorns (event NecroSpikes) on them
function Necro.applyGlyph(cid, summon, key)
	local glyph = Necro.glyph(cid, KEY_SPELL[key] or "")
	if(glyph) then
		if(glyph.vitality) then
			local hp = math.floor(getCreatureMaxHealth(summon) * glyph.vitality)
			setCreatureMaxHealth(summon, hp)
			doCreatureAddHealth(summon, hp)
		end

		if(glyph.regen) then
			Glyphs.regen(summon, glyph.regen, 3600, 1000)
		end
	end

	if(key ~= "dragon" and hasCreatureBuff(cid, "Bone Armor")) then
		local armor = Necro.glyph(cid, "bone armor")
		if(armor and armor.later) then
			doMonsterSetElementMod(summon, COMBAT_PHYSICALDAMAGE, Necro.armorPercent(cid))
		end

		if(armor and armor.spikes) then
			registerCreatureEvent(summon, "NecroSpikes")
		end
	end
end

-- % of physical resistance given by Bone Armor (25, or the glyph)
function Necro.armorPercent(cid)
	local armor = Necro.glyph(cid, "bone armor")
	return armor and armor.armor or 25
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

	-- glyph.soulSave = n: n% chance of not spending the soul (Summon Skeleton B)
	local glyph = Necro.glyph(cid, Necro.keySpell[key] or "")
	if(glyph and glyph.soulSave and math.random(100) <= glyph.soulSave) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "The soul was not spent.")
	else
		doPlayerAddSoul(cid, -Necro.soulCost)
	end

	Necro.scale(cid, summon, key)

	doSendMagicEffect(pos, CONST_ME_MORTAREA)
	doSendMagicEffect(getCreaturePosition(summon), CONST_ME_SMALLCLOUDS)
	return true
end

-- The Dragon Skeleton never heals and loses part of its max health every second until it dies.
function Necro.drain(id, percent)
	if(not isCreature(id) or getCreatureHealth(id) <= 0) then
		return
	end

	percent = percent or Necro.dragonDrainPercent
	local loss = math.max(1, math.floor(getCreatureMaxHealth(id) * percent / 100))
	doSendMagicEffect(getCreaturePosition(id), CONST_ME_MORTAREA)
	doCreatureAddHealth(id, -math.min(loss, getCreatureHealth(id)))
	addEvent(Necro.drain, 1000, id, percent)
end

-- Grave Burst of the Dragon Skeleton (ring of death around it). glyph.burst = {damage, every} of Summon Dragon Skeleton B: more damage
-- and an extra burst between the normal ones (the normal one is an attack of the monster file, every 10s)
function Necro.graveBurst(summon)
	if(not isCreature(summon) or getCreatureHealth(summon) <= 0) then
		return
	end

	local glyph = Necro.ownerGlyph(summon, "summon dragon skeleton")
	local min, max = Necro.summonValues(summon, 1.0, 1.8)
	if(glyph and glyph.burst) then
		min, max = math.floor(min * glyph.burst.damage), math.floor(max * glyph.burst.damage)
	end

	RingAttack.execute(summon, {
		holeRadius = 1, ringThickness = 2, sweepDuration = 1000,
		elements = {{combatType = COMBAT_DEATHDAMAGE, effect = CONST_ME_MORTAREA}},
		damageMin = min, damageMax = max
	})
end

function Necro.extraBurst(id, every)
	if(not isCreature(id) or getCreatureHealth(id) <= 0) then
		return
	end

	Necro.graveBurst(id)
	addEvent(Necro.extraBurst, every, id, every)
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

	local glyph = Necro.glyph(cid, "summon dragon skeleton")
	addEvent(Necro.drain, 1000, dragon, glyph and glyph.drain or Necro.dragonDrainPercent)
	if(glyph and glyph.burst) then
		addEvent(Necro.extraBurst, glyph.burst.every, dragon, glyph.burst.every * 2) -- between the normal bursts: one every `every` ms
	end

	return true
end

-- the soldiers of Army of the Dead B keep challenging the monsters around them
function Necro.soldierTaunt(id, taunt)
	if(not isCreature(id) or getCreatureHealth(id) <= 0) then
		return
	end

	for _, tid in ipairs(Necro.enemiesAround(getCreaturePosition(id), taunt.radius)) do
		doChallengeCreature(id, tid)
	end

	addEvent(Necro.soldierTaunt, taunt.every, id, taunt)
end

function Necro.expire(id)
	if(isCreature(id) and getCreatureHealth(id) > 0) then
		doSendMagicEffect(getCreaturePosition(id), CONST_ME_POFF)
		doRemoveCreature(id)
	end
end

-- Army of the Dead (Lich): raises Necro.armyCount temporary skeletons from a corpse for Necro.armyDuration ms. They use no summon
-- slot (and are not consumed by the Dragon Skeleton, Soul Sacrifice and Bone Shell). Costs Necro.armySoul soul.
function Necro.army(cid)
	if(Necro.hasDragon(cid)) then
		return cancel(cid, "No other summon can be raised while the Dragon Skeleton is active.")
	end

	if(getPlayerSoul(cid) < Necro.armySoul) then
		return cancel(cid, "You need " .. Necro.armySoul .. " soul.")
	end

	local pos, corpse = Necro.findCorpse(cid)
	if(not pos) then
		return cancel(cid, "You need a corpse near you.")
	end

	-- glyph = {count, duration, taunt = {radius, every}} (Army of the Dead A and B)
	local glyph = Necro.glyph(cid, "army of the dead")
	local count = glyph and glyph.count or Necro.armyCount
	local duration = glyph and glyph.duration or Necro.armyDuration

	local raised = {}
	for i = 1, count do
		local summon = doCreateMonster(Necro.defs.soldier.monster, pos, true, true)
		if(summon) then
			table.insert(raised, summon)
		end
	end

	if(#raised == 0) then
		return cancel(cid, "There is no room for the summons.")
	end

	doRemoveItem(corpse)
	doPlayerAddSoul(cid, -Necro.armySoul)
	for _, summon in ipairs(raised) do
		doConvinceCreature(cid, summon)
		Necro.scale(cid, summon, "soldier")
		doSendMagicEffect(getCreaturePosition(summon), CONST_ME_MORTAREA)
		addEvent(Necro.expire, duration, summon)
		if(glyph and glyph.taunt) then
			Necro.soldierTaunt(summon, glyph.taunt)
		end
	end

	doSendMagicEffect(pos, CONST_ME_MORTAREA)
	return true
end

-- Consumes the summon with the least health (never the Dragon Skeleton). Returns false when there is none.
function Necro.sacrifice(cid, refund)
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
	doPlayerAddSoul(cid, refund or Necro.soulRefund)
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
			local armor = Necro.glyph(cid, "bone armor")
			for _, sid in ipairs(Necro.summons(cid, false, true)) do
				doMonsterSetElementMod(sid, COMBAT_PHYSICALDAMAGE, Necro.armorPercent(cid))
				if(armor and armor.spikes) then
					registerCreatureEvent(sid, "NecroSpikes") -- Spiked Bones: attackers take part of the damage back
				end

				doSendMagicEffect(getCreaturePosition(sid), CONST_ME_MAGIC_BLUE)
			end
		end,
		onEnd = function(cid)
			for _, sid in ipairs(Necro.summons(cid, false, true)) do
				doMonsterSetElementMod(sid, COMBAT_PHYSICALDAMAGE, 0)
			end
		end
	},
	unholy_frenzy = {
		name = "Unholy Frenzy", duration = 20000, description = "+30% damage on the summons.",
		onStart = function(cid)
			for _, sid in ipairs(Necro.summons(cid, false, true)) do
				doSendMagicEffect(getCreaturePosition(sid), CONST_ME_MAGIC_RED)
			end
		end
	},
	-- versions of the buffs given by the glyphs (the same category, so they replace the normal one)
	unholy_frenzy_dire = {
		name = "Unholy Frenzy", duration = 12000, description = "+45% damage on the summons (Dire Frenzy).",
		onStart = function(cid)
			for _, sid in ipairs(Necro.summons(cid, false, true)) do
				doSendMagicEffect(getCreaturePosition(sid), CONST_ME_MAGIC_RED)
			end
		end
	},
	soul_sacrifice_pact = {
		name = "Soul Sacrifice", subId = 8332, duration = 15000, description = "+60% death and poison damage (Dark Pact).",
		params = {[CONDITION_PARAM_ELEMENTAL_AMP_DEATH] = 60, [CONDITION_PARAM_ELEMENTAL_AMP_EARTH] = 60}
	},
	bone_shell_reinforced = {
		name = "Bone Shell", subId = 8333, duration = 15000, description = "+24 armor and +18 defense (Reinforced Shell).",
		params = {[CONDITION_PARAM_ARMOR] = 24, [CONDITION_PARAM_DEFENSE] = 18}
	},
	-- Shell Burst: when the shell ends it explodes in death (radius 2, P x 1.5 to 2.5)
	bone_shell_burst = {
		name = "Bone Shell", subId = 8333, duration = 15000, description = "+14 armor and +10 defense; explodes in death when it ends (Shell Burst).",
		params = {[CONDITION_PARAM_ARMOR] = 14, [CONDITION_PARAM_DEFENSE] = 10},
		onEnd = function(cid)
			if(not isPlayer(cid) or getCreatureHealth(cid) <= 0) then
				return
			end

			local pos = getCreaturePosition(cid)
			local min, max = Necro.values(cid, 1.5, 2.5)
			doAreaCombatHealth(cid, COMBAT_DEATHDAMAGE, pos, Necro.shellArea, -min, -max, CONST_ME_MORTAREA)
			VFX.Explosion(pos, CONST_ANI_DEATH, {radius = 2, points = 12, rings = 2, ringInterval = 120, skipVoid = true})
		end
	},
	venom_corrosion_strong = {
		name = "Venom Corrosion", subId = 8334, duration = 20000, description = "+40% poison penetration (Corrosive Rain).",
		params = {[CONDITION_PARAM_PENETRATION_EARTH] = 40}
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

Necro.shellArea = createCombatArea(AREA_CIRCLE2X2)

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
		-- glyph of Unholy Frenzy: .frenzy = multiplier (Dire Frenzy), .leech = % of the damage of the attack that heals the summon
		local frenzy = Necro.glyph(master, "unholy frenzy")
		local multiplier = frenzy and frenzy.frenzy or Necro.frenzyMultiplier
		min, max = math.floor(min * multiplier), math.floor(max * multiplier)
		if(frenzy and frenzy.leech and isCreature(summon) and getCreatureHealth(summon) > 0) then
			doCreatureAddHealth(summon, math.max(1, math.floor((min + max) / 2 * frenzy.leech / 100)))
		end
	end

	-- glyph of the spell that raised the summon: .summonDamage = multiplier of every attack (Bone Fencer)
	local own = Necro.ownerGlyph(summon)
	if(own and own.summonDamage) then
		min, max = math.floor(min * own.summonDamage), math.floor(max * own.summonDamage)
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
