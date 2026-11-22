-- Bone Mend: heals the summons around you (7 SQM, P x 2.0 to 3.5). Does not heal the Dragon Skeleton.
function onCastSpell(cid, var)
	if(Necro.mend(cid, 2.0, 3.5, 7) == 0) then
		doPlayerSendCancel(cid, "You have no summon to heal.")
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
		return false
	end

	return true
end
