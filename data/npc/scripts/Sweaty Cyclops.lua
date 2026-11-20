local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid)        end
function onCreatureDisappear(cid)        npcHandler:onCreatureDisappear(cid)        end
function onCreatureSay(cid, type, msg)        npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                npcHandler:onThink()                end

-- XVX FORGER START --

function chicken(cid, message, keywords, parameters, node)
    if(not npcHandler:isFocused(cid)) then
        return false
    end
        if getPlayerItemCount(cid,2520) >= 1 then
        if doPlayerRemoveItem(cid,2520,1) then
            npcHandler:say('Here is your item!', cid)
            doPlayerAddItem(cid,5940,1)
        end
        else
            npcHandler:say('You don\'t have these items!', cid)
    end
end

function obsidian(cid, message, keywords, parameters, node)
    if(not npcHandler:isFocused(cid)) then
        return false
    end
        if getPlayerItemCount(cid,2516) >= 1 and getPlayerItemCount(cid,2425) >= 1 then
        if doPlayerRemoveItem(cid,2516,1) and doPlayerRemoveItem(cid,2425,1) then
            npcHandler:say('Here is your item!', cid)
            doPlayerAddItem(cid,5908,1)
        end
        else
            npcHandler:say('You don\'t have these items!', cid)
    end
end	

function crude(cid, message, keywords, parameters, node)
    if(not npcHandler:isFocused(cid)) then
        return false
    end
        if getPlayerItemCount(cid,5879) >= 1 then
        if doPlayerRemoveItem(cid,5879,1) then
            npcHandler:say('Here is your item!', cid)
            doPlayerAddItem(cid,5892,1)
        end
        else
            npcHandler:say('You don\'t have these items!', cid)
    end
end

function draconian(cid, message, keywords, parameters, node)
    if(not npcHandler:isFocused(cid)) then
        return false
    end
        if getPlayerItemCount(cid,2516) >= 1 then
        if doPlayerRemoveItem(cid,2516,1) then
            npcHandler:say('Here is your item!', cid)
            doPlayerAddItem(cid,5889,1)
        end
        else
            npcHandler:say('You don\'t have these items!', cid)
   end   
end

-- XVX FORGER END --

keywordHandler:addKeyword({'lista'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = "I troco {Enchanted Chicken Wing}, {Wolf Tooth Chain}, {Huge Chunk of Crude Iron}, {Piece of Hell Steel}, {Piece of Draconian Steel} and {Piece of Draconian Steel}!"})

local node1 = keywordHandler:addKeyword({'wolf tooth chain'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to trade a Demon Shield for a Wolf Tooth Chain?'})
    node1:addChildKeyword({'yes'}, chicken, {npcHandler = npcHandler, onlyFocus = true, reset = true})
    node1:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Alright then. Come back when you got the neccessary items.', reset = true})

local node2 = keywordHandler:addKeyword({'enchanted chicken wing'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to trade a Dragon Shield for an Enchanted Chicken Wing?'})
    node2:addChildKeyword({'yes'}, obsidian, {npcHandler = npcHandler, onlyFocus = true, reset = true})
    node2:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Alright then. Come back when you got the neccessary items.', reset = true})

local node3 = keywordHandler:addKeyword({'crude'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to trade a Giant Spider Silk for a Huge Chunk of Crude Iron?'})
    node3:addChildKeyword({'yes'}, crude, {npcHandler = npcHandler, onlyFocus = true, reset = true})
    node3:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Alright then. Come back when you got the neccessary items.', reset = true})
	
local node4 = keywordHandler:addKeyword({'draconian'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to trade a Dragon Shield for a Piece of Draconian Steel?'})
    node4:addChildKeyword({'yes'}, draconian, {npcHandler = npcHandler, onlyFocus = true, reset = true})
    node4:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Alright then. Come back when you got the neccessary items.', reset = true})

npcHandler:addModule(FocusModule:new())