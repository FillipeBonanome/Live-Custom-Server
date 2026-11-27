-- Tremor Wave: a wave of rock in front of you (5 long, 5 wide at the end). It starts at the center line and spreads to the borders: the
-- center line is struck first and takes 35% more damage, every lane further from the center is struck a moment later. Power x 0.8 to 1.2.
-- It never goes through walls and never hurts anyone in a protection zone. Each creature is hit once.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.epicenter = {bonus}                  single target damage: the center line deals `bonus` times more (instead of 1.35)
--   glyph.sluggish  = {percent, duration}      control: every creature hit is slowed by `percent` (0.3 = 30%) for `duration` ms
local config = {
	damage = {0.8, 1.2}, centerBonus = 1.35, length = 5,
	halfWidths = {0, 1, 1, 2, 2}, -- half width of the wave at each tile of distance
	forwardDelay = 70, -- ms between one row and the next
	laneDelay = 150 -- ms for each lane away from the center
}

function onCastSpell(cid, var)
	local glyph = Geomancer.glyph(cid, "tremor wave")
	local centerBonus = glyph and glyph.epicenter and glyph.epicenter.bonus or config.centerBonus

	local from = getCreaturePosition(cid)
	local v = Attacks.vector(getCreatureLookDirection(cid))
	local side = {-v[2], v[1]}

	local tiles = {}
	for row = 1, config.length do
		local half = config.halfWidths[row] or config.halfWidths[#config.halfWidths]
		for offset = -half, half do
			local pos = {x = from.x + v[1] * row + side[1] * offset, y = from.y + v[2] * row + side[2] * offset, z = from.z}
			if(type(getTileInfo(pos)) == "table" and isSightClear(from, pos, true)) then
				table.insert(tiles, {pos = pos, row = row, offset = offset})
			end
		end
	end

	if(#tiles == 0) then
		Geomancer.cancel(cid, "There is no room for the wave.")
		return false
	end

	local gem = Geomancer.gem(cid)
	local hit = {}
	for _, tile in ipairs(tiles) do
		local center = tile.offset == 0
		addEvent(function()
			if(not isCreature(cid)) then
				return
			end

			doSendMagicEffect(tile.pos, center and CONST_ME_GROUNDSHAKER or CONST_ME_STONES)
			if(gem) then
				doSendMagicEffect(tile.pos, gem.area)
			end

			for _, tid in ipairs(Attacks.enemiesOn(cid, {tile.pos}, tile.pos, 1)) do
				if(not hit[tid]) then
					hit[tid] = true
					Geomancer.hit(cid, tid, config.damage[1], config.damage[2], {multiplier = center and centerBonus or 1})
					if(glyph and glyph.sluggish and isCreature(tid)) then
						Geomancer.slow(tid, glyph.sluggish.percent, glyph.sluggish.duration)
					end
				end
			end
		end, (tile.row - 1) * config.forwardDelay + math.abs(tile.offset) * config.laneDelay)
	end

	return true
end
