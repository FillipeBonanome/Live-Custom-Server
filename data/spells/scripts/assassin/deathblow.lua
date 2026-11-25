-- Deathblow: huge cut (power x 4.5 to 6.0) that only works on a target with less than 25% of its health.
-- Spends the Momentum stacks: +20% damage for each one.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.below = %   the target may have up to that % of its health (instead of 25%)
--   glyph.reaper = {haste, invisible}   if the blow kills the target: haste and invisibility (ms)
local config = {damage = {4.5, 6.0}, maxHealth = 0.25, perStack = 0.20}

function onCastSpell(cid, var)
	local target = Assassin.target(cid, 1)
	if(not target) then
		return false
	end

	local glyph = Assassin.glyph(cid, "deathblow")
	local limit = glyph and glyph.below and glyph.below / 100 or config.maxHealth
	if(getCreatureHealth(target) >= getCreatureMaxHealth(target) * limit) then
		doPlayerSendCancel(cid, "Your target must have less than " .. math.floor(limit * 100) .. "% of its health.")
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
		return false
	end

	local multiplier = 1 + config.perStack * Assassin.consume(cid)
	Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_MORTAREA, multiplier)
	if(glyph and glyph.reaper and (not isCreature(target) or getCreatureHealth(target) <= 0)) then
		Glyphs.haste(cid, glyph.reaper.haste)
		Assassin.invisible(cid, glyph.reaper.invisible)
	end

	return true
end
