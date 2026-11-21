-- !guildinfo: level, bonus, gold missing for the next level and top donors of your guild.
-- !guilddonate amount: donates gold to your guild (the guild level is decided by the total donated).
function onSay(cid, words, param, channel)
	if(not GuildLevels.isEnabled()) then
		doPlayerSendCancel(cid, "The guild levels are disabled.")
		return true
	end

	if(words == "!guildinfo") then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, table.concat(GuildLevels.getInfoLines(cid), "\n"))
		return true
	end

	local amount = tonumber(param:trim())
	if(not amount or amount < 1) then
		doPlayerSendCancel(cid, "Usage: !guilddonate amount (example: !guilddonate 100000).")
		return true
	end

	local ok, level, donated = GuildLevels.donate(cid, amount)
	if(not ok) then
		doPlayerSendCancel(cid, level)
		return true
	end

	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_GIFT_WRAPS)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You donated " .. donated .. " gold coins to your guild (level " .. level .. ").")
	return true
end
