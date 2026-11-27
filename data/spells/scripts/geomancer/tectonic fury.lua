-- Tectonic Fury (Colossus): you slam the ground and the stone answers in waves that run from the center to the borders: 4 CIRCULAR rings (a disc
-- of radius 4 around you, like Hell's Core, not a square), 0.15s apart, hitting everyone on the ring for power x 1.6 to 2.4 (each creature is hit once).
-- Every ring also sends out ONE random walk (Attacks.randomWalk) from a random tile of the ring, away from you: 3 tiles, power x 0.3 to 0.45 on whoever is on them.
-- With a gem half of the damage is the element of the gem. Nothing goes through walls or hurts anyone in a protection zone.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.cataclysm = {damage, walks}    damage: the rings deal `damage` times more and every ring sends `walks` random walks
--   glyph.gravity   = {percent, duration} control: every creature hit by a ring is slowed by `percent` (0.4 = 40%) for `duration` ms
local config = {
	damage = {1.6, 2.4}, radius = 4, ringDelay = 150,
	walkDamage = {0.3, 0.45}, walkSteps = 3, walkInterval = 120
}

-- the tiles of ring r: those whose distance to the center, rounded, is r (so the rings make a circle, not a square)
local function ringTiles(from, r)
	local tiles = {}
	for dx = -r - 1, r + 1 do
		for dy = -r - 1, r + 1 do
			if(math.floor(math.sqrt(dx * dx + dy * dy) + 0.5) == r) then
				local pos = {x = from.x + dx, y = from.y + dy, z = from.z}
				if(type(getTileInfo(pos)) == "table" and isSightClear(from, pos, true)) then
					table.insert(tiles, pos)
				end
			end
		end
	end

	return tiles
end

function onCastSpell(cid, var)
	local glyph = Geomancer.glyph(cid, "tectonic fury")
	local damage = glyph and glyph.cataclysm and glyph.cataclysm.damage or 1
	local walks = glyph and glyph.cataclysm and glyph.cataclysm.walks or 1

	local from = getCreaturePosition(cid)
	local gem = Geomancer.gem(cid)
	local hit = {}

	doSendMagicEffect(from, CONST_ME_GROUNDSHAKER)

	for r = 1, config.radius do
		addEvent(function()
			if(not isCreature(cid)) then
				return
			end

			local tiles = ringTiles(from, r)
			for _, pos in ipairs(tiles) do
				doSendMagicEffect(pos, r == 1 and CONST_ME_GROUNDSHAKER or CONST_ME_STONES)
				if(gem) then
					doSendMagicEffect(pos, gem.area)
				end
			end

			for _, tid in ipairs(Attacks.enemiesOn(cid, tiles, from, r + 1)) do
				if(not hit[tid]) then
					hit[tid] = true
					Geomancer.hit(cid, tid, config.damage[1], config.damage[2], {multiplier = damage})
					if(glyph and glyph.gravity and isCreature(tid)) then
						Geomancer.slow(tid, glyph.gravity.percent, glyph.gravity.duration)
					end
				end
			end

			for _ = 1, #tiles > 0 and walks or 0 do
				local start = tiles[math.random(#tiles)]
				Attacks.randomWalk(cid, {
					from = start, direction = Attacks.sign(from, start), steps = config.walkSteps, interval = config.walkInterval,
					onStep = function(pos, number)
						if(number > 0) then
							doSendMagicEffect(pos, CONST_ME_GROUNDSHAKER)
						end
					end,
					onHit = function(tid, number)
						if(number > 0) then
							Geomancer.hit(cid, tid, config.walkDamage[1], config.walkDamage[2])
						end
					end
				})
			end
		end, (r - 1) * config.ringDelay)
	end

	return true
end
