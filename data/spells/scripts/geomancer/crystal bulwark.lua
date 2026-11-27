-- Crystal Bulwark (Colossus): a ring of large crystals rises around you (the 8 tiles next to you) and holds for 8s: monsters cannot reach you in
-- melee. The tile in FRONT of you (the direction you are looking at) is left open, so you can step out. While it lasts you take 20% less damage
-- from every element (buff in !buffs). A crystal that rises under an enemy hurts him (power x 0.6 to 0.9) and that tile stays empty; when each
-- crystal vanishes it explodes, hitting everyone within 1 tile for power x 0.5 to 0.8. Tiles behind a wall or in a protection zone are skipped.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.fortified = {percent}           defense: you take `percent`% less damage from every element
--   glyph.explosive = {damage, radius}    area: the explosion of each crystal deals `damage` times more and reaches `radius` tiles
local config = {duration = 8000, damage = {0.6, 0.9}, blast = {0.5, 0.8}, absorb = 20}

function onCastSpell(cid, var)
	local glyph = Geomancer.glyph(cid, "crystal bulwark")
	local absorb = glyph and glyph.fortified and glyph.fortified.percent or config.absorb
	local blastDamage = glyph and glyph.explosive and glyph.explosive.damage or 1
	local blastRadius = glyph and glyph.explosive and glyph.explosive.radius or 1

	local from = getCreaturePosition(cid)
	local v = Attacks.vector(getCreatureLookDirection(cid))
	local gem = Geomancer.gem(cid)

	local function explode(pos)
		if(not isCreature(cid)) then
			return
		end

		doSendMagicEffect(pos, gem and gem.area or CONST_ME_EXPLOSIONAREA)
		for _, tid in ipairs(Attacks.around(cid, pos, blastRadius)) do
			Geomancer.hit(cid, tid, config.blast[1], config.blast[2], {multiplier = blastDamage})
		end
	end

	local raised = 0
	for dx = -1, 1 do
		for dy = -1, 1 do
			if((dx ~= 0 or dy ~= 0) and not (dx == v[1] and dy == v[2])) then
				local pos = {x = from.x + dx, y = from.y + dy, z = from.z}
				if(type(getTileInfo(pos)) == "table" and isSightClear(from, pos, true)) then
					for _, tid in ipairs(Attacks.enemiesOn(cid, {pos}, pos, 1)) do
						Geomancer.hit(cid, tid, config.damage[1], config.damage[2], {effect = CONST_ME_STONES})
					end

					if(Geomancer.crystal(cid, pos, config.duration, gem and gem.area, explode)) then
						raised = raised + 1
					end
				end
			end
		end
	end

	if(raised == 0) then
		Geomancer.cancel(cid, "There is no room for the crystals.")
		return false
	end

	Geomancer.statBuff(cid, {
		name = "Crystal Bulwark", subId = Geomancer.bulwarkSubId, duration = config.duration, effect = CONST_ME_STONES,
		description = absorb .. "% less damage from every element while the crystals hold.",
		params = Geomancer.absorbAll(absorb)
	})

	return true
end
