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
				npcHandler:say("Patience, my friend: the blood needs time to settle. You must wait " .. formatRaceCooldown(left) .. " before changing your race again.", cid)
				return true
			end

			local hadRace = getPlayerRace(cid)
			if(doPlayerSetRace(cid, choice)) then
				if(hadRace) then
					doPlayerStartRaceCooldown(cid)
				end

				doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
				npcHandler:say("Fascinating... it is done. You are now a " .. RACES[choice].name .. "! Your old outfits are gone, and the garments of your new lineage are yours.", cid)
			end
		else
			choices[cid] = nil
			npcHandler:say("A wise pause; every great treatise begins with doubt. Which lineage shall it be, then? " .. raceList() .. ".", cid)
		end

		return true
	end

	if(msg == "race" or msg == "races" or msg == "help") then
		local left = getPlayerRaceCooldownLeft(cid)
		if(left > 0) then
			npcHandler:say("I would gladly change your race at no charge, but the ritual forbids it for now: you must wait " .. formatRaceCooldown(left) .. ". The lineages I have catalogued: " .. raceList() .. ".", cid)
		else
			npcHandler:say("My research allows me to change your race at no cost. Mind you, after each change one must wait " .. formatRaceCooldown(getRaceChangeCooldown()) ..
				" before changing again, though your first choice has no wait. The lineages I have catalogued: " .. raceList() .. ".", cid)
		end

		return true
	end

	local index, race = getRaceByName(msg)
	if(not index) then
		return false
	end

	local current = getPlayerRace(cid)
	if(current == index) then
		npcHandler:say("But you already are a " .. race.name .. ", dear friend! A fine choice, if I may say so.", cid)
		return true
	end

	local left = getPlayerRaceCooldownLeft(cid)
	if(left > 0) then
		npcHandler:say("You changed your race only recently. Science demands restraint: wait " .. formatRaceCooldown(left) .. " before another change.", cid)
		return true
	end

	choices[cid] = index
	doShowTextDialog(cid, 1982, getRaceDescription(index))
	local warning = ""
	if(getPlayerRace(cid) and getRaceChangeCooldown() > 0) then
		warning = " A footnote: you will only be able to change again in " .. formatRaceCooldown(getRaceChangeCooldown()) .. "."
	end

	npcHandler:say("Ah, the {" .. race.name .. "}! A remarkable lineage. Are you certain you wish to become one? Know that you will lose all your current outfits." .. warning .. " {yes} or {no}?", cid)
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
