-- Holy Fury: +20% holy damage on the caster for 15 seconds (buff "Holy Fury", Cleric.buffs in data/lib/372-cleric.lua).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.critical = n                  also +n% critical chance for the same time (buff "Righteous Fury", subId 8832)
--   glyph.share    = {radius, amp}      party members within `radius` sqm get +amp% holy damage (buff "Shared Fury", subId 8833)
local KEY = "support/holy fury"

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not Cleric.addBuff(cid, "holy_fury")) then
		return false
	end

	if(not glyph) then
		return true
	end

	if(glyph.critical) then
		Glyphs.statBuff(cid, {
			name = "Righteous Fury", duration = Cleric.buffs.holy_fury.duration, subId = 8832, effect = CONST_ME_HOLYAREA,
			description = "+" .. glyph.critical .. "% critical chance.", params = {[CONDITION_PARAM_CRITICALCHANCE] = glyph.critical}
		})
	end

	if(glyph.share) then
		for _, tid in ipairs(Cleric.allies(cid, getCreaturePosition(cid), glyph.share.radius)) do
			if(tid ~= cid) then
				Glyphs.statBuff(tid, {
					name = "Shared Fury", duration = Cleric.buffs.holy_fury.duration, subId = 8833, effect = CONST_ME_HOLYAREA,
					description = "+" .. glyph.share.amp .. "% holy damage.", params = {[CONDITION_PARAM_ELEMENTAL_AMP_HOLY] = glyph.share.amp}
				})
			end
		end
	end

	return true
end
