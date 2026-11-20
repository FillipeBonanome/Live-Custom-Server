local keywordHandler = KeywordHandler:new() 
local npcHandler = NpcHandler:new(keywordHandler) 
NpcSystem.parseParameters(npcHandler) 
local talkState = {} 
 
function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end 
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end 
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end 
function onThink() npcHandler:onThink() end 
 
function creatureSayCallback(cid, type, msg) 
if(not npcHandler:isFocused(cid)) then 
return false  
end  
 
local talkUser = NPCHANDLER_CONVbehavior == CONVERSATION_DEFAULT and 0 or cid  
 
-- Conversa Jogador/NPC  
if(msgcontains(msg, 'lista')) then 
selfSay('Eu troco {ceiron`s wolf tooth chain}, {enchanted chicken wing}, {piece of royal steel}, {piece of draconian steel}, {piece of hell steel}, {huge chunk} {of} {crude iron}, {damaged steel helmet}, {warrior`s sweat}, {soul stone}, {simon the beggar`s favorite staff}, {Waterhose}, {Ceiron`s Wolf Tooth Chain}, {fighting spirit}, {elane`s} {crossbow}, {vampiric crest}, {ankh} e {Mandrake}.', cid) 
elseif(msgcontains(msg, 'ceiron`s wolf tooth chain')) then 
selfSay('Voc\ê quer trocar um Demon Shield por um ceiron`s wolf tooth chain?', cid) 
talkState[talkUser] = 1 
elseif(msgcontains(msg, 'enchanted chicken wing')) then 
selfSay('Voc\ê quer trocar uma Boots of Haste por uma Enchanted Chicken Wing?', cid) 
talkState[talkUser] = 2 
elseif(msgcontains(msg, 'piece of royal steel') )then 
selfSay('Voc\ê quer trocar uma Crown Armor por um Piece of Royal Steel?', cid) 
talkState[talkUser] = 3 
elseif(msgcontains(msg, 'Piece of Draconian Steel')) then 
selfSay('Voc\ê quer trocar um Dragon Shield por um Piece of Draconian Steel?', cid) 
talkState[talkUser] = 4 
elseif(msgcontains(msg, 'Piece of Hell Steel')) then 
selfSay('Voc\ê quer trocar um Devil Helmet por um Piece of Hell Steel?', cid) 
talkState[talkUser] = 5 
elseif(msgcontains(msg, 'Huge Chunk of Crude Iron')) then 
selfSay('Voc\ê quer trocar uma Giant Sword por um Huge Chunk of Crude Iron?', cid) 
talkState[talkUser] = 6 
elseif(msgcontains(msg, 'Damaged Steel Helmet')) then 
selfSay('Voc\ê quer trocar um Skull Helmet por um Damaged Steel Helmet?', cid) 
talkState[talkUser] = 7 
elseif(msgcontains(msg, 'warrior`s sweat')) then 
selfSay('Voc\ê quer trocar QUATRO Warrior Helmets por um Warrior`s Sweat?', cid) 
talkState[talkUser] = 8 
elseif(msgcontains(msg, 'Soul Stone')) then 
selfSay('Voc\ê quer trocar DUAS Skull Staff por uma Soul Stone?', cid) 
talkState[talkUser] = 9 
elseif(msgcontains(msg, 'Simon the Beggar`s Favorite Staff')) then 
selfSay('Voc\ê quer trocar uma Staff por um Simon the Beggar`s Favorite Staff?', cid) 
talkState[talkUser] = 10 
elseif(msgcontains(msg, 'Waterhose')) then 
selfSay('Voc\ê quer trocar uma Knight Legs por um Waterhose?', cid) 
talkState[talkUser] = 11 
elseif(msgcontains(msg, 'fighting spirit')) then 
selfSay('Voc\ê quer trocar DOIS Royal Helmets por um Fighting Spirit?', cid) 
talkState[talkUser] = 12 
elseif(msgcontains(msg, 'elane`s crossbow')) then 
selfSay('Voc\ê quer trocar um Vampire Shield por um elane`s crossbow?', cid) 
talkState[talkUser] = 13 
elseif(msgcontains(msg, 'Mandrake')) then 
selfSay('Voc\ê quer trocar CINCO Fire Sword por um Mandrake?', cid) 
talkState[talkUser] = 14 
elseif(msgcontains(msg, 'vampiric crest')) then 
selfSay('Voc\ê quer trocar uma Golden Legs por um Vampiric Crest?', cid) 
talkState[talkUser] = 15 
elseif(msgcontains(msg, 'ankh')) then 
selfSay('Voc\ê quer trocar um Crystal coins por um Ankh?', cid) 
talkState[talkUser] = 16
 
