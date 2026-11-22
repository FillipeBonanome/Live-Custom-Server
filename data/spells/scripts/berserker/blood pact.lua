-- Blood Pact: +8% life leech for 12s (doubles the passive leech; buff "Blood Pact"). Costs 10% of the max health (healthpercent in spells.xml). Gives 1 Fury.
local config = {}

function onCastSpell(cid, var)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_DRAWBLOOD)
	Berserker.addBuff(cid, "blood_pact")
	Berserker.fury(cid)
	return true
end
