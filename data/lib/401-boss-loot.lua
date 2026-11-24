-- Boss loot: the invasion bosses (see 390-invasions.lua and 393..398) drop their own uniques (data/XML/uniques.xml, two per
-- boss) and enchantment runes (the same runes the Runecarving NPC makes, see 399-runecarving.lua) in the corpse.
-- Called by the AIDeath creature event (ai_death.lua), so the boss needs the "AI Think" attack like all the bosses.
-- Docs: doc/sistemas/40-loot-dos-bosses.md

BossLoot = {
	-- % of each unique of the boss to drop (rolled one by one, so a kill can drop none, one or both)
	uniqueChance = {20, 18, 16, 14, 12},

	-- runes: how many are always dropped, and the weights of the rune tier (1 Uncommon .. 4 Legendary, same as RuneCarving.tiers)
	runeCount = {1, 2, 2, 3, 3},
	runeTierWeights = {
		{[1] = 70, [2] = 30},
		{[1] = 30, [2] = 60, [3] = 10},
		{[2] = 40, [3] = 50, [4] = 10},
		{[2] = 20, [3] = 60, [4] = 20},
		{[3] = 40, [4] = 60}
	},
	-- % of the runes that match the element of the boss (when it has one of that tier)
	elementChance = 60,

	-- send a message to the server when a unique drops
	broadcast = true
}

BossLoot.bosses = {
	["Chief Grumbak"] = {tier = 1, element = "ice", uniques = {"Grumbak's Frostcleaver", "Frozen Chieftain's Furs"}},
	["Fenrak Moonfang"] = {tier = 1, element = "physical", uniques = {"Moonfang Blade", "Alpha's Pelt Mail"}},
	["Queen Silkara"] = {tier = 1, element = "earth", uniques = {"Silkara's Venom Fang", "Brood Mother's Crown"}},
	["Warlord Ruzad"] = {tier = 1, element = "physical", uniques = {"Ruzad's Warbrand", "Warlord's Crushing Helm"}},
	["Captain Blackreef"] = {tier = 2, element = "fire", uniques = {"Blackreef Cutlass", "Captain's Sea Coat"}},
	["Empress Aethra"] = {tier = 2, element = "physical", uniques = {"Aethra's Spearbow", "Empress Circlet"}},
	["Forgemaster Brokk"] = {tier = 2, element = "physical", uniques = {"Brokk's Forgehammer", "Forgemaster's Plate"}},
	["Hexlord Mokthar"] = {tier = 2, element = "energy", uniques = {"Mokthar's Hex Staff", "Hexlord Horns"}},
	["Hierarch Ssurrak"] = {tier = 2, element = "earth", uniques = {"Ssurrak's Sunblade", "Hierarch's Scale Shield"}},
	["Titan Korg"] = {tier = 2, element = "physical", uniques = {"Korg's Boulder Maul", "Titan's Greaves"}},
	["Vizier Khalzar"] = {tier = 2, element = "energy", uniques = {"Khalzar's Lamp Wand", "Vizier's Slippers"}},
	["Glaciarch Vorthrax"] = {tier = 3, element = "ice", uniques = {"Vorthrax Icebrand", "Glaciarch's Plate"}},
	["Iron Overseer Kragmor"] = {tier = 3, element = "energy", uniques = {"Kragmor's Overclock Axe", "Overseer's Servo Boots"}},
	["Necrarch Mortheus"] = {tier = 3, element = "death", uniques = {"Mortheus' Harvest Rod", "Harvester's Amulet"}},
	["Nightmare Weaver Syrelith"] = {tier = 3, element = "death", uniques = {"Syrelith's Dreamthread", "Nightmare Greaves"}},
	["Pyrothane the Cinderlord"] = {tier = 3, element = "fire", uniques = {"Pyrothane's Cinderblade", "Cinderlord's Shield"}},
	["Countess Sanguessa"] = {tier = 4, element = "death", uniques = {"Sanguessa's Bloodthorn", "Countess' Crimson Mantle"}},
	["Forgelord Vexmar"] = {tier = 4, element = "earth", uniques = {"Vexmar's Plaguehammer", "Plagueforged Legs"}},
	["Matriarch Ignaria"] = {tier = 4, element = "fire", uniques = {"Ignaria's Embertongue", "Matriarch's Flamecrown"}},
	["Warlord Zhardakkan"] = {tier = 4, element = "fire", uniques = {"Zhardakkan's Drakebreaker", "Draken Warplate"}},
	["Wyrmlord Azhrakar"] = {tier = 4, element = "death", uniques = {"Azhrakar's Wyrmfang", "Wyrmlord's Aegis"}},
	["Archfiend Zulkarath"] = {tier = 5, element = "fire", uniques = {"Zulkarath's Hellbrand", "Archfiend's Demonplate"}},
	["Deathwyrm Nekhrazul"] = {tier = 5, element = "death", uniques = {"Nekhrazul's Grave Staff", "Deathwyrm Crown"}},
	["Hellforged Overlord Malgorath"] = {tier = 5, element = "energy", uniques = {"Malgorath's Hellmaul", "Overlord's Hellshield"}},
}

