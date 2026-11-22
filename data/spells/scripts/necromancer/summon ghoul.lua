-- Summon Ghoul: raises a Ghoul (Necro.defs.ghoul) from a corpse near you. Costs 6 soul (Necro.soulCost), see Necro.summon in data/lib/373-necromancer.lua.
function onCastSpell(cid, var)
	return Necro.summon(cid, "ghoul")
end
