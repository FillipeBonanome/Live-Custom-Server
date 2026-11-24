-- Zulkarath Annihilation: the mechanic is defined in data/lib/398-bosses-tier5.lua (library in data/lib/394-boss-spells.lua)
function onCastSpell(cid, var)
	return BossSpell.cast(cid, "Zulkarath Annihilation")
end
