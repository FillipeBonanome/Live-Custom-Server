-- Chief Grumbak - Call Trolls: 3 Frost Trolls (never more than 5 summons alive at once).
function onCastSpell(cid, var)
	local pos = getCreaturePosition(cid)
	doSendMagicEffect(pos, CONST_ME_ICEAREA)
	for _, tile in ipairs(Telegraph.ring(pos, 2)) do
		doSendDistanceShoot(pos, tile, CONST_ANI_SMALLICE)
	end

	return MonsterAI.summon(cid, "Frost Troll", 3, 5) > 0
end
