function isSorcerer(cid)
	return isInArray({1, 5}, getPlayerVocation(cid))
end

function isDruid(cid)
	return isInArray({2, 6}, getPlayerVocation(cid))
end

function isPaladin(cid)
	return isInArray({3, 7}, getPlayerVocation(cid))
end

function isKnight(cid)
	return isInArray({4, 8}, getPlayerVocation(cid))
end

function isCleric(cid)
	return isInArray({9, 10}, getPlayerVocation(cid))
end

function isNecromancer(cid)
	return isInArray({11, 12}, getPlayerVocation(cid))
end

function isBerserker(cid)
	return isInArray({15, 16}, getPlayerVocation(cid))
end

function isAssassin(cid)
	return isInArray({13, 14}, getPlayerVocation(cid))
end

function isArcher(cid)
	return isInArray({17, 18}, getPlayerVocation(cid))
end

function isRookie(cid)
	return isInArray({0}, getPlayerVocation(cid))
end
