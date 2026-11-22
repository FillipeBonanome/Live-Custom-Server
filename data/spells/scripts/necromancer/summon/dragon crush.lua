-- Dragon Skeleton: Bone Crush, heavy physical melee hit (P x 2.0 to 3.5).
local combat = createCombatObject()

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		return false
	end

	return Necro.hit(cid, target, COMBAT_PHYSICALDAMAGE, 2.0, 3.5, CONST_ME_HITAREA)
end
