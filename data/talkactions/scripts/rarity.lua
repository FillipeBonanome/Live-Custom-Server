-- /rarity item, rarity
-- Creates an item (id or name) with the given rarity and puts it in the player's inventory (or at his feet). For tests.
-- Example: /rarity magic sword, legendary   /rarity 2400, epic
function onSay(cid, words, param, channel)
	local t = string.explode(param, ",")
	local itemName, rarity = t[1] and t[1]:trim() or "", t[2] and t[2]:trim() or ""
	if(itemName == "" or rarity == "") then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Usage: /rarity item id or name, rarity (Uncommon, Rare, Epic, Legendary)")
		return true
	end

	local itemId = tonumber(itemName) or getItemIdByName(itemName, false)
	if(not itemId or itemId <= 0) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Item not found.")
		return true
	end

	local item = doCreateItemEx(itemId, 1)
	if(not item or item <= 0) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Could not create the item.")
		return true
	end

	if(not doItemSetRarity(item, rarity)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Invalid rarity, or the item can not have a rarity (see data/XML/rarity_archetypes.xml).")
		return true
	end

	if(doPlayerAddItemEx(cid, item, true) ~= RETURNVALUE_NOERROR) then
		doTileAddItemEx(getCreaturePosition(cid), item)
	end

	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Created " .. itemName .. " (" .. rarity .. ").")
	return true
end
