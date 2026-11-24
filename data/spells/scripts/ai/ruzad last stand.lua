-- Warlord Ruzad - Last Stand: heals 15% of the health, only once (the flag in the memory is checked by the decision tree).
function onCastSpell(cid, var)
	MonsterAI.getMemory(cid).lastStand = true
	MonsterAI.say(cid, "Ikem rambo zambo!")
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_BLOCKHIT)
	MonsterAI.heal(cid, 15)
	return true
end
