-- Crystal Storm: large crystals rise one after another at random free tiles around the target (1 to 2 tiles away; the storm follows the target).
-- Where a crystal rises it hurts everyone within 2 tiles (power x 0.3 to 0.45) AND sends out 3 random walks (Attacks.randomWalk) from that tile, in
-- 3 different random directions: 4 tiles each, power x 0.2 to 0.3 on whoever is on them. The crystal blocks its tile for 6s and then vanishes;
-- the walks cannot cross it or any other crystal. Nothing rises on a creature, behind a wall or in a protection zone. Range 6.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.shatter = {damage, blast}   area: the eruption of each crystal deals `damage` times more and reaches `blast` tiles
--   glyph.bind    = {ms}              control: everyone within 1 tile of a crystal that rises is stunned for `ms`
local config = {
	damage = {0.3, 0.45}, range = 6, crystals = 6, interval = 350, duration = 6000, blast = 2, minRadius = 1, maxRadius = 2,
	walks = 3, walkSteps = 4, walkInterval = 120, walkDamage = {0.2, 0.3}
}

-- 3 different directions of the 8
local function directions(count)
	local list = {}
	for index, v in ipairs(Attacks.ring) do
		list[index] = v
	end

	for i = #list, 2, -1 do
		local j = math.random(i)
		list[i], list[j] = list[j], list[i]
	end

	local result = {}
	for index = 1, count do
		result[index] = list[index]
	end

	return result
end

function onCastSpell(cid, var)
	local target = Geomancer.target(cid, config.range)
	if(not target) then
		return false
	end

	local glyph = Geomancer.glyph(cid, "crystal storm")
	local blast, blastDamage = config.blast, 1
	if(glyph and glyph.shatter) then
		blast, blastDamage = glyph.shatter.blast, glyph.shatter.damage
	end

	local center = getCreaturePosition(target)
	local gem = Geomancer.gem(cid)

	local function walks(pos)
		for _, direction in ipairs(directions(config.walks)) do
			Attacks.randomWalk(cid, {
				from = pos, direction = direction, steps = config.walkSteps, interval = config.walkInterval,
				onStep = function(tile, number)
					if(number > 0) then
						doSendMagicEffect(tile, CONST_ME_GROUNDSHAKER)
						if(gem) then
							doSendMagicEffect(tile, gem.area)
						end
					end
				end,
				onHit = function(tid, number)
					if(number > 0) then
						Geomancer.hit(cid, tid, config.walkDamage[1], config.walkDamage[2])
					end
				end
			})
		end
	end

	local function rise(number)
		if(not isCreature(cid)) then
			return
		end

		if(isCreature(target) and getCreatureHealth(target) > 0) then
			center = getCreaturePosition(target)
		end

		for _ = 1, 12 do
			local dx = math.random(-config.maxRadius, config.maxRadius)
			local dy = math.random(-config.maxRadius, config.maxRadius)
			local distance = math.max(math.abs(dx), math.abs(dy))
			local pos = {x = center.x + dx, y = center.y + dy, z = center.z}
			if(distance >= config.minRadius and isSightClear(center, pos, true) and Geomancer.crystal(cid, pos, config.duration, gem and gem.area)) then
				doSendMagicEffect(pos, CONST_ME_GROUNDSHAKER)
				for _, tid in ipairs(Attacks.around(cid, pos, blast)) do
					Geomancer.hit(cid, tid, config.damage[1], config.damage[2], {multiplier = blastDamage})
				end

				if(glyph and glyph.bind) then
					for _, tid in ipairs(Attacks.around(cid, pos, 1)) do
						Geomancer.stun(tid, glyph.bind.ms)
					end
				end

				walks(pos)
				break
			end
		end

		if(number < config.crystals) then
			addEvent(rise, config.interval, number + 1)
		end
	end

	rise(1)
	return true
end
