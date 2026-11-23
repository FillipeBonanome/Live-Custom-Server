-- Elemental Avatar (Ranger): for 12s every attack and spell deals fire, poison, ice and energy (25% of the damage each) and applies the
-- four statuses; the basic attacks also deal +25% of each element. The elemental reactions do not trigger while it lasts.
function onCastSpell(cid, var)
	Archer.addBuff(cid, "avatar")
	Archer.fx("archer_avatar", cid)
	return true
end
