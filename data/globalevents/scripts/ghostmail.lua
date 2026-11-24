-- Ghostly effects of the Wraithvenom Scale Mail (unique of data/XML/uniques.xml, dropped by the Ghastly Dragon):
-- while a player wears it, poison orbits him and a ghost appears around him.
local UNIQUE = "Wraithvenom Scale Mail"

function onThink(cid, interval, lastExecution)
	for _, name in ipairs(getOnlinePlayers()) do
		local player = getPlayerByName(name)
		if(player) then
			local armor = getPlayerSlotItem(player, CONST_SLOT_ARMOR)
			if(armor.uid > 0 and getItemUnique(armor.uid) == UNIQUE) then
				VFX.Orbit(player, CONST_ANI_POISON, {radius = 2, points = 6, duration = 2000, step = 200})
				doSendMagicEffect(getCreaturePosition(player), CONST_ME_YALAHARIGHOST)
			end
		end
	end

	return true
end
