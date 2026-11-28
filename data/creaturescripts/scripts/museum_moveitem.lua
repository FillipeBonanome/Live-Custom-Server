-- Nenhum item pode ser movido de/para o salao de exposicao dos uniques (ver data/lib/405-museum.lua).
function onMoveItem(moveItem, frompos, position, cid)
	if(Museum.isInside(frompos) or Museum.isInside(position)) then
		doPlayerSendCancel(cid, "Voce nao pode mover itens do salao de exposicao.")
		return false
	end

	return true
end
