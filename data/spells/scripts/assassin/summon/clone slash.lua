-- Assassin Clone (Phantom Clones): Slash, physical melee hit (power of the owner x 0.5 to 0.8).
function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		return false
	end

	return Assassin.cloneHit(cid, target, 0.5, 0.8, CONST_ME_HITAREA)
end
