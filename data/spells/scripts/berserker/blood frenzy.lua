-- Blood Frenzy (Warlord): for 10s +10% life leech, +25 fist skill (attack speed) and +1 Fury every second (buff "Blood Frenzy").
-- Costs 15% of the max health (healthpercent in spells.xml).
local config = {seconds = 10}

function onCastSpell(cid, var)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_DRAWBLOOD)
	Berserker.addBuff(cid, "blood_frenzy")
	Berserker.fury(cid)

	for i = 1, config.seconds - 1 do
		addEvent(function()
			if(isCreature(cid) and hasCreatureBuff(cid, "Blood Frenzy")) then
				Berserker.fury(cid)
			end
		end, i * 1000)
	end

	return true
end
