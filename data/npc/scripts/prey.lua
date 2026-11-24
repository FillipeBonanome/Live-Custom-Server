local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- conversation state of each player: {step = "monster"|"type"|"strength"|"confirm", monster, type, strength}
local talks = {}

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end

local function typeList()
	local names = {}
	for _, preyType in ipairs(Prey.types) do
		table.insert(names, "{" .. preyType.name .. "}")
	end

	return table.concat(names, ", ")
end

local function strengthList()
	local entries = {}
	for _, strength in ipairs(Prey.strengths) do
		table.insert(entries, "{" .. strength.name .. "} (+" .. Prey.getBonus(strength) .. "%, " .. Prey.getPrice(strength) .. " gold)")
	end

	return table.concat(entries, ", ")
end

local function hours()
	return Prey.formatTime(Prey.getDuration())
end

local function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	if(not Prey.isEnabled()) then
		npcHandler:say("The prey system is disabled.", cid)
		return true
	end

	msg = msg:lower():trim()
	local talk = talks[cid]

	if(msg == "cancel") then
		talks[cid] = nil
		npcHandler:say("Alright, nothing was changed.", cid)
		return true
	end

	if(msg == "clear" or msg == "remove" or msg == "reset") then
		talks[cid] = nil
		if(Prey.clear(cid)) then
			npcHandler:say("Your prey was cleared for free. Say {prey} when you want a new one.", cid)
		else
			npcHandler:say("You have no active prey.", cid)
		end

		return true
	end

	if(msg == "status" or msg == "time") then
		local prey = Prey.get(cid)
		npcHandler:say(prey and ("Your prey: " .. Prey.describe(prey)) or "You have no active prey. Say {prey} to get one.", cid)
		return true
	end

	if(not talk) then
		if(msg == "prey" or msg == "hunt" or msg == "bonus" or msg == "help") then
			local prey = Prey.get(cid)
			if(prey) then
				npcHandler:say("You already have a prey. " .. Prey.describe(prey) .. " Say {clear} to remove it for free and pick another one.", cid)
				return true
			end

			talks[cid] = {step = "monster"}
			npcHandler:say("Which monster do you want to hunt? Tell me its name (or {cancel}). The bonus lasts " .. hours() .. ".", cid)
			return true
		end

		return false
	end

	if(talk.step == "monster") then
		local monster = Prey.findMonster(msg)
		if(not monster) then
			npcHandler:say("I do not know any huntable creature called " .. msg .. ". Tell me another name or say {cancel}.", cid)
			return true
		end

		talk.monster, talk.step = monster, "type"
		npcHandler:say("Which bonus do you want against " .. monster.name .. "? " .. typeList() .. ".", cid)
		return true
	end

	if(talk.step == "type") then
		local preyType = Prey.getType(msg)
		if(not preyType) then
			npcHandler:say("Choose one of: " .. typeList() .. ".", cid)
			return true
		end

		talk.type, talk.step = preyType, "strength"
		npcHandler:say("How strong? " .. strengthList() .. ".", cid)
		return true
	end

	if(talk.step == "strength") then
		local strength = Prey.getStrength(msg)
		if(not strength) then
			npcHandler:say("Choose one of: " .. strengthList() .. ".", cid)
			return true
		end

		talk.strength, talk.step = strength, "confirm"
		npcHandler:say(talk.type.label .. " +" .. Prey.getBonus(strength) .. "% against " .. talk.monster.name .. " for " .. hours() ..
			" costs " .. Prey.getPrice(strength) .. " gold. Do you accept? {yes} or {no}.", cid)
		return true
	end

	if(talk.step == "confirm") then
		talks[cid] = nil
		if(msg ~= "yes") then
			npcHandler:say("Alright, nothing was bought. Say {prey} to choose again.", cid)
			return true
		end

		local ok, reason = Prey.set(cid, talk.monster.name, talk.type.name, talk.strength.name)
		if(ok) then
			doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
			npcHandler:say("Done! Good hunt. " .. Prey.describe(Prey.get(cid)), cid)
		else
			npcHandler:say(reason, cid)
		end

		return true
	end

	return false
end

local function onFarewell(cid)
	talks[cid] = nil
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_CREATURE_DISAPPEAR, onFarewell)
npcHandler:setCallback(CALLBACK_FAREWELL, onFarewell)
npcHandler:addModule(FocusModule:new())

Language.install()
