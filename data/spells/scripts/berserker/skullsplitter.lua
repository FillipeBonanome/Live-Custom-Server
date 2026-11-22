-- Skullsplitter: huge blow in 1 adjacent target (power x 3.0 to 4.2). The damage grows with the health you are missing (up to x2 with no health left).
-- Costs 15% of the max health (healthpercent in spells.xml). Gives 1 Fury.
local config = {damage = {3.0, 4.2}}

function onCastSpell(cid, var)
	local target = Berserker.target(cid, 1)
	if(not target) then
		return false
	end

	local missing = 1 - getCreatureHealth(cid) / getCreatureMaxHealth(cid)
	Berserker.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_EXPLOSIONHIT, 1 + missing)
	Berserker.fury(cid)
	return true
end
