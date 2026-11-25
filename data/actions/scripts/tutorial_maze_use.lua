-- Tutorial maze: using the item with actionId 56001 releases an effect at the item's position.
function onUse(cid, item, fromPosition, itemEx, toPosition)
	local pos = (fromPosition.x ~= 0 and fromPosition.x ~= 65535) and fromPosition or toPosition
	doSendMagicEffect(pos, CONST_ME_MAGIC_BLUE)
	return true
end
