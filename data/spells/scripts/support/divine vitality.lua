-- Divine Vitality (Hierophant): +10% max health and +10% max mana for 2 minutes on the caster and the party (radius 7).
function onCastSpell(cid, var)
	for _, tid in ipairs(Cleric.allies(cid, getCreaturePosition(cid), 7)) do
		Cleric.addBuff(tid, "divine_vitality")
	end

	return true
end
