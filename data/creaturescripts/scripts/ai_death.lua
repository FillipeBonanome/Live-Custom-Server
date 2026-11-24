-- Death of a monster with AI: onDeath hook of the definition and the summons vanish. Registered by the AI at the first think.
function onDeath(cid, corpse)
	MonsterAI.onDeath(cid)
	return true
end
