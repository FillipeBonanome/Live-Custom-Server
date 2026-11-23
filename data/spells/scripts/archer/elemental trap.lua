-- Elemental Trap: trap in 3x3 on the target (range 6) for 6s, hurts whoever is inside once a second (power x 0.2 to 0.3).
-- fire: burning ground | poison: toxic cloud (a stack per second) | ice: roots (2s) the first time someone steps in, and chills
-- energy: stuns (1s) the first time someone steps in, and shocks
local config = {damage = {0.2, 0.3}, range = 6, radius = 1, duration = 6}

function onCastSpell(cid, var)
	local target = Archer.target(cid, config.range)
	if(not target) then
		return false
	end

	local element = Archer.element(cid)
	local center = getCreaturePosition(target)
	local tiles = {}
	for dx = -config.radius, config.radius do
		for dy = -config.radius, config.radius do
			table.insert(tiles, {x = center.x + dx, y = center.y + dy, z = center.z})
		end
	end

	local caught = {}
	Archer.fx("archer_trap", center, {element = element, times = config.duration})
	Archer.zone{
		cid = cid, tiles = tiles, center = center, radius = config.radius + 1, element = element, ticks = config.duration,
		interval = 1000, damage = config.damage,
		onTick = function(tid)
			if(not caught[tid]) then
				caught[tid] = true
				if(element == "ice") then
					Archer.freeze(tid, 2000)
				elseif(element == "energy") then
					Archer.freeze(tid, 1000)
				end
			end
		end
	}

	return true
end
