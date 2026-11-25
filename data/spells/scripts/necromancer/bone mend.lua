-- Bone Mend: heals the summons around you (7 SQM, P x 2.0 to 3.5). Does not heal the Dragon Skeleton.
-- Glyphs (data/lib/403-glyphs.lua): glyph.healing = multiplier of the healing; glyph.radius = range in sqm; glyph.link = {percent} you
-- recover that % of the average healing of the spell as well.
local KEY = "necromancer/bone mend"

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local multiplier = glyph and glyph.healing or 1
	local radius = glyph and glyph.radius or 7

	if(Necro.mend(cid, 2.0 * multiplier, 3.5 * multiplier, radius) == 0) then
		doPlayerSendCancel(cid, "You have no summon to heal.")
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
		return false
	end

	if(glyph and glyph.link) then
		local min, max = Necro.values(cid, 2.0 * multiplier, 3.5 * multiplier)
		doCreatureAddHealth(cid, math.max(1, math.floor((min + max) / 2 * glyph.link.percent / 100)))
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
	end

	return true
end
