-- !language english / !language portugues: changes the language (NPC speech that is translated and the combat messages)
function onSay(cid, words, param, channel)
	local id = Language.find(param)
	if(not id) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Language / Idioma: " .. Language.list[Language.get(cid)].name .. ". Use: !language english, !language portugues")
		return true
	end

	Language.set(cid, id)
	Language.send(cid, MESSAGE_STATUS_CONSOLE_BLUE, {
		en = "Language changed to English.",
		pt = "Idioma alterado para portugues."
	})
	return true
end
