-- Fenrak Moonfang - Pounce: marks 3x3 around the target; 1.4 s later he leaps next to it and everybody in the area takes physical damage.
function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(not target or target == 0 or not isCreature(target)) then
		return false
	end

	local center = getCreaturePosition(target)
	Telegraph.strike{
		caster = cid, tiles = Telegraph.square(center, 1), delay = 1400, refresh = 1400, combat = COMBAT_PHYSICALDAMAGE, min = 60, max = 110, effect = CONST_ME_HITAREA,
		onLand = function()
			local from = getCreaturePosition(cid)
			local offsets = {{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}}
			for i = #offsets, 2, -1 do
				local j = math.random(i)
				offsets[i], offsets[j] = offsets[j], offsets[i]
			end

			for _, offset in ipairs(offsets) do
				local landing = {x = center.x + offset[1], y = center.y + offset[2], z = center.z}
				if(doTeleportThing(cid, landing, false)) then
					doSendMagicEffect(from, CONST_ME_POFF)
					doSendMagicEffect(landing, CONST_ME_GROUNDSHAKER)
					break
				end
			end
		end
	}

	return true
end
