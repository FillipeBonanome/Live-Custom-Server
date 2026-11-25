-- Warcry: the monsters within 3 SQM start attacking you (taunt) and you get +5 armor and +3 defense for 8s (buff "Warcry").
-- Costs 6% of the max health (healthpercent in spells.xml). Gives 1 Fury.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.guard = {percent, duration}   the caster takes `percent`% less damage from every element (buff "Iron Cry", subId 8452)
--   glyph.rally = {radius, haste}       the party within `radius` sqm also gets the buff, plus haste for `haste` ms
local config = {radius = 3}

function onCastSpell(cid, var)
	local glyph = Berserker.glyph(cid, "warcry")
	local pos = getCreaturePosition(cid)
	local spectators = getSpectators(pos, config.radius, config.radius, false)
	if(type(spectators) == 'table') then
		for _, tid in ipairs(spectators) do
			if(isMonster(tid) and not getCreatureMaster(tid)) then
				doChallengeCreature(cid, tid)
			end
		end
	end

	doSendMagicEffect(pos, CONST_ME_BLOCKHIT)
	Berserker.addBuff(cid, "warcry")
	if(glyph and glyph.guard) then
		Berserker.guard(cid, "Iron Cry", 8452, glyph.guard.percent, glyph.guard.duration)
	end

	if(glyph and glyph.rally) then
		for _, tid in ipairs(Glyphs.allies(cid, glyph.rally.radius)) do
			if(tid ~= cid) then
				Berserker.addBuff(tid, "warcry")
				Glyphs.haste(tid, glyph.rally.haste)
			end
		end
	end

	Berserker.fury(cid)
	return true
end
