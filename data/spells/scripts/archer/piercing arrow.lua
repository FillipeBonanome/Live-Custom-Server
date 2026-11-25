-- Piercing Arrow: draws a line from you through the target (range 6) and goes on until it is 6 tiles long, even if the target is closer (the
-- arrow goes through it). Hits every creature on the line, power x 0.5 to 0.9 each. The line stops at walls and nobody in a protection zone
-- is hurt. The effect is sent to the last tile of the line.
-- fire: leaves a trail of fire on the line for 3s | poison: +1 stack on each one | ice: +1 stack of frost on each one
-- energy: +10% damage for each creature already pierced
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.long  = {length, damage}              the line is `length` tiles long (spells.xml has range 9 for it) and the damage is multiplied
--   glyph.tempo = {amp, critical, duration}     after the shot: +`amp`% damage and +`critical`% critical chance (buff "Hunter's Tempo", subId 8710)
local config = {damage = {0.5, 0.9}, length = 6, trail = {0.15, 0.25}, trailTicks = 3}

function onCastSpell(cid, var)
	local glyph = Archer.glyph(cid, "piercing arrow")
	local length = (glyph and glyph.long and glyph.long.length) or config.length
	local damage = (glyph and glyph.long and glyph.long.damage) or 1

	local target = Archer.target(cid, length)
	if(not target) then
		return false
	end

	local tiles = Archer.lineToward(cid, getCreaturePosition(target), length)
	if(#tiles == 0) then
		doPlayerSendCancel(cid, "There is no room to shoot.")
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
		return false
	end

	local from = getCreaturePosition(cid)
	local element = Archer.element(cid)
	Archer.fx("archer_pierce", tiles[#tiles], {from = from, element = element})

	local enemies = Archer.enemiesOn(cid, tiles, from, length)
	table.sort(enemies, function(a, b)
		return getDistanceBetween(from, getCreaturePosition(a)) < getDistanceBetween(from, getCreaturePosition(b))
	end)

	for index, tid in ipairs(enemies) do
		local multiplier = (element == "energy" and (1 + 0.1 * (index - 1)) or 1) * damage
		Archer.hit(cid, tid, config.damage[1], config.damage[2], element, multiplier)
	end

	if(glyph and glyph.tempo) then
		Archer.empower(cid, "Hunter's Tempo", 8710, glyph.tempo.amp, glyph.tempo.critical, glyph.tempo.duration)
	end

	if(element == "fire") then
		local function flames(left)
			for _, pos in ipairs(tiles) do
				doSendMagicEffect(pos, CONST_ME_FIREAREA)
			end

			if(left > 1) then
				addEvent(flames, 1000, left - 1)
			end
		end

		flames(config.trailTicks)
		addEvent(Archer.zone, 1000, {
			cid = cid, tiles = tiles, center = from, radius = length, element = "fire", ticks = config.trailTicks - 1,
			interval = 1000, damage = config.trail, options = {intensity = 0}
		})
	end

	return true
end
