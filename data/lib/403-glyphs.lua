-- Glyphs: every attack spell of the sorcerer and of the paladin has two glyphs (A and B); the player picks ONE of them to change the spell.
-- Glyphs are bought with bestiary points (see doc/sistemas/04-bestiary.md); swapping to the other glyph costs only gold.
-- See doc/sistemas/42-glifos.md. Everything that can be tuned is in config.lua (glyph* keys).
--
-- Glyphs.spell(name)                 spell entry by name (nil if it has no glyphs)
-- Glyphs.get(cid, key)               the active glyph of the player for a spell key ("attack/flame strike"): glyph table, "A" | "B"
-- Glyphs.multiplier(cid, key, kind)  damage / healing multiplier of the active glyph (1 without glyph), used by SpellBalance
-- Glyphs.cost(spell)                 price in bestiary points of a glyph of that spell
-- Glyphs.requiredLevel(spell)        player level needed
-- Glyphs.swapGold(spell)             gold to swap the chosen glyph
-- Glyphs.freePoints(cid)             bestiary points not spent yet
-- Glyphs.choose(cid, spell, letter)  buys (points) or swaps (gold) the glyph. Returns true, message or false, reason
--
-- HOW TO DESIGN A GLYPH (fill the "glyphs" table of a spell below):
--   glyphs = {
--     A = {name = "Ember Trail", description = "what it does, in words (shown to the player)", descriptionPt = "o mesmo em portugues (opcional, sem acentos)", damage = 1.15},
--     B = {name = "...", description = "...", cooldown = ...}
--   }
--   damage / healing = multiplier applied by SpellBalance automatically. Anything else (burn, area, converted element...)
--   is read by the spell script: local glyph = Glyphs.get(cid, "attack/flame strike") and then glyph.<field>.
--   A spell with an empty "glyphs" table cannot be bought yet.
--
-- The ORDER of Glyphs.spells defines the storage of each spell (glyphStorageBase + position): never reorder, add at the end.

Glyphs = {
	vocations = {1, 3} -- base vocations (data/XML/vocations.xml) that have glyphs: 1 = sorcerer, 3 = paladin (promotions follow)
}

