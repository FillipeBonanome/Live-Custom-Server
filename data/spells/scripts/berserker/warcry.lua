-- Warcry: the monsters within 3 SQM start attacking you (taunt) and you get +5 armor and +3 defense for 8s (buff "Warcry").
-- Costs 6% of the max health (healthpercent in spells.xml). Gives 1 Fury.
local config = {radius = 3}

function onCastSpell(cid, var)
	local pos = getCreaturePosition(cid)
	local spectators = getSpectators(pos, config.radius, config.radius, false)
	if(type(spectators) == 'table') then
		for _, tid in ipairs(spectators) do
			if(isMonster(tid) and not getCreatureMaster(tid)) then
				doChallengeCreature(cid, tid)
			end
		end
	end

	doSendMagicEffect(pos, CONST_ME_BLOCKHIT)
	Berserker.addBuff(cid, "warcry")
	Berserker.fury(cid)
	return true
end
