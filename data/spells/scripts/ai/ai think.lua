-- AI Think: the "brain" spell. The monster XML fires it as an attack (<attack name="AI Think" interval="1000" chance="100"/>)
-- and it asks the decision tree of the monster which spell to cast now (data/lib/391-monster-ai.lua).
function onCastSpell(cid, var)
	MonsterAI.think(cid)
	return true
end
