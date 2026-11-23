-- Convergence: shoots the 4 elements in a row (poison, fire, ice, energy, every 0.3s) in 1 target (range 7), power x 0.7 to 1.1 each.
-- The order triggers the elemental reactions in chain: poison > fire (ignite), fire > ice (shatter), ice > energy (conduct).
local config = {damage = {0.7, 1.1}, range = 7, interval = 300, order = {"poison", "fire", "ice", "energy"}}

function onCastSpell(cid, var)
	local target = Archer.target(cid, config.range)
	if(not target) then
		return false
	end

	local function shoot(index)
		if(not isCreature(cid) or not Archer.valid(cid, target)) then
			return
		end

		local element = config.order[index]
		Archer.fx("archer_shot", target, {from = getCreaturePosition(cid), element = element})
		Archer.hit(cid, target, config.damage[1], config.damage[2], element)
		if(index < #config.order) then
			addEvent(shoot, config.interval, index + 1)
		end
	end

	shoot(1)
	return true
end
