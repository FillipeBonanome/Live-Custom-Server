-- Summon Bone Abomination (Lich): raises a Bone Abomination (Necro.defs.abomination) from a corpse near you. Slow bruiser with a lot of
-- health that smashes everything around it and explodes in death when it dies. Costs 6 soul and a summon slot (Necro.summon).
function onCastSpell(cid, var)
	return Necro.summon(cid, "abomination")
end
