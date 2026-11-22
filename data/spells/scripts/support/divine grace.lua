-- Divine Grace: +10% magic level for 15 seconds on the caster and the party members around (radius 3) (buff "Divine Grace").
function onCastSpell(cid, var)
	for _, tid in ipairs(Cleric.allies(cid, getCreaturePosition(cid), 3)) do
		Cleric.addBuff(tid, "divine_grace")
	end

	return true
end
