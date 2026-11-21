-- Death penalty (items, experience, skills, magic level, blessings).
-- The source only fires this event after a player died; everything that is lost is decided here.
--
-- onDeathLoss(cid, corpse, deathList)
--   corpse: the corpse created for the player (corpse.uid is nil when there is none)
--   return true  -> the player goes to the relogin window (the usual death)
--   return false -> the player stays in the game (nothing else is done by the source)
-- Without any registered onDeathLoss event nothing is lost and the player goes to the relogin window.
--
-- Registered in login.lua as "DeathLoss". To customize, edit the config below or the functions further down.

local config = {
	-- blessings (the "blessings" and "blessingOnlyPremium" options of config.lua still turn the system on/off)
	-- each blessing lowers the chance of losing containers/items: the first one by blessItemBase, the next ones
	-- by blessItemBase - blessItemDecrement, and so on
	blessItemBase = 30,
	blessItemDecrement = 5,
	-- each blessing lowers the experience/magic level/skills loss by this percent (of the base loss)
	blessSkillReduction = 8,

	-- experience: up to this level the loss is experience * percent / expLowLevelDivider
	expLowLevel = 25,
	expLowLevelDivider = 10,

	-- skulls above this one (white = 3) drop all the equipment on death
	dropAllSkull = SKULL_WHITE,
	-- skulls from this one on (red) ignore the amulets with preventLoss/preventDrop
	ignoreAmuletSkull = SKULL_RED,

	-- what the player loses (set to false to disable)
	loseExperience = true,
	loseMagicLevel = true,
	loseSkills = true,
	loseItems = true,
	loseBlessings = true,

	-- items.xml abilities that are honoured: preventLoss (no experience/skill loss) and preventDrop (no items dropped)
	-- each death takes one charge of the amulet (or removes it when it has none left)
	usePreventLoss = true,
	usePreventDrop = true
}

local BLESSINGS_MAX = 16
local SKILLS = {SKILL_FIST, SKILL_CLUB, SKILL_SWORD, SKILL_AXE, SKILL_DISTANCE, SKILL_SHIELD, SKILL_FISHING}

-- how many blessings count for the penalty (0 when the system is off or the player cannot use it)
local function getBlessings(cid)
	if(not getBooleanFromString(getConfigInfo('blessings'))) then
		return 0
	end

	if(not isPremium(cid) and getBooleanFromString(getConfigInfo('blessingOnlyPremium'))) then
		return 0
	end

	local count = 0
	for i = 1, BLESSINGS_MAX do
		if(getPlayerBlessing(cid, i)) then
			count = count + 1
		end
	end

	return count
end

-- percent (0-100) of the containers lost, lowered by the blessings
local function getContainerLoss(cid, blessings)
	local loss, start = getPlayerLossPercent(cid, PLAYERLOSS_CONTAINERS), config.blessItemBase
	while(blessings > 0 and loss > 0) do
		loss = math.max(0, loss - start)
		start = start - config.blessItemDecrement
		blessings = blessings - 1
	end

	return loss
end

-- experience lost by a player that died (level <= expLowLevel: a fraction of the experience; above it: part of the last levels)
local function getLostExperience(cid, blessings)
	local percent = (getPlayerLossPercent(cid, PLAYERLOSS_EXPERIENCE) - getVocationInfo(getPlayerVocation(cid)).lessLoss - blessings * config.blessSkillReduction) / 100
	local level, experience = getPlayerLevel(cid), getPlayerExperience(cid)
	if(level <= config.expLowLevel) then
		return math.floor(experience * percent / config.expLowLevelDivider)
	end

	local base, levels, lost = level, (level + 50) / 100, 0
	while(levels > 1) do
		lost = lost + (getExperienceForLevel(base) - getExperienceForLevel(base - 1))
		base = base - 1
		levels = levels - 1
	end

	if(levels > 0) then
		lost = lost + math.floor((getExperienceForLevel(base) - getExperienceForLevel(base - 1)) * levels)
	end

	return math.floor(lost * percent)
end

