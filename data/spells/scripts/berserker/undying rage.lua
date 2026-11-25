-- Undying Rage (Warlord): for 6s the damage cannot kill you (you stay at 1 health, creaturescript "UndyingRage") and you get +10% life leech.
-- Costs 12% of the max health (healthpercent in spells.xml). Gives 1 Fury.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.heal       = {percent}                  when the rage ends you recover `percent`% of your maximum health
--   glyph.vengeance  = {amp, critical}            +`amp`% physical damage and +`critical`% critical chance while it lasts (buff "Vengeful Rage", subId 8455)
local config = {}

function onCastSpell(cid, var)
	local glyph = Berserker.glyph(cid, "undying rage")
	local duration = Berserker.buffs.undying_rage.duration
	registerCreatureEvent(cid, "UndyingRage")
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_RED)
	Berserker.addBuff(cid, "undying_rage")

	if(glyph and glyph.vengeance) then
		Berserker.vengeance(cid, "Vengeful Rage", 8455, glyph.vengeance.amp, glyph.vengeance.critical, duration)
	end

	if(glyph and glyph.heal) then
		addEvent(function()
			if(isCreature(cid) and getCreatureHealth(cid) > 0) then
				doCreatureAddHealth(cid, math.floor(getCreatureMaxHealth(cid) * glyph.heal.percent / 100))
				doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
			end
		end, duration + 100)
	end

	Berserker.fury(cid)
	return true
end
