-- Re-applies the attribute bonus of the player's race on login (the condition is not saved in the database).
function onLogin(cid)
	if(getPlayerAccountManager(cid) ~= MANAGER_NONE) then
		return true
	end

	doPlayerApplyRaceBonus(cid)
	return true
end
