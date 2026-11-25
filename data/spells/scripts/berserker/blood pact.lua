-- Blood Pact: +8% life leech for 12s (doubles the passive leech; buff "Blood Pact"). Costs 10% of the max health (healthpercent in spells.xml). Gives 1 Fury.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.flesh      = true                       the leech is +14% instead of +8% (Berserker.buffs.blood_pact_flesh)
--   glyph.vengeance  = {amp, critical}            +`amp`% physical damage and +`critical`% critical chance for 12s (buff "Pact of Vengeance", subId 8454)
local config = {}

function onCastSpell(cid, var)
	local glyph = Berserker.glyph(cid, "blood pact")
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_DRAWBLOOD)
	Berserker.addBuff(cid, (glyph and glyph.flesh) and "blood_pact_flesh" or "blood_pact")
	if(glyph and glyph.vengeance) then
		Berserker.vengeance(cid, "Pact of Vengeance", 8454, glyph.vengeance.amp, glyph.vengeance.critical, Berserker.buffs.blood_pact.duration)
	end

	Berserker.fury(cid)
	return true
end
