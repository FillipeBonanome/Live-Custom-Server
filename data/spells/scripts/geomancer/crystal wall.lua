-- Crystal Wall: a wall of 5 large crystals ACROSS the direction you are looking at, centered 2 tiles in front of you (perpendicular to the view).
-- They rise from the center to the sides (0.09s apart), block players and monsters and vanish after 8s. A crystal that rises under an enemy
-- hurts him (power x 0.5 to 0.8) instead of being raised there. Tiles behind a wall or in a protection zone are skipped (Geomancer.crystalLine).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.grand    = {length, duration}   control: a longer wall that holds longer
--   glyph.volatile = {damage}             area: every crystal explodes when it vanishes, hurting everyone within 1 tile (power x damage[1] to damage[2])
local config = {length = 5, distance = 2, duration = 8000, growDelay = 90, damage = {0.5, 0.8}}

function onCastSpell(cid, var)
	local glyph = Geomancer.glyph(cid, "crystal wall")
	local cast = {}
	for key, value in pairs(config) do
		cast[key] = value
	end

	if(glyph and glyph.grand) then
		cast.length, cast.duration = glyph.grand.length, glyph.grand.duration
	end

	if(glyph and glyph.volatile) then
		cast.onRemove = function(pos)
			if(not isCreature(cid)) then
				return
			end

			doSendMagicEffect(pos, CONST_ME_EXPLOSIONAREA)
			for _, tid in ipairs(Attacks.around(cid, pos, 1)) do
				Geomancer.hit(cid, tid, glyph.volatile.damage[1], glyph.volatile.damage[2])
			end
		end
	end

	return Geomancer.crystalLine(cid, false, cast)
end
