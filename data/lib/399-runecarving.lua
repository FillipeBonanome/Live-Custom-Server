-- Runecarving: the enchantment runes (see data/XML/enchantments.xml) are not sold or dropped anymore, they are carved by the
-- runesmith NPC (data/npc/scripts/runesmith.lua) from a blank rune (the only rune the NPCs sell). See doc/sistemas/38-runecarving.md.
--
-- The price of a rune depends on the rarity tier of the enchantment: gold + amount of the gem of its element.
--
-- RuneCarving.recipe(name)              recipe of the enchantment (nil if it does not exist)
-- RuneCarving.carve(cid, name)          carves the rune (checks everything, takes the price and gives the rune). Returns true, or false and the reason
-- RuneCarving.description(name)         what the enchantment does, in words (for the NPC)

RuneCarving = {
	blankRune = 2260,
	effect = CONST_ME_MAGIC_BLUE,

	-- cost of each tier (rarity). gems = amount of the material of the element, gold = price
	tiers = {
		{name = "Uncommon", gems = 2, gold = 500},
		{name = "Rare", gems = 4, gold = 2000},
		{name = "Epic", gems = 6, gold = 8000},
		{name = "Legendary", gems = 10, gold = 30000}
	},

	-- the material of each element
	materials = {
		earth = 2149, -- small emerald
		fire = 2147, -- small ruby
		energy = 2150, -- small amethyst
		ice = 2146, -- small sapphire
		holy = 2145, -- small diamond
		death = 2144, -- black pearl
		arcane = 2143 -- white pearl
	}
}

-- name = {rune item id (enchantments.xml), tier (1 uncommon .. 4 legendary), element}
RuneCarving.recipes = {
	["Venomous"] = {2285, 1, "earth"}, ["Blight"] = {2289, 1, "earth"}, ["Stoneskin"] = {2288, 1, "earth"},
	["Flaming"] = {2301, 1, "fire"}, ["Inferno"] = {2303, 1, "fire"}, ["Fireball"] = {2302, 1, "fire"},
	["Shocking"] = {2277, 1, "energy"}, ["Storm"] = {2279, 1, "energy"},
	["Frost"] = {2271, 1, "ice"}, ["Glacial"] = {2274, 1, "ice"}, ["Clearing"] = {2261, 1, "ice"},
	["Holy"] = {2295, 1, "holy"}, ["Purity"] = {2266, 1, "holy"}, ["Vitality"] = {2265, 1, "holy"},
	["Piercing"] = {2287, 1, "arcane"},

	["Toxic"] = {2286, 2, "earth"}, ["Earthen"] = {2292, 2, "earth"}, ["Overgrowth"] = {2269, 2, "earth"},
	["Scorching"] = {2305, 2, "fire"}, ["Soulburn"] = {2308, 2, "fire"},
	["Overload"] = {2262, 2, "energy"}, ["Thunder"] = {2315, 2, "energy"},
	["Warding"] = {2293, 2, "ice"},
	["Charm"] = {2290, 2, "holy"},
	["Necrotic"] = {2316, 2, "death"}, ["Disintegrating"] = {2310, 2, "death"}, ["Chameleon"] = {2291, 2, "death"},
	["Heavy Piercing"] = {2311, 2, "arcane"}, ["Explosive"] = {2313, 2, "arcane"},

	["Meteor"] = {2304, 3, "fire"}, ["Combustion"] = {2276, 3, "fire"},
	["Lightning"] = {2281, 3, "energy"},
	["Prison"] = {2272, 3, "ice"},
	["Rejuvenating"] = {2273, 3, "holy"},
	["Paralyzing"] = {2278, 3, "death"}, ["Drunken"] = {2267, 3, "death"},

	["Deadly"] = {2268, 4, "death"},
	["Shadow"] = {2283, 4, "death"},
	["Arcane"] = {2270, 4, "arcane"}
}

-- lower case name -> name, so the player does not need to care about the case
RuneCarving.names = {}
for name, _ in pairs(RuneCarving.recipes) do
	RuneCarving.names[string.lower(name)] = name
end

function RuneCarving.recipe(name)
	local key = RuneCarving.names[string.lower(tostring(name))]
	if(not key) then
		return nil
	end

	local data = RuneCarving.recipes[key]
	local tier = RuneCarving.tiers[data[2]]
	return {
		name = key, rune = data[1], tier = tier.name, gold = tier.gold,
		material = RuneCarving.materials[data[3]], gems = tier.gems
	}
end

