local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

-- keywords: palavras que ativam a troca; give/take: itemid recebido pelo player / itemid cobrado; name: item cobrado
local trades = {
	{keywords = {"ceiron's wolf tooth chain", "ceiron's wolf tooth"}, name = "Demon Shield", take = 2520, give = 5940},
	{keywords = {"enchanted chicken wing", "enchanted chicken"}, name = "Boots of Haste", take = 2195, give = 5891},
	{keywords = {"piece of royal steel"}, name = "Crown Armor", take = 2487, give = 5887},
}

local helpText = "Eu troco {ceiron's wolf tooth chain}, {enchanted chicken wing}, {piece of royal steel}, {piece of draconian steel}, {piece of hell steel}, {huge chunk of crude iron}, {damaged steel helmet}, {warrior's sweat}, {soul stone}, {simon the beggar's favorite staff}, {Ceiron's Waterskin}, {Ceiron's Wolf Tooth Chain}, {fighting spirit}."

function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid

	if(msgcontains(msg, 'help') or msgcontains(msg, 'ajuda')) then
		selfSay(helpText, cid)
		return true
	end

	-- confirmacao de uma troca ja oferecida
	local current = talkState[talkUser]
	if(current ~= nil) then
		if(msgcontains(msg, 'yes')) then
			local trade = trades[current]
			if(doPlayerRemoveItem(cid, trade.take, 1)) then
				doPlayerAddItem(cid, trade.give, 1)
				selfSay('Aqui está.', cid)
			else
				selfSay('Sorry, você não tem o item.', cid)
			end
			talkState[talkUser] = nil
			return true
		elseif(msgcontains(msg, 'no')) then
			talkState[talkUser] = nil
			selfSay('Ok then.', cid)
			return true
		end
	end

	-- inicio de uma troca
	for index, trade in ipairs(trades) do
		for _, keyword in ipairs(trade.keywords) do
			if(msgcontains(msg, keyword)) then
				selfSay('Você tem 1 ' .. trade.name .. ' para trocar pelo {' .. trade.keywords[1] .. '}?', cid)
				talkState[talkUser] = index
				return true
			end
		end
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
