local firstItems = {}
firstItems[0] =
{
2173,
2525,
3965,
2124,
2457,
2647,
2643
}
firstItems[1] =
{
2173,
2525,
2190,
2124,
2457,
2647,
2643
}
firstItems[2] =
{
2173,
2525,
2182,
2124,
2457,
2647,
2643
}
firstItems[3] =
{
2173,
2525,
2399,
2124,
2457,
2647,
2643
}
firstItems[4] =
{
2173,
2525,
2428,
2124,
2457,
2647,
2643,
2394,
}

-- Cleric: wand of vortex
firstItems[9] =
{
2173,
2525,
2190,
2124,
2457,
2647,
2643
}
-- Necromancer: skull staff
firstItems[11] =
{
2173,
2525,
2436,
2124,
2457,
2647,
2643
}
-- Assassin: two daggers (dual wield)
firstItems[13] =
{
2173,
2525,
2379,
2379,
2124,
2457,
2647,
2643
}
-- Berserker: orcish axe
firstItems[15] =
{
2173,
2525,
2428,
2124,
2457,
2647,
2643,
2394
}
-- Archer: bow + arrows
firstItems[17] =
{
2173,
2525,
2456,
2124,
2457,
2647,
2643
}
-- Geomancer: club (clubs only)
firstItems[19] =
{
2173,
2525,
2382,
2124,
2457,
2647,
2643
}

-- promoted vocations use the list of their base vocation (and unknown ones fall back to none)
local function getFirstItems(cid)
local voc = getPlayerVocation(cid)
if firstItems[voc] then
return firstItems[voc]
end
local info = getVocationInfo(voc)
local base = info and info.fromVocation
return firstItems[base or 0] or firstItems[0]
end

function onLogin(cid)
if getPlayerStorageValue(cid, 30001) == -1 then
local items = getFirstItems(cid)
for i = 1, table.maxn(items) do
doPlayerAddItem(cid, items[i], 1)
end
if items == firstItems[17] then
doPlayerAddItem(cid, 2544, 100)
end
if getPlayerSex(cid) == 0 then
doPlayerAddItem(cid, 2463, 1)
else
doPlayerAddItem(cid, 2463, 1)
end
local bag = doPlayerAddItem(cid, 11235, 1)
doAddContainerItem(bag, 2152, 2) -- 200gp
doAddContainerItem(bag, 2554, 1)
doAddContainerItem(bag, 2120, 1)
doAddContainerItem(bag, 7618, 1)
doAddContainerItem(bag, 2383, 1)
doAddContainerItem(bag, 2789, 20) -- 20 brown mushrooms (food)
setPlayerStorageValue(cid, 30001, 1)
end
return TRUE
end