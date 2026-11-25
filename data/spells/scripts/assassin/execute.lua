-- Execute: finisher in 1 adjacent target (power x 1.6 to 2.4), x1.75 when the target has less than 30% of its health.
-- Spends the Momentum stacks: +20% damage for each one. The knife lands 0.4s after the cast.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.execute = {below, damage}   replaces the 30% / x1.75
--   glyph.bounty  = {mana}            if the knife kills the target you get the Momentum stacks back and `mana`% of your maximum mana
local config = {damage = {1.6, 2.4}, lowHealth = 0.30, lowHealthBonus = 1.75, perStack = 0.20, delay = 400}

function onCastSpell(cid, var)
	local target = Assassin.target(cid, 1)
	if(not target) then
		return false
	end

	local glyph = Assassin.glyph(cid, "execute")
	local lowHealth = glyph and glyph.execute and glyph.execute.below / 100 or config.lowHealth
	local lowBonus = glyph and glyph.execute and glyph.execute.damage or config.lowHealthBonus
	local stacks = Assassin.consume(cid)
	local multiplier = 1 + config.perStack * stacks
	Assassin.fx("assassin_execute", target, {from = getCreaturePosition(cid)})
	addEvent(function()
		if(isCreature(cid) and isCreature(target)) then
			local finisher = multiplier
			if(getCreatureHealth(target) < getCreatureMaxHealth(target) * lowHealth) then
				finisher = finisher * lowBonus
			end

			Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_EXPLOSIONHIT, finisher)
			if(glyph and glyph.bounty and isPlayer(cid) and (not isCreature(target) or getCreatureHealth(target) <= 0)) then
				if(stacks > 0) then
					Assassin.momentum(cid, stacks)
				end

				doPlayerAddMana(cid, math.floor(getCreatureMaxMana(cid) * glyph.bounty.mana / 100))
			end
		end
	end, config.delay)

	return true
end
