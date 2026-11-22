-- Ghoul: Claw, weak physical melee hit (P x 0.3 to 0.6).
local combat = createCombatObject()

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		return false
	end

	return Necro.hit(cid, target, COMBAT_PHYSICALDAMAGE, 0.3, 0.6, CONST_ME_HITAREA)
end
