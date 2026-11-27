-- Gem Resonance: the gem in the ammo slot hums and mends you, 5 heals of level/5 + power x 0.5 to 0.7, one per second, and amplifies the
-- element of the gem: +25% damage of that element for 12s (buff Gem Resonance in !buffs). Without a gem you only get the healing.
local config = {heal = {0.5, 0.7}, ticks = 5, interval = 1000, amp = 25, duration = 12000}

function onCastSpell(cid, var)
	local gem = Geomancer.gem(cid)

	local function tick(number)
		if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
			return
		end

		Geomancer.heal(cid, config.heal[1], config.heal[2])
		doSendMagicEffect(getCreaturePosition(cid), gem and gem.area or CONST_ME_MAGIC_BLUE)
		if(number < config.ticks) then
			addEvent(tick, config.interval, number + 1)
		end
	end

	tick(1)

	if(not gem) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Put a gem in the ammo slot to amplify its element.")
		return true
	end

	Geomancer.statBuff(cid, {
		name = "Gem Resonance", subId = Geomancer.resonanceSubId, duration = config.duration, effect = gem.area,
		description = "+" .. config.amp .. "% " .. gem.name:lower() .. " damage.",
		params = {[gem.amp] = config.amp}
	})

	return true
end
