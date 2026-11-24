-- Create Food: puts a random food item in the backpack (or on the floor when there is no room).
local foods = {2666, 2671, 2681, 2674, 2689, 2690, 2696}

function onCastSpell(cid, var)
	local food = foods[math.random(#foods)]
	doPlayerAddItem(cid, food, 1)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
	return true
end
