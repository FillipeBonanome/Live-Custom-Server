function onUse(cid, item, frompos, item2, topos)

	newpos = {x=160, y=51, z=7}

	if item.uid == 9826 and item.itemid == 2433 then
		doPlayerRemoveMoney(cid,100)
		doTeleportThing(cid,newpos)
		doSendMagicEffect(newpos,2)
		doTransformItem(item.uid,item.itemid+1)
	elseif item.uid == 9826 and item.itemid == 2432 then
		doTransformItem(item.uid,item.itemid-1)
	else
		doPlayerSendCancel(cid,"Você precisa ter 1 fire axe")
	end
	return 1
end
