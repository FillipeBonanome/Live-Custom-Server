local talk_state = 0

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)  npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid)       npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg)  npcHandler:onCreatureSay(cid, type, msg)        end
function onThink()  npcHandler:onThink() end

function creatureSayCallback(cid, type, msg)


        if msgcontains(msg, 'yes') or msgcontains(msg, 'spider silk') then
        if getPlayerItemCount(cid,5879) >= 100 then
        if doPlayerRemoveItem(cid,5879,100) then
        doPlayerAddItem(cid,5886,10)
        npcHandler:say('Aqui está seu item')
                end
                else
        npcHandler:say('Você não tem o item')
        talk_state = 0
                end
        elseif msgcontains(msg, 'bye') then
                npcHandler:say('Até mais, ' .. getCreatureName(cid) .. '! Volte em breve...')
                talk_state = 0
     end

return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())