-- Unholy Frenzy: +30% damage on all your summons for 20s. (Necro.buffs in data/lib/373-necromancer.lua)
-- Glyphs (data/lib/403-glyphs.lua): glyph.buff = "key" is another version of the buff (Dire Frenzy: +45% for 12s); glyph.leech is read by
-- Necro.summonValues (the summons recover part of the damage of each attack).
local KEY = "necromancer/unholy frenzy"

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	return Necro.addBuff(cid, glyph and glyph.buff or "unholy_frenzy")
end
