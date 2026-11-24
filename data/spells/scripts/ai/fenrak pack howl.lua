-- Fenrak Moonfang - Pack Howl: 2 War Wolves answer the howl (3 after the moon rises), never more than 6 summons alive at once.
function onCastSpell(cid, var)
	local pos = getCreaturePosition(cid)
	doSendMagicEffect(pos, CONST_ME_MAGIC_BLUE)
	for _, tile in ipairs(Telegraph.ring(pos, 2)) do
		doSendMagicEffect(tile, CONST_ME_POFF)
	end

	local count = MonsterAI.getMemory(cid).moonrise and 3 or 2
	return MonsterAI.summon(cid, "War Wolf", count, 6) > 0
end
