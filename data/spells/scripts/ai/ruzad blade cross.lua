-- Warlord Ruzad - Blade Cross (berserk): 3 stars (center + 8 arms of 6 tiles, 1 wide: 4 straight and 4 diagonal) are marked over
-- random players, one after the other. Axes orbit the center and, when the mark lands, fly out along the eight arms (physical).
local orbit = {{-1, -1}, {0, -1}, {1, -1}, {1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}}
local arms = {
	{0, -1}, {1, -1}, {1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}
}

local LENGTH = 6

function onCastSpell(cid, var)
	local players = MonsterAI.playersAround(cid, 9)
	if(#players == 0) then
		return false
	end

	local delay, interval = 1600, 800
	local steps, stepTime = 8, 90
	Telegraph.strikes({caster = cid, delay = delay, refresh = 1600, combat = COMBAT_PHYSICALDAMAGE, min = 70, max = 130, effect = CONST_ME_HITAREA}, 3, function(index)
		local center = getCreaturePosition(players[math.random(#players)])
		local start = (index - 1) * interval

		-- two axes circle the center until the mark lands
		for step = 0, steps - 1 do
			addEvent(function()
				if(isCreature(cid)) then
					for _, side in ipairs({0, 4}) do
						local from = orbit[(step + side) % 8 + 1]
						local to = orbit[(step + side + 1) % 8 + 1]
						doSendDistanceShoot({x = center.x + from[1], y = center.y + from[2], z = center.z},
							{x = center.x + to[1], y = center.y + to[2], z = center.z}, CONST_ANI_WHIRLWINDAXE)
					end
				end
			end, start + delay - steps * stepTime - 100 + step * stepTime)
		end

		-- ...and then they fly out along the arms
		addEvent(function()
			if(isCreature(cid)) then
				for _, arm in ipairs(arms) do
					doSendDistanceShoot(center, {x = center.x + arm[1] * LENGTH, y = center.y + arm[2] * LENGTH, z = center.z}, CONST_ANI_WHIRLWINDAXE)
				end
			end
		end, start + delay - 150)

		local tiles = {{x = center.x, y = center.y, z = center.z}}
		for _, arm in ipairs(arms) do
			for i = 1, LENGTH do
				table.insert(tiles, {x = center.x + arm[1] * i, y = center.y + arm[2] * i, z = center.z})
			end
		end

		return Telegraph.merge(tiles)
	end, interval)

	return true
end
