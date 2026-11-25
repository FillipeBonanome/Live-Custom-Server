-- Dragon Skeleton: Grave Burst, ring of death around it (P x 1.0 to 1.8 per tile), drawn tile by tile with RingAttack.
-- The attack lives in Necro.graveBurst (data/lib/373-necromancer.lua) because the glyph Dragon's Fury (Summon Dragon Skeleton B) also casts it
-- by itself between the normal bursts, with more damage.
local combat = createCombatObject()

function onCastSpell(cid, var)
	Necro.graveBurst(cid)
	return true
end
