-- Warlord Ruzad - Warcry: the tiles around him (7x7, 9x9 in berserk) are marked and everybody still there takes physical damage.
function onCastSpell(cid, var)
	local berserk = MonsterAI.getMemory(cid).berserk
	Telegraph.strike{
		caster = cid, tiles = Telegraph.square(getCreaturePosition(cid), berserk and 4 or 3), delay = 1200,
		combat = COMBAT_PHYSICALDAMAGE, min = berserk and 60 or 50, max = berserk and 120 or 100, effect = CONST_ME_EXPLOSIONAREA
	}

	return true
end
