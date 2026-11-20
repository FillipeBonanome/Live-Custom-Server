-- !bestiary <monster name>
-- Without a name, a dialog explaining how the bestiary works is shown.
function onSay(cid, words, param, channel)
	param = param:gsub("^%s+", ""):gsub("%s+$", "")
	if(not doPlayerSendBestiary(cid, param)) then
		doPlayerSendCancel(cid, "There is no monster called '" .. param .. "' in the bestiary.")
	end

	return true
end
