function onUse(cid, item, frompos, item2, topos)

	if item.uid == 1011 then
	queststatus = getPlayerStorageValue(cid,1011)
	if queststatus == -1 then
	doPlayerSendTextMessage(cid,22,"You have found a Golden Helmet.")
	doPlayerAddItem(cid,2471,1)
	setPlayerStorageValue(cid,1011,1)
	else
	doPlayerSendTextMessage(cid,22,"It is empty.")
	end
	else
	return 0
	end

	return 1
	end