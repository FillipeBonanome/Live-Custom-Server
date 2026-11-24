-- Warlord Ruzad - Call Guards: 2 Orc Warriors (never more than 4 summons alive at once).
function onCastSpell(cid, var)
	return MonsterAI.summon(cid, "Orc Warrior", 2, 4) > 0
end
