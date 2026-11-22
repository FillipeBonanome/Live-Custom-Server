-- Radiant Strikes (Hierophant): basic attacks deal 15% of the damage as extra holy damage, for 1 minute, on the caster and the
-- party (radius 7) (buff "Radiant Strikes", uses the on hit holy attribute).
function onCastSpell(cid, var)
	for _, tid in ipairs(Cleric.allies(cid, getCreaturePosition(cid), 7)) do
		Cleric.addBuff(tid, "radiant_strikes")
	end

	return true
end
