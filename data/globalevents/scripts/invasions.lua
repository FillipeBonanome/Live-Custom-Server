-- Owner of the invasions (see the header of data/lib/390-invasions.lua): scheduler, waves, events, rewards and server bonuses.
function onThink(interval, lastExecution)
	if(Invasions.isEnabled()) then
		Invasions.tick()
	end

	return true
end
