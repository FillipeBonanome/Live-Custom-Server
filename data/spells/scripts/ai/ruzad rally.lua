-- Warlord Ruzad - Rally: he gets a shield (takes no damage) and 3 Orc Berserkers and 3 Orc Warriors protect him.
-- The AI takes the shield down when every summon is dead (state "Rally", data/lib/393-bosses.lua).
function onCastSpell(cid, var)
	MonsterAI.setImmune(cid, true)
	MonsterAI.say(cid, "Warriors! Protect your warlord!")
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
	MonsterAI.summon(cid, "Orc Berserker", 3)
	MonsterAI.summon(cid, "Orc Warrior", 3)
	return true
end
