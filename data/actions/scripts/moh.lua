function onUse(cid, item, frompos, item2, topos)

	if item.uid == 1015 then
	queststatus = getPlayerStorageValue(cid,1015)
	if queststatus == -1 then
	doPlayerSendTextMessage(cid,22,"Voce encontrou uma Medalia de Honra.")
	doPlayerAddItem(cid,5785,1)
	setPlayerStorageValue(cid,1015,1)
	else
	doPlayerSendTextMessage(cid,22,"Esta vazio.")
	end
	else
	return 0
	end

	return 1
	end