-- Staff, to test the glyphs without farming the bestiary (affects only the player who says it):
-- /glyph points <n>            adds n bestiary points to spend on glyphs (negative removes, never below 0 bonus)
-- /glyph give <spell> a|b      puts the glyph on the spell for free, ignoring level and points (swap it again to compare)
-- /glyph remove <spell>        takes the glyph off the spell
-- /glyph push                  pushes the creature you are targeting away from you (tests the push system, says why it did not move)
-- /glyph reset                 no glyphs, no spent points, no bonus points
-- /glyph                       status and help
function onSay(cid, words, param, channel)
	param = param:lower():gsub("^%s+", ""):gsub("%s+$", "")
	local command, rest = param:match("^(%S+)%s*(.-)$")
	local function say(text)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
	end

	if(command == "points") then
		local amount = tonumber(rest)
		if(not amount) then
			say("Usage: /glyph points <number>")
			return true
		end

		local bonus = math.max(0, Glyphs.bonusPoints(cid) + math.floor(amount))
		setPlayerStorageValue(cid, tonumber(getConfigValue("glyphStorageBase") or 56200) + 99, bonus)
		say("Bonus bestiary points: " .. bonus .. ". Free points: " .. Glyphs.freePoints(cid) .. ".")
	elseif(command == "give" or command == "remove") then
		local name, letter = rest:match("^(.-)%s+([ab])$")
		if(command == "remove") then
			name, letter = rest, nil
		end

		local spell = Glyphs.spell(name)
		if(not spell) then
			say("Usage: /glyph give <spell> a|b  or  /glyph remove <spell>")
			return true
		end

		if(letter and not spell.glyphs[letter:upper()]) then
			say("Glyph " .. letter:upper() .. " of " .. spell.name .. " is not designed yet.")
			return true
		end

		Glyphs.force(cid, spell, letter and letter:upper())
		say(letter and ("Glyph " .. letter:upper() .. " set on " .. spell.name .. ".") or ("Glyph removed from " .. spell.name .. "."))
	elseif(command == "push") then
		-- tests the push system: pushes the creature you are targeting (or the one in front of you) away from you, always
		local target = getCreatureTarget(cid)
		if(not target or target <= 0) then
			local front = getCreatureLookPosition(cid)
			front.stackpos = STACKPOS_TOP_CREATURE
			local thing = getThingFromPos(front)
			target = thing and thing.uid and thing.uid > 0 and isCreature(thing.uid) and thing.uid or 0
		end

		if(target <= 0) then
			say("Select a target (or stand in front of a creature) first.")
			return true
		end

		local ok, reason = Push.away(cid, target, 100)
		say(ok and ("Pushed " .. getCreatureName(target) .. ".") or ("Not pushed: " .. tostring(reason) .. "."))
	elseif(command == "reset") then
		Glyphs.resetAll(cid)
		say("Glyphs, spent points and bonus points reset.")
	else
		say("Glyph test: /glyph points <n> | give <spell> a|b | remove <spell> | push | reset. Free points: " .. Glyphs.freePoints(cid)
			.. " (earned " .. Glyphs.earnedPoints(cid) .. ", spent " .. Glyphs.spentPoints(cid) .. "). Use !glyphs to see the list.")
	end

	return true
end
