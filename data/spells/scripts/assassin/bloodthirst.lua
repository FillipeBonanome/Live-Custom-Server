-- Bloodthirst: +12% life leech and +5% critical chance for 12s (buff "Bloodthirst", Assassin.buffs in data/lib/374-assassin.lua).
-- It is how the Assassin heals, since he cannot drink great or ultimate health potions.
function onCastSpell(cid, var)
	Assassin.fx("assassin_bloodthirst", cid)
	return Assassin.addBuff(cid, "bloodthirst")
end
