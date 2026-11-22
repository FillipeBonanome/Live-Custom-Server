-- Summon Phantasm: raises a Phantasm (Necro.defs.phantasm) from a corpse near you. Costs 6 soul (Necro.soulCost), see Necro.summon in data/lib/373-necromancer.lua.
function onCastSpell(cid, var)
	return Necro.summon(cid, "phantasm")
end