-- name, key (script in data/spells/scripts, no extension), level (lvl in spells.xml), the glyphs and vocation (base vocation that
-- can use them: 1 = sorcerer when omitted, 3 = paladin)
Glyphs.spells = {
	{name = "Flame Strike", key = "attack/flame strike", level = 12, glyphs = {
		-- names are provisional
		A = {name = "Kinetic Flame", description = "+15% damage and a 30% chance to push the target 1 sqm away from you.",
			descriptionPt = "+15% de dano e 30% de chance de empurrar o alvo 1 sqm para longe de voce.",
			damage = 1.15, push = {chance = 30}},
		B = {name = "Cross Flame", description = "The strike also hits the 4 sqm around the target (a cross of 5 sqm).",
			descriptionPt = "O golpe tambem atinge os 4 sqm ao redor do alvo (uma cruz de 5 sqm).",
			area = "plus"}
	}},
	{name = "Energy Strike", key = "attack/energy strike", level = 12, glyphs = {
		-- names are provisional. damage = multiplier of EACH hit: 3 hits of 1.3 / 3 = 130% of the original in total
		A = {name = "Triple Thunder", description = "Strikes 3 times, once every 0.2 seconds, for a total of 130% of the original damage.",
			descriptionPt = "Golpeia 3 vezes, uma a cada 0,2 segundo, num total de 130% do dano original.",
			damage = 1.3 / 3, multi = {hits = 3, interval = 200}},
		-- damage = share of the original damage of each ricochet, range = sqm from the last creature hit, delay = ms between jumps
		B = {name = "Chain Lightning", description = "The lightning jumps to up to 2 more creatures within 3 sqm of the last one hit, each ricochet dealing 70% of the damage.",
			descriptionPt = "O raio salta para ate 2 criaturas a mais, a ate 3 sqm da ultima atingida, e cada ricochete causa 70% do dano.",
			chain = {bounces = 2, damage = 0.7, range = 3, delay = 150}}
	}},
	{name = "Terra Strike", key = "attack/terra strike", level = 13, glyphs = {
		-- names and numbers are provisional.
		-- poison: percent of the damage of the hit, paid in `ticks` hits, one every `interval` ms
		A = {name = "Toxic Earth", description = "Poisons the target for 50% of the damage of the strike, over 6 seconds.",
			descriptionPt = "Envenena o alvo com 50% do dano do golpe, ao longo de 6 segundos.",
			poison = {percent = 50, ticks = 6, interval = 1000}},
		-- resist: points of earth resistance taken from the monster for `duration` ms (before the hit, so the hit already benefits)
		B = {name = "Withering Earth", description = "Lowers the earth resistance of the monster by 10% for 10 seconds.",
			descriptionPt = "Reduz em 10% a resistencia a terra do monstro por 10 segundos.",
			resist = {percent = 10, duration = 10000}}
	}},
	{name = "Ice Strike", key = "attack/ice strike", level = 15, glyphs = {
		-- paralyze: slow in % (0.95 = almost stopped) for `duration` ms
		A = {name = "Glacial Grip", description = "Paralyzes the target for 1.5 seconds.",
			descriptionPt = "Paralisa o alvo por 1,5 segundo.",
			paralyze = {percent = 0.95, duration = 1500}},
		-- pierce: the strike goes through the target and hits everyone on its path, up to `length` sqm from you (walls stop it)
		B = {name = "Frost Lance", description = "The ice goes through the target and hits every creature on its path, up to 6 sqm from you.",
			descriptionPt = "O gelo atravessa o alvo e atinge todas as criaturas no caminho, ate 6 sqm de voce.",
			pierce = {length = 6}}
	}},
	{name = "Death Strike", key = "attack/death strike", level = 16, glyphs = {
		-- names and numbers are provisional
		A = {name = "Withering Death", description = "Lowers the death resistance of the monster by 10% for 10 seconds.",
			descriptionPt = "Reduz em 10% a resistencia a morte do monstro por 10 segundos.",
			resist = {percent = 10, duration = 10000}},
		-- curse: percent of the damage of the hit, paid in `ticks` hits, one every `interval` ms (darkness damage over time)
		B = {name = "Dark Curse", description = "Curses the target: 50% of the damage of the strike again as darkness damage over 10 seconds.",
			descriptionPt = "Amaldicoa o alvo: mais 50% do dano do golpe como dano de trevas, ao longo de 10 segundos.",
			curse = {percent = 50, ticks = 5, interval = 2000}}
	}},
	{name = "Fire Wave", key = "attack/fire wave", level = 18, glyphs = {
		-- names and numbers are provisional
		A = {name = "Great Wave", description = "A bigger wave: 1 more sqm of range and 2 more sqm of width at the far end.",
			descriptionPt = "Uma onda maior: 1 sqm a mais de alcance e 2 sqm a mais de largura na ponta.",
			wide = true},
		-- burn: percent of the average damage of the spell, paid in `ticks` hits, one every `interval` ms
		B = {name = "Scorching Wave", description = "Every creature hit burns for 50% of the average damage of the wave, over 10 seconds.",
			descriptionPt = "Toda criatura atingida queima por 50% do dano medio da onda, ao longo de 10 segundos.",
			burn = {percent = 50, ticks = 5, interval = 2000}}
	}},
	{name = "Energy Beam", key = "attack/energy beam", level = 23, glyphs = {
		-- names and numbers are provisional
		A = {name = "Overcharged Beam", description = "+15% damage.",
			descriptionPt = "+15% de dano.", damage = 1.15},
		-- haste: chance in % per cast and duration in ms (same speed bonus as the Haste spell, +30%)
		B = {name = "Static Rush", description = "25% chance to gain haste (+30% speed) for 5 seconds each time you cast the spell.",
			descriptionPt = "25% de chance de ganhar haste (+30% de velocidade) por 5 segundos cada vez que voce lanca a magia.",
			haste = {chance = 25, duration = 5000}}
	}},
	{name = "Thunderstorm", key = "attack/thunderstorm", level = 28, glyphs = {
		-- names and numbers are provisional
		-- chain: every enemy hit throws a lightning to up to `bounces` creatures that were not hit yet (damage = share of the spell)
		A = {name = "Storm Web", description = "The area is 1 sqm smaller, but every enemy hit throws a chain lightning (up to 2 jumps, 50% damage each) to creatures that were not hit.",
			descriptionPt = "A area fica 1 sqm menor, mas cada inimigo atingido solta um chain lightning (ate 2 saltos, 50% do dano cada) para criaturas que nao foram atingidas.",
			small = true, chain = {bounces = 2, damage = 0.5, range = 3, delay = 150}},
		-- zone: chance (%) of each tile hit to keep zapping: `ticks` hits, one every `interval` ms, 150% of the damage of the spell in total
		B = {name = "Lingering Storm", description = "Each tile hit has a 20% chance to keep zapping 10 times over 5 seconds, for 150% of the damage of the spell in total.",
			descriptionPt = "Cada tile atingido tem 20% de chance de continuar dando choques 10 vezes ao longo de 5 segundos, num total de 150% do dano da magia.",
			zone = {chance = 20, ticks = 10, interval = 500, percent = 150}}
	}},
	{name = "Great Energy Beam", key = "attack/great energy beam", level = 29, glyphs = {
		-- names and numbers are provisional (designed by Claude, not by the owner)
		-- long: a longer beam (10 sqm instead of 7) and a damage multiplier
		A = {name = "Longshot Beam", description = "The beam reaches 10 sqm instead of 7 and deals 10% more damage.",
			descriptionPt = "O feixe alcanca 10 sqm em vez de 7 e causa 10% mais dano.",
			long = true, damage = 1.1},
		-- resist: points of energy resistance taken from every monster hit for `duration` ms
		B = {name = "Conductive Beam", description = "Monsters hit lose 15% energy resistance for 8 seconds.",
			descriptionPt = "Monstros atingidos perdem 15% de resistencia a energia por 8 segundos.",
			resist = {percent = 15, duration = 8000}}
	}},
	{name = "Great Fireball", key = "attack/great fireball", level = 30, glyphs = {
		-- names and numbers are provisional
		A = {name = "Compact Fireball", description = "The area is 1 sqm smaller (5x5 instead of 7x7), but the damage is 15% higher.",
			descriptionPt = "A area fica 1 sqm menor (5x5 em vez de 7x7), mas o dano e 15% maior.",
			small = true, damage = 1.15},
		-- burnBonus: creatures that are burning take an extra hit of this % of the damage of the spell
		B = {name = "Kindling", description = "Creatures that are burning take 15% more damage.",
			descriptionPt = "Criaturas que estao queimando recebem 15% a mais de dano.",
			burnBonus = {percent = 15}}
	}},
	{name = "Energy Wave", key = "attack/energy wave", level = 38, glyphs = {
		-- names and numbers are provisional (designed by Claude, not by the owner)
		-- push: every creature hit is pushed 1 sqm away from you (the farthest first); see data/lib/404-push.lua
		A = {name = "Shockwave", description = "Every creature hit is pushed 1 sqm away from you.",
			descriptionPt = "Toda criatura atingida e empurrada 1 sqm para longe de voce.",
			push = {chance = 100}},
		-- siphon: mana back for each enemy hit (up to `targets`), a percent of the average damage of the wave
		B = {name = "Mana Siphon", description = "You recover mana for each enemy hit (up to 5): 5% of the average damage of the wave for each one.",
			descriptionPt = "Voce recupera mana por cada inimigo atingido (ate 5): 5% do dano medio da onda para cada um.",
			siphon = {percent = 5, targets = 5}}
	}},
	{name = "Rage of the Skies", key = "attack/rage of the skies", level = 55, glyphs = {
		-- names and numbers are provisional
		-- rain: replaces the blast by `drops` bolts that fall at random moments of `duration` ms on random tiles within `radius`
		-- sqm of you (each one hits a cross of 5 sqm); share = fraction of the damage of the spell that each bolt deals
		A = {name = "Skyfall", description = "Instead of the blast, 30 lightning bolts fall at random around you for 5 seconds.",
			descriptionPt = "No lugar da explosao, 30 raios caem aleatoriamente ao seu redor por 5 segundos.",
			rain = {radius = 6, drops = 30, duration = 5000, flight = 250, share = 0.8, combatType = COMBAT_ENERGYDAMAGE,
				animation = CONST_ANI_ENERGY, effect = CONST_ME_ENERGYHIT}},
		-- buff: after the blast, for `duration` ms: critical chance %, dodge %, energy damage % (elemental amplification) and
		-- haste (0.7 = the same as Strong Haste)
		B = {name = "Storm Rage", description = "After the blast you get, for 10 seconds: +15% critical chance, +15% dodge, +25% energy damage and a lot of speed.",
			descriptionPt = "Depois da explosao voce ganha, por 10 segundos: +15% de chance de critico, +15% de esquiva, +25% de dano de energia e muita velocidade.",
			buff = {duration = 10000, critical = 15, dodge = 15, amp = 25, haste = 0.7}}
	}},
	{name = "Hells Core", key = "attack/hells core", level = 60, glyphs = {
		-- names and numbers are provisional
		-- summon: one creature next to each enemy hit (up to `max`), for `duration` ms, that depends on the level of the caster
		-- (the highest tier whose level you reached)
		A = {name = "Infernal Legion", description = "Every enemy hit gets an infernal creature that fights for you for 6 seconds (up to 10). Its kind depends on your level.",
			descriptionPt = "Cada inimigo atingido ganha uma criatura infernal que luta por voce por 6 segundos (ate 10). O tipo depende do seu nivel.",
			summon = {duration = 6000, max = 10, effect = CONST_ME_FIREAREA, tiers = {
				{0, "Fire Devil"}, {80, "Fire Elemental"}, {120, "Massive Fire Elemental"}, {160, "Hellfire Fighter"},
				{220, "Hellhound"}, {300, "Demon"}}}},
		-- rain: replaces the blast by meteors (see Rage of the Skies)
		B = {name = "Meteor Storm", description = "Instead of the blast, 24 meteors fall at random around you for 4 seconds.",
			descriptionPt = "No lugar da explosao, 24 meteoros caem aleatoriamente ao seu redor por 4 segundos.",
			rain = {radius = 5, drops = 24, duration = 4000, flight = 300, share = 0.75, combatType = COMBAT_FIREDAMAGE,
				animation = CONST_ANI_FIRE, effect = CONST_ME_FIREAREA}}
	}},

	-- --- paladin (vocation = 3). Names and numbers are provisional (designed by Claude, not by the owner) ---
	{name = "Ethereal Spear", key = "attack/ethereal spear", level = 23, vocation = 3, glyphs = {
		-- pierce: the spear goes through the target and hits everyone on the line, up to `length` sqm from you (walls stop it)
		A = {name = "Piercing Lance", description = "The spear goes through the target and hits every creature on its path, up to 5 sqm from you.",
			descriptionPt = "A lanca atravessa o alvo e atinge todas as criaturas no caminho, ate 5 sqm de voce.",
			pierce = {length = 5}},
		-- execute: the hit deals `damage` times more when the target has `below`% of its health or less
		B = {name = "Executioner", description = "The spear deals 50% more damage to targets with 30% health or less.",
			descriptionPt = "A lanca causa 50% a mais de dano em alvos com 30% de vida ou menos.",
			execute = {below = 30, damage = 1.5}}
	}},
	{name = "Divine Missile", key = "attack/divine missile", level = 40, vocation = 3, glyphs = {
		-- damage = multiplier of EACH hit: 2 hits of 1.3 / 2 = 130% of the original in total
		A = {name = "Twin Missile", description = "Fires 2 missiles, 0.25 seconds apart, for a total of 130% of the original damage.",
			descriptionPt = "Dispara 2 misseis, com 0,25 segundo de intervalo, num total de 130% do dano original.",
			damage = 1.3 / 2, multi = {hits = 2, interval = 250}},
		-- resist: percent of holy resistance taken from the monster for `duration` ms (before the hit, so the hit already benefits)
		B = {name = "Sanctified Mark", description = "Lowers the holy resistance of the monster by 10% for 10 seconds.",
			descriptionPt = "Reduz em 10% a resistencia a sagrado do monstro por 10 segundos.",
			resist = {percent = 10, duration = 10000}}
	}},
	{name = "Divine Caldera", key = "attack/divine caldera", level = 50, vocation = 3, glyphs = {
		-- zone: chance (%) of each tile hit to turn into holy ground: `ticks` hits, one every `interval` ms, `percent`% of the
		-- damage of the spell in total
		A = {name = "Hallowed Ground", description = "The area stays holy for 5 seconds: it keeps hurting for 80% of the damage of the spell in total.",
			descriptionPt = "A area continua sagrada por 5 segundos: segue causando dano, 80% do dano da magia no total.",
			zone = {chance = 100, ticks = 5, interval = 1000, percent = 80}},
		-- push: every creature hit is pushed 1 sqm away from you (the farthest first); see data/lib/404-push.lua
		B = {name = "Repelling Light", description = "Every creature hit is pushed 1 sqm away from you.",
			descriptionPt = "Toda criatura atingida e empurrada 1 sqm para longe de voce.",
			push = {chance = 100}}
	}},
	{name = "Divine Grenade", key = "attack/divine grenade", level = 82, vocation = 3, glyphs = {
		-- twin: a second blast on the same spot `delay` ms after the first, with `percent`% of the damage
		A = {name = "Twin Grenade", description = "A second blast hits the same spot 1.5 seconds after the first, for 60% of the damage.",
			descriptionPt = "Uma segunda explosao atinge o mesmo local 1,5 segundo depois da primeira, com 60% do dano.",
			twin = {delay = 1500, percent = 60}},
		-- paralyze: slow in % (0.95 = almost stopped) for `duration` ms, on every creature hit
		B = {name = "Blinding Flash", description = "Every creature hit is paralyzed for 2 seconds.",
			descriptionPt = "Toda criatura atingida fica paralisada por 2 segundos.",
			paralyze = {percent = 0.95, duration = 2000}}
	}},
	{name = "Strong Ethereal Spear", key = "attack/strong ethereal spear", level = 90, vocation = 3, glyphs = {
		A = {name = "Impaling Lance", description = "The spear goes through the target and hits every creature on its path, up to 7 sqm from you, with 10% more damage.",
			descriptionPt = "A lanca atravessa o alvo e atinge todas as criaturas no caminho, ate 7 sqm de voce, com 10% a mais de dano.",
			pierce = {length = 7}, damage = 1.1},
		B = {name = "Hunter's Mark", description = "Lowers the physical resistance of the monster by 10% for 10 seconds.",
			descriptionPt = "Reduz em 10% a resistencia fisica do monstro por 10 segundos.",
			resist = {percent = 10, duration = 10000}}
	}}
}

