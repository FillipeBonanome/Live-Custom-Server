-- Elemental Shot: arrow with the element of the enchantment in 1 target (range 7), power x 0.7 to 1.1.
-- fire: burning | poison: +1 stack of venom | ice: +1 stack of frost | energy: 20% chance to jump to another enemy
local config = {damage = {0.7, 1.1}, range = 7}

function onCastSpell(cid, var)
	local target = Archer.target(cid, config.range)
	if(not target) then
		return false
	end

	local element = Archer.element(cid)
	Archer.fx("archer_shot", target, {from = getCreaturePosition(cid), element = element})
	Archer.hit(cid, target, config.damage[1], config.damage[2], element)
	return true
end
