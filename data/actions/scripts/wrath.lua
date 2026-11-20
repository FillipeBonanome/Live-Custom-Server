-- Wrath of the emperor chest

function onUse(cid, item, frompos, item2, topos)

       if item.uid == 9990 then
           queststatus = getPlayerStorageValue(cid,9990)
           if queststatus == -1 then
               doPlayerSendTextMessage(cid,22,"You have found a Elite Draken Helmet.")
               doPlayerAddItem(cid,12606,1)
               setPlayerStorageValue(cid,9990,1)
           else
               doPlayerSendTextMessage(cid,22,"It is empty.")
           end
       elseif item.uid == 9991 then
           queststatus = getPlayerStorageValue(cid,9990)
           if queststatus == -1 then
               doPlayerSendTextMessage(cid,22,"You have found a Royal Scale Robe.")
               doPlayerAddItem(cid,12604,1)
               setPlayerStorageValue(cid,9990,1)
           else
               doPlayerSendTextMessage(cid,22,"It is empty.")
           end
       elseif item.uid == 9992 then
           queststatus = getPlayerStorageValue(cid,9990)
           if queststatus == -1 then
               doPlayerSendTextMessage(cid,22,"You have found a Royal Draken Mail.")
               doPlayerAddItem(cid,12603,1)
               setPlayerStorageValue(cid,9990,1)
           else
               doPlayerSendTextMessage(cid,22,"It is empty.")
           end
    
    else
        return 0
       end

       return 1
end