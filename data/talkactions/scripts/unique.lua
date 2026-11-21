-- /unique name
-- Creates the unique item (data/XML/uniques.xml) and puts it in the player's inventory (or at his feet). For tests.
-- Example: /unique Blade of Embers
function onSay(cid, words, param, channel)
	param = param:trim()
	if(param == "") then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Usage: /unique unique name")
		return true
	end

	local itemId = getUniqueItemId(param)
	if(not itemId) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Unique not found.")
		return true
	end

	local item = doCreateItemEx(itemId, 1)
	if(not item or item <= 0 or not doItemSetUnique(item, param)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Could not create the unique item.")
		return true
	end

	if(doPlayerAddItemEx(cid, item, true) ~= RETURNVALUE_NOERROR) then
		doTileAddItemEx(getCreaturePosition(cid), item)
	end

	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Created the unique item " .. param .. ".")
	return true
end
