-- Race system.
-- The chosen race is kept in a player storage. Each race grants its outfits (outfit id == looktype, see XML/outfits.xml)
-- and a generic attribute bonus (CONDITION_ATTRIBUTES, re-applied on login because endless conditions are not saved).
-- Change the bonus of a race by editing its "bonus" table (keys are CONDITION_PARAM_* constants).

RACE_STORAGE = 52200
RACE_CONDITION_SUBID = 8200
RACE_DEFAULT_OUTFIT = 294 -- Wisp
RACE_COOLDOWN_STORAGE = 52201 -- os.time() of the last race change made at Magister Cassian Vael (race NPC)

RACES = {
	{name = "Human", outfits = {128, 129, 130, 131, 132, 133, 134, 143, 144, 145, 146, 151, 152, 153, 154, 251, 268, 273, 278, 289, 325, 335, 367},
		bonus = {[CONDITION_PARAM_EXPERIENCE] = 5, [CONDITION_PARAM_LOOT] = 3, [CONDITION_PARAM_COOLDOWNREDUCTION] = 3}},
	{name = "Orc", outfits = {2, 5, 6, 7, 8, 59},
		bonus = {[CONDITION_PARAM_STAT_MAXHEALTH] = 100, [CONDITION_PARAM_SKILL_MELEE] = 3, [CONDITION_PARAM_CRITICALDAMAGE] = 10}},
	{name = "Dwarf", outfits = {66, 69, 70, 71},
		bonus = {[CONDITION_PARAM_ARMOR] = 3, [CONDITION_PARAM_DEFENSE] = 3, [CONDITION_PARAM_BLOCKCOUNT] = 1, [CONDITION_PARAM_STAT_MAXHEALTH] = 50}},
	{name = "Undead", outfits = {18, 33, 37, 48, 65, 68, 78, 84, 87, 99, 100, 195, 196, 298, 306, 311, 312},
		bonus = {[CONDITION_PARAM_LIFELEECH] = 3, [CONDITION_PARAM_ELEMENTAL_AMP_DEATH] = 10, [CONDITION_PARAM_PENETRATION_DEATH] = 5}},
	{name = "Elf", outfits = {62, 63, 64},
		bonus = {[CONDITION_PARAM_DODGE] = 5, [CONDITION_PARAM_SKILL_DISTANCE] = 3, [CONDITION_PARAM_CRITICALCHANCE] = 3}},
	{name = "Minotaur", outfits = {23, 24, 25, 29},
		bonus = {[CONDITION_PARAM_STAT_MAXHEALTH] = 150, [CONDITION_PARAM_ARMOR] = 2, [CONDITION_PARAM_SKILL_MELEE] = 2}},
	{name = "Goblin", outfits = {61, 296, 297},
		bonus = {[CONDITION_PARAM_LOOT] = 10, [CONDITION_PARAM_DODGE] = 3, [CONDITION_PARAM_EXPERIENCE] = 2}},
	{name = "Lizard", outfits = {113, 114, 115, 334, 337, 338, 339, 340, 343, 344, 345, 357, 362},
		bonus = {[CONDITION_PARAM_ELEMENTAL_AMP_EARTH] = 10, [CONDITION_PARAM_PENETRATION_EARTH] = 5, [CONDITION_PARAM_STAT_MAXMANA] = 100}}
}

-- Lore of each race, shown by Magister Cassian Vael before the player confirms the choice (the bonuses are listed below it)
RACE_LORE = {
	["Human"] = "The most numerous of the peoples, neither the strongest nor the swiftest, yet the most adaptable. Humans learn quickly, trade shrewdly and bend every craft to their will. Where others are born with a gift, a human builds one.",
	["Orc"] = "Born in the fortresses of the mountains, the orcs live by the strength of their arms. Their clans measure honor in scars and victory in the number of enemies fallen. Few warriors strike as hard as a furious orc.",
	["Dwarf"] = "Children of stone and ember, the dwarves delve the deepest mines and forge the finest steel. Stubborn as the mountain itself, they endure what would break any other, and their armor is the envy of kings.",
	["Undead"] = "Those whom death refused to keep. The undead walk between two worlds, feeding on the life of the living and bending the powers of death. Cold, patient, and very hard to destroy for good.",
	["Elf"] = "Graceful keepers of the ancient forests, the elves are swift, keen of eye and nearly impossible to strike. Their arrows rarely miss and their feet barely touch the ground.",
	["Minotaur"] = "Tall, broad and tireless, the minotaurs descend from the labyrinths of the old kingdoms. Their hides turn blades and their horns have broken more than a few shields. Power, plainly spoken.",
	["Goblin"] = "Small, quick and endlessly resourceful, goblins find treasure where others see rubbish. They are slippery in battle and fortune seems to follow them, or perhaps they simply never leave anything behind.",
	["Lizard"] = "Hardened by the swamps and ancient temples of the south, the lizard folk are heirs of a forgotten empire. They command the energies of the earth and have a deep well of magical reserves."
}

