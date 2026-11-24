-- Durnok Runebrand, the runesmith. Carves the enchantment runes (blank rune + gold + gems, see lib/399-runecarving.lua).
-- Tier 1 runes for everybody; the next tiers need the respect of the NPC, earned delivering the items of his missions.
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- what each player is being asked: {name = "Flaming"}
local talks = {}

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end

-- says "prefix" and the entries, splitting in several messages to keep each one short
local function sayList(cid, prefix, entries)
	local part = prefix
	for _, entry in ipairs(entries) do
		if(#part + #entry + 2 > 200) then
			npcHandler:say(part, cid)
			part = ""
		end

		part = part .. " " .. entry
	end

	npcHandler:say(part, cid)
end

local function respectText(cid)
	local respect = RuneCarving.getRespect(cid)
	local rank = RuneCarving.getRank(cid)
	local text = "Your rank is {" .. RuneCarving.ranks[rank].name .. "} with " .. respect .. " respect. I carve {" .. RuneCarving.tiers[rank].name .. "} runes and the ones below."
	local nextRank = RuneCarving.ranks[rank + 1]
	if(nextRank) then
		text = text .. " " .. (nextRank.respect - respect) .. " more respect and I will carve " .. RuneCarving.tiers[rank + 1].name .. " runes for you."
	else
		text = text .. " There is nothing left I can teach you, the stone itself bows to you."
	end

	return text
end

local function missionText(cid)
	local index = RuneCarving.currentMission(cid)
	if(not index) then
		return "You have delivered everything I asked. I have no more missions, only respect for you."
	end

	local mission = RuneCarving.missions[index]
	return mission.text .. " Say {deliver} when you have them. It is worth " .. mission.respect .. " respect."
end

local function runesOfTier(tierIndex)
	local names = {}
	for name, data in pairs(RuneCarving.recipes) do
		if(data[2] == tierIndex) then
			table.insert(names, name)
		end
	end

	table.sort(names)
	for index, name in ipairs(names) do
		names[index] = "{" .. name .. "},"
	end

	return names
end

local function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	msg = msg:lower():trim()

	-- answering an offer
	local talk = talks[cid]
	if(talk) then
		if(msg == "yes") then
			talks[cid] = nil
			local ok, reason = RuneCarving.carve(cid, talk.name)
			if(ok) then
				npcHandler:say("Hah! Listen to it hum. A {" .. talk.name .. "} rune, fresh from the anvil. Use it on gear with a free slot, and make the enemy regret it!", cid)
			else
				npcHandler:say(reason .. " Come back when you have it all, I am not going anywhere.", cid)
			end

			return true
		elseif(msg == "no") then
			talks[cid] = nil
			npcHandler:say("No shame in thinking twice. A rushed rune is a broken rune.", cid)
			return true
		end
	end

	if(msg == "name" or msg == "durnok") then
		npcHandler:say("Durnok Runebrand, last keeper of the Brand-Forge. My beard is older than this city's walls, and my chisel is older than my beard.", cid)
	elseif(msg == "job" or msg == "occupation" or msg == "profession" or msg == "runesmith") then
		npcHandler:say("I wake the sleeping power in blank stone. Anyone can swing a sword, but a rune carries a piece of the mountain's heart. That is craft!", cid)
	elseif(msg == "blank rune" or msg == "blank" or msg == "runes" or msg == "carve") then
		npcHandler:say("Bring me a {blank rune} (the rune merchants sell them), some gold and gems of the element, and say the name of the rune you want, I will tell you what it does. Say {list} to hear which ones I know.", cid)
	elseif(msg == "respect" or msg == "rank" or msg == "status") then
		npcHandler:say(respectText(cid), cid)
	elseif(msg == "mission" or msg == "missions" or msg == "task") then
		npcHandler:say(missionText(cid), cid)
	elseif(msg == "deliver" or msg == "done" or msg == "finish" or msg == "complete") then
		local ok, gained, newRank = RuneCarving.deliver(cid)
		if(ok) then
			doSendMagicEffect(getThingPosition(cid), CONST_ME_FIREWORK_YELLOW)
			local text = "Now THAT is quality! You earned {" .. gained .. " respect}."
			if(newRank) then
				text = text .. " From today you are {" .. newRank .. "}, and the stronger runes are yours to command. Say {list} to see them!"
			else
				text = text .. " " .. missionText(cid)
			end

			npcHandler:say(text, cid)
		else
			npcHandler:say(gained .. " " .. (RuneCarving.currentMission(cid) and missionText(cid) or ""), cid)
		end
	elseif(msg == "list" or msg == "rune list") then
		local rank = RuneCarving.getRank(cid)
		for index = 1, rank do
			sayList(cid, RuneCarving.tiers[index].name .. " runes:", runesOfTier(index))
		end

		if(rank < #RuneCarving.tiers) then
			npcHandler:say("There are mightier runes, but you have not earned my {respect} for them yet.", cid)
		end
	elseif(msg == "price" or msg == "prices" or msg == "cost") then
		local lines = {}
		for _, tier in ipairs(RuneCarving.tiers) do
			table.insert(lines, tier.name .. ": " .. tier.gold .. " gold, " .. tier.gems .. " gems.")
		end

		npcHandler:say("The price of a rune: " .. table.concat(lines, " ") .. " The gem depends on the element.", cid)
	else
		-- the name of a rune
		local recipe = RuneCarving.recipe(msg)
		if(not recipe) then
			return false
		end

		-- every rune is explained on its own before the offer
		npcHandler:say("The {" .. recipe.name .. "} rune, " .. recipe.tier .. " work. " .. RuneCarving.description(recipe.name), cid)

		local tierIndex = RuneCarving.recipes[recipe.name][2]
		if(tierIndex > RuneCarving.getRank(cid)) then
			npcHandler:say("But I do not hand such power to someone who has not earned my {respect}. Ask me for a {mission}!", cid)
			return true
		end

		talks[cid] = {name = recipe.name}
		npcHandler:say("I need 1 blank rune, " .. recipe.gems .. " " .. getItemNameById(recipe.material) .. "s and " .. recipe.gold .. " gold coins. Shall I start? {yes} or {no}.", cid)
	end

	return true
end

local function onFarewell(cid)
	talks[cid] = nil
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_FAREWELL, onFarewell)
npcHandler:addModule(FocusModule:new())
