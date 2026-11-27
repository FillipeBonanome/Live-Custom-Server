-- Earthen Mend: the stone closes your wounds. Heals level/5 + power x 1.2 to 1.8 (power = club skill + attack of the club).
local config = {heal = {1.2, 1.8}}

function onCastSpell(cid, var)
	Geomancer.heal(cid, config.heal[1], config.heal[2])
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_STONES)
	return true
end
