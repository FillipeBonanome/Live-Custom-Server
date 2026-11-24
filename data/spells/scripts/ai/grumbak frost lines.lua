-- Chief Grumbak - Frost Lines: 4 lines of ice (7 tiles, north/east/south/west) are marked around him; in the rage the 4 diagonals
-- too. Stand in the gaps between the lines to be safe (ice).
local straight = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}
local diagonal = {{1, -1}, {1, 1}, {-1, 1}, {-1, -1}}
local LENGTH = 7

function onCastSpell(cid, var)
	local from = getCreaturePosition(cid)
	local arms = {}
	for _, arm in ipairs(straight) do
		table.insert(arms, arm)
	end

	if(MonsterAI.getMemory(cid).rage) then
		for _, arm in ipairs(diagonal) do
			table.insert(arms, arm)
		end
	end

	local tiles = {}
	for _, arm in ipairs(arms) do
		for i = 1, LENGTH do
			table.insert(tiles, {x = from.x + arm[1] * i, y = from.y + arm[2] * i, z = from.z})
		end
	end

	local delay = 1500
	addEvent(function()
		if(isCreature(cid)) then
			local pos = getCreaturePosition(cid)
			doSendMagicEffect(pos, CONST_ME_ICEAREA)
			for _, arm in ipairs(arms) do
				doSendDistanceShoot(pos, {x = from.x + arm[1] * LENGTH, y = from.y + arm[2] * LENGTH, z = from.z}, CONST_ANI_SMALLICE)
			end
		end
	end, delay - 250)

	Telegraph.strike{
		caster = cid, tiles = Telegraph.merge(tiles), delay = delay, refresh = 1500,
		combat = COMBAT_ICEDAMAGE, min = 60, max = 110, effect = CONST_ME_ICEAREA
	}

	return true
end
