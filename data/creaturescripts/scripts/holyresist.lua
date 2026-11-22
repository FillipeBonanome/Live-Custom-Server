-- Holy Resist Down: creatures hit by Sacred Wave get the buff "Holy Vulnerability" (8 seconds, addCreatureBuff) and are registered here.
-- While it lasts, each holy hit they take deals 10% extra holy damage, which is the same as 10% less holy resistance.
local busy = false

function onStatsChange(cid, attacker, type, combat, value, origin)
	if(busy or type ~= STATSCHANGE_HEALTHLOSS or combat ~= COMBAT_HOLYDAMAGE or not attacker or attacker == 0 or not isCreature(attacker)) then
		return true
	end

	if(not hasCreatureBuff(cid, "Holy Vulnerability")) then
		return true
	end

	local extra = math.ceil(value * 0.10)
	if(extra > 0) then
		busy = true -- the extra damage goes through this event again
		doTargetCombatHealth(attacker, cid, COMBAT_HOLYDAMAGE, -extra, -extra, CONST_ME_NONE)
		busy = false
	end

	return true
end
