-- Phantasm: Haunt, 7x7 circle on the target with death or poison (chosen at random each cast), P x 0.6 to 1.1.
-- Glyphs of the owner (Summon Phantasm, data/lib/403-glyphs.lua): glyph.twin = {hits, interval, share} the haunt strikes `hits` times,
-- `interval` ms apart, each with `share` of the damage; glyph.resist = {percent, duration} monsters hit lose death and poison resistance.
local combat = createCombatObject()
local area = createCombatArea(AREA_CIRCLE3X3)

-- one strike of the haunt on `pos` (also used by the later strikes of the glyph)
local function haunt(cid, pos, death, min, max)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	doAreaCombatHealth(cid, death and COMBAT_DEATHDAMAGE or COMBAT_EARTHDAMAGE, pos, area, -min, -max,
		death and CONST_ME_MORTAREA or CONST_ME_POISONAREA)
end

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		return false
	end

	local glyph = Necro.ownerGlyph(cid)
	local min, max = Necro.summonValues(cid, 0.6, 1.1)
	local pos = getCreaturePosition(target)
	local death = math.random(2) == 1

	if(glyph and glyph.resist) then
		for _, tid in ipairs(Necro.enemiesAround(pos, 3)) do
			Glyphs.reduceResistance(tid, COMBAT_DEATHDAMAGE, glyph.resist.percent, glyph.resist.duration)
			Glyphs.reduceResistance(tid, COMBAT_EARTHDAMAGE, glyph.resist.percent, glyph.resist.duration)
		end
	end

	doSendDistanceShoot(getCreaturePosition(cid), pos, death and CONST_ANI_DEATH or CONST_ANI_POISON)
	if(glyph and glyph.twin) then
		min, max = math.max(1, math.floor(min * glyph.twin.share)), math.max(1, math.floor(max * glyph.twin.share))
		for hit = 0, glyph.twin.hits - 1 do
			if(hit == 0) then
				haunt(cid, pos, death, min, max)
			else
				addEvent(haunt, hit * glyph.twin.interval, cid, pos, death, min, max)
			end
		end
	else
		haunt(cid, pos, death, min, max)
	end

	return true
end
