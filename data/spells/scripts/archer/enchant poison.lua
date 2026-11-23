-- Enchant Poison: the enchantment of the Archer becomes poison. Every spell changes its element and its effect (see data/lib/376-archer.lua) and the basic
-- attacks deal +30% of the damage as poison until you change it. Casting it again removes the enchantment (back to physical arrows).
-- Costs no mana, 1s of cooldown.
function onCastSpell(cid, var)
	local element = Archer.toggle(cid, "poison")
	if(element == "physical") then
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Enchantment removed: physical arrows.")
		return true
	end

	Archer.fx("archer_enchant", cid, {element = element})
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Enchantment: Poison.")
	return true
end
