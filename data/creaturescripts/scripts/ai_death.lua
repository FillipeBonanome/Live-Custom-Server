-- Death of a monster with AI: onDeath hook of the definition and the summons vanish. Registered by the AI at the first think.
-- Bosses also drop their uniques and runes here (see data/lib/401-boss-loot.lua).
function onDeath(cid, corpse)
	MonsterAI.onDeath(cid)
	BossLoot.drop(cid, corpse)
	return true
end
