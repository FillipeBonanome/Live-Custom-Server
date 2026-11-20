function onUse(cid, item, frompos, item2, topos)

	if item.uid == 1014 then
	queststatus = getPlayerStorageValue(cid,1014)
	if queststatus == -1 then
	doPlayerSendTextMessage(cid,22,"Voce encontrou uma Elite Draken Mail.")
	doPlayerAddItem(cid,12568,1)
	setPlayerStorageValue(cid,1014,1)
	else
	doPlayerSendTextMessage(cid,22,"Esta vazio.")
	end
	else
	return 0
	end

	return 1
	end