-- /testarea: teleports the GM/God to the test area (451, 40, 7).
local destination = {x = 451, y = 40, z = 7}

function onSay(cid, words, param, channel)
	if(not doTeleportThing(cid, destination)) then
		doPlayerSendCancel(cid, "Could not teleport to the test area.")
		return true
	end

	doSendMagicEffect(destination, CONST_ME_TELEPORT)
	return true
end
