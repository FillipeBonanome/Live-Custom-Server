-- Skeleton: Bone Slash, physical melee hit with high damage (P x 0.8 to 1.6, see Necro.summonValues in data/lib/373-necromancer.lua).
local combat = createCombatObject() -- monster scripts need a combat object

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		return false
	end

	return Necro.hit(cid, target, COMBAT_PHYSICALDAMAGE, 0.8, 1.6, CONST_ME_HITAREA)
end
