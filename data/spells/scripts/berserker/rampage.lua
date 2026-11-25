-- Rampage: 4 fast blows in 1.2s in 1 target within 2 SQM (power x 0.45 to 0.65 each). Costs 8% of the max health (healthpercent in spells.xml). Gives 1 Fury.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.blows = {count, damage}       more blows in the same 1.2s, each with `damage` times the normal damage
--   glyph.slow  = {percent, duration}   the target is slowed
local config = {damage = {0.45, 0.65}, blows = 4, interval = 400, range = 2}

function onCastSpell(cid, var)
	local target = Berserker.target(cid, 1)
	if(not target) then
		return false
	end

	local glyph = Berserker.glyph(cid, "rampage")
	local blows, multiplier = config.blows, 1
	if(glyph and glyph.blows) then
		blows, multiplier = glyph.blows.count, glyph.blows.damage
	end

	-- the whole combo always lasts the same: (4 - 1) x 400 ms
	local interval = math.floor(config.interval * (config.blows - 1) / (blows - 1))

	local function blow(left)
		if(not isCreature(cid) or not isCreature(target) or getCreatureHealth(target) <= 0) then
			return
		end

		if(getDistanceBetween(getCreaturePosition(cid), getCreaturePosition(target)) <= config.range) then
			Berserker.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_HITAREA, multiplier)
		end

		if(left > 1) then
			addEvent(blow, interval, left - 1)
		end
	end

	if(glyph and glyph.slow and Glyphs.paralyze(cid, target, glyph.slow.percent, glyph.slow.duration)) then
		doSendMagicEffect(getCreaturePosition(target), CONST_ME_STUN)
	end

	blow(blows)
	Berserker.fury(cid)
	return true
end