-- the first equipped item with the ability, nil if none
local function findAmulet(cid, ability)
	for slot = CONST_SLOT_FIRST, CONST_SLOT_LAST do
		local item = getPlayerSlotItem(cid, slot)
		if(item.uid > 0 and getItemInfo(item.itemid).abilities[ability]) then
			return item
		end
	end

	return nil
end

-- takes one charge of the item (removes it when it has no charges left)
local function consumeAmulet(item)
	if(item.type > 1) then
		doTransformItem(item.uid, item.itemid, item.type - 1)
	else
		doRemoveItem(item.uid)
	end
end

-- moves to the corpse the equipment the player lost
local function dropItems(cid, corpse, blessings)
	local containerLoss = getContainerLoss(cid, blessings)
	local itemLoss = math.floor((5 + containerLoss) * getPlayerLossPercent(cid, PLAYERLOSS_ITEMS) / 1000)
	local dropAll = getCreatureSkullType(cid) > config.dropAllSkull

	-- collected first, moving an item changes the slots
	local items = {}
	for slot = CONST_SLOT_FIRST, CONST_SLOT_LAST do
		local item = getPlayerSlotItem(cid, slot)
		if(item.uid > 0) then
			table.insert(items, item.uid)
		end
	end

	for _, uid in ipairs(items) do
		local chance = math.random(1, 100)
		if(dropAll or (isContainer(uid) and chance < containerLoss) or (not isContainer(uid) and chance < itemLoss)) then
			doMoveItemToContainer(uid, corpse.uid)
		end
	end
end

-- experience, magic level and skills
local function loseSkills(cid, blessings)
	local experience = getPlayerExperience(cid)
	local lostExperience = config.loseExperience and getLostExperience(cid, blessings) or 0
	if(lostExperience > 0) then
		doPlayerAddExperience(cid, -lostExperience)
	end

	-- fraction of the experience that was lost, the same fraction (times the loss percent) of magic level and skills goes away
	local ratio = experience > 0 and lostExperience / experience or 0
	if(ratio <= 0) then
		return
	end

	if(config.loseMagicLevel) then
		doPlayerRemoveSkillPercent(cid, SKILL__MAGLEVEL, ratio * getPlayerLossPercent(cid, PLAYERLOSS_MANA))
	end

	if(config.loseSkills) then
		local percent = ratio * getPlayerLossPercent(cid, PLAYERLOSS_SKILLS)
		for _, skill in ipairs(SKILLS) do
			doPlayerRemoveSkillPercent(cid, skill, percent)
		end
	end
end

function onDeathLoss(cid, corpse, deathList)
	-- the source clears this flag for deaths that must not cost anything (hardcore zones, summons, scripts)
	local loseSkill = getPlayerLossSkill(cid)
	local hasCorpse = type(corpse) == "table" and corpse.uid ~= nil and corpse.uid > 0
	local ignoreAmulets = getCreatureSkullType(cid) >= config.ignoreAmuletSkull

	local preventLoss, preventDrop
	if(not ignoreAmulets) then
		if(loseSkill and config.usePreventLoss) then
			preventLoss = findAmulet(cid, "preventLoss")
		end

		if(hasCorpse and config.usePreventDrop) then
			preventDrop = findAmulet(cid, "preventDrop")
		end
	end

	local blessings = getBlessings(cid)
	if(hasCorpse and not preventDrop and config.loseItems) then
		dropItems(cid, corpse, blessings)
	end

	if(preventDrop) then
		consumeAmulet(preventDrop)
	end

	if(preventLoss and (not preventDrop or preventLoss.uid ~= preventDrop.uid)) then
		consumeAmulet(preventLoss)
	end

	if(not loseSkill or preventLoss) then
		doPlayerSetLossSkill(cid, true)
		-- an amulet that saved the player still sends him to the temple, deaths that cost nothing keep him where he is
		return preventLoss ~= nil
	end

	loseSkills(cid, blessings)
	if(config.loseBlessings) then
		doPlayerRemoveBlessing(cid)
	end

	return true
end
