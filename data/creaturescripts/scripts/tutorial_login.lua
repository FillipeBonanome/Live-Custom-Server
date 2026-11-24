-- First login: sends the new character to the tutorial place (see data/lib/201-tutorial.lua).
-- Registered BEFORE firstitems.lua in creaturescripts.xml, because that one sets the storage used to detect a new character.
function onLogin(cid)
	if(getPlayerAccountManager(cid) ~= MANAGER_NONE) then
		return true
	end

	local state = getPlayerTutorialState(cid)
	if(state == 1 or (state == -1 and getPlayerStorageValue(cid, TUTORIAL_FIRSTITEMS_STORAGE) == -1)) then
		doPlayerStartTutorial(cid)
	end

	return true
end
