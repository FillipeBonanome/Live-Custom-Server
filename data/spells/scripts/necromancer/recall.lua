-- Recall: teleports all your summons next to you.
-- Glyphs (data/lib/403-glyphs.lua): glyph.haste = {duration} haste (+30%) for you and the summons; glyph.guard = {percent, duration} the
-- summons take that % less damage from every element (Necro.guard).
local KEY = "necromancer/recall"

function onCastSpell(cid, var)
	local summons = Necro.summons(cid, false, true)
	if(#summons == 0) then
		doPlayerSendCancel(cid, "You have no summon.")
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
		return false
	end

	local glyph = Glyphs.get(cid, KEY)
	local from = getCreaturePosition(cid)
	for _, sid in ipairs(summons) do
		local pos = getClosestFreeTile(sid, from, false, true)
		if(pos) then
			doSendMagicEffect(getCreaturePosition(sid), CONST_ME_POFF)
			doTeleportThing(sid, pos)
			doSendMagicEffect(pos, CONST_ME_MORTAREA)
		end

		if(glyph and glyph.haste) then
			Glyphs.haste(sid, glyph.haste.duration)
		end

		if(glyph and glyph.guard) then
			Necro.guard(sid, glyph.guard.percent, glyph.guard.duration)
		end
	end

	if(glyph and glyph.haste) then
		Glyphs.haste(cid, glyph.haste.duration)
	end

	return true
end
