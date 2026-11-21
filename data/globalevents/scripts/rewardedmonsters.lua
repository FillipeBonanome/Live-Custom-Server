-- Draws the rewarded creatures every time the server starts (see data/lib/310-rewarded.lua).
function onStartup()
	if(RewardedMonsters.roll()) then
		print(">> Rewarded creatures drawn.")
	end

	return true
end
