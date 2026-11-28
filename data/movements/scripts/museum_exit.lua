-- Teleporte de saida do salao de exposicao: leva o jogador ao templo da propria cidade.
function onStepIn(cid, item, position, fromPosition)
	if(not isPlayer(cid)) then
		return true
	end

	local pos = getTownTemplePosition(getPlayerTown(cid))
	if(not pos or pos.x == 0 or pos.y == 0) then
		doTeleportThing(cid, fromPosition, true)
		return true
	end

	pos = getClosestFreeTile(cid, pos)
	if(not pos or pos.x == 0 or pos.y == 0) then
		doTeleportThing(cid, fromPosition, true)
		return true
	end

	doTeleportThing(cid, pos, true)
	doSendMagicEffect(pos, CONST_ME_TELEPORT)
	return true
end
