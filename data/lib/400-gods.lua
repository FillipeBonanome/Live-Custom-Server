-- The Eleven: gods of the world, each one with a statue that gives a blessing (see doc/sistemas/39-deuses-e-estatuas.md for the lore).
--
-- Using a statue (an item with the action id of the god, see Gods.list) gives the player the blessing of that god for 2 hours (real time).
-- * Each blessing is a buff (shown in !buffs, category = its name). The blessings of different gods can be active together, but the same
--   blessing does NOT stack and is not renewed while it lasts (the statue tells how much time is left).
-- * The remaining time is saved in a player storage (Gods.storageBase + index of the god), so the blessing survives a logout; it is
--   restored by the login event (data/creaturescripts/scripts/gods.lua) and lost on death.
-- * Every bonus is a CONDITION_ATTRIBUTES (the elemental resistance is CONDITION_PARAM_ABSORB_*, subtracted from the damage in Player::blockHit).
-- * Statues are placed by the staff with /godstatue (saved in the table god_statues and recreated on startup) or in the map editor
--   (any statue item with the action id of the god).
--
-- Gods.give(cid, key[, seconds])   gives the blessing (seconds = time left, 2 hours by default); false if it is already active
-- Gods.restore(cid)                gives back the blessings that did not expire (login)
-- Gods.clear(cid)                  removes all the blessings and forgets them (death)
-- Gods.use(cid, key)               what the statue does
-- Gods.find(text)                  god by key or name

Gods = {
	duration = 2 * 60 * 60, -- seconds (real time)
	storageBase = 56100, -- + position of the god in Gods.list: os.time() when the blessing ends
	subIdBase = 8600, -- + position of the god: sub id of the attributes condition
	actionIdBase = 9810, -- + position of the god: action id of the statue
	resistance = 15, -- percent of elemental resistance (resist gods)
	lifeLeech = 4, -- percent
	manaLeech = 4, -- percent
	magicLevel = 3, -- magic levels
	skills = 5 -- every skill but fishing
}

-- key, name, title and domain are the lore; kind/combat/params the blessing; item = look of the statue
-- (the action id of the statue is Gods.actionIdBase + position)
Gods.list = {
	{key = "pyranor", name = "Pyranor", title = "the Ember Forger", domain = "fire", kind = "resist", combat = COMBAT_FIREDAMAGE, params = {[CONDITION_PARAM_ABSORB_FIRE] = "resistance"}, item = 1449,
		effect = CONST_ME_FIREAREA, speech = "The forge never dies, mortal. Carry my fire."},
	{key = "skadrin", name = "Skadrin", title = "the Winter Queen", domain = "ice", kind = "resist", combat = COMBAT_ICEDAMAGE, params = {[CONDITION_PARAM_ABSORB_ICE] = "resistance"}, item = 7446,
		effect = CONST_ME_ICEAREA, speech = "Winter does not hate you. It simply endures. Endure with me."},
	{key = "voltarion", name = "Voltarion", title = "the Storm Lord", domain = "energy", kind = "resist", combat = COMBAT_ENERGYDAMAGE, params = {[CONDITION_PARAM_ABSORB_ENERGY] = "resistance"}, item = 1444,
		effect = CONST_ME_ENERGYAREA, speech = "Let the thunder speak through your bones!"},
	{key = "verdantha", name = "Verdantha", title = "the Root Mother", domain = "earth", kind = "resist", combat = COMBAT_EARTHDAMAGE, params = {[CONDITION_PARAM_ABSORB_EARTH] = "resistance"}, item = 4861,
		effect = CONST_ME_POISONAREA, speech = "Every poison is a medicine, child. Learn which is which."},
	{key = "solanis", name = "Solanis", title = "the First Light", domain = "holy", kind = "resist", combat = COMBAT_HOLYDAMAGE, params = {[CONDITION_PARAM_ABSORB_HOLY] = "resistance"}, item = 1448,
		effect = CONST_ME_HOLYAREA, speech = "Where I shine, no shadow keeps its secrets."},
	{key = "morvaine", name = "Morvaine", title = "the Last Sleep", domain = "death", kind = "resist", combat = COMBAT_DEATHDAMAGE, params = {[CONDITION_PARAM_ABSORB_DEATH] = "resistance"}, item = 1452,
		effect = CONST_ME_MORTAREA, speech = "I am the end of every road. I will not hurry you."},
	{key = "nerezza", name = "Nerezza", title = "the Voice of the Deep", domain = "drown", kind = "resist", combat = COMBAT_DROWNDAMAGE, params = {[CONDITION_PARAM_ABSORB_DROWN] = "resistance"}, item = 5671,
		effect = CONST_ME_LOSEENERGY, speech = "The sea keeps what it takes... but it can be asked to lend."},
	{key = "haemora", name = "Haemora", title = "the Red Harvest", domain = "life leech", kind = "condition",
		params = {[CONDITION_PARAM_LIFELEECH] = "lifeLeech"}, item = 1478,
		effect = CONST_ME_BLOCKHIT, speech = "Life is a debt the fallen pay to the living. Collect it."},
	{key = "orrelith", name = "Orrelith", title = "the Star Drinker", domain = "mana leech", kind = "condition",
		params = {[CONDITION_PARAM_MANALEECH] = "manaLeech"}, item = 1443,
		effect = CONST_ME_MAGIC_BLUE, speech = "Every star is a cup. Drink, and do not spill."},
	{key = "azuriel", name = "Azuriel", title = "the First Word", domain = "magic level", kind = "condition",
		params = {[CONDITION_PARAM_STAT_MAGICLEVEL] = "magicLevel"}, item = 1445,
		effect = CONST_ME_MAGIC_GREEN, speech = "Before there was light, there was a word. Listen closely."},
	{key = "kharzul", name = "Kharzul", title = "the Thousand-Battle Master", domain = "skills", kind = "condition",
		params = {
			[CONDITION_PARAM_SKILL_MELEE] = "skills", [CONDITION_PARAM_SKILL_FIST] = "skills", [CONDITION_PARAM_SKILL_DISTANCE] = "skills",
			[CONDITION_PARAM_SKILL_SHIELD] = "skills"
		}, item = 1444,
		effect = CONST_ME_HITAREA, speech = "A blade only learns from the hand that bleeds. Train, and rise."}
}

