function onUse(cid, item, fromPosition, itemEx, toPosition)
        local pass = getPlayerStorageValue(cid,1031)
        if pass == 1 then
                doTransformItem(item.uid, item.itemid + 1)
                doTeleportThing(cid, toPosition)
        else
                doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Você precisa não pode passar.")
        end
        return true
end