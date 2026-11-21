-- Rank statues: statues of the best player of each ranking (!rank), with the outfit and the name of the player.
-- The name over the statue is the name of the player; looking at it shows the ranking and the score.
-- Each statue is a "Rank Statue" monster (data/monster/rankstatue.xml): it cannot be attacked, pushed or moved.
-- The statues are refreshed when the server starts and every few minutes (data/globalevents/scripts/rankstatues.lua),
-- and a statue is only recreated when its player (or his outfit / score) changed.
-- The positions are in RankStatues.categories: change them to move a statue (z must be the floor of the statues).
-- Staff (group 2 or higher) and the Account Manager are ignored.

RankStatues = {
	monster = "Rank Statue",
	-- creature storage that marks a creature as a rank statue (used to clean up old statues after a reload)
	storage = 52300,
	-- staff groups are not ranked
	minStaffGroup = 2,

	-- label: shown when looking at the statue; skillid: id of the skill in player_skills
	categories = {
		{label = "Level", field = "level", pos = {x = 150, y = 48, z = 6}},
		{label = "Magic", field = "maglevel", pos = {x = 152, y = 48, z = 6}},
		{label = "Fist", skillid = 0, pos = {x = 154, y = 48, z = 6}},
		{label = "Club", skillid = 1, pos = {x = 150, y = 49, z = 6}},
		{label = "Sword", skillid = 2, pos = {x = 152, y = 49, z = 6}},
		{label = "Axe", skillid = 3, pos = {x = 154, y = 49, z = 6}},
		{label = "Distance", skillid = 4, pos = {x = 150, y = 50, z = 6}},
		{label = "Shielding", skillid = 5, pos = {x = 152, y = 50, z = 6}},
		{label = "Fishing", skillid = 6, pos = {x = 154, y = 50, z = 6}}
	}
}

local OUTFIT_COLUMNS = "p.`name`, p.`looktype`, p.`lookhead`, p.`lookbody`, p.`looklegs`, p.`lookfeet`, p.`lookaddons`"

-- uid and signature of the statue of each category (index of RankStatues.categories)
local statues = {}

local function getQuery(category)
	local where = "p.`deleted` = 0 AND p.`group_id` < " .. RankStatues.minStaffGroup .. " AND p.`name` <> 'Account Manager'"
	if(category.skillid) then
		return "SELECT " .. OUTFIT_COLUMNS .. ", s.`value` AS `score` FROM `players` p JOIN `player_skills` s ON s.`player_id` = p.`id` WHERE " ..
			where .. " AND s.`skillid` = " .. category.skillid .. " ORDER BY s.`value` DESC, s.`count` DESC LIMIT 1"
	end

	if(category.field == "level") then
		return "SELECT " .. OUTFIT_COLUMNS .. ", p.`level` AS `score` FROM `players` p WHERE " .. where ..
			" ORDER BY p.`level` DESC, p.`experience` DESC LIMIT 1"
	end

	return "SELECT " .. OUTFIT_COLUMNS .. ", p.`maglevel` AS `score` FROM `players` p WHERE " .. where ..
		" ORDER BY p.`maglevel` DESC, p.`manaspent` DESC LIMIT 1"
end

-- {name, score, outfit = {...}} of the best player of the category, or nil
function RankStatues.getTop(category)
	local res = db.storeQuery(getQuery(category))
	if(not res) then
		return nil
	end

	local top = {
		name = result.getDataString(res, "name"),
		score = result.getDataInt(res, "score"),
		outfit = {
			lookType = result.getDataInt(res, "looktype"),
			lookHead = result.getDataInt(res, "lookhead"),
			lookBody = result.getDataInt(res, "lookbody"),
			lookLegs = result.getDataInt(res, "looklegs"),
			lookFeet = result.getDataInt(res, "lookfeet"),
			lookAddons = result.getDataInt(res, "lookaddons"),
			lookTypeEx = 0
		}
	}

	result.free(res)
	return top
end

-- removes the statue standing on the position (also the ones left by an old run of this script)
local function removeStatueAt(pos)
	local creature = getTopCreature(pos)
	if(creature.uid > 0 and getCreatureStorage(creature.uid, RankStatues.storage) == 1) then
		doRemoveCreature(creature.uid)
		return true
	end

	return false
end

local function getSignature(top)
	local o = top.outfit
	return table.concat({top.name, top.score, o.lookType, o.lookHead, o.lookBody, o.lookLegs, o.lookFeet, o.lookAddons}, "|")
end

local function createStatue(category, top)
	local pos = {x = category.pos.x, y = category.pos.y, z = category.pos.z, stackpos = STACKPOS_TOP_CREATURE}
	removeStatueAt(pos)

	-- the name is only the name of the player (what the client shows over the statue); the ranking is in the "look" text
	local uid = doCreateNamedMonster(RankStatues.monster, top.name, pos, "the statue of " .. top.name .. ", the best player in " .. category.label .. " (" .. top.score .. ")")
	if(not uid) then
		return nil
	end

	doCreatureSetStorage(uid, RankStatues.storage, 1)
	doCreatureSetNoMove(uid, true)
	doCreatureChangeOutfit(uid, top.outfit)
	doCreatureSetLookDirection(uid, SOUTH)
	doSendMagicEffect(pos, CONST_ME_TELEPORT)
	return uid
end

-- Refreshes all the statues (a statue is only recreated when something changed). Returns the number of statues placed.
function RankStatues.update()
	if(not doCreateNamedMonster) then
		print("[Warning - RankStatues] doCreateNamedMonster() not found, the server needs to be recompiled.")
		return 0
	end

	local placed = 0
	for index, category in ipairs(RankStatues.categories) do
		local top = RankStatues.getTop(category)
		local current = statues[index]
		if(top) then
			local signature = getSignature(top)
			if(current and current.signature == signature and isCreature(current.uid)) then
				placed = placed + 1
			else
				local uid = createStatue(category, top)
				if(uid) then
					statues[index] = {uid = uid, signature = signature}
					placed = placed + 1
				else
					statues[index] = nil
					print("[Warning - RankStatues] Could not place the statue of " .. category.label .. " at " ..
						category.pos.x .. ", " .. category.pos.y .. ", " .. category.pos.z .. " (blocked tile?).")
				end
			end
		elseif(current) then
			if(isCreature(current.uid)) then
				doRemoveCreature(current.uid)
			end

			statues[index] = nil
		end
	end

	return placed
end
