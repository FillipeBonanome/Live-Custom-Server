-- Warlord Ruzad - Axe Storm: 4 marks (3x3) appear one after the other over random players near him; axes orbit around the center of
-- each mark until it lands (physical).
local orbit = {{-1, -1}, {0, -1}, {1, -1}, {1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}}

function onCastSpell(cid, var)
	local players = MonsterAI.playersAround(cid, 9)
	if(#players == 0) then
		return false
	end

	local delay, interval = 1600, 450
	local steps, stepTime = 10, 90
	Telegraph.strikes({caster = cid, delay = delay, refresh = 1600, combat = COMBAT_PHYSICALDAMAGE, min = 40, max = 80, effect = CONST_ME_HITAREA}, 4, function(index)
		local pos = getCreaturePosition(players[math.random(#players)])
		local center = {x = pos.x + math.random(-2, 2), y = pos.y + math.random(-2, 2), z = pos.z}

		-- two axes (opposite sides) circle the center, one tile per step
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
			end, (index - 1) * interval + delay - steps * stepTime - 100 + step * stepTime)
		end

		return Telegraph.square(center, 1)
	end, interval)

	return true
end
