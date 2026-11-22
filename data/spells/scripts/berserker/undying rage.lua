-- Undying Rage (Warlord): for 6s the damage cannot kill you (you stay at 1 health, creaturescript "UndyingRage") and you get +10% life leech.
-- Costs 12% of the max health (healthpercent in spells.xml). Gives 1 Fury.
local config = {}

function onCastSpell(cid, var)
	registerCreatureEvent(cid, "UndyingRage")
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_RED)
	Berserker.addBuff(cid, "undying_rage")
	Berserker.fury(cid)
	return true
end
