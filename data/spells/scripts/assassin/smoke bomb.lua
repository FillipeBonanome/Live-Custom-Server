-- Smoke Bomb: smoke around you (radius 2) that hurts the enemies (power x 0.4 to 0.7) and makes you invisible for 3s. Gives 1 Momentum.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.paralyze = {percent, duration}   slows every enemy hit
--   glyph.linger   = {pulses, percent, interval}   the smoke stays: `pulses` more pulses, each with `percent`% of the damage
local config = {damage = {0.4, 0.7}, invisible = 3000}
local area = createCombatArea(AREA_CIRCLE2X2)

function onCastSpell(cid, var)
	local glyph = Assassin.glyph(cid, "smoke bomb")
	local pos = getCreaturePosition(cid)
	local min, max = Assassin.values(cid, config.damage[1], config.damage[2])
	doAreaCombatHealth(cid, COMBAT_PHYSICALDAMAGE, pos, area, -min, -max, CONST_ME_NONE)
	Assassin.fx("assassin_smoke", pos)
	if(glyph and glyph.paralyze) then
		for _, tid in ipairs(Assassin.enemiesAround(cid, pos, 2)) do
			Glyphs.paralyze(cid, tid, glyph.paralyze.percent, glyph.paralyze.duration)
		end
	end

	if(glyph and glyph.linger) then
		local share = glyph.linger.percent / 100
		for i = 1, glyph.linger.pulses do
			addEvent(function()
				if(isCreature(cid)) then
					doAreaCombatHealth(cid, COMBAT_PHYSICALDAMAGE, pos, area, -math.floor(min * share), -math.floor(max * share), CONST_ME_SMOKE)
				end
			end, i * glyph.linger.interval)
		end
	end

	Assassin.invisible(cid, config.invisible)
	Assassin.momentum(cid)
	return true
end
