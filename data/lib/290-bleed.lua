-- Bleeding: a CONDITION_PHYSICAL (damage over time, same engine condition as the bleed attribute of the items).
-- doTargetBleed(cid, target, perTick, ticks[, interval = 1000[, delayed = false]])
--   `ticks` hits of `perTick` physical damage, one every `interval` ms. delayed = true skips the hit of the first instant.
--   The kills are credited to cid. Re-applying only refreshes it when the new bleeding is longer and not weaker.
function doTargetBleed(cid, target, perTick, ticks, interval, delayed)
	if(not isCreature(cid) or not isCreature(target) or getCreatureHealth(target) <= 0) then
		return false
	end

	local condition = createConditionObject(CONDITION_PHYSICAL)
	setConditionParam(condition, CONDITION_PARAM_OWNER, cid)
	if(delayed) then
		setConditionParam(condition, CONDITION_PARAM_DELAYED, 1)
	end

	addDamageCondition(condition, math.max(1, ticks), interval or 1000, -math.max(1, math.floor(perTick)))
	return doAddCondition(target, condition)
end
