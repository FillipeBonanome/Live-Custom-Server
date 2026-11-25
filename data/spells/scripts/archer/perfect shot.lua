-- Perfect Shot (Ranger): the arrow of a sharpshooter, range 10, power x 4.0 to 5.5 with a guaranteed critical (+30%).
-- x1.5 if the target has 3 or more statuses (burning, venom, frost, supercharged or marked).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.execute = {below, damage}      `damage` times more damage when the target has `below`% of its health or less
--   glyph.rush    = {mana, haste}        if the shot kills the target you get back `mana`% of its mana cost and haste (+30%) for `haste` ms
local config = {damage = {4.0, 5.5}, range = 10, critical = 1.3, statusBonus = 1.5, statuses = 3, cost = 250}

function onCastSpell(cid, var)
	local target = Archer.target(cid, config.range)
	if(not target) then
		return false
	end

	local glyph = Archer.glyph(cid, "perfect shot")
	local element = Archer.element(cid)
	local critical = config.critical
	if(Archer.statusCount(target) >= config.statuses) then
		critical = critical * config.statusBonus
	end

	if(glyph and glyph.execute and getCreatureHealth(target) * 100 <= getCreatureMaxHealth(target) * glyph.execute.below) then
		critical = critical * glyph.execute.damage
	end

	Archer.fx("archer_shot", target, {from = getCreaturePosition(cid), element = element})
	Archer.hit(cid, target, config.damage[1], config.damage[2], element, nil, {critical = critical})

	if(glyph and glyph.rush and (not isCreature(target) or getCreatureHealth(target) <= 0)) then
		Archer.refundMana(cid, math.floor(config.cost * glyph.rush.mana / 100))
		Glyphs.haste(cid, glyph.rush.haste)
	end

	return true
end
