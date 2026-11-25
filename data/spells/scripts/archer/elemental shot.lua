-- Elemental Shot: arrow with the element of the enchantment in 1 target (range 7), power x 0.7 to 1.1.
-- fire: burning | poison: +1 stack of venom | ice: +1 stack of frost | energy: 20% chance to jump to another enemy
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.refund = {chance}              chance (%) of getting the mana of the shot back
--   glyph.far    = {distance, damage}    `damage` times more damage when the target is `distance` sqm away or farther
local config = {damage = {0.7, 1.1}, range = 7, cost = 10}

function onCastSpell(cid, var)
	local target = Archer.target(cid, config.range)
	if(not target) then
		return false
	end

	local glyph = Archer.glyph(cid, "elemental shot")
	local multiplier = 1
	if(glyph and glyph.far and getDistanceBetween(getCreaturePosition(cid), getCreaturePosition(target)) >= glyph.far.distance) then
		multiplier = glyph.far.damage
	end

	local element = Archer.element(cid)
	Archer.fx("archer_shot", target, {from = getCreaturePosition(cid), element = element})
	Archer.hit(cid, target, config.damage[1], config.damage[2], element, multiplier)

	if(glyph and glyph.refund and math.random(100) <= glyph.refund.chance) then
		Archer.refundMana(cid, config.cost)
	end

	return true
end
