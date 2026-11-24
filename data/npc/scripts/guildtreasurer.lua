local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- state of each player: {step = "amount" | "confirm", amount}
local talks = {}

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end

local function askConfirmation(cid, amount)
	talks[cid] = {step = "confirm", amount = amount}
	npcHandler:say("Do you want to donate {" .. amount .. " gold coins} to your guild? {yes} or {no}.", cid)
end

local function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	if(not GuildLevels.isEnabled()) then
		npcHandler:say("The guild levels are disabled.", cid)
		return true
	end

	msg = msg:lower():trim()
	local talk = talks[cid]

	if(msg == "cancel") then
		talks[cid] = nil
		npcHandler:say("Alright, nothing was donated.", cid)
		return true
	end

	if(talk and talk.step == "confirm") then
		talks[cid] = nil
		if(msg ~= "yes") then
			npcHandler:say("Alright, nothing was donated.", cid)
			return true
		end

		local ok, level, donated = GuildLevels.donate(cid, talk.amount)
		if(ok) then
			doSendMagicEffect(getCreaturePosition(cid), CONST_ME_GIFT_WRAPS)
			npcHandler:say("Thank you! You donated " .. donated .. " gold coins. Your guild is level " .. level .. ".", cid)
		else
			npcHandler:say(level, cid)
		end

		return true
	end

	if(talk and talk.step == "amount") then
		local amount = tonumber(msg)
		if(not amount or amount < 1) then
			npcHandler:say("Tell me a number of gold coins, or {cancel}.", cid)
			return true
		end

		askConfirmation(cid, math.floor(amount))
		return true
	end

	local direct = msg:match("^donate (%d+)$")
	if(direct) then
		if(getPlayerGuildId(cid) == 0) then
			npcHandler:say("You are not in a guild.", cid)
			return true
		end

		askConfirmation(cid, tonumber(direct))
		return true
	end

	if(msg == "donate" or msg == "donation") then
		if(getPlayerGuildId(cid) == 0) then
			npcHandler:say("You are not in a guild.", cid)
			return true
		end

		talks[cid] = {step = "amount"}
		npcHandler:say("How much gold do you want to donate? The minimum is " .. GuildLevels.getMinDonation() .. ". Tell me the number or {cancel}.", cid)
		return true
	end

	if(msg == "level" or msg == "guild" or msg == "info" or msg == "bonus") then
		for _, line in ipairs(GuildLevels.getInfoLines(cid)) do
			npcHandler:say(line, cid)
		end

		return true
	end

	if(msg == "donors" or msg == "top" or msg == "ranking") then
		local guildId = getPlayerGuildId(cid)
		if(guildId == 0) then
			npcHandler:say("You are not in a guild.", cid)
			return true
		end

		local donors = GuildLevels.getTopDonors(guildId, 5)
		if(#donors == 0) then
			npcHandler:say("Nobody donated to your guild yet.", cid)
			return true
		end

		local entries = {}
		for i, donor in ipairs(donors) do
			table.insert(entries, i .. ". " .. donor.name .. " (" .. donor.amount .. " gold)")
		end

		npcHandler:say("Top donors: " .. table.concat(entries, ", ") .. ".", cid)
		return true
	end

	return false
end

local function onFarewell(cid)
	talks[cid] = nil
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_FAREWELL, onFarewell)
npcHandler:addModule(FocusModule:new())

Language.install()
