-- Fissure: cracks open under the target (range 5) and run away from you: 4 or 5 random walks at once (Attacks.randomWalk, data/lib/377-attacks.lua),
-- fanned out around the direction from you to the target (straight ahead and 45 and 90 degrees to each side). Each one picks a random free tile
-- ahead of the previous one and strikes it 0.14s after the last: 7 tiles each, power x 0.25 to 0.4 on whoever is on them. They never cross a wall
-- and never enter a protection zone. Two walks that cross the same creature both hit him.
local config = {damage = {0.25, 0.4}, range = 5, steps = 7, interval = 140, walks = {4, 5}}

-- turns (in steps of 45 degrees) from the main direction, in the order the walks are used
local fan = {0, -1, 1, -2, 2}

function onCastSpell(cid, var)
	local target = Geomancer.target(cid, config.range)
	if(not target) then
		return false
	end

	local start = getCreaturePosition(target)
	local main = Attacks.sign(getCreaturePosition(cid), start) or Attacks.vector(getCreatureLookDirection(cid))
	local gem = Geomancer.gem(cid)

	for index = 1, math.random(config.walks[1], config.walks[2]) do
		Attacks.randomWalk(cid, {
			from = start, direction = Attacks.turn(main, fan[index]), steps = config.steps, interval = config.interval,
			onStep = function(pos)
				doSendMagicEffect(pos, CONST_ME_GROUNDSHAKER)
				if(gem) then
					doSendMagicEffect(pos, gem.area)
				end
			end,
			onHit = function(tid, number)
				-- the starting tile (the target) is hit once, below, not once per walk
				if(number > 0) then
					Geomancer.hit(cid, tid, config.damage[1], config.damage[2])
				end
			end
		})
	end

	Geomancer.hit(cid, target, config.damage[1], config.damage[2])

	return true
end
