-- Group Blessing: heals the caster and the party members around (radius 2) and gives them Holy Grace (category holy_grace).
local config = {radius = 2, heal = {5, 5, 4.0, 5.5}, buff = "divine_grace"}

function onCastSpell(cid, var)
	local pos = getCreaturePosition(cid)
	local allies = Cleric.allies(cid, pos, config.radius)
	local min, max = Cleric.values(cid, unpack(config.heal))
	Cleric.heal(cid, allies, min, max, CONST_ME_MAGIC_BLUE)
	for _, tid in ipairs(allies) do
		Cleric.addBuff(tid, config.buff)
	end

	doSendMagicEffect(pos, CONST_ME_HOLYAREA)
	Cleric.faith(cid)
	return true
end