-- action id of every statue (also the position of the god)
for index, god in ipairs(Gods.list) do
	god.index = index
	god.category = "Blessing of " .. god.name
	god.actionId = Gods.actionIdBase + index - 1
	god.storage = Gods.storageBase + index - 1
	god.subId = Gods.subIdBase + index - 1
end

local COMBAT_NAMES = {
	[COMBAT_FIREDAMAGE] = "fire", [COMBAT_ICEDAMAGE] = "ice", [COMBAT_ENERGYDAMAGE] = "energy", [COMBAT_EARTHDAMAGE] = "earth",
	[COMBAT_HOLYDAMAGE] = "holy", [COMBAT_DEATHDAMAGE] = "death", [COMBAT_DROWNDAMAGE] = "drown"
}

-- what the blessing does, in words (shown in !buffs and by the statue)
function Gods.effectText(god)
	if(god.kind == "resist") then
		return "+" .. Gods.resistance .. "% " .. COMBAT_NAMES[god.combat] .. " resistance."
	elseif(god.domain == "life leech") then
		return "+" .. Gods.lifeLeech .. "% life leech."
	elseif(god.domain == "mana leech") then
		return "+" .. Gods.manaLeech .. "% mana leech."
	elseif(god.domain == "magic level") then
		return "+" .. Gods.magicLevel .. " magic level."
	end

	return "+" .. Gods.skills .. " to all skills (except fishing)."
end

function Gods.find(text)
	text = tostring(text):lower():trim()
	for _, god in ipairs(Gods.list) do
		if(god.key == text or god.name:lower() == text) then
			return god
		end
	end

	return nil
end

function Gods.getByActionId(actionId)
	local god = Gods.list[actionId - Gods.actionIdBase + 1]
	return god and god.actionId == actionId and god or nil
end

function Gods.give(cid, key, seconds)
	local god = type(key) == "table" and key or Gods.find(key)
	if(not god or not isCreature(cid)) then
		return false
	end

	if(hasCreatureBuff(cid, god.category)) then
		return false
	end

	seconds = seconds or Gods.duration
	local duration = seconds * 1000
	setPlayerStorageValue(cid, god.storage, os.time() + seconds)

	return addCreatureBuff(cid, {
		name = god.category, category = god.category, duration = duration, description = Gods.effectText(god),
		onActivate = function(id, stacks)
			local condition = createConditionObject(CONDITION_ATTRIBUTES, duration, true, god.subId)
			for param, field in pairs(god.params) do
				setConditionParam(condition, param, Gods[field])
			end

			doAddCondition(id, condition)
		end,
		onRemove = function(id)
			if(isCreature(id)) then
				doRemoveCondition(id, CONDITION_ATTRIBUTES, god.subId)
			end
		end
	})
end

