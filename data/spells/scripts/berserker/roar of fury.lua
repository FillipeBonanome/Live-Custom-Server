-- Roar of Fury: gives 5 stacks of Fury at once (+10 axe skill for 12s). Costs 10% of the max health (healthpercent in spells.xml).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.stacks = n                              stacks of Fury (instead of 5)
--   glyph.slow   = {radius, percent, duration}    every enemy within `radius` sqm is slowed
local config = {stacks = 5}

function onCastSpell(cid, var)
	local glyph = Berserker.glyph(cid, "roar of fury")
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_BLOCKHIT)
	Berserker.fury(cid, (glyph and glyph.stacks) or config.stacks)
	if(glyph and glyph.slow) then
		Berserker.slowAll(cid, Berserker.enemiesAround(cid, getCreaturePosition(cid), glyph.slow.radius), glyph.slow.percent, glyph.slow.duration)
	end

	return true
end
