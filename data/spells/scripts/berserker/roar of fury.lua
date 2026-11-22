-- Roar of Fury: gives 5 stacks of Fury at once (+10 axe skill for 12s). Costs 10% of the max health (healthpercent in spells.xml).
local config = {stacks = 5}

function onCastSpell(cid, var)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_BLOCKHIT)
	Berserker.fury(cid, config.stacks)
	return true
end
