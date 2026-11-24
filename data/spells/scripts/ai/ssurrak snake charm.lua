-- Ssurrak Snake Charm: the mechanic is defined in data/lib/395-bosses-tier2.lua (library in data/lib/394-boss-spells.lua)
function onCastSpell(cid, var)
	return BossSpell.cast(cid, "Ssurrak Snake Charm")
end
