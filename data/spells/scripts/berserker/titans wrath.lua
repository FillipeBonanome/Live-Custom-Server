-- Titan's Wrath (Warlord): 3 heavy blows in 3s around you (3x3), each one stronger than the last
-- (power x 1.5 to 2.0, then 2.0 to 2.6, then 2.8 to 3.6). Costs 20% of the max health (healthpercent in spells.xml). Gives 1 Fury.
local config = {interval = 1000, blows = {{1.5, 2.0}, {2.0, 2.6}, {2.8, 3.6}}}
local area = createCombatArea(AREA_SQUARE1X1)

function onCastSpell(cid, var)
	local function blow(index)
		if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
			return
		end

		local factor = config.blows[index]
		Berserker.area(cid, getCreaturePosition(cid), area, factor[1], factor[2], index == #config.blows and CONST_ME_GROUNDSHAKER or CONST_ME_HITAREA)
		if(index < #config.blows) then
			addEvent(blow, config.interval, index + 1)
		end
	end

	blow(1)
	Berserker.fury(cid)
	return true
end
