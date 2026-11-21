-- !daily: shows the daily contracts of the player.
-- /dailymonsters [min level],[max level] | [name]: lists the monsters that can be used in the contracts with their level (staff)
-- /dailyreset <player name>: deletes the contracts of a player so new ones are generated (staff)
function onSay(cid, words, param, channel)
	if(words == "!daily") then
		if(not DailyQuest.isEnabled()) then
			doPlayerSendCancel(cid, "The daily contracts are disabled.")
			return true
		end

		doPlayerPopupFYI(cid, DailyQuest.getDescription(cid))
		return true
	end

	if(words == "/dailyreset") then
		local guid = getPlayerGUIDByName(param)
		if(not guid) then
			doPlayerSendCancel(cid, "Player not found: " .. param)
			return true
		end

		db.query("DELETE FROM `player_daily_quests` WHERE `player_id` = " .. guid)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Daily contracts of " .. param .. " deleted (new ones are generated when the player logs in or kills something).")
		return true
	end

	-- /dailymonsters
	local minLevel, maxLevel, name = 0, math.huge, nil
	local a, b = param:match("^(%d+)%s*,%s*(%d+)$")
	if(a) then
		minLevel, maxLevel = tonumber(a), tonumber(b)
	elseif(param ~= "") then
		name = param:lower()
	end

	local lines, total, limit = {}, 0, 150
	for _, monster in ipairs(DailyQuest.getMonsters()) do
		if(monster.level >= minLevel and monster.level <= maxLevel and (not name or monster.name:lower():find(name, 1, true))) then
			total = total + 1
			if(total <= limit) then
				table.insert(lines, "level " .. monster.level .. ": " .. monster.name .. " (" .. monster.experience .. " exp)")
			end
		end
	end

	local text = "Monsters used in the daily contracts: " .. total .. " found.\nUsage: /dailymonsters <min>,<max> or /dailymonsters <name>\n\n" .. table.concat(lines, "\n")
	if(total > limit) then
		text = text .. "\n... and " .. (total - limit) .. " more (narrow the search)."
	end

	doPlayerPopupFYI(cid, text)
	return true
end
