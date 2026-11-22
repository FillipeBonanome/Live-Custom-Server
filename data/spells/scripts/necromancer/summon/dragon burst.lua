-- Dragon Skeleton: Grave Burst, ring of death around it (P x 1.0 to 1.8 per tile), drawn tile by tile with RingAttack.
local combat = createCombatObject()

function onCastSpell(cid, var)
	local min, max = Necro.summonValues(cid, 1.0, 1.8)
	RingAttack.execute(cid, {
		holeRadius = 1, ringThickness = 2, sweepDuration = 1000,
		elements = {{combatType = COMBAT_DEATHDAMAGE, effect = CONST_ME_MORTAREA}},
		damageMin = min, damageMax = max
	})
	return true
end
