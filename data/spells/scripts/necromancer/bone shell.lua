-- Bone Shell: consumes your weakest summon (never the Dragon Skeleton): +14 armor and +10 defense for 15s and gives back 3 soul.
function onCastSpell(cid, var)
	if(not Necro.sacrifice(cid)) then
		return false
	end

	return Necro.addBuff(cid, "bone_shell")
end
