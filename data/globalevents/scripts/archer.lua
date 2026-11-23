-- Keeps the Enchant buff of the Archer and the Ranger in place once a second (after login, death or a server restart).
-- See data/lib/376-archer.lua.
function onThink(interval, lastExecution)
	for _, pid in ipairs(getPlayersOnline()) do
		if(isArcher(pid)) then
			Archer.refresh(pid)
		end
	end

	return true
end
