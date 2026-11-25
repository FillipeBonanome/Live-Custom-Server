-- Elemental Trap: trap in 3x3 on the target (range 6) for 6s, hurts whoever is inside once a second (power x 0.2 to 0.3).
-- fire: burning ground | poison: toxic cloud (a stack per second) | ice: roots (2s) the first time someone steps in, and chills
-- energy: stuns (1s) the first time someone steps in, and shocks
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.lasting = {duration, damage}         the trap lasts `duration` seconds and hurts `damage` times more
--   glyph.net     = {percent, duration}        whoever steps in is slowed (0.5 = 50%) for `duration` ms (after the root or stun of ice and energy)
local config = {damage = {0.2, 0.3}, range = 6, radius = 1, duration = 6}

function onCastSpell(cid, var)
	local target = Archer.target(cid, config.range)
	if(not target) then
		return false
	end

	local glyph = Archer.glyph(cid, "elemental trap")
	local duration = (glyph and glyph.lasting and glyph.lasting.duration) or config.duration
	local more = (glyph and glyph.lasting and glyph.lasting.damage) or 1

	local element = Archer.element(cid)
	local center = getCreaturePosition(target)
	local tiles = {}
	for dx = -config.radius, config.radius do
		for dy = -config.radius, config.radius do
			table.insert(tiles, {x = center.x + dx, y = center.y + dy, z = center.z})
		end
	end

	local caught = {}
	Archer.fx("archer_trap", center, {element = element, times = duration})
	Archer.zone{
		cid = cid, tiles = tiles, center = center, radius = config.radius + 1, element = element, ticks = duration,
		interval = 1000, damage = {config.damage[1] * more, config.damage[2] * more},
		onTick = function(tid)
			if(not caught[tid]) then
				caught[tid] = true
				local wait = 0
				if(element == "ice") then
					Archer.freeze(tid, 2000)
					wait = 2100
				elseif(element == "energy") then
					Archer.freeze(tid, 1000)
					wait = 1100
				end

				if(glyph and glyph.net) then
					addEvent(function()
						if(isCreature(cid) and isCreature(tid) and getCreatureHealth(tid) > 0) then
							Glyphs.paralyze(cid, tid, glyph.net.percent, glyph.net.duration)
						end
					end, math.max(50, wait))
				end
			end
		end
	}

	return true
end
