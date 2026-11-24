-- Warlord Ruzad - Rally: he gets a shield (takes no damage) and 3 Orc Berserkers and 3 Orc Warriors protect him.
-- The AI takes the shield down when every summon is dead (state "Rally", data/lib/393-bosses.lua).
function onCastSpell(cid, var)
	MonsterAI.setImmune(cid, true)
	MonsterAI.say(cid, "Warriors! Protect your warlord!")
	local pos = getCreaturePosition(cid)
	doSendMagicEffect(pos, CONST_ME_BLOCKHIT)
	for _, tile in ipairs(Telegraph.ring(pos, 2)) do
		doSendDistanceShoot(pos, tile, CONST_ANI_WHIRLWINDAXE)
	end
	MonsterAI.summon(cid, "Orc Berserker", 3)
	MonsterAI.summon(cid, "Orc Warrior", 3)
	return true
end