local byName, byKey = {}, {}
for index, spell in ipairs(Glyphs.spells) do
	spell.index = index
	spell.vocation = spell.vocation or 1
	byName[spell.name:lower()] = spell
	byKey[spell.key] = spell
end

local function cfg(key, default)
	local value = getConfigValue(key)
	if(value == nil or value == "") then
		return default
	end

	return value
end

local function cfgNumber(key, default)
	return tonumber(cfg(key, default)) or default
end

function Glyphs.enabled()
	return getBooleanFromString(cfg("glyphsEnabled", true))
end

function Glyphs.spell(name)
	return byName[tostring(name or ""):lower()]
end

function Glyphs.spellByKey(key)
	return byKey[key]
end

-- --- storages ----------------------------------------------------------------------------------------------------

local function base()
	return cfgNumber("glyphStorageBase", 56200)
end

function Glyphs.spentPoints(cid)
	return math.max(0, getPlayerStorageValue(cid, base()))
end

-- points given by the staff command /glyph (tests): storage glyphStorageBase + 60
function Glyphs.bonusPoints(cid)
	return math.max(0, getPlayerStorageValue(cid, base() + 60))
end

function Glyphs.earnedPoints(cid)
	return (getPlayerBestiaryPoints(cid) or 0) + Glyphs.bonusPoints(cid)
