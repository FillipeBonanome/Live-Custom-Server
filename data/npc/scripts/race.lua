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
			if(doPlayerSetRace(cid, choice)) then
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
		npcHandler:say("I can change your race for free, as many times as you want: " .. raceList() .. ".", cid)
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

	choices[cid] = index
	npcHandler:say("Do you want to become a {" .. race.name .. "}? You will lose all your current outfits. {yes} or {no}?", cid)
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
