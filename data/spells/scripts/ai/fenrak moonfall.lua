-- Fenrak Moonfall: 5 marks (3x3) appear one after the other over random players and moonlight crashes on them (death).
function onCastSpell(cid, var)
	local players = MonsterAI.playersAround(cid, 9)
	if(#players == 0) then
		return false
	end

	local delay, interval = 1500, 400
	Telegraph.strikes({caster = cid, delay = delay, refresh = 1500, combat = COMBAT_DEATHDAMAGE, min = 40, max = 80, effect = CONST_ME_MORTAREA}, 5, function(index)
		local pos = getCreaturePosition(players[math.random(#players)])
		local center = {x = pos.x + math.random(-1, 1), y = pos.y + math.random(-1, 1), z = pos.z}
		return Telegraph.square(center, 1)
	end, interval)

	return true
end
