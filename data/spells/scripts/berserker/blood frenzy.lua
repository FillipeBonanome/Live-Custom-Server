-- Blood Frenzy (Warlord): for 10s +10% life leech, +25 fist skill (attack speed) and +1 Fury every second (buff "Blood Frenzy").
-- Costs 15% of the max health (healthpercent in spells.xml).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.haste  = true                           haste (+30%) while the frenzy lasts
--   glyph.guard  = {percent}                      `percent`% less damage from every element while it lasts (buff "Unbroken Frenzy", subId 8453)
--   glyph.immune = true                           no paralysis while it lasts
local config = {seconds = 10}

function onCastSpell(cid, var)
	local glyph = Berserker.glyph(cid, "blood frenzy")
	local duration = Berserker.buffs.blood_frenzy.duration
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_DRAWBLOOD)
	Berserker.addBuff(cid, "blood_frenzy")
	Berserker.fury(cid)

	if(glyph and glyph.haste) then
		Glyphs.haste(cid, duration)
	end

	if(glyph and glyph.guard) then
		Berserker.guard(cid, "Unbroken Frenzy", 8453, glyph.guard.percent, duration)
	end

	if(glyph and glyph.immune) then
		Glyphs.paralysisImmunity(cid, duration)
	end

	for i = 1, config.seconds - 1 do
		addEvent(function()
			if(isCreature(cid) and hasCreatureBuff(cid, "Blood Frenzy")) then
				Berserker.fury(cid)
			end
		end, i * 1000)
	end

	return true
end