end

-- staff: forces a glyph (no cost, no requirements). letter nil/"" removes it
function Glyphs.force(cid, spell, letter)
	local number = letter == "A" and 1 or (letter == "B" and 2 or 0)
	setPlayerStorageValue(cid, base() + spell.index, number)
end

-- staff: back to the start (no glyphs, nothing spent, no bonus points)
function Glyphs.resetAll(cid)
	for _, spell in ipairs(Glyphs.spells) do
		setPlayerStorageValue(cid, base() + spell.index, 0)
	end

	setPlayerStorageValue(cid, base(), 0)
	setPlayerStorageValue(cid, base() + 60, 0)
end

function Glyphs.freePoints(cid)
	return math.max(0, Glyphs.earnedPoints(cid) - Glyphs.spentPoints(cid))
end

-- 0 = none, 1 = glyph A, 2 = glyph B
local function chosen(cid, spell)
	return math.max(0, getPlayerStorageValue(cid, base() + spell.index))
end

local letters = {[1] = "A", [2] = "B"}

function Glyphs.chosenLetter(cid, spell)
	return letters[chosen(cid, spell)]
end

-- --- prices ------------------------------------------------------------------------------------------------------

local function overrides()
	local result = {}
	for name, value in tostring(cfg("glyphCostOverrides", "")):gmatch("%s*([^=,]+)%s*=%s*(%d+)") do
		result[name:gsub("%s+$", ""):lower()] = tonumber(value)
	end

	return result