-- what each enchantment does (the bonuses are in enchantments.xml; keep both in sync)
RuneCarving.descriptions = {
	["Venomous"] = "Your hits poison the enemy with a bit of earth damage (weapons).",
	["Blight"] = "Your attacks pierce earth resistance (helmet, armor, legs, boots).",
	["Stoneskin"] = "Hardens your gear with +2 armor (helmet, armor, legs, boots, shield).",
	["Flaming"] = "Your hits burn with a bit of fire damage (weapons).",
	["Inferno"] = "Your attacks pierce fire resistance (helmet, armor, legs, boots).",
	["Fireball"] = "+4 attack (swords, clubs, axes).",
	["Shocking"] = "Your hits shock with a bit of energy damage (weapons).",
	["Storm"] = "Your attacks pierce energy resistance (helmet, armor, legs, boots).",
	["Frost"] = "Your hits chill with a bit of ice damage (weapons).",
	["Glacial"] = "Your attacks pierce ice resistance (helmet, armor, legs, boots).",
	["Clearing"] = "Light feet: +20 speed (boots).",
	["Holy"] = "Your hits carry holy damage (weapons).",
	["Purity"] = "A little dodge chance (helmet, armor, legs, boots, shield).",
	["Vitality"] = "+40 maximum health (helmet, armor, legs, boots).",
	["Piercing"] = "Your shots pierce physical resistance (distance weapons and wands).",

	["Toxic"] = "Stronger poison on your hits and some earth penetration (weapons).",
	["Earthen"] = "+2 bonus armor and +30 maximum health (helmet, armor, legs, boots, shield).",
	["Overgrowth"] = "+25 maximum health and +1 bonus defense (helmet, armor, legs, boots).",
	["Scorching"] = "Stronger fire on your hits and some fire penetration (weapons).",
	["Soulburn"] = "Leeches mana and gives +30 maximum mana (necklace, ring).",
	["Overload"] = "Stronger energy on your hits and some energy penetration (weapons).",
	["Thunder"] = "Energy hits with a chance to critical (wands and distance weapons).",
	["Warding"] = "+3 defense and blocks one more hit (shield, armor).",
	["Charm"] = "A bonus on the experience you earn (necklace, ring).",
	["Necrotic"] = "Leeches life from the enemy (weapons).",
	["Disintegrating"] = "Your attacks pierce physical resistance (swords, clubs, axes).",
	["Chameleon"] = "More dodge chance (helmet, armor, legs).",
	["Heavy Piercing"] = "Stronger physical penetration and +3 attack (distance weapons and wands).",
	["Explosive"] = "More chance for critical hits (swords, clubs, axes, distance).",

	["Meteor"] = "+7 attack and +5 critical damage (swords, clubs, axes).",
	["Combustion"] = "Strong fire on your hits plus a bit of critical chance (weapons).",
	["Lightning"] = "Strong energy on your hits and +1 distance skill (distance weapons and wands).",
	["Prison"] = "Blocks 2 more hits (shield, armor, legs).",
	["Rejuvenating"] = "+80 maximum health and more critical healing (helmet, armor, legs, boots).",
	["Paralyzing"] = "More critical chance and a bit of dodge (swords, clubs, axes, distance).",
	["Drunken"] = "+2 club and axe skill (clubs, axes).",

	["Deadly"] = "Death damage on your hits and +10 critical damage (weapons).",
	["Shadow"] = "Greater dodge and +20 speed (helmet, armor, legs, boots).",
	["Arcane"] = "+1 magic level (wands, necklace, ring)."
}

function RuneCarving.description(name)
	local key = RuneCarving.names[string.lower(tostring(name))]
	return key and RuneCarving.descriptions[key] or ""
end

-- Returns true on success, or false and the reason.
function RuneCarving.carve(cid, name)
	local recipe = RuneCarving.recipe(name)
	if(not recipe) then
		return false, "There is no rune with this name."
	end

	if(getPlayerItemCount(cid, RuneCarving.blankRune) < 1) then
		return false, "You need a blank rune."
	end

	if(getPlayerItemCount(cid, recipe.material) < recipe.gems) then
		return false, "You need " .. recipe.gems .. " " .. getItemNameById(recipe.material) .. "s."
	end

	if(getPlayerMoney(cid) < recipe.gold) then
		return false, "You need " .. recipe.gold .. " gold coins."
	end

	-- the rune goes first: if it does not fit the player keeps everything
	if(not doPlayerAddItem(cid, recipe.rune, 1)) then
		return false, "You have no room (or capacity) for the rune."
	end

	doPlayerRemoveItem(cid, RuneCarving.blankRune, 1)
	doPlayerRemoveItem(cid, recipe.material, recipe.gems)
	doPlayerRemoveMoney(cid, recipe.gold)
	doSendMagicEffect(getThingPosition(cid), RuneCarving.effect)
	doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You carved a " .. recipe.name .. " rune (" .. recipe.tier .. "). Use it on an item with a free enchantment slot.")
	return true
