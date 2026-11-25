-- Glyphs: every attack spell of the sorcerer, of the paladin, the druid, the knight, the cleric and every spell of the necromancer and of the assassin has two glyphs (A and B); the player picks ONE of them to change the spell.
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
	vocations = {1, 3, 2, 4, 9, 11, 13, 15} -- base vocations (data/XML/vocations.xml) that have glyphs: 1 = sorcerer, 3 = paladin, 2 = druid, 4 = knight, 9 = cleric, 11 = necromancer, 13 = assassin, 15 = berserker (promotions follow)
}

-- name, key (script in data/spells/scripts, no extension), level (lvl in spells.xml), the glyphs and vocation (base vocation that
-- can use them: 1 = sorcerer when omitted, 3 = paladin, 2 = druid, 4 = knight, 9 = cleric, 11 = necromancer, 13 = assassin)
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
		A = {name = "Skyfall", description = "Instead of the blast, 60 lightning bolts fall at random around you for 5 seconds.",
			descriptionPt = "No lugar da explosao, 60 raios caem aleatoriamente ao seu redor por 5 segundos.",
			rain = {radius = 6, drops = 60, duration = 5000, flight = 250, share = 0.4, combatType = COMBAT_ENERGYDAMAGE,
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
		B = {name = "Meteor Storm", description = "Instead of the blast, 48 meteors fall at random around you for 4 seconds.",
			descriptionPt = "No lugar da explosao, 48 meteoros caem aleatoriamente ao seu redor por 4 segundos.",
			rain = {radius = 5, drops = 48, duration = 4000, flight = 300, share = 0.375, combatType = COMBAT_FIREDAMAGE,
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
	}},

	-- --- druid (vocation = 2). Names and numbers are provisional (designed by Claude, not by the owner) ---
	{name = "Ice Wave", key = "attack/ice wave", level = 18, vocation = 2, glyphs = {
		-- paralyze: slow in % (0.4 = 40% slower) for `duration` ms, on every creature hit
		A = {name = "Frostbite", description = "Every creature hit is slowed by 40% for 4 seconds.",
			descriptionPt = "Toda criatura atingida fica 40% mais lenta por 4 segundos.",
			paralyze = {percent = 0.4, duration = 4000}},
		-- haste: speed of the Haste spell (+30%) for `duration` ms, only if the wave hit at least one enemy
		B = {name = "Glacial Slide", description = "If the wave hits at least 1 enemy you gain haste (+30% speed) for 3 seconds.",
			descriptionPt = "Se a onda atingir pelo menos 1 inimigo voce ganha haste (+30% de velocidade) por 3 segundos.",
			haste = {duration = 3000}}
	}},
	{name = "Stone Shower", key = "attack/stone shower", level = 28, vocation = 2, glyphs = {
		-- stun: chance (%) of each creature hit to be slowed almost to a stop (percent 0.95) for `duration` ms
		A = {name = "Stunning Stones", description = "Each creature hit has a 25% chance to be paralyzed for 1.5 seconds.",
			descriptionPt = "Cada criatura atingida tem 25% de chance de ficar paralisada por 1,5 segundo.",
			stun = {chance = 25, percent = 0.95, duration = 1500}},
		-- armor: % less damage taken by the caster for `duration` ms (buff in !buffs)
		B = {name = "Gravel Armor", description = "For 8 seconds you take 15% less physical and earth damage.",
			descriptionPt = "Por 8 segundos voce recebe 15% menos dano fisico e de terra.",
			armor = {duration = 8000, physical = 15, earth = 15}}
	}},
	{name = "Avalanche", key = "attack/avalanche", level = 30, vocation = 2, glyphs = {
		-- roll: a second impact `distance` sqm farther in the direction of the cast, `delay` ms later, with `percent`% of the damage
		A = {name = "Rolling Avalanche", description = "0.8 seconds later a second impact hits 2 sqm further in the direction of the cast, with 70% of the damage.",
			descriptionPt = "0,8 segundo depois um segundo impacto atinge 2 sqm mais longe na direcao do lancamento, com 70% do dano.",
			roll = {distance = 2, delay = 800, percent = 70}},
		B = {name = "Shatterfrost", description = "Monsters hit lose 15% ice resistance for 8 seconds.",
			descriptionPt = "Monstros atingidos perdem 15% de resistencia a gelo por 8 segundos.",
			resist = {percent = 15, duration = 8000}}
	}},
	{name = "Terra Wave", key = "attack/terra wave", level = 38, vocation = 2, glyphs = {
		-- zone: chance (%) of each tile hit to turn into thorns: `ticks` hits, one every `interval` ms, `percent`% of the damage in total
		A = {name = "Thorn Field", description = "Each tile hit has a 30% chance to turn into thorns for 5 seconds: 120% of the damage of the spell in total.",
			descriptionPt = "Cada tile atingido tem 30% de chance de virar espinhos por 5 segundos: 120% do dano da magia no total.",
			zone = {chance = 30, ticks = 5, interval = 1000, percent = 120}},
		-- regrowth: heals you and the party within `range` sqm for `percent`% of the average damage per enemy hit (up to `targets`)
		B = {name = "Regrowth", description = "For each enemy hit (up to 5) you and your party within 3 sqm recover 4% of the average damage of the wave as health.",
			descriptionPt = "Por cada inimigo atingido (ate 5) voce e sua party num raio de 3 sqm recuperam 4% do dano medio da onda em vida.",
			regrowth = {percent = 4, targets = 5, range = 3}}
	}},
	{name = "Wrath of Nature", key = "attack/wrath of nature", level = 55, vocation = 2, glyphs = {
		-- summon: one creature next to each enemy hit (up to `max`), for `duration` ms, that depends on the level of the caster
		A = {name = "Living Forest", description = "Every enemy hit gets a creature of the forest that fights for you for 8 seconds (up to 10). Its kind depends on your level.",
			descriptionPt = "Cada inimigo atingido ganha uma criatura da floresta que luta por voce por 8 segundos (ate 10). O tipo depende do seu nivel.",
			summon = {duration = 8000, max = 10, effect = CONST_ME_PLANTATTACK, tiers = {
				{0, "Spit Nettle"}, {70, "Carniphila"}, {110, "Haunted Treeling"}, {150, "Earth Elemental"},
				{220, "Massive Earth Elemental"}, {300, "Defiler"}}}},
		-- buff: after the blast, for `duration` ms: earth damage % (elemental amplification) and `regen`% of the maximum health per second
		B = {name = "Primal Fury", description = "After the blast you get, for 10 seconds: +25% earth damage and 1% of your health back every second.",
			descriptionPt = "Depois da explosao voce ganha, por 10 segundos: +25% de dano de terra e 1% da sua vida de volta a cada segundo.",
			buff = {duration = 10000, amp = 25, regen = 1}}
	}},
	{name = "Eternal Winter", key = "attack/eternal winter", level = 60, vocation = 2, glyphs = {
		-- rain: replaces the blast by ice shards that fall around the caster (see Rage of the Skies)
		A = {name = "Hailstorm", description = "Instead of the blast, 60 shards of ice fall at random around you for 5 seconds.",
			descriptionPt = "No lugar da explosao, 60 estilhacos de gelo caem aleatoriamente ao seu redor por 5 segundos.",
			rain = {radius = 5, drops = 60, duration = 5000, flight = 300, share = 0.4, combatType = COMBAT_ICEDAMAGE,
				animation = CONST_ANI_ICE, effect = CONST_ME_ICEAREA}},
		-- ring: replaces the blast by a full disc of ice (no hole in the middle) of `radius` sqm that sweeps around the caster tile by
		-- tile in `sweep` ms (RingAttack, data/lib/069-ringattack.lua), `turns` times in a row; damage = multiplier of EACH turn
		-- applied by SpellBalance: 2 turns of 0.7 = 140% of the original in total
		B = {name = "Glacial Cyclone", description = "Instead of the blast, a disc of ice with 5 sqm of radius sweeps around you twice (1.3 seconds each), tile by tile, for a total of 140% of the original damage.",
			descriptionPt = "No lugar da explosao, um disco de gelo de 5 sqm de raio varre ao seu redor duas vezes (1,3 segundo cada), tile a tile, num total de 140% do dano original.",
			ring = {radius = 5, sweep = 1300, turns = 2}, damage = 1.4 / 2}
	}},
	{name = "Heal Friend", key = "healing/heal friend", level = 18, vocation = 2, glyphs = {
		-- hot: `percent`% of the average healing of the spell again, spread in `ticks` heals, one every `interval` ms
		A = {name = "Rejuvenation", description = "The target heals 40% more, spread over 6 seconds.",
			descriptionPt = "O alvo cura 40% a mais, espalhado ao longo de 6 segundos.",
			hot = {percent = 40, ticks = 6, interval = 1000}},
		-- cleanse: removes every harmful condition of the target; haste: speed of the Haste spell for `duration` ms
		B = {name = "Swift Remedy", description = "Removes every harmful condition (poison, fire, curse...) of the target and gives it haste for 4 seconds.",
			descriptionPt = "Remove toda condicao ruim do alvo (veneno, fogo, maldicao...) e da haste a ele por 4 segundos.",
			cleanse = true, haste = {duration = 4000}}
	}},
	{name = "Mass Healing", key = "healing/mass healing", level = 36, vocation = 2, glyphs = {
		-- ward: every player healed takes `percent`% less damage for `duration` ms (buff in !buffs)
		A = {name = "Verdant Ward", description = "Every player healed takes 10% less damage for 6 seconds.",
			descriptionPt = "Todo jogador curado recebe 10% menos dano por 6 segundos.",
			ward = {percent = 10, duration = 6000}},
		-- wide: the area is 1 sqm bigger (radius 4); healing = multiplier applied by SpellBalance
		B = {name = "Blooming Circle", description = "The area is 1 sqm bigger and the healing is 15% higher.",
			descriptionPt = "A area fica 1 sqm maior e a cura e 15% maior.",
			wide = true, healing = 1.15}
	}},
	{name = "Undead Legion", key = "summon/undead legion", level = 30, vocation = 2, glyphs = {
		-- tiers: the kind of the raised creature depends on the level of the caster (the highest tier whose level you reached)
		A = {name = "Dread Legion", description = "The raised creatures are stronger as you level up: skeletons, then warriors, bone beasts, liches, blightwalkers and undead dragons.",
			descriptionPt = "As criaturas levantadas ficam mais fortes conforme seu nivel: esqueletos, guerreiros, bonebeasts, liches, blightwalkers e dragoes mortos-vivos.",
			tiers = {{0, "Skeleton"}, {60, "Skeleton Warrior"}, {100, "BoneBeast"}, {160, "Lich"}, {240, "Blightwalker"}, {300, "Undead Dragon"}}},
		-- harvest: each creature raised (up to `max`) gives back `percent`% of the maximum health and mana of the caster
		B = {name = "Soul Harvest", description = "Each skeleton raised (up to 5) gives you back 3% of your maximum health and mana.",
			descriptionPt = "Cada esqueleto levantado (ate 5) devolve 3% da sua vida e mana maximas.",
			harvest = {percent = 3, max = 5}}
	}},
	{name = "Wild Growth", key = "support/wild growth rune", level = 27, vocation = 2, glyphs = {
		-- thorns: the wild growth hurts the creatures next to it (3x3): `ticks` pulses, one every `interval` ms
		A = {name = "Thornwall", description = "The wild growth hurts the creatures next to it with earth damage, once per second for 10 seconds.",
			descriptionPt = "A vegetacao fere as criaturas ao lado dela com dano de terra, uma vez por segundo durante 10 segundos.",
			thorns = {ticks = 10, interval = 1000}},
		-- lasting: the wild growth is renewed once, so it lasts about twice as long
		B = {name = "Lasting Growth", description = "The wild growth lasts twice as long.",
			descriptionPt = "A vegetacao dura o dobro do tempo.",
			lasting = true}
	}},

	-- --- knight (vocation = 4). Names and numbers are provisional (designed by Claude, not by the owner) ---
	{name = "Whirlwind Throw", key = "attack/whirlwind throw", level = 15, vocation = 4, glyphs = {
		-- chain: the weapon ricochets to up to `bounces` creatures within `range` sqm of the last one hit (damage = share of the spell)
		A = {name = "Ricochet Throw", description = "The weapon ricochets to up to 2 more enemies within 3 sqm of the last one hit, each ricochet dealing 70% of the damage.",
			descriptionPt = "A arma ricocheteia para ate 2 inimigos a mais, a ate 3 sqm do ultimo atingido, e cada ricochete causa 70% do dano.",
			chain = {bounces = 2, damage = 0.7, range = 3, delay = 150, animation = CONST_ANI_WEAPONTYPE}},
		-- paralyze: slow in % for `duration` ms; resist: points of physical resistance taken from the monster (before the hit)
		B = {name = "Hamstring", description = "The target is slowed by 40% for 4 seconds and loses 10% physical resistance for 6 seconds.",
			descriptionPt = "O alvo fica 40% mais lento por 4 segundos e perde 10% de resistencia fisica por 6 segundos.",
			paralyze = {percent = 0.4, duration = 4000}, resist = {percent = 10, duration = 6000}}
	}},
	{name = "Brutal Strike", key = "attack/brutal strike", level = 16, vocation = 4, glyphs = {
		-- execute: the hit deals `damage` times more when the target has `below`% of its health or less
		A = {name = "Crushing Blow", description = "The strike deals 50% more damage to targets with 30% health or less.",
			descriptionPt = "O golpe causa 50% a mais de dano em alvos com 30% de vida ou menos.",
			execute = {below = 30, damage = 1.5}},
		-- resist: physical resistance taken from the monster; bleed: percent of the damage of the hit, paid in `ticks` hits, one every `interval` ms
		B = {name = "Sundering Strike", description = "The target loses 15% physical resistance for 8 seconds and bleeds for 50% of the damage of the strike, over 10 seconds.",
			descriptionPt = "O alvo perde 15% de resistencia fisica por 8 segundos e sangra por 50% do dano do golpe, ao longo de 10 segundos.",
			resist = {percent = 15, duration = 8000}, bleed = {percent = 50, ticks = 5, interval = 2000}}
	}},
	{name = "Groundshaker", key = "attack/groundshaker", level = 33, vocation = 4, glyphs = {
		-- stun: chance (%) of each creature hit to be slowed almost to a stop (percent 0.95) for `duration` ms
		A = {name = "Tremor", description = "Each creature hit has a 25% chance to be paralyzed for 1.5 seconds.",
			descriptionPt = "Cada criatura atingida tem 25% de chance de ficar paralisada por 1,5 segundo.",
			stun = {chance = 25, percent = 0.95, duration = 1500}},
		-- wide: the area is 1 sqm bigger (radius 4); push: every creature hit is pushed 1 sqm away from you
		B = {name = "Quake Wave", description = "The area is 1 sqm bigger and every creature hit is pushed 1 sqm away from you.",
			descriptionPt = "A area fica 1 sqm maior e toda criatura atingida e empurrada 1 sqm para longe de voce.",
			wide = true, push = {chance = 100}}
	}},
	{name = "Berserk", key = "attack/berserk", level = 35, vocation = 4, glyphs = {
		-- heal: percent of your maximum health back for each creature hit (up to `targets`)
		A = {name = "Bloodlust", description = "You recover 3% of your maximum health for each enemy hit (up to 5).",
			descriptionPt = "Voce recupera 3% da sua vida maxima por inimigo atingido (ate 5).",
			heal = {percent = 3, targets = 5}},
		-- damage = multiplier of EACH hit: 2 hits of 1.3 / 2 = 130% of the original in total
		B = {name = "Rampage", description = "Strikes twice, 0.3 seconds apart, for a total of 130% of the original damage.",
			descriptionPt = "Golpeia 2 vezes, com 0,3 segundo de intervalo, num total de 130% do dano original.",
			damage = 1.3 / 2, multi = {hits = 2, interval = 300}}
	}},
	{name = "Fierce Berserk", key = "attack/fierce berserk", level = 70, vocation = 4, glyphs = {
		-- buff: after the blow, for `duration` ms: physical damage % (elemental amplification) and critical chance %
		A = {name = "Savage Fury", description = "After the blow you get, for 8 seconds: +15% physical damage and +15% critical chance.",
			descriptionPt = "Depois do golpe voce ganha, por 8 segundos: +15% de dano fisico e +15% de chance de critico.",
			buff = {duration = 8000, amp = 15, critical = 15}},
		-- guard: % less damage taken for `duration` ms; resist: physical resistance taken from every creature hit
		B = {name = "Warlord's Roar", description = "After the blow you take 15% less damage for 6 seconds and every creature hit loses 10% physical resistance for 6 seconds.",
			descriptionPt = "Depois do golpe voce recebe 15% menos dano por 6 segundos e toda criatura atingida perde 10% de resistencia fisica por 6 segundos.",
			guard = {duration = 6000, percent = 15}, resist = {percent = 10, duration = 6000}}
	}},
	{name = "Bruise Bane", key = "healing/bruise bane", level = 8, vocation = 4, glyphs = {
		-- hot: `percent`% of the average healing of the spell again, spread in `ticks` heals, one every `interval` ms
		A = {name = "Second Wind", description = "You heal 40% more, spread over 4 seconds.",
			descriptionPt = "Voce cura 40% a mais, espalhado ao longo de 4 segundos.",
			hot = {percent = 40, ticks = 4, interval = 1000}},
		-- armor: % less physical damage taken for `duration` ms (buff in !buffs)
		B = {name = "Hardened Skin", description = "For 5 seconds you take 10% less physical damage.",
			descriptionPt = "Por 5 segundos voce recebe 10% menos dano fisico.",
			armor = {duration = 5000, physical = 10}}
	}},
	{name = "Wound Cleansing", key = "healing/wound cleasing", level = 30, vocation = 4, glyphs = {
		-- cleanse: removes every harmful condition; haste: speed of the Haste spell for `duration` ms
		A = {name = "Purifying Blood", description = "Removes every harmful condition (poison, fire, curse...) and gives you haste for 3 seconds.",
			descriptionPt = "Remove toda condicao ruim (veneno, fogo, maldicao...) e da haste a voce por 3 segundos.",
			cleanse = true, haste = {duration = 3000}},
		-- immune: no paralysis for `duration` ms
		B = {name = "Iron Will", description = "You cannot be paralyzed for 6 seconds.",
			descriptionPt = "Voce nao pode ser paralisado por 6 segundos.",
			immune = {duration = 6000}}
	}},
	{name = "Fair Wound Cleansing", key = "healing/fair wound cleansing", level = 40, vocation = 4, glyphs = {
		A = {name = "Soothing Rest", description = "+15% healing.",
			descriptionPt = "+15% de cura.", healing = 1.15},
		B = {name = "Battle Recovery", description = "Removes every harmful condition (poison, fire, curse...) besides healing.",
			descriptionPt = "Alem de curar, remove toda condicao ruim (veneno, fogo, maldicao...).",
			cleanse = true}
	}},
	{name = "Intense Wound Cleansing", key = "healing/intense wound cleansing", level = 60, vocation = 4, glyphs = {
		-- lastStand: the lower your health, the bigger the heal: up to `bonus`% more when you are almost dead
		A = {name = "Last Stand", description = "The lower your health, the stronger the heal: up to 50% more when you are almost dead.",
			descriptionPt = "Quanto menor a sua vida, mais forte a cura: ate 50% a mais quando voce esta quase morto.",
			lastStand = {bonus = 50}},
		-- shield: % less damage taken from every source for `duration` ms (buff in !buffs)
		B = {name = "Unyielding", description = "After the heal you take 20% less damage for 8 seconds.",
			descriptionPt = "Depois da cura voce recebe 20% menos dano por 8 segundos.",
			shield = {duration = 8000, percent = 20}}
	}},
	{name = "Charge", key = "support/charge", level = 25, vocation = 4, glyphs = {
		-- push: every enemy within `range` sqm of you is pushed 1 sqm away
		A = {name = "Shoulder Charge", description = "Every enemy next to you is pushed 1 sqm away when you charge.",
			descriptionPt = "Todo inimigo ao seu lado e empurrado 1 sqm quando voce avanca.",
			push = {chance = 100, range = 1}},
		-- longer: the speed lasts `duration` ms instead of 5000
		B = {name = "Long Rush", description = "The speed of the charge lasts 8 seconds instead of 5.",
			descriptionPt = "A velocidade da investida dura 8 segundos em vez de 5.",
			longer = {duration = 8000}}
	}},
	{name = "Protector", key = "support/protector", level = 55, vocation = 4, glyphs = {
		-- ward: % less damage taken from every source for `duration` ms (buff in !buffs)
		A = {name = "Iron Wall", description = "While the protector lasts you take 20% less damage from every source.",
			descriptionPt = "Enquanto o protetor durar voce recebe 20% menos dano de qualquer fonte.",
			ward = {percent = 20, duration = 10000}},
		-- regen: percent of the maximum health back every `interval` ms, `ticks` times
		B = {name = "Healing Aegis", description = "While the protector lasts you recover 1% of your maximum health every second.",
			descriptionPt = "Enquanto o protetor durar voce recupera 1% da sua vida maxima por segundo.",
			regen = {percent = 1, ticks = 10, interval = 1000}}
	}},
	{name = "Blood Rage", key = "support/blood rage", level = 60, vocation = 4, glyphs = {
		-- melee: the melee skill bonus (135 = +35%); regen: percent of the maximum health back every `interval` ms
		A = {name = "Berserker's Heart", description = "The melee bonus is +50% instead of +35% and you recover 1% of your maximum health every second.",
			descriptionPt = "O bonus de combate corpo a corpo e +50% em vez de +35% e voce recupera 1% da sua vida maxima por segundo.",
			melee = 150, regen = {percent = 1, ticks = 10, interval = 1000}},
		-- leech: life leech % while the rage lasts
		B = {name = "Frenzy", description = "While the rage lasts you also recover 5% of the damage you deal as health.",
			descriptionPt = "Enquanto a furia durar voce tambem recupera 5% do dano que causa em vida.",
			leech = 5}
	}},
	-- ===== Cleric (vocation 9; the Hierophant follows). Names are provisional, designed by Claude =====
	{name = "Holy Ray", key = "attack/holy ray", level = 8, vocation = 9, glyphs = {
		-- mend: the caster or party member (within `radius` sqm) with the lowest health is healed `percent`% of the average damage of the spell
		A = {name = "Mending Ray", description = "The ally (you or a party member within 7 sqm) with the lowest health is healed for 25% of the average damage of the spell.",
			descriptionPt = "O aliado (voce ou alguem da party a ate 7 sqm) com menos vida e curado em 25% do dano medio da magia.",
			mend = {percent = 25, radius = 7}},
		-- faith: stacks of Faith given by each cast (normally 1)
		B = {name = "Zealous Ray", description = "Each cast gives 2 stacks of Faith instead of 1.",
			descriptionPt = "Cada uso da magia da 2 stacks de Faith em vez de 1.",
			faith = 2}
	}},
	{name = "Divine Lance", key = "attack/divine lance", level = 23, vocation = 9, glyphs = {
		-- long: the beam reaches 7 sqm instead of 5
		A = {name = "Long Lance", description = "The beam reaches 7 sqm (instead of 5) and damage and healing are 10% higher.",
			descriptionPt = "O feixe alcanca 7 sqm (antes 5) e o dano e a cura sobem 10%.",
			damage = 1.1, healing = 1.1, long = true},
		-- haste: every player the beam heals gets the speed of Haste for `duration` ms
		B = {name = "Guiding Light", description = "Healing +25%, and every player healed by the beam gets haste for 3 seconds.",
			descriptionPt = "Cura +25% e todo jogador curado pelo feixe ganha haste por 3 segundos.",
			healing = 1.25, haste = {duration = 3000}}
	}},
	{name = "Holy Nova", key = "attack/holy nova", level = 18, vocation = 9, glyphs = {
		-- wide: radius 3 instead of 2 (damage and healing area)
		A = {name = "Wide Nova", description = "The nova has radius 3 (instead of 2) and heals 15% more.",
			descriptionPt = "A nova tem raio 3 (antes 2) e cura 15% a mais.",
			healing = 1.15, wide = true},
		-- echo: a second pulse `delay` ms later with `share` of the damage and of the healing
		B = {name = "Echoing Nova", description = "A second pulse 1 second later with 50% of the damage and of the healing (150% in total).",
			descriptionPt = "Um segundo pulso 1 segundo depois, com 50% do dano e da cura (150% no total).",
			echo = {delay = 1000, share = 0.5}}
	}},
	{name = "Rain of Light", key = "attack/rain of light", level = 30, vocation = 9, glyphs = {
		-- longer: `ticks` pulses, each one with `share` of the normal pulse (6 x 0.65 = 130% of the normal total)
		A = {name = "Downpour", description = "The rain lasts 6 pulses instead of 3 and deals 30% more damage and healing in total.",
			descriptionPt = "A chuva dura 6 pulsos em vez de 3 e causa 30% a mais de dano e cura no total.",
			longer = {ticks = 6, share = 0.65}},
		-- mana: players inside the rain recover `percent`% of their maximum mana on every pulse
		B = {name = "Rain of Mana", description = "You and your party inside the rain recover 1% of your maximum mana on every pulse.",
			descriptionPt = "Voce e sua party dentro da chuva recuperam 1% da mana maxima a cada pulso.",
			mana = {percent = 1}}
	}},
	{name = "Celestial Hammer", key = "attack/celestial hammer", level = 35, vocation = 9, glyphs = {
		-- cleave: the 4 sqm next to the target take `share` of the damage
		A = {name = "Cleaving Hammer", description = "The hammer also hits the 4 sqm around the target for 50% of the damage.",
			descriptionPt = "O martelo tambem atinge os 4 sqm ao redor do alvo com 50% do dano.",
			cleave = {share = 0.5}},
		-- stun: the paralysis lasts `duration` ms instead of 2000
		B = {name = "Heavy Hand", description = "+20% damage and the stun lasts 3 seconds instead of 2.",
			descriptionPt = "+20% de dano e o stun dura 3 segundos em vez de 2.",
			damage = 1.2, stun = {duration = 3000}}
	}},
	{name = "Judgment", key = "attack/judgment", level = 42, vocation = 9, glyphs = {
		-- delay: ms until the sentence falls (1500 normally)
		A = {name = "Swift Verdict", description = "The sentence falls after 0.75 second instead of 1.5.",
			descriptionPt = "A sentenca cai depois de 0,75 segundo em vez de 1,5.",
			delay = 750},
		-- mass: every other enemy within `radius` sqm of the target takes `share` of the damage
		B = {name = "Mass Verdict", description = "The sentence also falls on every other enemy within 2 sqm of the target, for 60% of the damage.",
			descriptionPt = "A sentenca tambem cai em todo outro inimigo a ate 2 sqm do alvo, com 60% do dano.",
			mass = {radius = 2, share = 0.6}}
	}},
	{name = "Pillar of Light", key = "attack/pillar of light", level = 38, vocation = 9, glyphs = {
		-- pulses: number of pulses of the circle (4 normally)
		A = {name = "Enduring Pillar", description = "The circle of light lasts 7 pulses instead of 4.",
			descriptionPt = "O circulo de luz dura 7 pulsos em vez de 4.",
			pulses = 7},
		-- mercy: the healing of the circle is multiplied by `heal` and players inside take `ward`% less damage from every element
		B = {name = "Pillar of Mercy", description = "The healing of the circle is doubled and players inside take 10% less damage.",
			descriptionPt = "A cura do circulo dobra e os jogadores dentro recebem 10% menos dano.",
			mercy = {heal = 2, ward = 10}}
	}},
	{name = "Sacred Wave", key = "attack/sacred wave", level = 58, vocation = 9, glyphs = {
		-- resist: holy resistance taken from the monsters for `duration` ms (instead of the normal -10% for 8s)
		A = {name = "Shattering Wave", description = "Monsters hit lose 20% holy resistance for 12 seconds instead of 10% for 8.",
			descriptionPt = "Monstros atingidos perdem 20% de resistencia sagrada por 12 segundos, em vez de 10% por 8.",
			resist = {percent = 20, duration = 12000}},
		-- paralyze: every enemy hit is slowed by `percent` (0.4 = 40%) for `duration` ms
		B = {name = "Slowing Light", description = "Every enemy hit is 40% slower for 4 seconds.",
			descriptionPt = "Todo inimigo atingido fica 40% mais lento por 4 segundos.",
			paralyze = {percent = 0.4, duration = 4000}}
	}},
	{name = "Divine Tempest", key = "attack/divine tempest", level = 64, vocation = 9, glyphs = {
		-- slow: the caster is only slowed by `percent` instead of paralyzed (0.9)
		A = {name = "Steady Footing", description = "You are only 50% slower during the tempest instead of paralyzed.",
			descriptionPt = "Voce fica so 50% mais lento durante a tempestade, em vez de paralisado.",
			slow = 0.5},
		-- grace: every `interval` ms (`ticks` times) you and your party within `radius` sqm recover `percent`% of the total average damage of the spell
		B = {name = "Tempest of Grace", description = "Every second of the tempest you and your party within 5 sqm recover 4% of the total average damage of the spell in health.",
			descriptionPt = "A cada segundo da tempestade voce e sua party a ate 5 sqm recuperam 4% do dano medio total da magia em vida.",
			grace = {percent = 4, ticks = 5, interval = 1000, radius = 5}}
	}},
	{name = "Soothing Touch", key = "healing/soothing touch", level = 10, vocation = 9, glyphs = {
		-- twin: when you heal someone else, you recover `percent`% of the average healing of the spell
		A = {name = "Twin Souls", description = "When you heal another player, you recover 50% of the average healing of the spell too.",
			descriptionPt = "Quando voce cura outro jogador, voce tambem recupera 50% da cura media da magia.",
			twin = {percent = 50}},
		-- cleanse + ward: removes every harmful condition of the target and gives it `percent`% less damage for `duration` ms
		B = {name = "Absolving Touch", description = "Removes every harmful condition of the target and gives it 15% less damage for 4 seconds.",
			descriptionPt = "Remove toda condicao ruim do alvo e da a ele 15% menos dano por 4 segundos.",
			cleanse = true, ward = {percent = 15, duration = 4000}}
	}},
	{name = "Group Blessing", key = "healing/group blessing", level = 26, vocation = 9, glyphs = {
		-- radius: instead of 2
		A = {name = "Wide Blessing", description = "Radius 4 (instead of 2) and +15% healing.",
			descriptionPt = "Raio 4 (antes 2) e +15% de cura.",
			healing = 1.15, radius = 4},
		-- regen: every blessed player recovers `percent`% of the maximum health every `interval` ms, `ticks` times
		B = {name = "Blessing of Renewal", description = "Everyone blessed recovers 1% of their maximum health every second for 8 seconds.",
			descriptionPt = "Todos os abencoados recuperam 1% da vida maxima por segundo durante 8 segundos.",
			regen = {percent = 1, ticks = 8, interval = 1000}}
	}},
	{name = "Purify", key = "healing/purify", level = 15, vocation = 9, glyphs = {
		-- radius 3 instead of 2, removes every harmful condition (also dazzle, freezing...) and +30% damage
		A = {name = "Wide Purification", description = "Radius 3 (instead of 2), cleans every harmful condition and deals 30% more damage.",
			descriptionPt = "Raio 3 (antes 2), limpa toda condicao ruim e causa 30% a mais de dano.",
			damage = 1.3, radius = 3, cleanse = true},
		-- immune: cleaned players cannot get poison, fire, energy, curse or paralysis for `duration` ms
		B = {name = "Warding Purification", description = "The players cleaned cannot be poisoned, burned, shocked, cursed or paralyzed for 6 seconds.",
			descriptionPt = "Os jogadores limpos nao podem ser envenenados, queimados, chocados, amaldicoados ou paralisados por 6 segundos.",
			immune = {duration = 6000}}
	}},
	{name = "Final Prayer", key = "healing/final prayer", level = 48, vocation = 9, glyphs = {
		-- ticks: pulses of the prayer (3 normally)
		A = {name = "Endless Prayer", description = "The prayer lasts 5 pulses (10 seconds) instead of 3.",
			descriptionPt = "A prece dura 5 pulsos (10 segundos) em vez de 3.",
			ticks = 5},
		-- salvation: on every pulse, players below `threshold`% of health receive `bonus`% of the healing again
		B = {name = "Prayer of Salvation", description = "On every pulse, players below 35% health are healed 100% more.",
			descriptionPt = "A cada pulso, jogadores abaixo de 35% de vida sao curados 100% a mais.",
			salvation = {threshold = 35, bonus = 100}}
	}},
	{name = "Shield of Faith", key = "support/shield of faith", level = 13, vocation = 9, glyphs = {
		-- reinforced: duration, armor and defense
		A = {name = "Reinforced Faith", description = "The shield lasts 10 seconds (instead of 6) and gives +12 armor and +9 defense.",
			descriptionPt = "O escudo dura 10 segundos (antes 6) e da +12 de armadura e +9 de defesa.",
			reinforced = {duration = 10000, armor = 12, defense = 9}},
		-- burst: when it ends, other allies within `radius` sqm are healed `share` of the heal and enemies take that much holy damage
		B = {name = "Burst of Faith", description = "When the shield ends it bursts: other allies within 2 sqm are healed and enemies take holy damage, 50% of the healing.",
			descriptionPt = "Quando o escudo acaba ele explode: outros aliados a ate 2 sqm sao curados e inimigos recebem dano sagrado, 50% da cura.",
			burst = {radius = 2, share = 0.5}}
	}},
	{name = "Holy Fury", key = "support/holy fury", level = 20, vocation = 9, glyphs = {
		-- critical: extra critical chance (buff in !buffs, subId 8832)
		A = {name = "Righteous Fury", description = "Also gives +10% critical chance for the 15 seconds.",
			descriptionPt = "Tambem da +10% de chance de critico pelos 15 segundos.",
			critical = 10},
		-- share: party members within `radius` sqm get `amp`% holy damage (buff in !buffs, subId 8833)
		B = {name = "Shared Fury", description = "The party within 3 sqm gets half of the fury: +10% holy damage for 15 seconds.",
			descriptionPt = "A party a ate 3 sqm recebe metade da furia: +10% de dano sagrado por 15 segundos.",
			share = {radius = 3, amp = 10}}
	}},
	{name = "Divine Grace", key = "support/divine grace", level = 28, vocation = 9, glyphs = {
		-- buff: key of a variant in Cleric.buffs (data/lib/372-cleric.lua)
		A = {name = "Radiant Grace", description = "+20% magic level instead of +10%.",
			descriptionPt = "+20% de magic level em vez de +10%.",
			buff = "divine_grace_radiant"},
		-- mana: percent of the maximum mana given at once
		B = {name = "Graceful Flow", description = "The grace lasts 25 seconds and restores 5% of the maximum mana at once.",
			descriptionPt = "A graca dura 25 segundos e restaura 5% da mana maxima na hora.",
			buff = "divine_grace_flow", mana = 5}
	}},
	{name = "Wall of Light", key = "support/wall of light", level = 32, vocation = 9, glyphs = {
		A = {name = "Reinforced Wall", description = "Armor and defense are doubled (+10 armor and +8 defense).",
			descriptionPt = "Armadura e defesa dobram (+10 de armadura e +8 de defesa).",
			buff = "wall_of_light_reinforced"},
		-- ward: % less damage from every element for `duration` ms (buff in !buffs, subId 8834)
		B = {name = "Wall of Reflection", description = "Also gives 15% less damage from every element for 10 seconds.",
			descriptionPt = "Tambem da 15% menos dano de todo elemento por 10 segundos.",
			ward = {percent = 15, duration = 10000}}
	}},
	{name = "Divine Vitality", key = "support/divine vitality", level = 54, vocation = 9, glyphs = {
		A = {name = "Greater Vitality", description = "+15% maximum health and mana instead of +10%.",
			descriptionPt = "+15% de vida e mana maximas em vez de +10%.",
			buff = "divine_vitality_greater"},
		-- heal: percent of the new maximum health restored at once
		B = {name = "Instant Reprieve", description = "Besides the buff, everyone affected recovers 15% of their maximum health at once.",
			descriptionPt = "Alem do bonus, todos os afetados recuperam 15% da vida maxima na hora.",
			heal = 15}
	}},
	{name = "Radiant Strikes", key = "support/radiant strikes", level = 51, vocation = 9, glyphs = {
		A = {name = "Piercing Radiance", description = "Basic attacks deal 25% of the damage as holy damage instead of 15%.",
			descriptionPt = "Os ataques basicos causam 25% do dano como dano sagrado em vez de 15%.",
			buff = "radiant_strikes_piercing"},
		-- radius: sqm around you whose party gets the buff (7 normally)
		B = {name = "Lasting Radiance", description = "The buff lasts 2 minutes instead of 1 and reaches the party within 10 sqm instead of 7.",
			descriptionPt = "O bonus dura 2 minutos em vez de 1 e alcanca a party a ate 10 sqm em vez de 7.",
			buff = "radiant_strikes_lasting", radius = 10}
	}},
	-- ===== Necromancer (vocation 11; the Lich follows). Names are provisional, designed by Claude =====
	-- summons (glyph fields read by Necro.summon, Necro.scale / Necro.applyGlyph and the attacks of the summons: data/lib/373-necromancer.lua)
	{name = "Summon Skeleton", key = "necromancer/summon skeleton", level = 8, vocation = 11, glyphs = {
		-- vitality: x times the health of the summon; summonDamage: x times the damage of every attack of the summon
		A = {name = "Bone Fencer", description = "The skeleton is raised with 30% more health and deals 20% more damage.",
			descriptionPt = "O esqueleto nasce com 30% mais vida e causa 20% mais dano.",
			vitality = 1.3, summonDamage = 1.2},
		-- soulSave: chance (%) of not spending the soul
		B = {name = "Frugal Soul", description = "25% chance of not spending the soul when you raise it.",
			descriptionPt = "25% de chance de nao gastar o soul ao invocar.",
			soulSave = 25}
	}},
	{name = "Summon Ghoul", key = "necromancer/summon ghoul", level = 18, vocation = 11, glyphs = {
		-- regen: % of the health back every second
		A = {name = "Rotten Flesh", description = "The ghoul has 30% more health and recovers 1% of it every second.",
			descriptionPt = "O ghoul tem 30% mais vida e recupera 1% dela por segundo.",
			vitality = 1.3, regen = 1},
		-- taunt: radius of the Taunt of the ghoul; the monsters challenged are slowed by `slow` (0.25 = 25%) for `duration` ms
		B = {name = "Stench of the Grave", description = "The taunt of the ghoul reaches 2 sqm and the monsters challenged are 25% slower for 4 seconds.",
			descriptionPt = "O taunt do ghoul alcanca 2 sqm e os monstros desafiados ficam 25% mais lentos por 4 segundos.",
			taunt = {radius = 2, slow = 0.25, duration = 4000}}
	}},
	{name = "Summon Banshee", key = "necromancer/summon banshee", level = 26, vocation = 11, glyphs = {
		-- pierce: the wail goes through the target and hits everything on the line, up to `length` sqm from the banshee
		A = {name = "Piercing Wail", description = "The wail of the banshee goes through the target and hits every enemy on its line, up to 5 sqm from her.",
			descriptionPt = "O grito da banshee atravessa o alvo e atinge todo inimigo na linha, ate 5 sqm dela.",
			pierce = {length = 5}},
		-- slow: the target is slowed by `percent` (0.3 = 30%) for `duration` ms
		B = {name = "Keening", description = "The wail slows the target by 30% for 3 seconds.",
			descriptionPt = "O grito deixa o alvo 30% mais lento por 3 segundos.",
			slow = {percent = 0.3, duration = 3000}}
	}},
	{name = "Summon Phantasm", key = "necromancer/summon phantasm", level = 35, vocation = 11, glyphs = {
		-- twin: `hits` strikes `interval` ms apart, each with `share` of the damage (2 x 0.65 = 130%)
		A = {name = "Twin Haunt", description = "The haunt strikes twice, 0.5 seconds apart, for a total of 130% of the damage.",
			descriptionPt = "A assombracao golpeia duas vezes, com 0,5 segundo de intervalo, num total de 130% do dano.",
			twin = {hits = 2, interval = 500, share = 0.65}},
		-- resist: death and poison resistance taken from the monsters hit for `duration` ms
		B = {name = "Withering Haunt", description = "Monsters hit lose 10% death and poison resistance for 6 seconds.",
			descriptionPt = "Monstros atingidos perdem 10% de resistencia a morte e a veneno por 6 segundos.",
			resist = {percent = 10, duration = 6000}}
	}},
	{name = "Summon Dragon Skeleton", key = "necromancer/summon dragon skeleton", level = 54, vocation = 11, glyphs = {
		-- drain: % of the maximum health the dragon loses per second (1.5 normally)
		A = {name = "Ancient Bones", description = "The dragon skeleton loses 0.75% of its health per second instead of 1.5%, so it lasts twice as long.",
			descriptionPt = "O dragon skeleton perde 0,75% da vida por segundo em vez de 1,5%, entao dura o dobro.",
			drain = 0.75},
		-- burst: Grave Burst deals `damage` times more and an extra one comes every `every` ms between the normal ones (every 10s)
		B = {name = "Dragon's Fury", description = "Grave Burst deals 20% more damage and happens twice as often (every 5 seconds).",
			descriptionPt = "O Grave Burst causa 20% mais dano e acontece o dobro de vezes (a cada 5 segundos).",
			burst = {damage = 1.2, every = 5000}}
	}},

	-- attacks
	{name = "Death Touch", key = "necromancer/death touch", level = 8, vocation = 11, glyphs = {
		-- mana: percent of the average damage of the spell given back as mana when it hits
		A = {name = "Soul Tap", description = "You recover mana equal to 10% of the average damage of the spell.",
			descriptionPt = "Voce recupera mana igual a 10% do dano medio da magia.",
			mana = {percent = 10}},
		B = {name = "Marked for Death", description = "Lowers the death resistance of the monster by 10% for 8 seconds.",
			descriptionPt = "Reduz em 10% a resistencia a morte do monstro por 8 segundos.",
			resist = {percent = 10, duration = 8000}}
	}},
	{name = "Venom Touch", key = "necromancer/venom touch", level = 12, vocation = 11, glyphs = {
		-- poison: ticks (1 per second) and mult (damage per tick, 1 = the normal poison)
		A = {name = "Festering Wound", description = "The poison lasts 15 seconds instead of 10 (150% of the poison damage).",
			descriptionPt = "O veneno dura 15 segundos em vez de 10 (150% do dano do veneno).",
			poison = {ticks = 15, mult = 1}},
		B = {name = "Crippling Venom", description = "The poisoned target is 30% slower for 4 seconds.",
			descriptionPt = "O alvo envenenado fica 30% mais lento por 4 segundos.",
			slow = {percent = 0.3, duration = 4000}}
	}},
	{name = "Dark Orb", key = "necromancer/dark orb", level = 20, vocation = 11, glyphs = {
		A = {name = "Grim Burst", description = "+20% damage.",
			descriptionPt = "+20% de dano.", damage = 1.2},
		-- feed: the summons around you recover `percent`% of their health for each enemy hit (up to `targets`)
		B = {name = "Feeding Orb", description = "Your summons recover 3% of their health for each enemy hit (up to 5).",
			descriptionPt = "Seus summons recuperam 3% da vida por inimigo atingido (ate 5).",
			feed = {percent = 3, targets = 5}}
	}},
	{name = "Venom Orb", key = "necromancer/venom orb", level = 20, vocation = 11, glyphs = {
		-- cloud: the spot stays poisoned: `ticks` pulses, one every `interval` ms, `percent`% of the damage of the spell in total
		A = {name = "Toxic Cloud", description = "The area stays poisoned for 5 seconds: 120% of the damage of the spell in total.",
			descriptionPt = "A area continua envenenada por 5 segundos: 120% do dano da magia no total.",
			cloud = {ticks = 5, interval = 1000, percent = 120}},
		-- resist: poison resistance taken from the monsters hit
		B = {name = "Plague Spores", description = "Monsters hit lose 15% poison resistance for 8 seconds.",
			descriptionPt = "Monstros atingidos perdem 15% de resistencia a veneno por 8 segundos.",
			resist = {percent = 15, duration = 8000}}
	}},
	{name = "Death Wave", key = "necromancer/death wave", level = 28, vocation = 11, glyphs = {
		A = {name = "Wide Wave", description = "A bigger wave: 5 sqm wide and 1 sqm longer.",
			descriptionPt = "Uma onda maior: 5 sqm de largura e 1 sqm a mais de alcance.",
			wide = true},
		-- reap: if the wave hits at least `targets` enemies there is a `chance`% chance of gaining `soul` soul
		B = {name = "Soul Reaper", description = "If the wave hits 3 or more enemies, 25% chance of gaining 1 soul.",
			descriptionPt = "Se a onda atingir 3 ou mais inimigos, 25% de chance de ganhar 1 soul.",
			reap = {targets = 3, chance = 25, soul = 1}}
	}},
	{name = "Venom Wave", key = "necromancer/venom wave", level = 28, vocation = 11, glyphs = {
		A = {name = "Virulent Wave", description = "The poison deals twice as much damage.",
			descriptionPt = "O veneno causa o dobro do dano.",
			poison = {ticks = 10, mult = 2}},
		B = {name = "Retching Gust", description = "Every creature hit is pushed 1 sqm away from you.",
			descriptionPt = "Toda criatura atingida e empurrada 1 sqm para longe de voce.",
			push = {chance = 100}}
	}},
	{name = "Rain of Poison", key = "necromancer/rain of poison", level = 40, vocation = 11, glyphs = {
		-- ticks: pulses of the rain (5 normally)
		A = {name = "Acid Rain", description = "The rain lasts 8 seconds (8 pulses) instead of 5.",
			descriptionPt = "A chuva dura 8 segundos (8 pulsos) em vez de 5.",
			ticks = 8},
		-- buff: version of the buff in Necro.buffs; party: radius in sqm whose party members get it too
		B = {name = "Corrosive Rain", description = "Venom Corrosion gives +40% poison penetration for 20 seconds, to you and your party within 7 sqm.",
			descriptionPt = "O Venom Corrosion da +40% de penetracao de veneno por 20 segundos, a voce e a sua party a ate 7 sqm.",
			buff = "venom_corrosion_strong", party = 7}
	}},
	{name = "Death Tornado", key = "necromancer/death tornado", level = 46, vocation = 11, glyphs = {
		-- turns: the disc sweeps this many times in a row; share: fraction of the damage of each turn (2 x 0.7 = 140%)
		A = {name = "Twin Gale", description = "The tornado sweeps around you twice (1.3 seconds each), for a total of 140% of the damage.",
			descriptionPt = "O tornado varre ao seu redor duas vezes (1,3 segundo cada), num total de 140% do dano.",
			turns = 2, share = 0.7},
		B = {name = "Dead Calm", description = "Every enemy hit is 35% slower for 4 seconds.",
			descriptionPt = "Todo inimigo atingido fica 35% mais lento por 4 segundos.",
			slow = {percent = 0.35, duration = 4000}}
	}},

	-- buffs and support
	{name = "Bone Armor", key = "necromancer/bone armor", level = 16, vocation = 11, glyphs = {
		-- armor: % of physical resistance; later: the summons raised while the buff lasts get it too
		A = {name = "Ossified Armor", description = "+40% physical resistance (instead of 25%), also on the summons you raise while it lasts.",
			descriptionPt = "+40% de resistencia fisica (em vez de 25%), tambem nos summons que voce invocar enquanto durar.",
			armor = 40, later = true},
		-- spikes: % of the damage that a monster hitting a summon takes back (event NecroSpikes)
		B = {name = "Spiked Bones", description = "While it lasts, monsters that hit your summons take 10% of the damage back.",
			descriptionPt = "Enquanto durar, monstros que atingem seus summons levam 10% do dano de volta.",
			spikes = 10}
	}},
	{name = "Unholy Frenzy", key = "necromancer/unholy frenzy", level = 23, vocation = 11, glyphs = {
		-- buff: version of the buff in Necro.buffs; frenzy: damage multiplier
		A = {name = "Dire Frenzy", description = "+45% damage on the summons, but only for 12 seconds.",
			descriptionPt = "+45% de dano nos summons, mas so por 12 segundos.",
			buff = "unholy_frenzy_dire", frenzy = 1.45},
		-- leech: % of the damage of each attack that the summon recovers as health
		B = {name = "Bloodthirsty Dead", description = "While it lasts, your summons recover 5% of the damage of each attack as health.",
			descriptionPt = "Enquanto durar, seus summons recuperam 5% do dano de cada ataque em vida.",
			leech = 5}
	}},
	{name = "Soul Sacrifice", key = "necromancer/soul sacrifice", level = 31, vocation = 11, glyphs = {
		-- refund: soul given back (3 normally)
		A = {name = "Mercy of the Fallen", description = "Gives back 5 soul instead of 3.",
			descriptionPt = "Devolve 5 soul em vez de 3.",
			refund = 5},
		-- buff: version of the buff; heal: % of your maximum health recovered at once
		B = {name = "Dark Pact", description = "The bonus is +60% death and poison damage (instead of 40%) and you recover 10% of your health.",
			descriptionPt = "O bonus e +60% de dano de morte e veneno (em vez de 40%) e voce recupera 10% da vida.",
			buff = "soul_sacrifice_pact", heal = 10}
	}},
	{name = "Bone Shell", key = "necromancer/bone shell", level = 31, vocation = 11, glyphs = {
		A = {name = "Reinforced Shell", description = "+24 armor and +18 defense instead of +14 and +10.",
			descriptionPt = "+24 de armadura e +18 de defesa em vez de +14 e +10.",
			buff = "bone_shell_reinforced"},
		B = {name = "Shell Burst", description = "When the shell ends it explodes in death around you (radius 2).",
			descriptionPt = "Quando a casca acaba ela explode em morte ao seu redor (raio 2).",
			buff = "bone_shell_burst"}
	}},
	{name = "Bone Mend", key = "necromancer/bone mend", level = 14, vocation = 11, glyphs = {
		A = {name = "Greater Mend", description = "+30% healing and 9 sqm of range (instead of 7).",
			descriptionPt = "+30% de cura e 9 sqm de alcance (em vez de 7).",
			healing = 1.3, radius = 9},
		-- link: you recover `percent`% of the average healing of the spell too
		B = {name = "Marrow Link", description = "You recover 25% of the average healing of the spell as well.",
			descriptionPt = "Voce tambem recupera 25% da cura media da magia.",
			link = {percent = 25}}
	}},
	{name = "Recall", key = "necromancer/recall", level = 11, vocation = 11, glyphs = {
		A = {name = "Swift Recall", description = "You and your summons gain haste (+30% speed) for 3 seconds.",
			descriptionPt = "Voce e seus summons ganham haste (+30% de velocidade) por 3 segundos.",
			haste = {duration = 3000}},
		-- guard: % less damage taken by the summons that were recalled
		B = {name = "Bone Barrier", description = "The summons arrive with 15% less damage from every element for 6 seconds.",
			descriptionPt = "Os summons chegam com 15% menos dano de todo elemento por 6 segundos.",
			guard = {percent = 15, duration = 6000}}
	}},

	-- Lich (premium)
	{name = "Soul Siphon", key = "necromancer/soul siphon", level = 58, vocation = 11, glyphs = {
		-- selfHeal / summonHeal: share of the damage dealt that heals you / your summons (0.40 / 0.10 normally)
		A = {name = "Greater Siphon", description = "Heals you for 55% of the damage (instead of 40%) and your summons for 15% (instead of 10%).",
			descriptionPt = "Cura voce em 55% do dano (em vez de 40%) e seus summons em 15% (em vez de 10%).",
			selfHeal = 0.55, summonHeal = 0.15},
		-- execute: the hit deals `damage` times more against a target with `below`% of its health or less; soul: soul for a kill (1 normally)
		B = {name = "Reaping Siphon", description = "+50% damage against targets with 30% health or less, and a kill gives 2 soul instead of 1.",
			descriptionPt = "+50% de dano em alvos com 30% de vida ou menos, e a morte da 2 soul em vez de 1.",
			execute = {below = 30, damage = 1.5}, soul = 2}
	}},
	{name = "Summon Bone Abomination", key = "necromancer/summon bone abomination", level = 62, vocation = 11, glyphs = {
		-- tauntRadius: radius (sqm) of the Taunt of the abomination (1 normally)
		A = {name = "Colossal Bones", description = "The abomination has 40% more health and its taunt reaches 5 sqm.",
			descriptionPt = "A abomination tem 40% mais vida e o taunt dela alcanca 5 sqm.",
			vitality = 1.4, tauntRadius = 5},
		-- blast: the explosion when it dies has a bigger area (radius 3, 7x7) and `damage` times the damage
		B = {name = "Volatile Marrow", description = "The explosion when it dies is bigger (7x7) and deals 50% more damage.",
			descriptionPt = "A explosao quando ela morre e maior (7x7) e causa 50% mais dano.",
			blast = {damage = 1.5}}
	}},
	{name = "Corpse Explosion", key = "necromancer/corpse explosion", level = 66, vocation = 11, glyphs = {
		-- chain: up to `corpses` other corpses within `radius` sqm of the explosion explode too, with `share` of the damage
		A = {name = "Chain Detonation", description = "Up to 2 other corpses in the area explode too, for 50% of the damage each.",
			descriptionPt = "Ate 2 outros corpos na area tambem explodem, com 50% do dano cada.",
			chain = {corpses = 2, share = 0.5, radius = 2}},
		B = {name = "Shattering Blast", description = "Every enemy hit is 50% slower for 3 seconds.",
			descriptionPt = "Todo inimigo atingido fica 50% mais lento por 3 segundos.",
			slow = {percent = 0.5, duration = 3000}}
	}},
	{name = "Army of the Dead", key = "necromancer/army of the dead", level = 70, vocation = 11, glyphs = {
		-- count / duration: soldiers raised and how long they last (3 and 20s normally)
		A = {name = "Legion", description = "Raises 5 bone soldiers for 15 seconds instead of 3 for 20.",
			descriptionPt = "Levanta 5 bone soldiers por 15 segundos em vez de 3 por 20.",
			count = 5, duration = 15000},
		-- taunt: the soldiers challenge the monsters within `radius` sqm every `every` ms; slow: every hit of a soldier slows the target
		B = {name = "Undying Vanguard", description = "The 3 soldiers last 30 seconds, challenge the monsters around them and every hit slows the target by 20% for 2 seconds.",
			descriptionPt = "Os 3 soldados duram 30 segundos, desafiam os monstros em volta e cada golpe deixa o alvo 20% mais lento por 2 segundos.",
			duration = 30000, taunt = {radius = 3, every = 6000}, slow = {percent = 0.2, duration = 2000}}
	}},

	-- ===== Assassin (vocation 13; the Nightblade follows). Names are provisional, designed by Claude =====
	-- The assassin spells do not go through the SpellBalance: every field is read by the script in data/spells/scripts/assassin/
	-- (and Assassin.* in data/lib/374-assassin.lua). Each spell has two glyphs of different kinds.
	{name = "Quick Slash", key = "assassin/quick slash", level = 8, vocation = 13, glyphs = {
		-- flurry: chance (%) of a second cut at once, with `percent`% of the damage
		A = {name = "Rapid Flurry", description = "20% chance to cut again at once, for 60% of the damage.",
			descriptionPt = "20% de chance de cortar de novo na hora, com 60% do dano.",
			flurry = {chance = 20, percent = 60}},
		-- momentum: chance (%) of giving `amount` Momentum stacks instead of 1
		B = {name = "Opening Cut", description = "25% chance to give 2 Momentum stacks instead of 1.",
			descriptionPt = "25% de chance de dar 2 stacks de Momentum em vez de 1.",
			momentum = {chance = 25, amount = 2}}
	}},
	{name = "Shadow Step", key = "assassin/shadow step", level = 12, vocation = 13, glyphs = {
		-- longDodge: the dodge buff becomes +40% for 3s (Assassin.buffs.shadow_dodge_long)
		A = {name = "Fleeting Shade", description = "The dodge after the step is +40% instead of +25% and lasts 3 seconds.",
			descriptionPt = "A esquiva depois do passo e de +40% em vez de +25% e dura 3 segundos.",
			longDodge = true},
		-- paralyze: slow in % for `duration` ms on the target
		B = {name = "Lingering Fear", description = "The target is slowed by 40% for 3 seconds after the step.",
			descriptionPt = "O alvo fica 40% mais lento por 3 segundos depois do passo.",
			paralyze = {percent = 0.4, duration = 3000}}
	}},
	{name = "Twin Fang", key = "assassin/twin fang", level = 16, vocation = 13, glyphs = {
		-- bleed: every cut makes the target bleed for `percent`% of its average damage, paid in `ticks` hits, one every `interval` ms
		A = {name = "Serrated Fangs", description = "Every cut makes the target bleed for 40% of its damage, over 4 seconds.",
			descriptionPt = "Cada corte faz o alvo sangrar por 40% do dano dele, ao longo de 4 segundos.",
			bleed = {percent = 40, ticks = 4, interval = 1000}},
		-- leech: every cut that hits heals `percent`% of your maximum health
		B = {name = "Hungry Fangs", description = "You recover 3% of your maximum health for every cut that hits.",
			descriptionPt = "Voce recupera 3% da sua vida maxima por corte que acertar.",
			leech = {percent = 3}}
	}},
	{name = "Venom Edge", key = "assassin/venom edge", level = 20, vocation = 13, glyphs = {
		-- poison: the poison hits `multiplier` times harder and lasts `ticks` seconds
		A = {name = "Lethal Dose", description = "The poison deals double damage per second and lasts 10 seconds.",
			descriptionPt = "O veneno causa o dobro de dano por segundo e dura 10 segundos.",
			poison = {multiplier = 2, ticks = 10}},
		-- paralyze: slow on the target; resist: earth resistance taken from the monster (before the hit)
		B = {name = "Creeping Toxin", description = "The target is slowed by 30% for 4 seconds and loses 10% earth resistance for 8 seconds.",
			descriptionPt = "O alvo fica 30% mais lento por 4 segundos e perde 10% de resistencia a terra por 8 segundos.",
			paralyze = {percent = 0.3, duration = 4000}, resist = {percent = 10, duration = 8000}}
	}},
	{name = "Bleeding Cut", key = "assassin/bleeding cut", level = 25, vocation = 13, glyphs = {
		-- cutDamage: multiplier of the cut; ticks: seconds of bleeding
		A = {name = "Open Wound", description = "The cut deals 30% more damage and the bleeding lasts 8 seconds instead of 6.",
			descriptionPt = "O corte causa 30% a mais de dano e o sangramento dura 8 segundos em vez de 6.",
			cutDamage = 1.3, ticks = 8},
		-- spread: the bleeding also starts on the enemies within `range` sqm of the target, with `percent`% per tick
		B = {name = "Hemorrhage", description = "The bleeding also spreads to the enemies within 2 sqm of the target, with 50% of the damage.",
			descriptionPt = "O sangramento tambem se espalha para os inimigos a ate 2 sqm do alvo, com 50% do dano.",
			spread = {range = 2, percent = 50}}
	}},
	{name = "Backstab", key = "assassin/backstab", level = 28, vocation = 13, glyphs = {
		-- buff: after the hit, +15% critical chance for 6s (Assassin.buffs.assassins_prey)
		A = {name = "Assassin's Prey", description = "After the blow you get +15% critical chance for 6 seconds.",
			descriptionPt = "Depois do golpe voce ganha +15% de chance de critico por 6 segundos.",
			buff = true},
		-- side: the sides of the target count too, only its front is refused
		B = {name = "Shadowed Strike", description = "The blow also works from the sides of the target, not only from behind.",
			descriptionPt = "O golpe tambem funciona pelos lados do alvo, nao so pelas costas.",
			side = true}
	}},
	{name = "Smoke Bomb", key = "assassin/smoke bomb", level = 30, vocation = 13, glyphs = {
		-- paralyze: slow on every enemy hit
		A = {name = "Choking Smoke", description = "Every enemy hit is slowed by 40% for 4 seconds.",
			descriptionPt = "Todo inimigo atingido fica 40% mais lento por 4 segundos.",
			paralyze = {percent = 0.4, duration = 4000}},
		-- linger: `pulses` more pulses of the smoke, one every `interval` ms, each with `percent`% of the damage
		B = {name = "Lingering Haze", description = "The smoke stays for 4 more seconds: 4 more pulses, each with 25% of the damage.",
			descriptionPt = "A fumaca fica por mais 4 segundos: 4 pulsos a mais, cada um com 25% do dano.",
			linger = {pulses = 4, percent = 25, interval = 1000}}
	}},
	{name = "Blade Dance", key = "assassin/blade dance", level = 35, vocation = 13, glyphs = {
		-- wide: the area is a circle of radius 2 (5x5) instead of 3x3
		A = {name = "Whirling Blades", description = "The area is 1 sqm bigger (radius 2 instead of 3x3).",
			descriptionPt = "A area fica 1 sqm maior (raio 2 em vez de 3x3).",
			wide = true},
		-- heal: percent of your maximum health back for each enemy hit (up to `targets`)
		B = {name = "Dance of Steel", description = "You recover 2% of your maximum health for each enemy hit (up to 5).",
			descriptionPt = "Voce recupera 2% da sua vida maxima por inimigo atingido (ate 5).",
			heal = {percent = 2, targets = 5}}
	}},
	{name = "Bloodthirst", key = "assassin/bloodthirst", level = 40, vocation = 13, glyphs = {
		-- buff: key of the buff of Assassin.buffs (data/lib/374-assassin.lua) that replaces the normal one
		A = {name = "Crimson Thirst", description = "The life leech is 20% instead of 12%.",
			descriptionPt = "O life leech e de 20% em vez de 12%.",
			buff = "bloodthirst_crimson"},
		B = {name = "Predator's Edge", description = "+15% critical chance (instead of 5%) and +10% physical damage, and the buff lasts 15 seconds.",
			descriptionPt = "+15% de chance de critico (em vez de 5%) e +10% de dano fisico, e o buff dura 15 segundos.",
			buff = "bloodthirst_predator"}
	}},
	{name = "Execute", key = "assassin/execute", level = 46, vocation = 13, glyphs = {
		-- execute: the knife deals `damage` times more when the target has less than `below`% of its health (replaces 30% / x1.75)
		A = {name = "Merciless", description = "The bonus applies to targets below 40% health (instead of 30%) and is x2.0 instead of x1.75.",
			descriptionPt = "O bonus vale para alvos abaixo de 40% de vida (em vez de 30%) e e x2,0 em vez de x1,75.",
			execute = {below = 40, damage = 2.0}},
		-- bounty: if the knife kills the target you get the Momentum stacks back and `mana`% of your maximum mana
		B = {name = "Bounty", description = "If the knife kills the target you get the Momentum stacks it spent back and recover 10% of your maximum mana.",
			descriptionPt = "Se a faca matar o alvo voce recebe de volta os stacks de Momentum gastos e recupera 10% da sua mana maxima.",
			bounty = {mana = 10}}
	}},
	{name = "Deathblow", key = "assassin/deathblow", level = 50, vocation = 13, glyphs = {
		-- below: the target may have up to this % of its health (instead of 25%)
		A = {name = "Final Mercy", description = "The target can have up to 35% of its health (instead of 25%).",
			descriptionPt = "O alvo pode ter ate 35% de vida (em vez de 25%).",
			below = 35},
		-- reaper: if the blow kills the target, haste (+30%) and invisibility for the given ms
		B = {name = "Reaper's Rush", description = "If the blow kills the target you gain haste for 5 seconds and invisibility for 2 seconds.",
			descriptionPt = "Se o golpe matar o alvo voce ganha haste por 5 segundos e invisibilidade por 2 segundos.",
			reaper = {haste = 5000, invisible = 2000}}
	}},
	{name = "Vanish", key = "assassin/vanish", level = 54, vocation = 13, glyphs = {
		-- haste: speed of the Haste spell (+30%) for that many ms
		A = {name = "Ghost Walk", description = "You also gain haste (+30% speed) for 5 seconds.",
			descriptionPt = "Voce tambem ganha haste (+30% de velocidade) por 5 segundos.",
			haste = 5000},
		-- lethal: the first spell hit within `duration` ms deals `damage` times more
		B = {name = "Lethal Shadow", description = "The first spell hit within 5 seconds deals 40% more damage.",
			descriptionPt = "O primeiro golpe de magia em ate 5 segundos causa 40% a mais de dano.",
			lethal = {damage = 1.4, duration = 5000}}
	}},
	{name = "Thousand Cuts", key = "assassin/thousand cuts", level = 58, vocation = 13, glyphs = {
		-- bleed: every cut makes the target bleed for `percent`% of its average damage, in `ticks` hits
		A = {name = "Rending Flurry", description = "Every cut makes the target bleed for 25% of its damage, over 5 seconds.",
			descriptionPt = "Cada corte faz o alvo sangrar por 25% do dano dele, ao longo de 5 segundos.",
			bleed = {percent = 25, ticks = 5, interval = 1000}},
		-- splash: every cut also hits the other enemies within `range` sqm of the target, with `percent`% of the damage
		B = {name = "Whirling Cuts", description = "Every cut also hits the other enemies within 1 sqm of the target, with 40% of the damage.",
			descriptionPt = "Cada corte tambem atinge os outros inimigos a ate 1 sqm do alvo, com 40% do dano.",
			splash = {range = 1, percent = 40}}
	}},
	{name = "Death Mark", key = "assassin/death mark", level = 62, vocation = 13, glyphs = {
		-- resist: death resistance taken from the marked monster while the mark lasts
		A = {name = "Marked for Ruin", description = "The marked monster loses 15% death resistance for 6 seconds.",
			descriptionPt = "O monstro marcado perde 15% de resistencia a morte por 6 segundos.",
			resist = {percent = 15, duration = 6000}},
		-- wide: the detonation is a circle of radius 2 (5x5) instead of 3x3
		B = {name = "Spreading Doom", description = "The detonation is 1 sqm bigger (radius 2 instead of 3x3).",
			descriptionPt = "A detonacao fica 1 sqm maior (raio 2 em vez de 3x3).",
			wide = true}
	}},
	{name = "Phantom Clones", key = "assassin/phantom clones", level = 66, vocation = 13, glyphs = {
		-- count: number of clones
		A = {name = "Legion of Shadows", description = "3 clones instead of 2.",
			descriptionPt = "3 clones em vez de 2.",
			count = 3},
		-- duration: ms the clones last; challenge: radius (sqm) of the monsters that the clones challenge when they appear
		B = {name = "Enduring Illusion", description = "The clones last 18 seconds and challenge the monsters within 3 sqm when they appear.",
			descriptionPt = "Os clones duram 18 segundos e desafiam os monstros a ate 3 sqm quando aparecem.",
			duration = 18000, challenge = 3}
	}},
	{name = "Night Veil", key = "assassin/night veil", level = 70, vocation = 13, glyphs = {
		-- swift: the buff lasts 15s and you also gain haste (+30%) for the same time
		A = {name = "Veil of Swiftness", description = "The veil lasts 15 seconds and also gives haste (+30% speed) while it lasts.",
			descriptionPt = "O veu dura 15 segundos e tambem da haste (+30% de velocidade) enquanto durar.",
			swift = true},
		-- guard: besides the veil, `percent`% less damage of every element for `duration` ms (buff in !buffs, subId 8407)
		B = {name = "Veil of Reflection", description = "Besides the veil, you take 15% less damage from every element for 10 seconds.",
			descriptionPt = "Alem do veu, voce recebe 15% menos dano de todo elemento por 10 segundos.",
			guard = {percent = 15, duration = 10000}}
	}},

	-- ===== Berserker (vocation 15; the Warlord follows). Names and numbers are provisional, designed by Claude =====
	-- The Berserker spells do not go through the SpellBalance, so every field is read by the script in data/spells/scripts/berserker/
	-- (`damage` is only used by Cleave). Each spell has two glyphs of different kinds.
	{name = "Cleave", key = "berserker/cleave", level = 8, vocation = 15, glyphs = {
		-- wide: the swing also hits the 3 tiles in front of you
		A = {name = "Wide Cleave", description = "The swing also hits the 3 tiles in front of you and deals 10% more damage.",
			descriptionPt = "O golpe tambem atinge os 3 tiles a sua frente e causa 10% a mais de dano.",
			wide = true, damage = 1.1},
		-- fury: chance (%) of 1 extra stack of Fury
		B = {name = "Fury Surge", description = "30% chance to gain 1 extra stack of Fury.",
			descriptionPt = "30% de chance de ganhar 1 stack extra de Furia.",
			fury = {chance = 30}}
	}},
	{name = "Savage Leap", key = "berserker/savage leap", level = 12, vocation = 15, glyphs = {
		-- stun: every enemy hit by the landing is paralyzed (percent 0.95 = almost stopped) for `duration` ms
		A = {name = "Quaking Landing", description = "Every enemy hit by the landing is paralyzed for 1.5 seconds.",
			descriptionPt = "Todo inimigo atingido pela aterrissagem fica paralisado por 1,5 segundo.",
			stun = {percent = 0.95, duration = 1500}},
		-- range: sqm the leap reaches (4 normally); haste: speed of the Haste spell for `duration` ms after the leap
		B = {name = "Long Leap", description = "The leap reaches 6 sqm (instead of 4) and you gain haste (+30% speed) for 3 seconds after it.",
			descriptionPt = "O pulo alcanca 6 sqm (antes 4) e voce ganha haste (+30% de velocidade) por 3 segundos depois dele.",
			range = 6, haste = {duration = 3000}}
	}},
	{name = "Rending Blow", key = "berserker/rending blow", level = 16, vocation = 15, glyphs = {
		-- bleed: ticks of 1s (6 normally) and the damage of each tick times `multiplier`
		A = {name = "Deep Wound", description = "The bleeding lasts 10 seconds (instead of 6) and hurts 40% more each second.",
			descriptionPt = "O sangramento dura 10 segundos (antes 6) e causa 40% a mais de dano por segundo.",
			bleed = {ticks = 10, multiplier = 1.4}},
		-- resist: physical resistance taken from the monster for `duration` ms (before the hit, so the hit already benefits)
		B = {name = "Sundering Blow", description = "The target loses 15% physical resistance for 8 seconds (monsters only).",
			descriptionPt = "O alvo perde 15% de resistencia fisica por 8 segundos (so monstros).",
			resist = {percent = 15, duration = 8000}}
	}},
	{name = "Warcry", key = "berserker/warcry", level = 20, vocation = 15, glyphs = {
		-- guard: % less damage from every element for `duration` ms (buff Iron Cry in !buffs, subId 8452)
		A = {name = "Iron Cry", description = "You take 10% less damage from every element for 8 seconds.",
			descriptionPt = "Voce recebe 10% menos dano de todo elemento por 8 segundos.",
			guard = {percent = 10, duration = 8000}},
		-- rally: the party within `radius` sqm gets the armor and defense of the Warcry and haste for `haste` ms
		B = {name = "Rallying Cry", description = "Your party within 5 sqm also gets the armor and defense of the Warcry, and haste (+30% speed) for 4 seconds.",
			descriptionPt = "Sua party a ate 5 sqm tambem ganha o armor e a defense do Warcry, e haste (+30% de velocidade) por 4 segundos.",
			rally = {radius = 5, haste = 4000}}
	}},
	{name = "Whirlwind", key = "berserker/whirlwind", level = 25, vocation = 15, glyphs = {
		-- wide: a circle of radius 2 (AREA_CIRCLE2X2) instead of 3x3
		A = {name = "Hurricane", description = "The area is a circle of 2 sqm of radius (5x5) instead of 3x3.",
			descriptionPt = "A area e um circulo de 2 sqm de raio (5x5) em vez de 3x3.",
			wide = true},
		-- heal: percent of the maximum health back for each enemy hit (up to `targets`)
		B = {name = "Bloodspin", description = "You recover 2% of your maximum health for each enemy hit (up to 5).",
			descriptionPt = "Voce recupera 2% da sua vida maxima por inimigo atingido (ate 5).",
			heal = {percent = 2, targets = 5}}
	}},
	{name = "Ground Slam", key = "berserker/ground slam", level = 30, vocation = 15, glyphs = {
		-- long: a bigger wave (one more sqm of range and two more of width at the far end)
		A = {name = "Seismic Reach", description = "A bigger wave: 1 more sqm of range and 2 more sqm of width at the far end.",
			descriptionPt = "Uma onda maior: 1 sqm a mais de alcance e 2 sqm a mais de largura na ponta.",
			long = true},
		-- stun: chance (%) of each creature hit to be paralyzed; slow: the normal slow of the spell, longer
		B = {name = "Tectonic Shock", description = "Each creature hit has a 30% chance to be paralyzed for 2 seconds, and the slow lasts 5 seconds instead of 3.",
			descriptionPt = "Cada criatura atingida tem 30% de chance de ficar paralisada por 2 segundos, e a lentidao dura 5 segundos em vez de 3.",
			stun = {chance = 30, percent = 0.95, duration = 2000, slow = {percent = 0.6, duration = 5000}}}
	}},
	{name = "Blood Pact", key = "berserker/blood pact", level = 35, vocation = 15, glyphs = {
		-- flesh: the leech of the pact is +14% instead of +8%
		A = {name = "Pact of Flesh", description = "The pact gives +14% life leech instead of +8%.",
			descriptionPt = "O pacto da +14% de life leech em vez de +8%.",
			flesh = true},
		-- vengeance: physical damage % (elemental amplification) and critical chance % while the pact lasts (buff in !buffs, subId 8454)
		B = {name = "Pact of Vengeance", description = "While the pact lasts you get +15% physical damage and +10% critical chance.",
			descriptionPt = "Enquanto o pacto durar voce ganha +15% de dano fisico e +10% de chance de critico.",
			vengeance = {amp = 15, critical = 10}}
	}},
	{name = "Rampage", key = "berserker/rampage", level = 40, vocation = 15, glyphs = {
		-- blows: number of blows in the same 1.2s; damage = multiplier of EACH blow: 6 blows of 1.3 * 4 / 6 = 130% of the original in total
		A = {name = "Relentless Rampage", description = "6 blows instead of 4 in the same time, for a total of 130% of the original damage.",
			descriptionPt = "6 golpes em vez de 4 no mesmo tempo, num total de 130% do dano original.",
			blows = {count = 6, damage = 1.3 * 4 / 6}},
		-- slow: percent (0.4 = 40% slower) for `duration` ms
		B = {name = "Hamstring", description = "The target is slowed by 40% for 4 seconds.",
			descriptionPt = "O alvo fica 40% mais lento por 4 segundos.",
			slow = {percent = 0.4, duration = 4000}}
	}},
	{name = "Skullsplitter", key = "berserker/skullsplitter", level = 46, vocation = 15, glyphs = {
		-- execute: the blow deals `damage` times more when the target has `below`% of its health or less
		A = {name = "Cranium Crusher", description = "The blow deals 50% more damage to targets with 30% health or less.",
			descriptionPt = "O golpe causa 50% a mais de dano em alvos com 30% de vida ou menos.",
			execute = {below = 30, damage = 1.5}},
		-- bounty: if the blow kills the target the health the spell cost comes back (15%) and `fury` stacks of Fury are given
		B = {name = "Bounty of Blood", description = "If the blow kills the target you get back the health the spell cost and gain 3 stacks of Fury.",
			descriptionPt = "Se o golpe matar o alvo voce recupera a vida que a magia custou e ganha 3 stacks de Furia.",
			bounty = {fury = 3}}
	}},
	{name = "Roar of Fury", key = "berserker/roar of fury", level = 54, vocation = 15, glyphs = {
		-- stacks: stacks of Fury given (5 normally)
		A = {name = "Berserk Roar", description = "Gives 7 stacks of Fury instead of 5.",
			descriptionPt = "Da 7 stacks de Furia em vez de 5.",
			stacks = 7},
		-- slow: every enemy within `radius` sqm is slowed by `percent` for `duration` ms
		B = {name = "Dreadful Roar", description = "Every enemy within 3 sqm is slowed by 40% for 4 seconds.",
			descriptionPt = "Todo inimigo a ate 3 sqm fica 40% mais lento por 4 segundos.",
			slow = {radius = 3, percent = 0.4, duration = 4000}}
	}},
	{name = "Earthshatter", key = "berserker/earthshatter", level = 58, vocation = 15, glyphs = {
		-- echo: a second wave `delay` ms later with `share` of the damage
		A = {name = "Aftershock", description = "A second wave shakes the ground 1.2 seconds later, with 60% of the damage.",
			descriptionPt = "Uma segunda onda sacode o chao 1,2 segundo depois, com 60% do dano.",
			echo = {delay = 1200, share = 0.6}},
		-- guard: % less damage from every element for `duration` ms (buff Stonehide in !buffs, subId 8451)
		B = {name = "Stonehide", description = "After the blow you take 20% less damage from every element for 8 seconds.",
			descriptionPt = "Depois do golpe voce recebe 20% menos dano de todo elemento por 8 segundos.",
			guard = {percent = 20, duration = 8000}}
	}},
	{name = "Blood Frenzy", key = "berserker/blood frenzy", level = 62, vocation = 15, glyphs = {
		-- haste: speed of the Haste spell while the frenzy lasts
		A = {name = "Hunting Frenzy", description = "You gain haste (+30% speed) while the frenzy lasts.",
			descriptionPt = "Voce ganha haste (+30% de velocidade) enquanto o frenzy durar.",
			haste = true},
		-- guard: % less damage from every element (buff Unbroken Frenzy in !buffs, subId 8453); immune: no paralysis
		B = {name = "Unbroken Frenzy", description = "While the frenzy lasts you take 15% less damage from every element and cannot be paralyzed.",
			descriptionPt = "Enquanto o frenzy durar voce recebe 15% menos dano de todo elemento e nao pode ser paralisado.",
			guard = {percent = 15}, immune = true}
	}},
	{name = "Titan's Wrath", key = "berserker/titans wrath", level = 66, vocation = 15, glyphs = {
		-- finale: the last blow hits a circle of radius 2 (5x5) and deals `damage` times more
		A = {name = "Cataclysm", description = "The last blow hits a circle of 2 sqm of radius (5x5) and deals 20% more damage.",
			descriptionPt = "O ultimo golpe atinge um circulo de 2 sqm de raio (5x5) e causa 20% a mais de dano.",
			finale = {damage = 1.2}},
		-- grip: every blow slows the enemies hit; the last one stuns them for `stun` ms instead
		B = {name = "Titan's Grip", description = "Every blow slows the enemies hit by 40% for 4 seconds, and the last one paralyzes them for 2 seconds.",
			descriptionPt = "Cada golpe deixa os inimigos atingidos 40% mais lentos por 4 segundos, e o ultimo os paralisa por 2 segundos.",
			grip = {percent = 0.4, duration = 4000, stun = 2000}}
	}},
	{name = "Undying Rage", key = "berserker/undying rage", level = 70, vocation = 15, glyphs = {
		-- heal: percent of the maximum health back when the rage ends
		A = {name = "Second Life", description = "When the rage ends you recover 30% of your maximum health.",
			descriptionPt = "Quando a furia acaba voce recupera 30% da sua vida maxima.",
			heal = {percent = 30}},
		-- vengeance: physical damage % (elemental amplification) and critical chance % while the rage lasts (buff in !buffs, subId 8455)
		B = {name = "Vengeful Rage", description = "While the rage lasts you get +30% physical damage and +15% critical chance.",
			descriptionPt = "Enquanto a furia durar voce ganha +30% de dano fisico e +15% de chance de critico.",
			vengeance = {amp = 30, critical = 15}}
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

-- points given by the staff command /glyph (tests): storage glyphStorageBase + 200 (the spells use +1 to +112; it was +99 before the berserker)
function Glyphs.bonusPoints(cid)
	return math.max(0, getPlayerStorageValue(cid, base() + 200))
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
	setPlayerStorageValue(cid, base() + 200, 0)
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

-- the caster and the players of its party that are within `radius` sqm of the caster
function Glyphs.allies(cid, radius)
	local list, from = {}, getCreaturePosition(cid)
	for _, tid in ipairs(getSpectators(from, radius, radius, false) or {}) do
		if(tid ~= cid and isPlayer(tid) and Cleric.isAlly(cid, tid) and getDistanceBetween(from, getCreaturePosition(tid)) <= radius) then
			table.insert(list, tid)
		end
	end

	table.insert(list, cid)
	return list
end

-- the speed of the Haste spell (+30%) for `ms`; a haste that is already running is never replaced
function Glyphs.haste(cid, ms)
	if(not isCreature(cid) or getCreatureCondition(cid, CONDITION_HASTE)) then
		return false
	end

	local condition = createConditionObject(CONDITION_HASTE)
	setConditionParam(condition, CONDITION_PARAM_TICKS, ms)
	setConditionFormula(condition, 0.3, -24, 0.3, -24)
	doAddCondition(cid, condition)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
	return true
end

-- buff (!buffs) made of a CONDITION_ATTRIBUTES. config = {name, description, duration, subId, params = {[CONDITION_PARAM_*] = value},
-- effect}. Every buff needs its own subId (8801 Storm Rage, 8810 Gravel Armor, 8811 Verdant Ward, 8812 Primal Fury, 8820 Savage Fury, 8821 Warlord's Roar, 8822 Hardened Skin, 8823 Unyielding, 8824 Iron Wall)
function Glyphs.statBuff(cid, config)
	return addCreatureBuff(cid, {
		name = config.name, category = config.name, duration = config.duration, description = config.description,
		onActivate = function(id)
			local condition = createConditionObject(CONDITION_ATTRIBUTES, config.duration, true, config.subId)
			for param, value in pairs(config.params) do
				setConditionParam(condition, param, value)
			end

			doAddCondition(id, condition)
			doSendMagicEffect(getCreaturePosition(id), config.effect or CONST_ME_MAGIC_GREEN)
		end,
		onRemove = function(id)
			if(isCreature(id)) then
				doRemoveCondition(id, CONDITION_ATTRIBUTES, config.subId)
			end
		end
	})
end

-- healing over time: `total` health in `ticks` heals, one every `interval` ms (stops if the target dies or leaves)
local function healTick(tid, amount, left, interval, effect)
	if(left <= 0 or not isCreature(tid) or getCreatureHealth(tid) <= 0) then
		return
	end

	doCreatureAddHealth(tid, amount)
	if(effect) then
		doSendMagicEffect(getCreaturePosition(tid), effect)
	end

	addEvent(healTick, interval, tid, amount, left - 1, interval, effect)
end

function Glyphs.healOverTime(tid, total, ticks, interval, effect)
	addEvent(healTick, interval, tid, math.max(1, math.floor(total / ticks)), ticks, interval, effect)
end

-- `percent`% of the maximum health of the creature, back every `interval` ms, `ticks` times
local function regenTick(cid, percent, left, interval)
	if(left <= 0 or not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	doCreatureAddHealth(cid, math.max(1, math.floor(getCreatureMaxHealth(cid) * percent / 100)))
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
	addEvent(regenTick, interval, cid, percent, left - 1, interval)
end

function Glyphs.regen(cid, percent, ticks, interval)
	addEvent(regenTick, interval, cid, percent, ticks, interval)
end

-- bleeding: `total` physical damage in `ticks` hits, one every `interval` ms (stops if the caster or the target are gone)
local function bleedTick(cid, target, amount, left, interval)
	if(left <= 0 or not isCreature(cid) or not isCreature(target) or getCreatureHealth(target) <= 0) then
		return
	end

	doTargetCombatHealth(cid, target, COMBAT_PHYSICALDAMAGE, -amount, -amount, CONST_ME_DRAWBLOOD)
	addEvent(bleedTick, interval, cid, target, amount, left - 1, interval)
end

function Glyphs.bleed(cid, target, total, ticks, interval)
	addEvent(bleedTick, interval, cid, target, math.max(1, math.floor(total / ticks)), ticks, interval)
end

-- no paralysis for `ms`: the paralysis is removed every 400 ms
local function immuneTick(cid, left)
	if(left <= 0 or not isCreature(cid)) then
		return
	end

	if(getCreatureCondition(cid, CONDITION_PARALYZE)) then
		doRemoveCondition(cid, CONDITION_PARALYZE)
	end

	addEvent(immuneTick, 400, cid, left - 1)
end

function Glyphs.paralysisImmunity(cid, ms)
	immuneTick(cid, math.ceil(ms / 400))
end

-- pushes every creature of `list` 1 sqm away from the caster (the farthest first, so the ones behind get out of the way); chance in %
function Glyphs.pushAll(cid, list, chance)
	local from, entries = getCreaturePosition(cid), {}
	for _, tid in ipairs(list) do
		if(isCreature(tid) and getCreatureHealth(tid) > 0) then
			table.insert(entries, {id = tid, distance = getDistanceBetween(from, getCreaturePosition(tid))})
		end
	end

	table.sort(entries, function(a, b) return a.distance > b.distance end)
	for _, entry in ipairs(entries) do
		if(isCreature(entry.id)) then
			Push.away(cid, entry.id, chance)
		end
	end
end

-- params for Glyphs.statBuff: `percent`% less damage from every element
function Glyphs.absorbAll(percent)
	return {
		[CONDITION_PARAM_ABSORB_PHYSICAL] = percent, [CONDITION_PARAM_ABSORB_ENERGY] = percent,
		[CONDITION_PARAM_ABSORB_EARTH] = percent, [CONDITION_PARAM_ABSORB_FIRE] = percent,
		[CONDITION_PARAM_ABSORB_ICE] = percent, [CONDITION_PARAM_ABSORB_HOLY] = percent,
		[CONDITION_PARAM_ABSORB_DEATH] = percent, [CONDITION_PARAM_ABSORB_DROWN] = percent
	}
end

-- removes every harmful condition of the creature
local harmful = {CONDITION_POISON, CONDITION_FIRE, CONDITION_ENERGY, CONDITION_PARALYZE, CONDITION_DROWN, CONDITION_FREEZING,
	CONDITION_DAZZLED, CONDITION_CURSED, CONDITION_DRUNK}
function Glyphs.cleanse(cid)
	for _, condition in ipairs(harmful) do
		if(getCreatureCondition(cid, condition)) then
			doRemoveCondition(cid, condition)
		end
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
