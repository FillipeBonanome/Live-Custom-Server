-- Queen Silkara - Egg Sac: she wraps herself in silk (shield: takes no damage) and 4 Poison Spiders and 2 Tarantulas hatch to protect her.
-- The AI takes the shield down when every summon is dead (state "Brood", data/lib/393-bosses.lua).
function onCastSpell(cid, var)
	MonsterAI.setImmune(cid, true)
	MonsterAI.say(cid, "The eggs hatch! Protect your queen!")
	local pos = getCreaturePosition(cid)
	doSendMagicEffect(pos, CONST_ME_BLOCKHIT)
	for _, tile in ipairs(Telegraph.ring(pos, 2)) do
		doSendDistanceShoot(pos, tile, CONST_ANI_POISON)
	end

	MonsterAI.summon(cid, "Poison Spider", 4)
	MonsterAI.summon(cid, "Tarantula", 2)
	return true
end
