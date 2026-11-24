-- Blocks the damage while the monster is shielded (MonsterAI.setImmune). Registered by the AI at the first think.
function onStatsChange(cid, attacker, type, combat, value, origin)
	return MonsterAI.onStats(cid, type)
end
