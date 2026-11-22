-- Recall: teleports all your summons next to you.
function onCastSpell(cid, var)
	local summons = Necro.summons(cid, false, true)
	if(#summons == 0) then
		doPlayerSendCancel(cid, "You have no summon.")
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
		return false
	end

	local from = getCreaturePosition(cid)
	for _, sid in ipairs(summons) do
		local pos = getClosestFreeTile(sid, from, false, true)
		if(pos) then
			doSendMagicEffect(getCreaturePosition(sid), CONST_ME_POFF)
			doTeleportThing(sid, pos)
			doSendMagicEffect(pos, CONST_ME_MORTAREA)
		end
	end

	return true
end
