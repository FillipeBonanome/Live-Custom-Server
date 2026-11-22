-- Bone Abomination (Lich): when it dies it explodes in death (5x5, P x 2.0 to 3.5, Frenzy included). The damage is dealt in the name of
-- the owner. It does not explode when it is consumed (Dragon Skeleton, Soul Sacrifice, Bone Shell) because that is not a death.
local area = createCombatArea(AREA_CIRCLE2X2)

function onDeath(cid, corpse, lastHitKiller, mostDamageKiller)
	local master = getCreatureMaster(cid)
	if(not master or not isPlayer(master)) then
		return true
	end

	local pos = getCreaturePosition(cid)
	local min, max = Necro.summonValues(cid, 2.0, 3.5)
	doAreaCombatHealth(master, COMBAT_DEATHDAMAGE, pos, area, -min, -max, CONST_ME_MORTAREA)
	VFX.Explosion(pos, CONST_ANI_DEATH, {radius = 3, points = 12, rings = 2, ringInterval = 120, skipVoid = true})
	return true
end
