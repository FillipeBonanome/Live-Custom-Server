-- Savage Leap: jumps to a target up to 4 SQM away and smashes the ground around it when landing (3x3 centered on the target, power x 1.0 to 1.6).
-- Costs 4% of the max health (healthpercent in spells.xml, which has range 6 for the glyph; the script keeps 4 without it). Gives 1 Fury.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.stun  = {percent, duration}   every enemy hit by the landing is paralyzed
--   glyph.range = sqm                   the leap reaches that far (instead of 4)
--   glyph.haste = {duration}            haste (+30%) after the leap
local config = {damage = {1.0, 1.6}, range = 4}
local area = createCombatArea(AREA_SQUARE1X1)

local function sign(n)
	return n > 0 and 1 or (n < 0 and -1 or 0)
end

function onCastSpell(cid, var)
	local glyph = Berserker.glyph(cid, "savage leap")
	local target = Berserker.target(cid, (glyph and glyph.range) or config.range)
	if(not target) then
		return false
	end

	local from, to = getCreaturePosition(cid), getCreaturePosition(target)
	if(not isSightClear(from, to, true)) then
		doPlayerSendDefaultCancel(cid, RETURNVALUE_CANNOTTHROW)
		doSendMagicEffect(from, CONST_ME_POFF)
		return false
	end

	-- lands on the side of the target that faces you
	local near = {x = to.x - sign(to.x - from.x), y = to.y - sign(to.y - from.y), z = to.z}
	local dest = (getDistanceBetween(from, to) > 1) and getClosestFreeTile(cid, near, false, true) or from
	if(not dest or getDistanceBetween(dest, to) > 1) then
		doPlayerSendCancel(cid, "There is no room to land next to your target.")
		doSendMagicEffect(from, CONST_ME_POFF)
		return false
	end

	if(dest ~= from) then
		doTeleportThing(cid, dest)
	end

	doCreatureSetLookDirection(cid, getDirectionTo(dest, to))
	Berserker.area(cid, to, area, config.damage[1], config.damage[2], CONST_ME_NONE)
	Berserker.fx("berserker_leap", to)
	if(glyph and glyph.stun) then
		Berserker.slowAll(cid, Berserker.enemiesAround(cid, to, 1), glyph.stun.percent, glyph.stun.duration)
	end

	if(glyph and glyph.haste) then
		Glyphs.haste(cid, glyph.haste.duration)
	end

	Berserker.fury(cid)
	return true
end
