-- Judgment: marks the target; after 1.5 seconds the sentence falls (big holy hit) and heals party members around it.
local config = {
	delay = 1500, radius = 3,
	damage = {5, 5, 4.0, 5.5, 20, 40},
	heal = {5, 5, 1.0, 1.6}
}

local function sentence(cid, target)
	if(not isCreature(cid) or not isCreature(target) or getCreatureHealth(target) <= 0) then
		return
	end

	local pos = getCreaturePosition(target)
	local min, max = Cleric.values(cid, unpack(config.damage))
	doTargetCombatHealth(cid, target, COMBAT_HOLYDAMAGE, -min, -max, CONST_ME_HOLYDAMAGE)
	doSendMagicEffect(pos, CONST_ME_HOLYAREA)

	local hmin, hmax = Cleric.values(cid, unpack(config.heal))
	Cleric.heal(Cleric.allies(cid, pos, config.radius), hmin, hmax, CONST_ME_MAGIC_BLUE)
end

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
		return false
	end

	doSendMagicEffect(getCreaturePosition(target), CONST_ME_YELLOW_RINGS)
	addEvent(sentence, config.delay, cid, target)
	return true
end
