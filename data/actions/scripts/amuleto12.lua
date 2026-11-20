function onUse(cid, item, frompos, item2, topos)

	if item.uid == 1013 then
	queststatus = getPlayerStorageValue(cid,1013)
	if queststatus == -1 then
	doPlayerSendTextMessage(cid,22,"Voce encontrou um koshei's ancient amulet.")
	doPlayerAddItem(cid,8266,1)
	setPlayerStorageValue(cid,1013,1)
	else
	doPlayerSendTextMessage(cid,22,"Esta vazio.")
	end
	else
	return 0
	end

	return 1
	end