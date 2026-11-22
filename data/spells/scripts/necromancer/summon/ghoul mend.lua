-- Ghoul: Mend, heals 8% of its max health (only when hurt).
local combat = createCombatObject()

function onCastSpell(cid, var)
	local missing = getCreatureMaxHealth(cid) - getCreatureHealth(cid)
	if(missing <= 0) then
		return false
	end

	doCreatureAddHealth(cid, math.min(missing, math.max(1, math.floor(getCreatureMaxHealth(cid) * 0.08))))
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
	return true
end
