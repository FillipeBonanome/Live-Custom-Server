-- Queen Silkara - Venom Rain: 4 marks (3x3) appear one after the other over random players; venom drops from the ceiling when
-- each one lands (earth). 6 marks in the frenzy.
function onCastSpell(cid, var)
	local players = MonsterAI.playersAround(cid, 9)
	if(#players == 0) then
		return false
	end

	local delay, interval = 1600, 450
	local count = MonsterAI.getMemory(cid).frenzy and 6 or 4
	Telegraph.strikes({caster = cid, delay = delay, refresh = 1600, combat = COMBAT_EARTHDAMAGE, min = 35, max = 70, effect = CONST_ME_POISONAREA}, count, function(index)
		local pos = getCreaturePosition(players[math.random(#players)])
		local center = {x = pos.x + math.random(-1, 1), y = pos.y + math.random(-1, 1), z = pos.z}

		-- she spits the venom up just before it lands
		addEvent(function()
			if(isCreature(cid)) then
				doSendDistanceShoot(getCreaturePosition(cid), center, CONST_ANI_POISON)
			end
		end, (index - 1) * interval + delay - 600)

		return Telegraph.square(center, 1)
	end, interval)

	return true
end
