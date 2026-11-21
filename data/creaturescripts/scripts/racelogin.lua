-- Re-applies the attribute bonus of the player's race on login (the condition is not saved in the database).
function onLogin(cid)
	if(getPlayerAccountManager(cid) ~= MANAGER_NONE) then
		return true
	end

	-- hands out the outfits of the race again (keeps addons); needed for races that got new outfits later
	local _, race = getPlayerRace(cid)
	if(race) then
		for _, lookType in ipairs(race.outfits) do
			doPlayerAddOutfitId(cid, lookType, 0)
		end
	end

	doPlayerApplyRaceBonus(cid)
	return true
end
