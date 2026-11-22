-- Wall of Light: +armor and +defense for 10 seconds on the caster and the party members around (radius 3) (buff "wall_of_light").
function onCastSpell(cid, var)
	for _, tid in ipairs(Cleric.allies(cid, getCreaturePosition(cid), 3)) do
		Buffs.add(tid, "wall_of_light")
	end

	return true
end