end

-- sum of the levels of the spells of one vocation (the budget of each vocation is shared among its own spells)
function Glyphs.totalLevels(vocation)
	local total = 0
	for _, spell in ipairs(Glyphs.spells) do
		if(not vocation or spell.vocation == vocation) then
			total = total + spell.level
		end
	end

	return total
end

-- points of a glyph: the override of config.lua, or the share of the budget (glyphBudgetPercent of all the bestiary
-- points) that belongs to the spell, proportional to the spell level
function Glyphs.cost(spell)
	local fixed = overrides()[spell.name:lower()]
	if(fixed) then
		return fixed
	end

	local budget = getBestiaryTotalPoints() * cfgNumber("glyphBudgetPercent", 20) / 100
	return math.max(1, math.floor(budget * spell.level / Glyphs.totalLevels(spell.vocation) + 0.5))
end

function Glyphs.requiredLevel(spell)
	return math.floor(spell.level * cfgNumber("glyphLevelMultiplier", 4))
end

function Glyphs.swapGold(spell)
	return math.floor(spell.level * cfgNumber("glyphSwapGoldPerSpellLevel", 50000))
end

-- --- use in the spells -------------------------------------------------------------------------------------------

local function baseVocation(cid)
	local voc = getPlayerVocation(cid)
	local info = getVocationInfo(voc)
	if(info and info.fromVocation and info.fromVocation ~= voc) then
		return info.fromVocation
	end

	return voc
end

-- the staff (access 4+, to test the glyphs with any character) and the vocation of the spell (any glyph vocation when no spell)
function Glyphs.canUse(cid, spell)
	if(getPlayerAccess(cid) >= 4) then
		return true
	end

	if(spell) then
		return baseVocation(cid) == spell.vocation
	end

	return isInArray(Glyphs.vocations, baseVocation(cid))
end

-- the spells whose glyphs the player can use (the staff sees all of them)
function Glyphs.spellsOf(cid)
	local list = {}
	for _, spell in ipairs(Glyphs.spells) do
		if(Glyphs.canUse(cid, spell)) then
			table.insert(list, spell)
		end
	end

	return list
end

-- active glyph of the player for a spell key: glyph table and "A" | "B" (nothing when there is none)
function Glyphs.get(cid, key)
	local spell = byKey[key]
	if(not spell or not Glyphs.enabled() or not isPlayer(cid) or not Glyphs.canUse(cid, spell)) then
		return nil
	end

	local letter = Glyphs.chosenLetter(cid, spell)
	local glyph = letter and spell.glyphs[letter]
	if(not glyph) then
		return nil
	end

	return glyph, letter
end

-- the creature a target spell was aimed at: the selected target, or whoever is on the tile in front of the caster (0 if none)
function Glyphs.aimed(var)
	local target = variantToNumber(var)
	if(target and target > 0) then
		return target
	end

	local pos = variantToPosition(var)
	if(pos and pos.x and pos.x > 0) then
		pos.stackpos = STACKPOS_TOP_CREATURE
		local creature = getThingFromPos(pos)
		if(creature and creature.uid and creature.uid > 0 and isCreature(creature.uid)) then
			return creature.uid
		end
	end

	return 0
end

-- tiles of the line that starts next to `from` and goes through `aim`, up to `length` sqm. Stops at walls (blocked sight) and at
-- tiles that do not exist (used by the piercing glyphs)
function Glyphs.linePositions(from, aim, length)
	local dx, dy = aim.x - from.x, aim.y - from.y
	local steps = math.max(math.abs(dx), math.abs(dy))
	if(steps == 0) then
		return {}
	end

	local list = {}
	for i = 1, length do
		local pos = {x = from.x + math.floor(dx * i / steps + 0.5), y = from.y + math.floor(dy * i / steps + 0.5), z = from.z}
		if(not getTileInfo(pos) or not isSightClear(from, pos, false)) then
			break
		end

		table.insert(list, pos)
	end

	return list
