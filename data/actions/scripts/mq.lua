function onUse(cid, item, frompos, item2, topos)

	if item.uid == 1017 then
	queststatus = getPlayerStorageValue(cid,1017)
	if queststatus == -1 then
	doPlayerSendTextMessage(cid,22,"Voce encontrou um Snake God's Wristguard.")
	doPlayerAddItem(cid,12608,1)
	setPlayerStorageValue(cid,1017,1)
	else
	doPlayerSendTextMessage(cid,22,"Esta vazio.")
	end
	else
	return 0
	end

	return 1
	end