-- !attributes
-- Shows the player's relevant attributes in a text dialog.
local SKILLS = {
	{SKILL_FIST, "Fist Fighting"},
	{SKILL_CLUB, "Club Fighting"},
	{SKILL_SWORD, "Sword Fighting"},
	{SKILL_AXE, "Axe Fighting"},
	{SKILL_DISTANCE, "Distance Fighting"},
	{SKILL_SHIELD, "Shielding"},
	{SKILL_FISHING, "Fishing"}
}

local ELEMENTS = {
	{COMBAT_PHYSICALDAMAGE, "Physical"},
	{COMBAT_ENERGYDAMAGE, "Energy"},
	{COMBAT_EARTHDAMAGE, "Earth"},
	{COMBAT_FIREDAMAGE, "Fire"},
	{COMBAT_ICEDAMAGE, "Ice"},
	{COMBAT_HOLYDAMAGE, "Holy"},
	{COMBAT_DEATHDAMAGE, "Death"},
	{COMBAT_DROWNDAMAGE, "Drown"}
}

function onSay(cid, words, param, channel)
	local level = getPlayerLevel(cid)
	local nextExp = getExperienceForLevel(level + 1)
	local rates = getPlayerRates(cid) or {}

	local t = {}
	local function add(text) table.insert(t, text) end

	add("[General]")
	add("Name: " .. getCreatureName(cid))
	add("Vocation: " .. getPlayerVocationName(cid))
	add("Level: " .. level)
	add("Experience: " .. getPlayerExperience(cid) .. " (" .. math.max(0, nextExp - getPlayerExperience(cid)) .. " to next level)")
	add("")
	add("[Status]")
	add("Health: " .. getCreatureHealth(cid) .. " / " .. getCreatureMaxHealth(cid))
	add("Mana: " .. getCreatureMana(cid) .. " / " .. getCreatureMaxMana(cid))
	add("Soul: " .. getPlayerSoul(cid) .. " / " .. getPlayerMaxSoul(cid))
	add("Capacity: " .. getPlayerFreeCap(cid))
	add("Speed: " .. getCreatureSpeed(cid))
	add("")
	add("[Combat]")
	add("Attack: " .. getPlayerAttack(cid))
	add("Defense: " .. getPlayerDefense(cid))
	add("Armor: " .. getPlayerArmor(cid))
	add("Attack Speed: " .. getPlayerAttackSpeed(cid) .. " ms")
	add("")
	add("[Skills]")
	add("Magic Level: " .. getPlayerMagLevel(cid))
	for _, s in ipairs(SKILLS) do
		add(s[2] .. ": " .. getPlayerSkillLevel(cid, s[1]))
	end

	add("")
	add("[Bonuses]")
	add("Armor: " .. getPlayerBonus(cid, PLAYER_BONUS_ARMOR) .. " (" .. getPlayerBonus(cid, PLAYER_BONUS_ARMOR_PERCENT) .. "%)")
	add("Defense: " .. getPlayerBonus(cid, PLAYER_BONUS_DEFENSE) .. " (" .. getPlayerBonus(cid, PLAYER_BONUS_DEFENSE_PERCENT) .. "%)")
	add("Soul Amount: " .. getPlayerBonus(cid, PLAYER_BONUS_SOUL_AMOUNT))
	add("Cooldown Reduction: " .. getPlayerBonus(cid, PLAYER_BONUS_COOLDOWN_REDUCTION) .. "%")
	add("Life Leech: " .. getPlayerBonus(cid, PLAYER_BONUS_LIFE_LEECH) .. "%")
	add("Mana Leech: " .. getPlayerBonus(cid, PLAYER_BONUS_MANA_LEECH) .. "%")
	add("Experience: " .. getPlayerBonus(cid, PLAYER_BONUS_EXPERIENCE) .. "%")
	add("Loot: " .. getPlayerBonus(cid, PLAYER_BONUS_LOOT) .. "%")
	add("")
	add("[Elemental Amplification]")
	for _, e in ipairs(ELEMENTS) do
		add(e[2] .. ": " .. getPlayerElementalAmplification(cid, e[1]) .. "%")
	end

	add("")
	add("[Elemental Resistance]")
	for _, e in ipairs(ELEMENTS) do
		add(e[2] .. ": " .. getPlayerElementalResistance(cid, e[1]) .. "%")
	end

	if(rates[SKILL__LEVEL] or rates[SKILL__MAGLEVEL]) then
		add("")
		add("[Rates]")
		add("Experience: x" .. (rates[SKILL__LEVEL] or 1))
		add("Magic Level: x" .. (rates[SKILL__MAGLEVEL] or 1))
	end

	doShowTextDialog(cid, 1982, table.concat(t, "\n"))
	return true
end
