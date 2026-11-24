local SEARCH_ACTION_ID = 45001   -- actionId temporario (nao pode estar em uso por outro script)
local COOLDOWN = 60 * 1000       -- 60s
local VAMPIRE_CHANCE = 20        -- %
local ITEM_CHANCE = 50           -- %

-- {id, nome}
local LOOT = {
	{2229, "skull"},
	{2230, "bone"},
	{2744, "red rose"},
	{2745, "blue rose"},
	{2746, "yellow rose"},
	{2199, "garlic necklace"},
	-- {ID_AQUI, "bulb of garlic"}, -- esse item nao existe no items.xml do servidor
}

local NEIGHBOURS = {{0,1},{1,0},{0,-1},{-1,0},{1,1},{-1,-1},{1,-1},{-1,1}}

local function resetItem(uid)
	local thing = getThing(uid)
	if thing and thing.uid > 0 and getItemAttribute(uid, "aid") == SEARCH_ACTION_ID then
		doItemEraseAttribute(uid, "aid")
	end
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	local ppos = getCreaturePosition(cid)

	if getItemAttribute(item.uid, "aid") == SEARCH_ACTION_ID then
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You found nothing.")
		doSendMagicEffect(ppos, CONST_ME_POFF)
		return true
	end

	-- cooldown de 60s em qualquer uso
	doItemSetAttribute(item.uid, "aid", SEARCH_ACTION_ID)
	addEvent(resetItem, COOLDOWN, item.uid)

	local found = false

	if math.random(100) <= VAMPIRE_CHANCE then
		for _, d in ipairs(NEIGHBOURS) do
			local p = {x = ppos.x + d[1], y = ppos.y + d[2], z = ppos.z}
			if doSummonCreature("Vampire", p) then
				doSendMagicEffect(p, CONST_ME_MORTAREA)
				doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You've found a vampire resting in his coffin.")
				found = true
				break
			end
		end
	end

	-- se um monstro apareceu, o jogador nao ganha item
	if not found and math.random(100) <= ITEM_CHANCE then
		local loot = LOOT[math.random(#LOOT)]
		if doPlayerAddItem(cid, loot[1], 1) then
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You've found a " .. loot[2] .. ".")
			found = true
		end
	end

	if not found then
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You found nothing.")
		doSendMagicEffect(ppos, CONST_ME_POFF)
	end
	return true
end
