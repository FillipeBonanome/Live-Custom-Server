-- Perfect Shot (Ranger): the arrow of a sharpshooter, range 10, power x 4.0 to 5.5 with a guaranteed critical (+30%).
-- x1.5 if the target has 3 or more statuses (burning, venom, frost, supercharged or marked).
local config = {damage = {4.0, 5.5}, range = 10, critical = 1.3, statusBonus = 1.5, statuses = 3}

function onCastSpell(cid, var)
	local target = Archer.target(cid, config.range)
	if(not target) then
		return false
	end

	local element = Archer.element(cid)
	local critical = config.critical
	if(Archer.statusCount(target) >= config.statuses) then
		critical = critical * config.statusBonus
	end

	Archer.fx("archer_shot", target, {from = getCreaturePosition(cid), element = element})
	Archer.hit(cid, target, config.damage[1], config.damage[2], element, nil, {critical = critical})
	return true
end
