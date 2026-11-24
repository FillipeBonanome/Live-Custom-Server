-- Chief Grumbak - Boulder Toss: marks 3x3 around the target and hurls a boulder that lands 1.6 s later (physical). In the rage he
-- throws a second boulder at another player.
function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(not target or target == 0 or not isCreature(target)) then
		return false
	end

	local centers = {getCreaturePosition(target)}
	if(MonsterAI.getMemory(cid).rage) then
		local players = MonsterAI.playersAround(cid, 9)
		if(#players > 1) then
			table.insert(centers, getCreaturePosition(players[math.random(#players)]))
		end
	end

	local delay, interval = 1600, 500
	Telegraph.strikes({caster = cid, delay = delay, refresh = 1600, combat = COMBAT_PHYSICALDAMAGE, min = 55, max = 105, effect = CONST_ME_GROUNDSHAKER}, #centers, function(index)
		local center = centers[index]
		addEvent(function()
			if(isCreature(cid)) then
				doSendDistanceShoot(getCreaturePosition(cid), center, CONST_ANI_LARGEROCK)
			end
		end, (index - 1) * interval + delay - 500)

		return Telegraph.square(center, 1)
	end, interval)

	return true
end
