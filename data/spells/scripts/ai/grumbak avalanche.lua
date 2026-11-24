-- Chief Grumbak - Avalanche (rage): stripes of snow (2 tiles wide, with a 1 tile lane between them) are marked across the arena, vertical
-- or horizontal at random, and an avalanche rolls over them 2 s later (ice). Find a lane or leave the area.
function onCastSpell(cid, var)
	local from = getCreaturePosition(cid)
	local vertical = math.random(2) == 1
	local shift = math.random(0, 2)
	local tiles = {}
	for _, offset in ipairs({-6, -3, 0, 3, 6}) do
		for width = 0, 1 do
			for along = -7, 7 do
				local a = offset + width + shift
				if(vertical) then
					table.insert(tiles, {x = from.x + a, y = from.y + along, z = from.z})
				else
					table.insert(tiles, {x = from.x + along, y = from.y + a, z = from.z})
				end
			end
		end
	end

	MonsterAI.say(cid, "AVALANCHE!", TALKTYPE_MONSTER_YELL)
	Telegraph.strike{
		caster = cid, tiles = Telegraph.merge(tiles), delay = 2000, refresh = 2000,
		combat = COMBAT_ICEDAMAGE, min = 70, max = 130, effect = CONST_ME_ICEAREA
	}

	return true
end