-- how each bonus is described to the player
RACE_BONUS_TEXT = {
	[CONDITION_PARAM_EXPERIENCE] = "+%d%% experience",
	[CONDITION_PARAM_LOOT] = "+%d%% loot chance",
	[CONDITION_PARAM_COOLDOWNREDUCTION] = "-%d%% spell cooldowns",
	[CONDITION_PARAM_STAT_MAXHEALTH] = "+%d maximum health",
	[CONDITION_PARAM_STAT_MAXMANA] = "+%d maximum mana",
	[CONDITION_PARAM_SKILL_MELEE] = "+%d melee skills",
	[CONDITION_PARAM_SKILL_DISTANCE] = "+%d distance skill",
	[CONDITION_PARAM_CRITICALDAMAGE] = "+%d%% critical damage",
	[CONDITION_PARAM_CRITICALCHANCE] = "+%d%% critical chance",
	[CONDITION_PARAM_ARMOR] = "+%d armor",
	[CONDITION_PARAM_DEFENSE] = "+%d defense",
	[CONDITION_PARAM_BLOCKCOUNT] = "blocks %d more hit(s)",
	[CONDITION_PARAM_LIFELEECH] = "+%d%% life leech",
	[CONDITION_PARAM_DODGE] = "+%d%% dodge",
	[CONDITION_PARAM_ELEMENTAL_AMP_DEATH] = "+%d%% death damage",
	[CONDITION_PARAM_PENETRATION_DEATH] = "+%d%% death penetration",
	[CONDITION_PARAM_ELEMENTAL_AMP_EARTH] = "+%d%% earth damage",
	[CONDITION_PARAM_PENETRATION_EARTH] = "+%d%% earth penetration"
}

-- text of the dialog with the lore, the bonuses and the outfits of the race
function getRaceDescription(raceIndex)
	local race = RACES[raceIndex]
	if(not race) then
		return ""
	end

	local lines = {}
	for param, value in pairs(race.bonus) do
		local format = RACE_BONUS_TEXT[param]
		table.insert(lines, "- " .. (format and string.format(format, value) or ("bonus " .. value)))
	end

	table.sort(lines)
	local nl = string.char(10)
	return race.name .. nl .. nl .. (RACE_LORE[race.name] or "") .. nl .. nl .. "Bonuses:" .. nl .. table.concat(lines, nl) ..
		nl .. nl .. "Choosing this race removes all your current outfits and gives you the " .. #race.outfits .. " outfits of the " .. race.name .. "s."
end

function getRaceByName(name)
	name = tostring(name):trim():lower()
	for index, race in ipairs(RACES) do
		if(race.name:lower() == name) then
			return index, race
		end
	end

	return nil
end

function getPlayerRace(cid)
	local index = tonumber(getPlayerStorageValue(cid, RACE_STORAGE))
	if(index and RACES[index]) then
		return index, RACES[index]
	end

	return nil
end

-- The default Wisp outfit is given back to everybody on login, so it is removed again whenever the race has outfits of its own
function doPlayerRemoveWisp(cid)
	local _, race = getPlayerRace(cid)
	if(race and #race.outfits > 0) then
		doPlayerRemoveOutfitId(cid, RACE_DEFAULT_OUTFIT)
	end
end

function doPlayerApplyRaceBonus(cid)
	doRemoveCondition(cid, CONDITION_ATTRIBUTES, RACE_CONDITION_SUBID)
	doPlayerRemoveWisp(cid)
	local _, race = getPlayerRace(cid)
	if(not race) then
		return false
	end

	local condition = createConditionObject(CONDITION_ATTRIBUTES)
	setConditionParam(condition, CONDITION_PARAM_TICKS, -1)
	setConditionParam(condition, CONDITION_PARAM_SUBID, RACE_CONDITION_SUBID)
	for param, value in pairs(race.bonus) do
		setConditionParam(condition, param, value)
	end

	return doAddCondition(cid, condition)
end

-- Gives the new race (removing every outfit of the old ones), swaps the current outfit for a random one of the new
-- race and applies the bonus. Returns false when the race does not exist.
function doPlayerSetRace(cid, raceIndex)
	local race = RACES[raceIndex]
	if(not race) then
		return false
	end

	-- remove every race outfit the player has
	for _, other in ipairs(RACES) do
		for _, lookType in ipairs(other.outfits) do
			doPlayerRemoveOutfitId(cid, lookType)
		end
	end

	-- random outfit of the new race, set before the new outfits are handed out
	local outfit = getCreatureOutfit(cid)
	if(#race.outfits > 0) then
		outfit.lookType = race.outfits[math.random(#race.outfits)]
	else
		outfit.lookType = RACE_DEFAULT_OUTFIT -- race without outfits: back to the default one
	end
	outfit.lookAddons = 0
	doCreatureChangeOutfit(cid, outfit)

	for _, lookType in ipairs(race.outfits) do
		doPlayerAddOutfitId(cid, lookType, 0)
	end

	doCreatureSetStorage(cid, RACE_STORAGE, raceIndex)
	doPlayerApplyRaceBonus(cid)
	return true
end

-- Race change cooldown (config.lua: raceChangeCooldown, in seconds) --------------------------------------------------

function getRaceChangeCooldown()
	local value = getConfigValue('raceChangeCooldown')
	if(value == nil) then
		return 86400
	end

	return math.max(0, tonumber(value) or 0)
end

-- seconds the player still has to wait to change race (0 = can change; the first choice is always free)
function getPlayerRaceCooldownLeft(cid)
	if(not getPlayerRace(cid)) then
		return 0
	end

	local last = tonumber(getPlayerStorageValue(cid, RACE_COOLDOWN_STORAGE)) or 0
	return math.max(0, last + getRaceChangeCooldown() - os.time())
end

-- starts the cooldown (call after a change made by the player, not for the first choice)
function doPlayerStartRaceCooldown(cid)
	doCreatureSetStorage(cid, RACE_COOLDOWN_STORAGE, os.time())
end

function formatRaceCooldown(seconds)
	local days = math.floor(seconds / 86400)
	local hours = math.floor((seconds % 86400) / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	if(days > 0) then
		return days .. "d " .. hours .. "h"
	elseif(hours > 0) then
		return hours .. "h " .. minutes .. "min"
	end

	return math.max(1, minutes) .. "min"
end
