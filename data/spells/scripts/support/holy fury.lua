-- Holy Fury: +20% holy damage on the caster for 15 seconds (buff "Holy Fury", Cleric.buffs in data/lib/372-cleric.lua).
function onCastSpell(cid, var)
	return Cleric.addBuff(cid, "holy_fury")
end
