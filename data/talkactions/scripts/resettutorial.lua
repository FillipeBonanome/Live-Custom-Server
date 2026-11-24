-- !resettutorial: forgets the race and the language and restarts the first login tutorial (for tests)
function onSay(cid, words, param, channel)
	doPlayerResetTutorial(cid)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Tutorial restarted / Tutorial reiniciado.")
	return true
end