-- gives back the blessings that did not expire
function Gods.restore(cid)
	local now = os.time()
	for _, god in ipairs(Gods.list) do
		local ends = getPlayerStorageValue(cid, god.storage)
		if(ends and ends > now) then
			Gods.give(cid, god, ends - now)
		end
	end
end

-- removes every blessing (the buffs are cleared by the BuffsDeath event, here the effects and the saved time)
function Gods.clear(cid)
	for _, god in ipairs(Gods.list) do
		doRemoveCondition(cid, CONDITION_ATTRIBUTES, god.subId)
		setPlayerStorageValue(cid, god.storage, -1)
		removeCreatureBuff(cid, god.category)
	end
end

function Gods.use(cid, god)
	local buff = getCreatureBuffByCategory(cid, god.category)
	if(buff) then
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, god.name .. " " .. god.title .. ": your blessing still burns (" ..
			Buffs.formatTime(buff.timeLeft) .. " left). The blessings of a god do not stack.")
		return true
	end

	Gods.give(cid, god)
	doSendMagicEffect(getThingPosition(cid), god.effect)
	doSendMagicEffect(getThingPosition(cid), CONST_ME_MAGIC_GREEN)
	doCreatureSay(cid, god.name .. "!", TALKTYPE_MONSTER)
	doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "\"" .. god.speech .. "\" You received the " .. god.category .. " for 2 hours: " .. Gods.effectText(god))
	return true
end

-- Statues placed by the staff (/godstatue), kept in the database ------------------------------------------------------

local tablesReady = false

function Gods.createTable()
	if(tablesReady) then
		return true
	end

	if(getConfigValue('sqlType') == "sqlite") then
		db.query("CREATE TABLE IF NOT EXISTS `god_statues` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `god` VARCHAR(32) NOT NULL, `x` INTEGER NOT NULL, `y` INTEGER NOT NULL, `z` INTEGER NOT NULL)")
	else
		db.query("CREATE TABLE IF NOT EXISTS `god_statues` (`id` INT UNSIGNED NOT NULL AUTO_INCREMENT, `god` VARCHAR(32) NOT NULL, `x` INT NOT NULL, `y` INT NOT NULL, `z` INT NOT NULL, PRIMARY KEY (`id`)) ENGINE = InnoDB")
	end

	tablesReady = true
	return true
end

-- creates the statue of the god on the tile (nothing is done if the tile already has it)
local function placeStatue(god, pos)
	pos.stackpos = 0
	if(getTileItemById(pos, god.item).uid > 0) then
		return false
	end

	local uid = doCreateItem(god.item, 1, pos)
	if(not uid or uid <= 0) then
		return false
	end

	doItemSetAttribute(uid, "aid", god.actionId)
	doItemSetAttribute(uid, "description", "It is a statue of " .. god.name .. ", " .. god.title .. ". Use it to receive a blessing.")
	return true
end

-- places all the saved statues (startup); returns how many
function Gods.placeAll()
	Gods.createTable()
	local res = db.storeQuery("SELECT `god`, `x`, `y`, `z` FROM `god_statues`")
	if(not res) then
		return 0
	end

	local count = 0
	repeat
		local god = Gods.find(result.getDataString(res, "god"))
		if(god and placeStatue(god, {x = result.getDataInt(res, "x"), y = result.getDataInt(res, "y"), z = result.getDataInt(res, "z")})) then
			count = count + 1
		end
	until not result.next(res)

	result.free(res)
	return count
end

-- saves and places a statue
function Gods.addStatue(key, pos)
	local god = Gods.find(key)
	if(not god) then
		return false, "Unknown god."
	end

	Gods.createTable()
	if(not placeStatue(god, {x = pos.x, y = pos.y, z = pos.z})) then
		return false, "Could not place the statue there (invalid tile or there is already one)."
	end

	db.query("INSERT INTO `god_statues` (`god`, `x`, `y`, `z`) VALUES (" .. db.escapeString(god.key) .. ", " .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. ")")
	return true, god
end

-- removes the statue on the tile (saved and placed); returns true if there was one
function Gods.removeStatue(pos)
	Gods.createTable()
	local removed = false
	for _, god in ipairs(Gods.list) do
		local item = getTileItemById({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}, god.item)
		if(item.uid > 0 and item.actionid == god.actionId) then
			doRemoveItem(item.uid)
			removed = true
		end
	end

	db.query("DELETE FROM `god_statues` WHERE `x` = " .. pos.x .. " AND `y` = " .. pos.y .. " AND `z` = " .. pos.z)
	return removed
end
