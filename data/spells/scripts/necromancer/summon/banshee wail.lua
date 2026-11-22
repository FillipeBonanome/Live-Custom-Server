-- Banshee: Wail, death damage from a distance (P x 0.7 to 1.3).
local combat = createCombatObject()

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		return false
	end

	return Necro.hit(cid, target, COMBAT_DEATHDAMAGE, 0.7, 1.3, CONST_ME_MORTAREA, CONST_ANI_DEATH)
end
