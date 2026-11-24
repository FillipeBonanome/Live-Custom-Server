-- Vorthrax Rime Call: the mechanic is defined in data/lib/396-bosses-tier3.lua (library in data/lib/394-boss-spells.lua)
function onCastSpell(cid, var)
	return BossSpell.cast(cid, "Vorthrax Rime Call")
end
