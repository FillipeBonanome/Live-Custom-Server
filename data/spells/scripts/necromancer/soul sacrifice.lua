-- Soul Sacrifice: consumes your weakest summon (never the Dragon Skeleton): +40% death and poison damage for 15s and gives back 3 soul.
-- Glyphs (data/lib/403-glyphs.lua): glyph.refund = soul given back; glyph.buff = another version of the buff (+60%); glyph.heal = % of your
-- maximum health recovered at once.
local KEY = "necromancer/soul sacrifice"

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not Necro.sacrifice(cid, glyph and glyph.refund)) then
		return false
	end

	if(glyph and glyph.heal) then
		doCreatureAddHealth(cid, math.max(1, math.floor(getCreatureMaxHealth(cid) * glyph.heal / 100)))
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
	end

	return Necro.addBuff(cid, glyph and glyph.buff or "soul_sacrifice")
end
