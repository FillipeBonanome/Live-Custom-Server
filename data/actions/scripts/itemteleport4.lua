function onUse(cid, item, frompos, item2, topos)


        if item.uid == 1023 and item.itemid == 1945 then

  player1pos = {x=371, y=480, z=7, stackpos=253}
  player1 = getThingfromPos(player1pos)

  item1pos = {x=372, y=480, z=7, stackpos=1}
  item1 = getThingfromPos(item1pos)

  if player1.itemid > 0 then
        queststatus1 = getPlayerStorageValue(player1.uid,1002)
  
  if queststatus1 == -1 and item1.itemid == 2432 then

  doRemoveItem(item1.uid,1)
  doSendMagicEffect(item1,2)

  nplayer1pos = {x=313, y=415, z=7}
  doSendMagicEffect(player1pos,2)
  doTeleportThing(player1.uid,nplayer1pos)
  doSendMagicEffect(nplayer1pos,10)
  doTransformItem(item.uid,item.itemid+1)
  setPlayerStorageValue(cid,1020,1)
  
  else
  doPlayerSendCancel(cid,"Sorry, not possible.")
  end
  else
  doPlayerSendCancel(cid,"Sorry, not possible.")
  end

  elseif item.uid == 1023 and item.itemid == 1946 then

  player1pos = {x=371, y=480, z=7, stackpos=253}
  player1 = getThingfromPos(player1pos)

  item1pos = {x=372, y=480, z=7, stackpos=1}
  item1 = getThingfromPos(item1pos)

  if player1.itemid > 0 then
        queststatus1 = getPlayerStorageValue(player1.uid,1002)
  
  if queststatus1 == -1 and item1.itemid == 2498 then

  doRemoveItem(item1.uid,1)
  doSendMagicEffect(item1,2)

  nplayer1pos = {x=313, y=415, z=7}
  doSendMagicEffect(player1pos,2)
  doTeleportThing(player1.uid,nplayer1pos)
  doSendMagicEffect(nplayer1pos,10)
  doTransformItem(item.uid,1945) 
  setPlayerStorageValue(cid,1023,1)
  
  else
  doPlayerSendCancel(cid,"Sorry, not possible.")
  end
  else
  doPlayerSendCancel(cid,"Sorry, not possible.")
  end
        else
  return 0
        end

        return 1
end