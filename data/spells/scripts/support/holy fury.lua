-- Holy Fury: +20% holy damage on the caster for 15 seconds (buff "holy_fury").
function onCastSpell(cid, var)
	return Buffs.add(cid, "holy_fury")
end
