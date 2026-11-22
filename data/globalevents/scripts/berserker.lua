-- Renews the passive of the Berserker and the Warlord once a second: life leech and Rage (more physical damage the lower the health).
-- See data/lib/375-berserker.lua.
function onThink(interval, lastExecution)
	for _, pid in ipairs(getPlayersOnline()) do
		if(isBerserker(pid)) then
			Berserker.refresh(pid)
		end
	end

	return true
end
