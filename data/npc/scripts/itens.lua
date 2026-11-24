-- A Sweaty Cyclops: trades items for other items. Speaks the language chosen by the player (data/lib/202-language.lua).
-- Names of items are not translated. Texts have no accents on purpose (encoding of the files).
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- item the player is being asked to trade, by player: index of TRADES
local talks = {}

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end

-- key = what the player says, give = {item id, amount} the player delivers, get = item id received
local TRADES = {
	{key = "ceiron's wolf tooth chain", give = {2520, 1}, get = 5940},
	{key = "enchanted chicken wing", give = {2195, 1}, get = 5891},
	{key = "piece of royal steel", give = {2487, 1}, get = 5887},
	{key = "piece of draconian steel", give = {2516, 1}, get = 5889},
	{key = "piece of hell steel", give = {2462, 1}, get = 5888},
	{key = "huge chunk of crude iron", give = {2393, 1}, get = 5892},
	{key = "damaged steel helmet", give = {5741, 1}, get = 5924},
	{key = "warrior's sweat", give = {2475, 4}, get = 5885},
	{key = "soul stone", give = {2436, 2}, get = 5809},
	{key = "simon the beggar's favorite staff", give = {2401, 1}, get = 6107},
	{key = "waterhose", give = {2477, 1}, get = 5939},
	{key = "fighting spirit", give = {2498, 2}, get = 5884},
	{key = "elane's crossbow", give = {2534, 1}, get = 5947},
	{key = "mandrake", give = {2392, 5}, get = 5015},
	{key = "vampiric crest", give = {2470, 1}, get = 9955},
	{key = "ankh", give = {2160, 1}, get = 2193}
}

local TEXTS = {
	greet = {
		en = "Hum Humm! Welcome |NAME|. I trade items. Say {list} and check the items.",
		pt = "Hum Humm! Bem-vindo |NAME|. Eu troco itens. Diga {lista} e confira os itens."
	},
	job = {
		en = "I'm an forger.",
		pt = "Eu sou um forjador."
	},
	list = {
		en = "I trade LIST.",
		pt = "Eu troco LIST."
	},
	ask = {
		en = "Do you want to trade AMOUNT GIVE for a GET?",
		pt = "Voce quer trocar AMOUNT GIVE por um GET?"
	},
	done = {
		en = "Thank you for trading!",
		pt = "Obrigado pela troca!"
	},
	missing = {
		en = "You do not have AMOUNT GIVE.",
		pt = "Voce nao tem AMOUNT GIVE."
	},
	declined = {
		en = "Alright then. Come back when you got the necessary items.",
		pt = "Certo entao. Volte quando tiver os itens necessarios."
	}
}

local ALIASES = {["lista"] = "list", ["sim"] = "yes", ["nao"] = "no", ["profissao"] = "job", ["trabalho"] = "job"}

local function text(cid, texts, replaces)
	local value = Language.text(cid, texts):gsub("|NAME|", function() return getCreatureName(cid) end)
	for key, replace in pairs(replaces or {}) do
		value = value:gsub(key, function() return tostring(replace) end)
	end

	return value
end

local function say(cid, texts, replaces)
	npcHandler:say(text(cid, texts, replaces), cid)
end

local function findTrade(msg)
	msg = msg:gsub("`", "'")
	for index, trade in ipairs(TRADES) do
		if(msg:find(trade.key, 1, true)) then
			return index
		end
	end

	return nil
end

-- "Skull Staffs" for more than one, "Demon Shield" for one
local function giveName(trade)
	return getItemNameById(trade.give[1]) .. (trade.give[2] > 1 and "s" or "")
end

local function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	msg = msg:lower():trim()
	msg = ALIASES[msg] or msg

	if(msg == "list") then
		local names = {}
		for _, trade in ipairs(TRADES) do
			table.insert(names, "{" .. trade.key .. "}")
		end

		say(cid, TEXTS.list, {LIST = table.concat(names, ", ")})
		return true
	elseif(msg == "job") then
		say(cid, TEXTS.job)
		return true
	end

	local offered = talks[cid]
	if(offered and (msg == "yes" or msg == "no")) then
		talks[cid] = nil
		if(msg == "no") then
			say(cid, TEXTS.declined)
			return true
		end

		local trade = TRADES[offered]
		if(doPlayerRemoveItem(cid, trade.give[1], trade.give[2])) then
			doPlayerAddItem(cid, trade.get, 1)
			say(cid, TEXTS.done)
		else
			say(cid, TEXTS.missing, {AMOUNT = trade.give[2], GIVE = giveName(trade)})
		end

		return true
	end

	local index = findTrade(msg)
	if(index) then
		talks[cid] = index
		local trade = TRADES[index]
		say(cid, TEXTS.ask, {AMOUNT = trade.give[2], GIVE = giveName(trade), GET = getItemNameById(trade.get)})
		return true
	end

	return false
end

local function onFarewell(cid)
	talks[cid] = nil
	return true
end

local function onGreet(cid)
	npcHandler:setMessage(MESSAGE_GREET, text(cid, TEXTS.greet))
	return true
end

npcHandler:setCallback(CALLBACK_GREET, onGreet)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_CREATURE_DISAPPEAR, onFarewell)
npcHandler:setCallback(CALLBACK_FAREWELL, onFarewell)
npcHandler:addModule(FocusModule:new())
Language.install()