end

-- true if the creature is something the caster can hit with a glyph effect that picks targets by itself (ricochets...):
-- no npcs, party members, own summons or creatures in protection zones
function Glyphs.isEnemy(cid, tid)
	return Archer.valid(cid, tid)
end

-- --- effects shared by the glyphs ------------------------------------------------------------------------------------

-- setCombatCallback with a function (local, closure...). The server forgets a global function once it is registered as a
-- callback, so every registration needs its own global name: this creates one and registers it
local callbackCount = 0
function Glyphs.setCallback(combat, callbackKey, handler)
	callbackCount = callbackCount + 1
	local name = "__glyphCallback" .. callbackCount
	_G[name] = handler
	return setCombatCallback(combat, callbackKey, name)
end

-- rain of projectiles around the caster (meteors, lightning...): `drops` projectiles fall at random moments of `duration` ms, each
-- on a random tile within `radius` sqm that exists, is outside protection zones and is in sight of the caster, and hits `area`
-- (a combat area id the spell script creates, such as createCombatArea(AREA_CROSS1X1)) after `flight` ms.
-- config = {radius, drops, duration, flight, share, combatType, animation, effect [, offset, height]}
--   share   fraction of the damage of the spell (its formula) that each projectile deals
-- values(cid) gives the min and max of the formula of the spell (positive); SpellBalance is applied on top
local function rainLand(cid, key, values, config, area, pos)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	local min, max = values(cid)
	doAreaCombatHealth(cid, config.combatType, pos, area, SpellBalance.scale(cid, key, -min * config.share),
		SpellBalance.scale(cid, key, -max * config.share), config.effect)
end

local function rainDrop(cid, key, values, config, area)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	local from, radius = getCreaturePosition(cid), config.radius
	for attempt = 1, 6 do
		local dx, dy = math.random(-radius, radius), math.random(-radius, radius)
		if(dx * dx + dy * dy <= radius * radius + 1) then
			local pos = {x = from.x + dx, y = from.y + dy, z = from.z}
			local info = getTileInfo(pos)
			if(type(info) == "table" and not info.protection and isSightClear(from, pos, false)) then
				VFX.SkyFall(pos, config.animation, {offsetX = config.offset or -4, height = config.height or 4})
				addEvent(rainLand, config.flight, cid, key, values, config, area, pos)
				return
			end
		end
	end
end

function Glyphs.rain(cid, key, values, config, area)
	for i = 1, config.drops do
		addEvent(rainDrop, math.random(0, config.duration), cid, key, values, config, area)
	end
end

-- creatures that fight for the caster for `duration` ms: one at each of the positions (up to `max`), whose kind depends on the
-- level of the caster. config = {duration, max, tiers = {{minimum level, "Monster Name"}, ...} (ascending levels), effect}
function Glyphs.summonTier(cid, tiers)
	local level, name = getPlayerLevel(cid), tiers[1][2]
	for _, tier in ipairs(tiers) do
		if(level >= tier[1]) then
			name = tier[2]
		end
	end

	return name
end

local function dismiss(id)
	if(isCreature(id)) then
		doSendMagicEffect(getCreaturePosition(id), CONST_ME_POFF)
		doRemoveCreature(id)
	end
end

function Glyphs.summonAt(cid, positions, config)
	local name, created = Glyphs.summonTier(cid, config.tiers), 0
	for _, pos in ipairs(positions) do
		if(created >= config.max or not isCreature(cid)) then
			break
		end

		local summon = doCreateMonster(name, pos, true, false)
		if(summon) then
			if(doConvinceCreature(cid, summon)) then
				created = created + 1
				doSendMagicEffect(getCreaturePosition(summon), config.effect or CONST_ME_FIREAREA)
				addEvent(dismiss, config.duration, summon)
			else
				doRemoveCreature(summon)
			end
		end
	end

	return created
end

