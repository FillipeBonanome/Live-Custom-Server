-- Fenrak Moonfang - Claw Rake: a cone of 5 tiles in the direction of the target is marked and he rakes it with his claws (physical).
-- In the blood moon he rakes the opposite side too.
function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(not target or target == 0 or not isCreature(target)) then
		return false
	end

	local from = getCreaturePosition(cid)
	local direction = Telegraph.directionTo(from, getCreaturePosition(target))
	local tiles = Telegraph.cone(from, direction, 5)
	if(MonsterAI.getMemory(cid).bloodmoon) then
		tiles = Telegraph.merge(tiles, Telegraph.cone(from, (direction + 2) % 4, 5))
	end

	Telegraph.strike{
		caster = cid, tiles = tiles, delay = 1300, refresh = 1300,
		combat = COMBAT_PHYSICALDAMAGE, min = 70, max = 120, effect = CONST_ME_HITAREA,
		onLand = function()
			if(isCreature(cid)) then
				doSendMagicEffect(getCreaturePosition(cid), CONST_ME_BLOCKHIT)
			end
		end
	}

	return true
end
