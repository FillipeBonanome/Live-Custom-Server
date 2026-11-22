-- Summon Banshee: raises a Banshee (Necro.defs.banshee) from a corpse near you. Costs 6 soul (Necro.soulCost), see Necro.summon in data/lib/373-necromancer.lua.
function onCastSpell(cid, var)
	return Necro.summon(cid, "banshee")
end
