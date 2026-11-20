-- Template: preencha os valores abaixo antes de usar.
local config = {
	doorUid = 0,                      -- uniqueid da porta
	doorPos = {x = 0, y = 0, z = 0},  -- posicao da porta
	vocations = {1, 2, 3, 4}          -- vocacoes que podem passar
}

function onUse(cid, item, frompos, item2, topos)
	local doorpos = {x = frompos.x, y = frompos.y, z = frompos.z}
	local playervoc = getPlayerVocation(cid)

	if item.uid == config.doorUid and doorpos.x == config.doorPos.x and doorpos.y == config.doorPos.y and doorpos.z == config.doorPos.z then
		if isInArray(config.vocations, playervoc) then
			doTeleportThing(cid, doorpos)
		else
			doPlayerSendTextMessage(cid, 22, "Apenas algumas vocacoes podem passar.")
		end
	end
	return 1
end
