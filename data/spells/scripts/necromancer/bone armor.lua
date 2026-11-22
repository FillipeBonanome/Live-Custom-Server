-- Bone Armor: +25% physical resistance on your summons for 20s. (Necro.buffs in data/lib/373-necromancer.lua)
function onCastSpell(cid, var)
	return Necro.addBuff(cid, "bone_armor")
end
