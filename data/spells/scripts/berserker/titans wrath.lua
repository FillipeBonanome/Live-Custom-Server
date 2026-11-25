-- Titan's Wrath (Warlord): 3 heavy blows in 3s around you (3x3), each one stronger than the last
-- (power x 1.5 to 2.0, then 2.0 to 2.6, then 2.8 to 3.6). Costs 20% of the max health (healthpercent in spells.xml). Gives 1 Fury.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.finale = {damage}                       the last blow hits a circle of radius 2 (AREA_CIRCLE2X2) and deals `damage` times more
--   glyph.grip   = {percent, duration, stun}      every blow slows the enemies hit; the last one stuns them for `stun` ms instead
local config = {interval = 1000, blows = {{1.5, 2.0}, {2.0, 2.6}, {2.8, 3.6}}}
local area = createCombatArea(AREA_SQUARE1X1)
local areaWide = createCombatArea(AREA_CIRCLE2X2)

function onCastSpell(cid, var)
	local function blow(index)
		if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
			return
		end

		local glyph = Berserker.glyph(cid, "titans wrath")
		local last = index == #config.blows
		local factor = config.blows[index]
		local pos = getCreaturePosition(cid)
		local usedArea, multiplier = area, 1
		if(last and glyph and glyph.finale) then
			usedArea, multiplier = areaWide, glyph.finale.damage
		end

		Berserker.area(cid, pos, usedArea, factor[1], factor[2], last and CONST_ME_GROUNDSHAKER or CONST_ME_HITAREA, multiplier)
		if(glyph and glyph.grip) then
			local percent, duration = glyph.grip.percent, glyph.grip.duration
			if(last) then
				percent, duration = 0.95, glyph.grip.stun
			end

			Berserker.slowAll(cid, Berserker.enemiesAround(cid, pos, 1), percent, duration)
		end

		if(index < #config.blows) then
			addEvent(blow, config.interval, index + 1)
		end
	end

	blow(1)
	Berserker.fury(cid)
	return true
end
