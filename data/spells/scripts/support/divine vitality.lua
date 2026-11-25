-- Divine Vitality (Hierophant): +10% max health and +10% max mana for 2 minutes on the caster and the party (radius 7).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.buff = "key"   another version of the buff from Cleric.buffs (data/lib/372-cleric.lua): +15% instead of +10%
--   glyph.heal = n       everyone affected recovers n% of the (new) maximum health at once
local KEY = "support/divine vitality"

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local buff = (glyph and glyph.buff) or "divine_vitality"
	for _, tid in ipairs(Cleric.allies(cid, getCreaturePosition(cid), 7)) do
		Cleric.addBuff(tid, buff)
		if(glyph and glyph.heal) then
			doCreatureAddHealth(tid, math.floor(getCreatureMaxHealth(tid) * glyph.heal / 100))
			doSendMagicEffect(getCreaturePosition(tid), CONST_ME_MAGIC_GREEN)
		end
	end

	return true
end
