-- Warlord Ruzad - Fire Storm (berserk): 6 marks (3x3) of fire fall over random players near him.
function onCastSpell(cid, var)
	local players = MonsterAI.playersAround(cid, 9)
	if(#players == 0) then
		return false
	end

	Telegraph.strikes({caster = cid, delay = 1500, combat = COMBAT_FIREDAMAGE, min = 50, max = 100, effect = CONST_ME_FIREAREA}, 6, function()
		local pos = getCreaturePosition(players[math.random(#players)])
		return Telegraph.square({x = pos.x + math.random(-2, 2), y = pos.y + math.random(-2, 2), z = pos.z}, 1)
	end, 450)

	return true
end
