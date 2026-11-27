-- Seismic Slam (Colossus): a crushing blow on one target (range 2), power x 2.2 to 3.0, that stuns him for 1.5s. +30% damage if the target is
-- ROOTED: already slowed/stunned or with a large crystal on a tile next to him. With a gem in the ammo slot it also applies the element:
--   fire: burns 3s (power x 0.1 to 0.15 per second) | poison: venom 4s (power x 0.08 to 0.12 per second)
--   ice: -40% speed for 4s once the stun ends | energy: the force jumps to 2 enemies close to him (power x 0.6 to 0.9, falling 15% per jump)
--   holy: you heal 25% of the damage dealt
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.titanic   = {damage, rooted}   single target damage: the blow deals `damage` times more and the rooted bonus is `rooted` (instead of 1.3)
--   glyph.shockwave = {damage, stun}     area: the enemies next to the target take `damage` of the blow and are stunned for `stun` ms
local config = {
	damage = {2.2, 3.0}, range = 2, rootedBonus = 1.3, stun = 1500,
	fire = {ticks = 3, factor = {0.1, 0.15}}, poison = {ticks = 4, factor = {0.08, 0.12}},
	ice = {percent = 0.4, ms = 4000}, energy = {bounces = 2, jumpRange = 3, falloff = 0.85, factor = {0.6, 0.9}}, holy = {leech = 0.25}
}

-- a large crystal on any of the 8 tiles around the position
local function nextToCrystal(pos)
	for dx = -1, 1 do
		for dy = -1, 1 do
			if(dx ~= 0 or dy ~= 0) then
				local tile = {x = pos.x + dx, y = pos.y + dy, z = pos.z}
				for _, id in ipairs(Geomancer.crystalItems) do
					local item = getTileItemById(tile, id)
					if(item and item.uid > 0) then
						return true
					end
				end
			end
		end
	end

	return false
end

-- damage over time with the element of the gem, `ticks` times, once a second
local function dot(cid, target, gem, def)
	local function tick(left)
		if(left <= 0 or not isCreature(cid) or not Attacks.valid(cid, target)) then
			return
		end

		local min, max = Geomancer.values(cid, def.factor[1], def.factor[2])
		local amount = math.max(1, math.random(math.min(min, max), math.max(min, max)))
		doTargetCombatHealth(cid, target, gem.combat, -amount, -amount, gem.effect)
		addEvent(tick, 1000, left - 1)
	end

	addEvent(tick, 1000, def.ticks)
end

function onCastSpell(cid, var)
	local target = Geomancer.target(cid, config.range)
	if(not target) then
		return false
	end

	local glyph = Geomancer.glyph(cid, "seismic slam")
	local pos = getCreaturePosition(target)
	local rooted = getCreatureCondition(target, CONDITION_PARALYZE) or nextToCrystal(pos)
	local gem = Geomancer.gem(cid)

	local bonus = glyph and glyph.titanic and glyph.titanic.rooted or config.rootedBonus
	local multiplier = (glyph and glyph.titanic and glyph.titanic.damage or 1) * (rooted and bonus or 1)

	local damage = Geomancer.hit(cid, target, config.damage[1], config.damage[2], {multiplier = multiplier, effect = CONST_ME_GROUNDSHAKER})
	if(not damage or not isCreature(target) or getCreatureHealth(target) <= 0) then
		return true
	end

	Geomancer.slow(target, 0.95, config.stun)
	doSendMagicEffect(pos, CONST_ME_STUN)

	if(glyph and glyph.shockwave) then
		for _, tid in ipairs(Attacks.around(cid, pos, 1)) do
			if(tid ~= target) then
				Geomancer.hit(cid, tid, config.damage[1] * glyph.shockwave.damage, config.damage[2] * glyph.shockwave.damage)
				if(isCreature(tid)) then
					Geomancer.stun(tid, glyph.shockwave.stun)
				end
			end
		end
	end

	if(not gem) then
		return true
	end

	if(gem.element == "fire") then
		dot(cid, target, gem, config.fire)
	elseif(gem.element == "poison") then
		dot(cid, target, gem, config.poison)
	elseif(gem.element == "ice") then
		addEvent(function()
			if(isCreature(target) and Attacks.valid(cid, target)) then
				Geomancer.slow(target, config.ice.percent, config.ice.ms)
			end
		end, config.stun)
	elseif(gem.element == "energy") then
		Attacks.chainLightning(cid, target, {
			bounces = config.energy.bounces, jumpRange = config.energy.jumpRange, falloff = config.energy.falloff,
			ani = CONST_ANI_ENERGY, effect = CONST_ME_ENERGYHIT,
			onHit = function(tid, multiplier, number)
				if(number > 1) then
					Geomancer.hit(cid, tid, config.energy.factor[1], config.energy.factor[2], {multiplier = multiplier})
				end
			end
		})
	elseif(gem.element == "holy") then
		doCreatureAddHealth(cid, math.max(1, math.floor(damage * config.holy.leech)))
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_HOLYAREA)
	end

	return true
end
