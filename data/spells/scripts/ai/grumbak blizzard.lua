-- Chief Grumbak - Blizzard: 6 marks (3x3) appear one after the other over random players and shards of ice rain on them (ice).
function onCastSpell(cid, var)
	local players = MonsterAI.playersAround(cid, 9)
	if(#players == 0) then
		return false
	end

	local delay, interval = 1600, 400
	Telegraph.strikes({caster = cid, delay = delay, refresh = 1600, combat = COMBAT_ICEDAMAGE, min = 40, max = 80, effect = CONST_ME_ICEAREA}, 6, function(index)
		local pos = getCreaturePosition(players[math.random(#players)])
		local center = {x = pos.x + math.random(-2, 2), y = pos.y + math.random(-2, 2), z = pos.z}

		addEvent(function()
			if(isCreature(cid)) then
				doSendDistanceShoot(getCreaturePosition(cid), center, CONST_ANI_SMALLICE)
			end
		end, (index - 1) * interval + delay - 600)

		return Telegraph.square(center, 1)
	end, interval)

	return true
end
