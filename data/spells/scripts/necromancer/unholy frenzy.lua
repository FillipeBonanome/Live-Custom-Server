-- Unholy Frenzy: +30% damage on all your summons for 20s. (Necro.buffs in data/lib/373-necromancer.lua)
function onCastSpell(cid, var)
	return Necro.addBuff(cid, "unholy_frenzy")
end
