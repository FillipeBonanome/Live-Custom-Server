-- Undying Rage (Warlord): while the buff "Undying Rage" is active a hit that would kill the player leaves 1 health instead.
-- The event is registered on the player by the spell (data/spells/scripts/berserker/undying rage.lua).
local busy = false

function onStatsChange(cid, attacker, type, combat, value, origin)
	if(busy or type ~= STATSCHANGE_HEALTHLOSS or not hasCreatureBuff(cid, "Undying Rage")) then
		return true
	end

	local health = getCreatureHealth(cid)
	if(value < health) then
		return true
	end

	if(health > 1) then
		busy = true -- the health change goes through this event again
		doCreatureAddHealth(cid, 1 - health)
		busy = false
	end

	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_RED)
	return false
end
