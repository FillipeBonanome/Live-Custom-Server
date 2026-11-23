-- Elemental Surge: for 10s the basic attacks deal +40% of the damage as the element of the enchantment (on top of the +30% of the Enchant buff),
-- +15 fist skill (attack speed) and every status (burn, venom, frost, shock) gets one extra stack.
function onCastSpell(cid, var)
	Archer.addBuff(cid, "surge", {[Archer.def(cid).onhit] = 40})
	Archer.fx("archer_surge", cid)
	return true
end
