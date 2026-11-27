-- Gem Resonance: the gem in the ammo slot hums and mends you, 5 heals of level/5 + power x 0.5 to 0.7, one per second, and amplifies the
-- element of the gem: +25% damage of that element for 12s (buff Gem Resonance in !buffs). Without a gem you only get the healing.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.amplify  = {amp, duration}   buff: a bigger amplification that lasts longer
--   glyph.soothing = {ticks, heal}     sustain: more heals (one per second) and each one is `heal` times bigger
local config = {heal = {0.5, 0.7}, ticks = 5, interval = 1000, amp = 25, duration = 12000}

function onCastSpell(cid, var)
	local glyph = Geomancer.glyph(cid, "gem resonance")
	local gem = Geomancer.gem(cid)

	local ticks, heal = config.ticks, 1
	if(glyph and glyph.soothing) then
		ticks, heal = glyph.soothing.ticks, glyph.soothing.heal
	end

	local function tick(number)
		if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
			return
		end

		Geomancer.heal(cid, config.heal[1] * heal, config.heal[2] * heal)
		doSendMagicEffect(getCreaturePosition(cid), gem and gem.area or CONST_ME_MAGIC_BLUE)
		if(number < ticks) then
			addEvent(tick, config.interval, number + 1)
		end
	end

	tick(1)

	if(not gem) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Put a gem in the ammo slot to amplify its element.")
		return true
	end

	local amp, duration = config.amp, config.duration
	if(glyph and glyph.amplify) then
		amp, duration = glyph.amplify.amp, glyph.amplify.duration
	end

	Geomancer.statBuff(cid, {
		name = "Gem Resonance", subId = Geomancer.resonanceSubId, duration = duration, effect = gem.area,
		description = "+" .. amp .. "% " .. gem.name:lower() .. " damage.",
		params = {[gem.amp] = amp}
	})

	return true
end