end

-- RESPECT (runesmith NPC Durnok Runebrand): the NPC carves the runes of the tier 1 for anyone; the rank of respect of the player
-- unlocks the next tiers (rank n = tier n). Respect is earned delivering the items of the missions below, one after the other.
-- Missions are saved in storages (done flag), so never reorder or remove entries; append new ones at the end.
RuneCarving.storageRespect = 56000
RuneCarving.storageMission = 56001 -- + mission position: 1 when delivered

RuneCarving.ranks = {
	{name = "Stranger", respect = 0},
	{name = "Apprentice of the Forge", respect = 30},
	{name = "Forge Companion", respect = 100},
	{name = "Heart of the Mountain", respect = 250}
}

-- item = id of the item to deliver, respect = reward, text = what the NPC says
RuneCarving.missions = {
	{item = 5878, count = 30, respect = 10, text = "My boots are worn thin from walking on cold stone. Bring me {30 minotaur leathers} and I shall mend them."},
	{item = 5881, count = 30, respect = 10, text = "A good carving tool needs a scaled grip. Bring me {30 lizard scales} from the swamps."},
	{item = 5897, count = 40, respect = 10, text = "The winter is coming and the forge is cold. Bring me {40 wolf paws}, I will make charms of them."},

	{item = 5879, count = 25, respect = 15, text = "A rune must be bound with silk that never breaks. Bring me {25 giant spider silks}."},
	{item = 5898, count = 20, respect = 15, text = "I need eyes that see what stone hides. Bring me {20 beholder eyes}."},
	{item = 5882, count = 10, respect = 20, text = "Dragonfire tempers the best chisels. Bring me {10 red dragon scales}."},
	{item = 5911, count = 15, respect = 20, text = "My banner burnt in the last fire. Bring me {15 red pieces of cloth}."},

	{item = 5954, count = 10, respect = 30, text = "Now the real work. The old powers hide in demon bone. Bring me {10 demon horns}."},
	{item = 6500, count = 30, respect = 30, text = "Legendary runes drink essence. Bring me {30 demonic essences}."},
	{item = 5893, count = 5, respect = 30, text = "Only the strongest beasts leave such trophies. Bring me {5 perfect behemoth fangs}."},
	{item = 5943, count = 3, respect = 40, text = "The greatest proof of all: slay the lord of the flames and bring me {3 Morgaroth's hearts}."},
	{item = 5944, count = 10, respect = 20, text = "One last thing, and then the mountain itself will know your name: {10 soul orbs}."}
}

function RuneCarving.getRespect(cid)
	return math.max(0, getPlayerStorageValue(cid, RuneCarving.storageRespect))
end

-- index of the rank of the player (= highest tier of runes the NPC carves for him)
function RuneCarving.getRank(cid)
	local respect = RuneCarving.getRespect(cid)
	local rank = 1
	for index, data in ipairs(RuneCarving.ranks) do
		if(respect >= data.respect) then
			rank = index
		end
	end

	return rank
end

-- index of the first mission not delivered yet (nil when all are done)
function RuneCarving.currentMission(cid)
	for index = 1, #RuneCarving.missions do
		if(getPlayerStorageValue(cid, RuneCarving.storageMission + index) ~= 1) then
			return index
		end
	end

	return nil
end

-- takes the items of the current mission and gives the respect. Returns true, respect gained, new rank name or nil (or false, reason)
function RuneCarving.deliver(cid)
	local index = RuneCarving.currentMission(cid)
	if(not index) then
		return false, "You have no missions left."
	end

	local mission = RuneCarving.missions[index]
	if(getPlayerItemCount(cid, mission.item) < mission.count) then
		return false, "You need " .. mission.count .. " " .. getItemNameById(mission.item) .. "s."
	end

	local rankBefore = RuneCarving.getRank(cid)
	doPlayerRemoveItem(cid, mission.item, mission.count)
	setPlayerStorageValue(cid, RuneCarving.storageMission + index, 1)
	setPlayerStorageValue(cid, RuneCarving.storageRespect, RuneCarving.getRespect(cid) + mission.respect)

	local rankAfter = RuneCarving.getRank(cid)
	return true, mission.respect, (rankAfter > rankBefore) and RuneCarving.ranks[rankAfter].name or nil
end
