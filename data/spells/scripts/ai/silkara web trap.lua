-- Queen Silkara - Web Trap: she spits a web over the target; a circle (radius 2) is marked and, when it lands, whoever is still inside
-- takes a little earth damage and is slowed for 4 s.
function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(not target or target == 0 or not isCreature(target)) then
		return false
	end

	local center = getCreaturePosition(target)
	doSendDistanceShoot(getCreaturePosition(cid), center, CONST_ANI_POISON)
	Telegraph.strike{
		caster = cid, tiles = Telegraph.disc(center, 2), delay = 1400, refresh = 1400,
		combat = COMBAT_EARTHDAMAGE, min = 20, max = 40, effect = CONST_ME_POISONAREA,
		onHit = function(pid, pos)
			doRemoveCondition(pid, CONDITION_PARALYZE)
			local condition = createConditionObject(CONDITION_PARALYZE)
			setConditionParam(condition, CONDITION_PARAM_TICKS, 4000)
			setConditionFormula(condition, -0.6, 0, -0.6, 0)
			doAddCondition(pid, condition)
			doSendMagicEffect(pos, CONST_ME_STUN)
		end
	}

	return true
end
