-- Night Veil (Nightblade): +25% dodge, +6 armor and +4 defense for 12s (buff "Night Veil").
function onCastSpell(cid, var)
	Assassin.fx("assassin_veil", cid)
	return Assassin.addBuff(cid, "night_veil")
end
