-- Sanguessa Eclipse: the mechanic is defined in data/lib/397-bosses-tier4.lua (library in data/lib/394-boss-spells.lua)
function onCastSpell(cid, var)
	return BossSpell.cast(cid, "Sanguessa Eclipse")
end
