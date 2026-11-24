-- Warlord Ruzad - Call Guards: 2 Orc Warriors (never more than 4 summons alive at once).
function onCastSpell(cid, var)
	local pos = getCreaturePosition(cid)
	doSendMagicEffect(pos, CONST_ME_BLOCKHIT)
	for _, tile in ipairs(Telegraph.ring(pos, 2)) do
		doSendDistanceShoot(pos, tile, CONST_ANI_WHIRLWINDAXE)
	end

	return MonsterAI.summon(cid, "Orc Warrior", 2, 4) > 0
end
