-- Queen Silkara - Venom Spit: a cone of 6 tiles in the direction of the target is marked; she spits a spray of venom over it (earth).
function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(not target or target == 0 or not isCreature(target)) then
		return false
	end

	local from = getCreaturePosition(cid)
	local tiles = Telegraph.cone(from, Telegraph.directionTo(from, getCreaturePosition(target)), 6)
	Telegraph.strike{
		caster = cid, tiles = tiles, delay = 1300, refresh = 1300,
		combat = COMBAT_EARTHDAMAGE, min = 50, max = 95, effect = CONST_ME_POISONAREA,
		onLand = function()
			if(isCreature(cid)) then
				local pos = getCreaturePosition(cid)
				for i = 1, #tiles, 2 do
					doSendDistanceShoot(pos, tiles[i], CONST_ANI_POISON)
				end
			end
		end
	}

	return true
end