-- chain lightning: from `fromPos` it jumps to the closest enemy that is not in the set `hit` (creature id -> true, filled as the
-- chain goes), within config.range sqm and in sight, hits it with `chainCombat` (a combat object of the script with the damage
-- of the ricochet already scaled), draws the jump, and goes on from there until `left` jumps are used. config = {range, delay,
-- animation}. Use it with addEvent(Glyphs.ricochet, config.delay, cid, fromPos, hit, bounces, config, chainCombat)
function Glyphs.ricochet(cid, fromPos, hit, left, config, chainCombat)
	if(left <= 0 or not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	local range = config.range or 3
	local best, bestDistance
	for _, tid in ipairs(getSpectators(fromPos, range, range, false) or {}) do
		if(not hit[tid] and isCreature(tid) and Glyphs.isEnemy(cid, tid)) then
			local pos = getCreaturePosition(tid)
			local distance = getDistanceBetween(fromPos, pos)
			if(distance <= range and isSightClear(fromPos, pos, true) and (not best or distance < bestDistance)) then
				best, bestDistance = tid, distance
			end
		end
	end

	if(not best) then
		return
	end

	hit[best] = true
	local toPos = getCreaturePosition(best)
	if(not doCombat(cid, chainCombat, numberToVariant(best))) then
		-- not allowed to hit this one (pvp rules...): try the next closest without using a jump
		return Glyphs.ricochet(cid, fromPos, hit, left, config, chainCombat)
	end

	doSendDistanceShoot(fromPos, toPos, config.animation or CONST_ANI_ENERGY)
	addEvent(Glyphs.ricochet, config.delay or 150, cid, toPos, hit, left - 1, config, chainCombat)
end

-- damage over time (CONDITION_POISON, CONDITION_CURSED...) that deals `total` damage in `ticks` hits, one every `interval` ms.
-- Returns false if the target is not allowed/immune
function Glyphs.dot(cid, target, conditionType, total, ticks, interval)
	local condition = createConditionObject(conditionType)
	setConditionParam(condition, CONDITION_PARAM_DELAYED, 1)
	addDamageCondition(condition, ticks, interval, -math.max(1, math.ceil(total / ticks)))
	return doTargetCombatCondition(cid, target, condition, CONST_ME_NONE)
end

function Glyphs.poison(cid, target, total, ticks, interval)
	return Glyphs.dot(cid, target, CONDITION_POISON, total, ticks, interval)
end

function Glyphs.curse(cid, target, total, ticks, interval)
	return Glyphs.dot(cid, target, CONDITION_CURSED, total, ticks, interval)
end

-- "rolled" damage, for glyphs that need to know how much the hit did (a dot that is a percent of it...).
-- Glyphs.defineRoll("globalFunctionName", "attack/some spell", "glyphField") creates the level/magic callback of a strike
-- (same formula as setCombatFormula(-1, -10, -1, -20, 5, 5, 1.4, 2.1)) that rolls the damage by itself while the player has a
-- glyph with that field; the script uses it with setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, "globalFunctionName")
-- and, after doCombat, Glyphs.takeRoll(cid, key) gives the damage dealt (positive, with SpellBalance applied) or nil.
local rolls = {}
function Glyphs.defineRoll(name, key, field)
	_G[name] = function(cid, level, maglevel)
		local min = -(level / 5 + maglevel * 1.4) - 10
		local max = -(level / 5 + maglevel * 2.1) - 20

		local glyph = Glyphs.get(cid, key)
		if(glyph and glyph[field]) then
			local value = math.random(math.floor(math.min(min, max)), math.floor(math.max(min, max)))
			rolls[cid] = value
			return value, value
		end

		return min, max
	end
end

function Glyphs.takeRoll(cid, key)
	local value = rolls[cid]
	rolls[cid] = nil
	if(not value) then
		return nil
	end

	return math.abs(SpellBalance and SpellBalance.scale(cid, key, value) or value)
end

function Glyphs.clearRoll(cid)
	rolls[cid] = nil
end

-- "paralysis": slows the target by `percent` (0.95 = 95%) for `ms`. Monsters immune to paralysis are not affected
function Glyphs.paralyze(cid, target, percent, ms)
	local condition = createConditionObject(CONDITION_PARALYZE)
	setConditionParam(condition, CONDITION_PARAM_TICKS, ms)
	setConditionFormula(condition, -percent, 0, -percent, 0)
	return doTargetCombatCondition(cid, target, condition, CONST_ME_NONE)
end

-- elemental resistance (the same CONDITION_PARAM_ABSORB_* of the blessings) per damage type, and the subId of the condition
-- of each one (8700 + param), so every element has its own condition and they do not replace each other
local absorbParams = {
	[COMBAT_PHYSICALDAMAGE] = CONDITION_PARAM_ABSORB_PHYSICAL, [COMBAT_ENERGYDAMAGE] = CONDITION_PARAM_ABSORB_ENERGY,
	[COMBAT_EARTHDAMAGE] = CONDITION_PARAM_ABSORB_EARTH, [COMBAT_FIREDAMAGE] = CONDITION_PARAM_ABSORB_FIRE,
	[COMBAT_ICEDAMAGE] = CONDITION_PARAM_ABSORB_ICE, [COMBAT_HOLYDAMAGE] = CONDITION_PARAM_ABSORB_HOLY,
	[COMBAT_DEATHDAMAGE] = CONDITION_PARAM_ABSORB_DEATH, [COMBAT_DROWNDAMAGE] = CONDITION_PARAM_ABSORB_DROWN
}

-- the monster takes `percent` more damage of that element for `ms` (its resistance goes down by that many points): a
-- CONDITION_ATTRIBUTES with a negative CONDITION_PARAM_ABSORB_*, read by Monster::blockHit. Only monsters (on players a
-- negative resistance is ignored). Casting it again renews it. Remove it with Glyphs.restoreResistance
function Glyphs.reduceResistance(target, combatType, percent, ms)
	local param = absorbParams[combatType]
	if(not param or not isMonster(target)) then
		return false
	end

	local condition = createConditionObject(CONDITION_ATTRIBUTES, ms, true, 8700 + param)
	setConditionParam(condition, param, -percent)
	return doAddCondition(target, condition)
