-- Registered on every invader when it is created (see Invasions.releaseQueue). The kill events (score) run before this one.
function onDeath(cid, corpse)
	Invasions.push("K," .. cid)
	return true
end
