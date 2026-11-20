-- !trackbestiary on/off
-- When enabled, every kill shows the bestiary progress of the monster, e.g. Rotworm [766/1000].
function onSay(cid, words, param, channel)
	param = param:gsub("^%s+", ""):gsub("%s+$", ""):lower()
	if(param == "on") then
		doPlayerSetBestiaryTracking(cid, true)
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Bestiary tracking enabled.")
	elseif(param == "off") then
		doPlayerSetBestiaryTracking(cid, false)
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Bestiary tracking disabled.")
	else
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Usage: !trackbestiary on/off (currently " .. (getPlayerBestiaryTracking(cid) and "on" or "off") .. ").")
	end

	return true
end
