-- Push: pushes a creature 1 sqm away (used by spell glyphs). The checks are done by the server in doCreaturePush
-- (src/luascript.cpp): the push is refused when the tile does not exist, is a protection zone or a house, changes floor
-- (stairs, holes, ladders), is a teleport, has a magic field, is blocked (walls, items, creatures) or the creature cannot be
-- pushed (pushable="0" monsters, creatures that cannot move). When refused, the creature simply stays where it is.
--
-- Push.direction(from, to)              direction that goes from one position to the other (nil if it is the same tile or another floor)
-- Push.creature(cid, direction)         pushes 1 sqm that way. Returns true if it moved
-- Push.away(caster, target[, chance])   pushes the target away from the caster, with a chance in % (default 100). Returns true if it moved

Push = {}

function Push.direction(from, to)
	if(from.z ~= to.z) then
		return nil
	end

	local dx, dy = to.x - from.x, to.y - from.y
	if(dx == 0 and dy == 0) then
		return nil
	end

	-- the main axis wins when the target is much farther on one axis (3 sqm east and 1 north is just "east")
	local ax, ay = math.abs(dx), math.abs(dy)
	if(ax > 2 * ay) then
		dy = 0
	elseif(ay > 2 * ax) then
		dx = 0
	end

	if(dx == 0) then
		return dy < 0 and NORTH or SOUTH
	elseif(dy == 0) then
		return dx < 0 and WEST or EAST
	elseif(dx < 0) then
		return dy < 0 and NORTHWEST or SOUTHWEST
	end

	return dy < 0 and NORTHEAST or SOUTHEAST
end

-- returns true, or false and the reason (only true/false matters for the spells; the reason is for /glyph push)
function Push.creature(cid, direction)
	if(not direction) then
		return false, "same tile or another floor"
	end

	if(not isCreature(cid)) then
		return false, "no creature"
	end

	return doCreaturePush(cid, direction)
end

function Push.away(caster, target, chance)
	if(caster == target or not isCreature(caster) or not isCreature(target)) then
		return false, "no target"
	end

	chance = chance or 100
	if(chance < 100 and math.random(100) > chance) then
		return false, "chance"
	end

	return Push.creature(target, Push.direction(getThingPos(caster), getThingPos(target)))
end
