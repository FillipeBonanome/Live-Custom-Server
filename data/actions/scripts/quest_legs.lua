-- vip chests

function onUse(cid, item, fromPosition, itemEx, toPosition)

   	if item.uid == 5100 then
   		queststatus = getPlayerStorageValue(cid,50330)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_INFO_DESCR,"You have found a dragon scale legs.")
   			doPlayerAddItem(cid,2469,1)
   			setPlayerStorageValue(cid,50330,1)
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_INFO_DESCR,"It is empty.")
   		end

	end
   	return 1
end
