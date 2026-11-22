-- Summon Skeleton: raises a Skeleton (Necro.defs.skeleton) from a corpse near you. Costs 6 soul (Necro.soulCost), see Necro.summon in data/lib/373-necromancer.lua.
function onCastSpell(cid, var)
	return Necro.summon(cid, "skeleton")
end
