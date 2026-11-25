-- Skullsplitter: huge blow in 1 adjacent target (power x 3.0 to 4.2). The damage grows with the health you are missing (up to x2 with no health left).
-- Costs 15% of the max health (healthpercent in spells.xml). Gives 1 Fury.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.execute = {below, damage}     `damage` times more damage when the target has `below`% of its health or less
--   glyph.bounty  = {fury}              if the blow kills the target you get back the health the spell cost and `fury` stacks of Fury
local config = {damage = {3.0, 4.2}, cost = 15}

function onCastSpell(cid, var)
	local target = Berserker.target(cid, 1)
	if(not target) then
		return false
	end

	local glyph = Berserker.glyph(cid, "skullsplitter")
	local missing = 1 - getCreatureHealth(cid) / getCreatureMaxHealth(cid)
	local multiplier = 1 + missing
	if(glyph and glyph.execute and getCreatureHealth(target) * 100 <= getCreatureMaxHealth(target) * glyph.execute.below) then
		multiplier = multiplier * glyph.execute.damage
	end

	Berserker.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_EXPLOSIONHIT, multiplier)
	Berserker.fury(cid)

	if(glyph and glyph.bounty and (not isCreature(target) or getCreatureHealth(target) <= 0)) then
		Berserker.fury(cid, glyph.bounty.fury)
		-- the cost of the spell is taken after the script, so the health comes back a moment later
		addEvent(function()
			if(isCreature(cid) and getCreatureHealth(cid) > 0) then
				doCreatureAddHealth(cid, math.floor(getCreatureMaxHealth(cid) * config.cost / 100))
				doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_RED)
			end
		end, 400)
	end

	return true
end
