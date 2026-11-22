-- Soul Harvest (passive of the Necromancer): when a monster dies there is a chance that its soul is absorbed (Necro.harvest in
-- data/lib/373-necromancer.lua). onKill runs once for each creature that damaged the monster and the damage of the summons is
-- credited to their owner, so the kills of the summons count too. A kill is remembered to avoid giving soul twice for the same monster.
local lastTarget = {}

function onKill(cid, target, damage, flags, war)
	if(not isPlayer(cid) or not isNecromancer(cid) or lastTarget[cid] == target) then
		return true
	end

	lastTarget[cid] = target
	Necro.harvest(cid, target)
	return true
end
