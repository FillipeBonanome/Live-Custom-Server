--- Created by Darkhaos

function onDeath(cid, corpse, killer)

registerCreatureEvent(cid, "Azerus")

local creaturename = getCreatureName(cid)
local in_pos = {x=1253, y=172, z=9, stackpos=2}
local checkIID = getThingfromPos(in_pos)
local to_pos = {x=1287, y=165, z=9, stackpos=1} 
local time_to_pass = 30 -- in seconds
local tpID = 1387

if creaturename == 'Azerus' then

teleport = doCreateTeleport(tpID, to_pos, in_pos)

doSendMagicEffect(in_pos, CONST_ME_TELEPORT)

doCreatureSay(cid, "You have 30 seconds to enter the teleport before it is closed.", TALKTYPE_ORANGE_1)
addEvent(removeTeleport, (1000*time_to_pass))


end
end

function removeTeleport()
if getThingfromPos({x=1253, y=172, z=9, stackpos=1}).itemid == 1387 then
doRemoveItem(getThingfromPos({x=1253, y=172, z=9, stackpos=1}).uid,1)
doSendMagicEffect({x=1253, y=172, z=9, stackpos=1}, CONST_ME_POFF)
return TRUE
end
end 