-- Crystal Pillar: a lane of 5 large crystals in the direction you are looking at, starting 2 tiles in front of you (along the view). They rise
-- one after another from the nearest to the farthest (0.09s apart), block players and monsters and vanish after 8s. A crystal that rises under
-- an enemy hurts him (power x 0.5 to 0.8) instead of being raised there. Tiles behind a wall or in a protection zone are skipped.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.stunning = {length, stun}   control: a longer lane and an enemy under a rising crystal is stunned for `stun` ms
--   glyph.shelter  = {percent}        defense: you take `percent`% less damage from every element while the crystals stand (buff in !buffs, subId 8911)
local config = {length = 5, distance = 2, duration = 8000, growDelay = 90, damage = {0.5, 0.8}}

function onCastSpell(cid, var)
	local glyph = Geomancer.glyph(cid, "crystal pillar")
	local cast = {}
	for key, value in pairs(config) do
		cast[key] = value
	end

	if(glyph and glyph.stunning) then
		cast.length, cast.stun = glyph.stunning.length, glyph.stunning.stun
	end

	if(not Geomancer.crystalLine(cid, true, cast)) then
		return false
	end

	if(glyph and glyph.shelter) then
		Geomancer.statBuff(cid, {
			name = "Sheltering Lane", subId = 8911, duration = config.duration, effect = CONST_ME_STONES,
			description = glyph.shelter.percent .. "% less damage from every element while the crystals stand.",
			params = Geomancer.absorbAll(glyph.shelter.percent)
		})
	end

	return true
end
