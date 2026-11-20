function onThink(cid, interval)

if getTilePzInfo(getCreaturePosition(cid)) then
    return true
end

local minuto = 1 -- quantos minuto para atravesar o player.
local protectionLevel = 40 -- protection level do server.
local position = getPlayerPosition(cid)

if getPlayerLookDir(cid) == 0 then
    position = {x=position.x, y=position.y-1, z=position.z}
elseif getPlayerLookDir(cid) == 1 then
    position = {x=position.x+1, y=position.y, z=position.z}
elseif getPlayerLookDir(cid) == 2 then
    position = {x=position.x, y=position.y+1, z=position.z}
elseif getPlayerLookDir(cid) == 3 then
    position = {x=position.x-1, y=position.y, z=position.z}
end

for i = 0, 255 do
local o = 0
    position.stackpos = i
    local tile = getTileThingByPos(position)
    if isPlayer(tile.uid) and getPlayerLevel(tile.uid) < protectionLevel then
local o = 1
        setPlayerStorageValue(cid, 56421, getPlayerStorageValue(cid,56421)+1)
        if getPlayerStorageValue(cid, 56421) >= 120*minuto then
            setPlayerStorageValue(cid, 56421, 0)
            doTeleportThing(cid, getPlayerPosition(tile.uid))
        end
break
    elseif i == 255 and o == 0 then
setPlayerStorageValue(cid, 56421, 0)
end
end

return true
end