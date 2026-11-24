-- Places the statues of the gods saved with /godstatue (see data/lib/400-gods.lua).
function onStartup()
	print(">> God statues placed: " .. Gods.placeAll())
	return true
end