-- pool of runes: [tier] = {{name, rune item id, element}, ...}
local pool
local function runePool()
	if(pool) then
		return pool
	end

	pool = {}
	if(RuneCarving and RuneCarving.recipes) then
		for name, data in pairs(RuneCarving.recipes) do
			pool[data[2]] = pool[data[2]] or {}
			table.insert(pool[data[2]], {name = name, id = data[1], element = data[3]})
		end
	end

	return pool
end

local function rollTier(tier)
	local weights = BossLoot.runeTierWeights[tier] or BossLoot.runeTierWeights[1]
	local total = 0
	for _, w in pairs(weights) do
		total = total + w
	end

	local roll, sum = math.random(total), 0
	for runeTier = 1, 4 do
		sum = sum + (weights[runeTier] or 0)
		if(roll <= sum) then
			return runeTier
		end
	end

	return 1
end

-- random rune of the tier, preferring the element of the boss
function BossLoot.rollRune(def)
	local runes = runePool()[rollTier(def.tier)]
	if(not runes or #runes == 0) then
		return nil
	end

	if(math.random(100) <= BossLoot.elementChance) then
		local matching = {}
		for _, rune in ipairs(runes) do
			if(rune.element == def.element) then
				table.insert(matching, rune)
			end
		end

		if(#matching > 0) then
			runes = matching
		end
	end

	return runes[math.random(#runes)]
end

-- puts the item in the corpse, or at the feet of the boss when the corpse is full
local function give(corpse, pos, itemId, unique)
	local item = doCreateItemEx(itemId, 1)
	if(not item or item <= 0) then
		return false
	end

	if(unique and not doItemSetUnique(item, unique)) then
		return false
	end

	if(corpse and corpse > 0 and doAddContainerItemEx(corpse, item) == RETURNVALUE_NOERROR) then
		return true
	end

	return doTileAddItemEx(pos, item) == RETURNVALUE_NOERROR
end

-- death of the monster `cid` (corpse = the table of the onDeath event). Does nothing for monsters that are not in BossLoot.bosses.
function BossLoot.drop(cid, corpse)
	local name = getCreatureName(cid)
	local def = name and BossLoot.bosses[name]
	if(not def) then
		return false
	end

	local uid = type(corpse) == "table" and corpse.uid or nil
	local pos = getCreaturePosition(cid)
	local tier = def.tier

	for _, unique in ipairs(def.uniques) do
		if(math.random(100) <= (BossLoot.uniqueChance[tier] or 10)) then
			local itemId = getUniqueItemId(unique)
			if(itemId and give(uid, pos, itemId, unique) and BossLoot.broadcast) then
				doBroadcastMessage(name .. " dropped the unique " .. unique .. "!", MESSAGE_STATUS_WARNING)
			end
		end
	end

	for i = 1, (BossLoot.runeCount[tier] or 1) do
		local rune = BossLoot.rollRune(def)
		if(rune) then
			give(uid, pos, rune.id)
		end
	end

	return true
end
