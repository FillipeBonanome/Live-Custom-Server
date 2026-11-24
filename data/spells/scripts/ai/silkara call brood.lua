-- Queen Silkara - Call Brood: 3 Poison Spiders (never more than 6 summons alive at once).
function onCastSpell(cid, var)
	local pos = getCreaturePosition(cid)
	doSendMagicEffect(pos, CONST_ME_POISONAREA)
	for _, tile in ipairs(Telegraph.ring(pos, 2)) do
		doSendDistanceShoot(pos, tile, CONST_ANI_POISON)
	end

	return MonsterAI.summon(cid, "Poison Spider", 3, 6) > 0
end
