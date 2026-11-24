-- Training time (given by the "trainer" tasks of the Drillmaster NPC, see lib/340-tasks.lua and
-- data/npc/scripts/trainer_tasks.lua). The time is stored in seconds and converted by the NPC when the player asks to train:
-- every SECONDS_PER_TRY seconds of training = 1 skill try of the weapon the player is holding (no weapon = fist fighting).
-- Wands and rods train magic level: every try is worth MANA_PER_TRY mana spent (~ the ratio between the base cost of
-- a magic level, 1600 mana, and of a skill level, 50 tries).
--
-- NOTE: the WEAPON_* constants of data/lib/000-constant.lua are NOT the same as the ones of the server
-- (src/const.h: NONE 0, SWORD 1, CLUB 2, AXE 3, DIST 4, SHIELD 5, FIST 6, WAND 7, AMMO 8), so the numbers
-- of the server are used here. Also, the skill ids are not in the same order as the weapon types: club = 1 and sword = 2.

Training = {
	storageTime = 54400, -- seconds of training time stored
	storageDone = 54410, -- + id of the task in Tasks.order: 1 when the "once" task was already completed

	secondsPerTry = 2,
	manaPerTry = 30,

	-- weapon type of the server (itemType.weaponType) -> skill id (SKILL_*), SKILL__MAGLEVEL for wands and rods
	weapons = {
		[1] = {skill = SKILL_SWORD, name = "sword fighting"},
		[2] = {skill = SKILL_CLUB, name = "club fighting"},
		[3] = {skill = SKILL_AXE, name = "axe fighting"},
		[4] = {skill = SKILL_DISTANCE, name = "distance fighting"},
		[7] = {skill = SKILL__MAGLEVEL, name = "magic level"}
	},
	fist = {skill = SKILL_FIST, name = "fist fighting"}
}

function Training.getTime(cid)
	return math.max(0, getPlayerStorageValue(cid, Training.storageTime))
end

function Training.addTime(cid, seconds)
	doPlayerSetStorageValue(cid, Training.storageTime, Training.getTime(cid) + seconds)
end

function Training.isDone(cid, key)
	for i, k in ipairs(Tasks.order) do
		if(k == key) then
			return getPlayerStorageValue(cid, Training.storageDone + i) == 1
		end
	end

	return false
end

function Training.timeText(seconds)
	local minutes, secs = math.floor(seconds / 60), seconds % 60
	if(minutes > 0 and secs > 0) then
		return minutes .. " minutes and " .. secs .. " seconds"
	elseif(minutes > 0) then
		return minutes .. " minutes"
	end

	return secs .. " seconds"
end

-- what the player trains with the weapon in his hands: table {skill, name}
function Training.getType(cid)
	for _, slot in ipairs({CONST_SLOT_LEFT, CONST_SLOT_RIGHT}) do
		local item = getPlayerSlotItem(cid, slot)
		if(item.uid > 0) then
			local weapon = Training.weapons[getItemInfo(item.itemid).weaponType]
			if(weapon) then
				return weapon
			end
		end
	end

	return Training.fist
end

-- converts all the stored time. Returns tries, skill name (nil when there is no time stored)
function Training.use(cid)
	local seconds = Training.getTime(cid)
	local tries = math.floor(seconds / Training.secondsPerTry)
	if(tries < 1) then
		return nil
	end

	local weapon = Training.getType(cid)
	if(weapon.skill == SKILL__MAGLEVEL) then
		doPlayerAddSpentMana(cid, tries * Training.manaPerTry, false)
	else
		doPlayerAddSkillTry(cid, weapon.skill, tries, false)
	end

	-- keeps the odd second that did not complete a try
	doPlayerSetStorageValue(cid, Training.storageTime, seconds - tries * Training.secondsPerTry)
	return tries, weapon.name
end