-- Confirmação da Compra  
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 1) then  
if(doPlayerRemoveItem(cid, 2520, 1) == true) then  
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 5940, 1) 
talkState[talkUser] = 0 
else  
selfSay('Voc\ê n\ão tem um Demon Shield.', cid) 
talkState[talkUser] = 0  
end  
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 2) then 
if(doPlayerRemoveItem(cid, 2195, 1) == true) then 
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 5891, 1) 
talkState[talkUser] = 0 
else  
selfSay('Voc\ê n\ão tem uma Boots of Haste.', cid) 
talkState[talkUser] = 0 
end  
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 3) then 
if(doPlayerRemoveItem(cid, 2487, 1) == true) then 
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 5887, 1) 
talkState[talkUser] = 0 
else 
selfSay('Voc\ê n\ão tem um Crown Armor.', cid) 
talkState[talkUser] = 0 
end  
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 4) then 
if(doPlayerRemoveItem(cid, 2516, 1) == true) then 
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 5889, 1) 
talkState[talkUser] = 0 
else 
selfSay('Voc\ê n\ão tem um Dragon Shield.', cid) 
talkState[talkUser] = 0 
end 
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 5) then 
if(doPlayerRemoveItem(cid, 2462, 1) == true) then 
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 5888, 1)  
talkState[talkUser] = 0 
else 
selfSay('Voc\ê n\ão tem um Devil Helmet.', cid) 
talkState[talkUser] = 0 
end 
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 6) then 
if(doPlayerRemoveItem(cid, 2393, 1) == true) then 
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 5892, 1)  
talkState[talkUser] = 0 
else  
selfSay('Voc\ê n\ão tem uma Giant Sword.', cid) 
talkState[talkUser] = 0  
end  
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 7) then 
if(doPlayerRemoveItem(cid, 5741, 1) == true) then 
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 5924, 1) 
talkState[talkUser] = 0 
else  
selfSay('Voc\ê n\ão tem um Skull Helmet.', cid) 
talkState[talkUser] = 0 
end  
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 8) then 
if(doPlayerRemoveItem(cid, 2475, 4) == true) then 
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 5885, 1) 
talkState[talkUser] = 0 
else 
selfSay('Voc\ê n\ão tem QUATRO Warrior Helmets.', cid) 
talkState[talkUser] = 0 
end  
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 9) then 
if(doPlayerRemoveItem(cid, 2436, 2) == true) then 
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 5809, 1)  
talkState[talkUser] = 0 
else 
selfSay('Voc\ê n\ão tem DUAS Skull Staff.', cid) 
talkState[talkUser] = 0 
end 
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 10) then 
if(doPlayerRemoveItem(cid, 2401, 1) == true) then 
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 6107, 1)  
talkState[talkUser] = 0 
else 
selfSay('Voc\ê n\ão tem uma Staff.', cid) 
talkState[talkUser] = 0 
end 
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 11) then  
if(doPlayerRemoveItem(cid, 2477, 1) == true) then 
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 5939, 1) 
talkState[talkUser] = 0 
else  
selfSay('Voc\ê n\ão tem uma Knight Legs.', cid) 
talkState[talkUser] = 0  
end  
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 12) then 
if(doPlayerRemoveItem(cid, 2498, 2) == true) then 
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 5884, 1) 
talkState[talkUser] = 0 
else  
selfSay('Voc\ê n\ão tem DOIS Royal Helmets.', cid) 
talkState[talkUser] = 0 
end  
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 13) then 
if(doPlayerRemoveItem(cid, 2534, 1) == true) then 
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 5947, 1)  
talkState[talkUser] = 0 
else 
selfSay('Voc\ê n\ão tem um Vampire Shield.', cid) 
talkState[talkUser] = 0 
end  
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 14) then 
if(doPlayerRemoveItem(cid, 2392, 5) == true) then 
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 5015, 1) 
talkState[talkUser] = 0 
else 
selfSay('Voc\ê n\ão tem CINCO Fire Sword.', cid) 
talkState[talkUser] = 0 
end 
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 15) then 
if(doPlayerRemoveItem(cid, 2470, 1) == true) then 
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 9955, 1) 
talkState[talkUser] = 0 
else 
selfSay('Voc\ê n\ão tem uma Golden Legs.', cid) 
talkState[talkUser] = 0 
end
elseif(msgcontains(msg, 'yes') and talkState[talkUser] == 16) then 
if(doPlayerRemoveItem(cid, 2160, 1) == true) then 
selfSay('Obrigado por comprar!', cid) 
doPlayerAddItem(cid, 2193, 1) 
talkState[talkUser] = 0 
else 
selfSay('Voc\ê n\ão tem um Crystal coins.', cid) 
talkState[talkUser] = 0 
end 
end 
return TRUE 
end 
 
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback) 
npcHandler:addModule(FocusModule:new())