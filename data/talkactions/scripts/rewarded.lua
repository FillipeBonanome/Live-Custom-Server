-- !rewarded: lists the creatures that currently give bonus experience or loot, with their levels.
function onSay(cid, words, param, channel)
	if(not RewardedMonsters.isEnabled()) then
		doPlayerSendCancel(cid, "The rewarded creatures are disabled.")
		return true
	end

	doPlayerPopupFYI(cid, RewardedMonsters.getDescription())
	return true
end
