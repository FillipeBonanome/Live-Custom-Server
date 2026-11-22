-- Death Mark (Nightblade): marks the target (range 4) for 6s. When it ends the mark detonates in death damage (3x3, power x 2.0 to 3.0)
-- on the place where the target was, even if it died or moved away.
local config = {damage = {2.0, 3.0}, duration = 6000, range = 4}
local area = createCombatArea(AREA_SQUARE1X1)

function onCastSpell(cid, var)
	local target = Assassin.target(cid, config.range)
	if(not target) then
		return false
	end

	local pos = getCreaturePosition(target)
	Assassin.fx("assassin_mark", target, {duration = config.duration})

	-- remembers where the target is (it keeps moving); the last known position is where the mark detonates
	local function follow()
		if(isCreature(target) and getCreatureHealth(target) > 0) then
			pos = getCreaturePosition(target)
		end
	end

	for i = 1, config.duration / 1000 - 1 do
		addEvent(follow, i * 1000)
	end

	addEvent(function()
		follow()
		if(not isCreature(cid)) then
			return
		end

		local min, max = Assassin.values(cid, config.damage[1], config.damage[2])
		doAreaCombatHealth(cid, COMBAT_DEATHDAMAGE, pos, area, -min, -max, CONST_ME_MORTAREA)
		Assassin.fx("assassin_mark_blast", pos)
	end, config.duration)

	return true
end
