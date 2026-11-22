-- Death Tornado (ultimate): a full disc of death with 5 SQM of radius around the Necromancer (no hole), swept tile by tile in one turn
-- of 1.3s (RingAttack, data/lib/069-ringattack.lua). Damage P x 1.2 to 2.0 per tile (a single hit per tile). It does not hold the enemies.
-- The animation of each tile is picked at random from `effects` (sent from onTile, so the damage hit itself draws nothing).
local effects = {CONST_ME_MORTAREA, CONST_ME_YALAHARIGHOST}

function onCastSpell(cid, var)
	local min, max = Necro.values(cid, 1.2, 2.0)
	RingAttack.execute(cid, {
		holeRadius = 0, ringThickness = 5, sweepDuration = 1300,
		elements = {{combatType = COMBAT_DEATHDAMAGE, effect = CONST_ME_NONE}},
		damageMin = min, damageMax = max,
		onTile = function(position)
			doSendMagicEffect(position, effects[math.random(#effects)])
		end
	})
	return true
end
