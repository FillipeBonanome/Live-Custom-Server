-- Soul Sacrifice: consumes your weakest summon (never the Dragon Skeleton): +40% death and poison damage for 15s and gives back 3 soul.
function onCastSpell(cid, var)
	if(not Necro.sacrifice(cid)) then
		return false
	end

	return Necro.addBuff(cid, "soul_sacrifice")
end
