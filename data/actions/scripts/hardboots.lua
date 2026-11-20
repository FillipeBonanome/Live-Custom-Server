function onUse(cid, item, frompos, item2, topos)

	if item.uid == 1016 then
	queststatus = getPlayerStorageValue(cid,1016)
	if queststatus == -1 then
	doPlayerSendTextMessage(cid,22,"Voce encontrou uma Hard Boots.")
	doPlayerAddItem(cid,2358,1)
	setPlayerStorageValue(cid,1016,1)
	else
	doPlayerSendTextMessage(cid,22,"Esta vazio.")
	end
	else
	return 0
	end

	return 1
	end