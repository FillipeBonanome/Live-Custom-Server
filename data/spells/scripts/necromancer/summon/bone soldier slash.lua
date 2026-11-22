-- Bone Soldier (Army of the Dead): Slash, physical melee hit (P x 0.5 to 1.0).
local combat = createCombatObject()

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		return false
	end

	return Necro.hit(cid, target, COMBAT_PHYSICALDAMAGE, 0.5, 1.0, CONST_ME_HITAREA)
end
