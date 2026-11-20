-- vip chests

function onUse(cid, item, fromPosition, itemEx, toPosition)

   	if item.uid == 5061 then
   		queststatus = getPlayerStorageValue(cid,50302)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_INFO_DESCR,"You have found a vip axe.")
   			doPlayerAddItem(cid,7455,1)
   			setPlayerStorageValue(cid,50302,1)
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_INFO_DESCR,"It is empty.")
   		end
   	elseif item.uid == 5062 then
   		queststatus = getPlayerStorageValue(cid,50302)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_INFO_DESCR,"You have found a vip sword.")
   			doPlayerAddItem(cid,8932,1)
   			setPlayerStorageValue(cid,50302,1)
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_INFO_DESCR,"It is empty.")
   		end
	elseif item.uid == 5064 then
   		queststatus = getPlayerStorageValue(cid,50302)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_INFO_DESCR,"You have found a vip star.")
   			doPlayerAddItem(cid,7366,1)
   			setPlayerStorageValue(cid,50302,1)
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_INFO_DESCR,"It is empty.")
   		end
	elseif item.uid == 5065 then
   		queststatus = getPlayerStorageValue(cid,50302)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_INFO_DESCR,"You have found a vip Staff.")
   			doPlayerAddItem(cid,7958,1)
   			setPlayerStorageValue(cid,50302,1)
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_INFO_DESCR,"It is empty.")
   		end
   	elseif item.uid == 5063 then
   		queststatus = getPlayerStorageValue(cid,50302)
   		if queststatus == -1 then
   			doPlayerSendTextMessage(cid,MESSAGE_INFO_DESCR,"You have found a vip club.")
   			doPlayerAddItem(cid,7450,1)
   			setPlayerStorageValue(cid,50302,1)
   		else
   			doPlayerSendTextMessage(cid,MESSAGE_INFO_DESCR,"It is empty.")
   		end
	end
   	return 1
end


