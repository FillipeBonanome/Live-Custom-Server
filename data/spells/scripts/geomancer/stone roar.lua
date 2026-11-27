-- Stone Roar: a roar that shakes the ground. Every enemy within 4 tiles takes a little damage (power x 0.3 to 0.5) and every monster is forced
-- to attack you (challenge). Players are not challenged.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.shatter = {percent, duration}   debuff: the monsters lose `percent` resistance to every element for `duration` ms (before the hit)
--   glyph.feed    = {percent, max}        sustain: you recover `percent`% of your maximum health for each monster challenged (at most `max` monsters)
local config = {damage = {0.3, 0.5}, radius = 4}

function onCastSpell(cid, var)
	local glyph = Geomancer.glyph(cid, "stone roar")
	local enemies = Attacks.around(cid, getCreaturePosition(cid), config.radius)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_GROUNDSHAKER)

	local challenged = 0
	for _, tid in ipairs(enemies) do
		if(isMonster(tid)) then
			doChallengeCreature(cid, tid)
			challenged = challenged + 1
			if(glyph and glyph.shatter) then
				Geomancer.weaken(tid, glyph.shatter.percent, glyph.shatter.duration)
			end
		end

		Geomancer.hit(cid, tid, config.damage[1], config.damage[2], {effect = CONST_ME_BLOCKHIT})
	end

	if(glyph and glyph.feed and challenged > 0) then
		local percent = glyph.feed.percent * math.min(challenged, glyph.feed.max)
		doCreatureAddHealth(cid, math.max(1, math.floor(getCreatureMaxHealth(cid) * percent / 100)))
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
	end

	return true
end
