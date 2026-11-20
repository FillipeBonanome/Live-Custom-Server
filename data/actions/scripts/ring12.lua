function onUse(cid, item, frompos, item2, topos)

	if item.uid == 1012 then
	queststatus = getPlayerStorageValue(cid,1012)
	if queststatus == -1 then
	doPlayerSendTextMessage(cid,22,"You have found a Hard Ring.")
	doPlayerAddItem(cid,7708,1)
	setPlayerStorageValue(cid,1012,1)
	else
	doPlayerSendTextMessage(cid,22,"It is empty.")
	end
	else
	return 0
	end

	return 1
	end