end

function Glyphs.restoreResistance(target, combatType)
	local param = absorbParams[combatType]
	if(param and isCreature(target)) then
		doRemoveCondition(target, CONDITION_ATTRIBUTES, 8700 + param)
	end
end

-- kind = "damage" | "healing"
function Glyphs.multiplier(cid, key, kind)
	local glyph = Glyphs.get(cid, key)
	return glyph and tonumber(glyph[kind]) or 1
end

-- --- buying / swapping -------------------------------------------------------------------------------------------

function Glyphs.choose(cid, spell, letter)
	letter = tostring(letter or ""):upper()
	local number = letter == "A" and 1 or (letter == "B" and 2 or 0)
	if(number == 0) then
		return false, "Choose glyph A or B."
	end

	if(not Glyphs.enabled()) then
		return false, "The glyph system is disabled."
	end

	if(not Glyphs.canUse(cid, spell)) then
		return false, "Your vocation cannot use the glyphs of this spell."
	end

	local glyph = spell.glyphs[letter]
	if(not glyph) then
		return false, "This glyph is not available yet."
	end

	local required = Glyphs.requiredLevel(spell)
	if(getPlayerLevel(cid) < required) then
		return false, "You need level " .. required .. " to use a glyph of " .. spell.name .. "."
	end

	local current = chosen(cid, spell)
	if(current == number) then
		return false, "You already have this glyph."
	end

	if(current == 0) then
		local cost = Glyphs.cost(spell)
		if(Glyphs.freePoints(cid) < cost) then
			return false, "You need " .. cost .. " bestiary points (you have " .. Glyphs.freePoints(cid) .. ")."
		end

		setPlayerStorageValue(cid, base(), Glyphs.spentPoints(cid) + cost)
		setPlayerStorageValue(cid, base() + spell.index, number)
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
		return true, "You carved the glyph '" .. glyph.name .. "' into " .. spell.name .. " (" .. cost .. " bestiary points)."
	end

	local gold = Glyphs.swapGold(spell)
	if(getPlayerMoney(cid) < gold) then
		return false, "Swapping the glyph of " .. spell.name .. " costs " .. gold .. " gold coins."
	end

	doPlayerRemoveMoney(cid, gold)
	setPlayerStorageValue(cid, base() + spell.index, number)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
	return true, "You swapped the glyph of " .. spell.name .. " for '" .. glyph.name .. "' (" .. gold .. " gold coins)."
end

-- --- texts ---------------------------------------------------------------------------------------------------------

-- description of a glyph in the language of the player (the portuguese one is optional: descriptionPt)
function Glyphs.description(cid, glyph)
	if(glyph.descriptionPt and Language and Language.get(cid) == LANGUAGE_PORTUGUESE) then
		return glyph.descriptionPt
	end

	return glyph.description
end

local function glyphLine(cid, letter, glyph)
	if(not glyph) then
		return "  Glyph " .. letter .. ": not available yet\n"
	end

	return "  Glyph " .. letter .. ": " .. glyph.name .. "\n    " .. glyph.description .. "\n"
end

function Glyphs.describe(cid, spell)
	local text = spell.name .. " (spell level " .. spell.level .. ")\n\n"
	text = text .. glyphLine(cid, "A", spell.glyphs.A) .. glyphLine(cid, "B", spell.glyphs.B) .. "\n"

	local letter = Glyphs.chosenLetter(cid, spell)
	text = text .. "Needs level " .. Glyphs.requiredLevel(spell) .. ". First glyph: " .. Glyphs.cost(spell)
		.. " bestiary points. Swapping: " .. Glyphs.swapGold(spell) .. " gold coins.\n"
	if(letter) then
		text = text .. "Your glyph: " .. letter .. ".\n"
	else
		text = text .. "You have no glyph on this spell.\n"
	end

	return text .. "\nUse !glyphs " .. spell.name:lower() .. " a|b to choose (it asks for confirmation)."
end

function Glyphs.summary(cid)
	local text = "Spell Glyphs\n\nBestiary points: " .. Glyphs.freePoints(cid) .. " free (" .. Glyphs.earnedPoints(cid)
		.. " earned, " .. Glyphs.spentPoints(cid) .. " spent)\nYour level: " .. getPlayerLevel(cid) .. "\n\n"
	for _, spell in ipairs(Glyphs.spellsOf(cid)) do
		local letter = Glyphs.chosenLetter(cid, spell)
		local status
		if(letter and spell.glyphs[letter]) then
			status = "glyph " .. letter .. " (" .. spell.glyphs[letter].name .. ")"
		elseif(not spell.glyphs.A and not spell.glyphs.B) then
			status = "glyphs not available yet"
		else
			status = "no glyph"
		end

		text = text .. spell.name .. " - level " .. Glyphs.requiredLevel(spell) .. ", " .. Glyphs.cost(spell) .. " points - " .. status .. "\n"
	end

	return text .. "\n!glyphs <spell> shows the glyphs of a spell.\n!glyphs <spell> a|b chooses one."
end
