local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local choices = {}

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end

local function raceList()
	local names = {}
	for _, race in ipairs(RACES) do
		table.insert(names, "{" .. race.name .. "}")
	end

	return table.concat(names, ", ")
end

local function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	msg = msg:lower():trim()
	local choice = choices[cid]
	if(choice) then
		if(msg == "yes") then
			choices[cid] = nil
			local left = getPlayerRaceCooldownLeft(cid)
			if(left > 0) then
				npcHandler:say("You have to wait " .. formatRaceCooldown(left) .. " to change your race again.", cid)
				return true
			end

			local hadRace = getPlayerRace(cid)
			if(doPlayerSetRace(cid, choice)) then
				if(hadRace) then
					doPlayerStartRaceCooldown(cid)
				end

				doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
				npcHandler:say("You are now a " .. RACES[choice].name .. "! Your old outfits are gone and the outfits of your new race are yours.", cid)
			end
		else
			choices[cid] = nil
			npcHandler:say("Alright. Which race do you want? " .. raceList() .. ".", cid)
		end

		return true
	end

	if(msg == "race" or msg == "races" or msg == "help") then
		local left = getPlayerRaceCooldownLeft(cid)
		if(left > 0) then
			npcHandler:say("I can change your race for free, but not now: you have to wait " .. formatRaceCooldown(left) .. ". Races: " .. raceList() .. ".", cid)
		else
			npcHandler:say("I can change your race for free (after each change you have to wait " .. formatRaceCooldown(getRaceChangeCooldown()) ..
				" to change again, the first choice has no wait): " .. raceList() .. ".", cid)
		end

		return true
	end

	local index, race = getRaceByName(msg)
	if(not index) then
		return false
	end

	local current = getPlayerRace(cid)
	if(current == index) then
		npcHandler:say("You already are a " .. race.name .. ".", cid)
		return true
	end

	local left = getPlayerRaceCooldownLeft(cid)
	if(left > 0) then
		npcHandler:say("You changed your race recently. You have to wait " .. formatRaceCooldown(left) .. " to change it again.", cid)
		return true
	end

	choices[cid] = index
	local warning = ""
	if(getPlayerRace(cid) and getRaceChangeCooldown() > 0) then
		warning = " After this you will only be able to change again in " .. formatRaceCooldown(getRaceChangeCooldown()) .. "."
	end

	npcHandler:say("Do you want to become a {" .. race.name .. "}? You will lose all your current outfits." .. warning .. " {yes} or {no}?", cid)
	return true
end

local function onFarewell(cid)
	choices[cid] = nil
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_CREATURE_DISAPPEAR, onFarewell)
npcHandler:setCallback(CALLBACK_FAREWELL, onFarewell)
npcHandler:addModule(FocusModule:new())
