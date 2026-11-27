-- Large crystal raised by the Geomancer / Colossus (Geomancer.crystal in data/lib/378-geomancer.lua): using it makes it vanish.
-- Registered by action id (Geomancer.crystalActionId) in actions.xml. The Crystal Bulwark explosion only happens when the time runs out.
function onUse(cid, item, fromPosition, itemEx, toPosition)
	if(item.actionid ~= Geomancer.crystalActionId) then
		return false
	end

	doRemoveItem(item.uid)
	doSendMagicEffect(toPosition.x ~= 0 and toPosition or fromPosition, CONST_ME_BLOCKHIT)
	return true
end
