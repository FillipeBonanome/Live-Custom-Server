-- Places the statues of the best players on startup and refreshes them every few minutes (see data/lib/330-rankstatues.lua).
function onStartup()
	print(">> Rank statues placed: " .. RankStatues.update())
	return true
end

function onThink(interval, lastExecution)
	RankStatues.update()
	return true
end
