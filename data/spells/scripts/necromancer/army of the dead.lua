-- Army of the Dead (Lich): raises 3 temporary skeletons (20s) from a corpse near you. They use no summon slot. Costs 12 soul (Necro.army).
function onCastSpell(cid, var)
	return Necro.army(cid)
end
