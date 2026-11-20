-- !autoloot add <id or name> | remove <id or name> | list | clear
function onSay(cid, words, param, channel)
	doPlayerAutoloot(cid, param)
	return true
end
