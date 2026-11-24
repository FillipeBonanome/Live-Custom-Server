local SEARCH_ACTION_ID = 45000   -- actionId temporario (nao pode estar em uso por outro script)
local COOLDOWN = 60 * 1000       -- 60s
local CHANCE = 50                -- %
local MONSTERS = {"Rotworm", "Carrion Worm"}

local function resetItem(uid)
	local thing = getThing(uid)
	if thing and thing.uid > 0 and getItemAttribute(uid, "aid") == SEARCH_ACTION_ID then
		doItemEraseAttribute(uid, "aid")
	end
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	if getItemAttribute(item.uid, "aid") == SEARCH_ACTION_ID then
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You found nothing.")
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
		return true
	end

	if math.random(100) <= CHANCE then
		doItemSetAttribute(item.uid, "aid", SEARCH_ACTION_ID)
		addEvent(resetItem, COOLDOWN, item.uid)
		local ppos = getCreaturePosition(cid)
		local name = MONSTERS[math.random(#MONSTERS)]
		for _, d in ipairs({{0,1},{1,0},{0,-1},{-1,0},{1,1},{-1,-1},{1,-1},{-1,1}}) do
			local p = {x = ppos.x + d[1], y = ppos.y + d[2], z = ppos.z}
			if doSummonCreature(name, p) then
				doSendMagicEffect(p, CONST_ME_POFF)
				doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You've found a " .. name .. ".")
				break
			end
		end
	else
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You found nothing.")
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
	end
	return true
end
