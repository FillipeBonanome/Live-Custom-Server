-- Fenrak Moonfang - Blood Rend (blood moon): first the 4 diagonals (7 tiles) around him are marked, 0.8 s later the 4 straight lines;
-- the safe spot of the first strike is hit by the second, so keep moving (physical).
local diagonal = {{1, -1}, {1, 1}, {-1, 1}, {-1, -1}}
local straight = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}
local LENGTH = 7

local function arms(from, list)
	local tiles = {}
	for _, arm in ipairs(list) do
		for i = 1, LENGTH do
			table.insert(tiles, {x = from.x + arm[1] * i, y = from.y + arm[2] * i, z = from.z})
		end
	end

	return Telegraph.merge(tiles)
end

function onCastSpell(cid, var)
	local from = getCreaturePosition(cid)
	MonsterAI.say(cid, "Rrrrraaagh!")
	Telegraph.strikes({caster = cid, delay = 1500, refresh = 1500, combat = COMBAT_PHYSICALDAMAGE, min = 60, max = 110, effect = CONST_ME_HITAREA}, 2, function(index)
		return arms(from, index == 1 and diagonal or straight)
	end, 800)

	return true
end
