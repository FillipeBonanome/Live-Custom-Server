-- !glyphs                          points, prices and the glyph of each spell
-- !glyphs <spell>                  the two glyphs of a spell
-- !glyphs <spell> a|b              asks for confirmation to choose a glyph
-- !glyphs <spell> a|b yes          chooses it (points the first time, gold to swap)
function onSay(cid, words, param, channel)
	if(not Glyphs.enabled()) then
		doPlayerSendCancel(cid, "The glyph system is disabled.")
		return true
	end

	if(not Glyphs.canUse(cid)) then
		doPlayerSendCancel(cid, "Only sorcerers can carve glyphs.")
		return true
	end

	param = param:gsub("^%s+", ""):gsub("%s+$", ""):lower()
	if(param == "") then
		doPlayerPopupFYI(cid, Glyphs.summary(cid))
		return true
	end

	local confirm = false
	local rest = param:match("^(.-)%s+yes$")
	if(rest) then
		confirm, param = true, rest
	end

	local letter
	local name, last = param:match("^(.-)%s+([ab])$")
	if(name) then
		letter, param = last, name
	end

	local spell = Glyphs.spell(param)
	if(not spell) then
		doPlayerSendCancel(cid, "There is no glyph for the spell '" .. param .. "'. Use !glyphs to see the list.")
		return true
	end

	if(not letter) then
		doPlayerPopupFYI(cid, Glyphs.describe(cid, spell))
		return true
	end

	if(not confirm) then
		local glyph = spell.glyphs[letter:upper()]
		if(not glyph) then
			doPlayerSendCancel(cid, "This glyph is not available yet.")
			return true
		end

		local price
		if(Glyphs.chosenLetter(cid, spell)) then
			price = Glyphs.swapGold(spell) .. " gold coins"
		else
			price = Glyphs.cost(spell) .. " bestiary points"
		end

		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Glyph " .. letter:upper() .. " of " .. spell.name .. ": " .. glyph.name
			.. " - " .. Glyphs.description(cid, glyph) .. " It costs " .. price .. ". Say '!glyphs " .. spell.name:lower() .. " " .. letter .. " yes' to confirm.")
		return true
	end

	local ok, message = Glyphs.choose(cid, spell, letter)
	if(ok) then
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, message)
	else
		doPlayerSendCancel(cid, message)
	end

	return true
end
