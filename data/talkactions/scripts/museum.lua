-- /museum
-- Recria o salao de exposicao dos uniques lendo data/XML/uniques.xml de novo (use depois de mudar o arquivo e dar /reload).
function onSay(cid, words, param, channel)
	local exposed = Museum.build()
	if(not exposed) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Could not read uniques.xml.")
		return true
	end

	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Unique museum rebuilt: " .. exposed .. " uniques.")
	return true
end
