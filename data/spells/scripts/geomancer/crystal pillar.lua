-- Crystal Pillar: a lane of 5 large crystals in the direction you are looking at, starting 2 tiles in front of you (along the view). They rise
-- one after another from the nearest to the farthest (0.09s apart), block players and monsters and vanish after 8s. A crystal that rises under
-- an enemy hurts him (power x 0.5 to 0.8) instead of being raised there. Tiles behind a wall or in a protection zone are skipped.
local config = {length = 5, distance = 2, duration = 8000, growDelay = 90, damage = {0.5, 0.8}}

function onCastSpell(cid, var)
	return Geomancer.crystalLine(cid, true, config)
end
