-- Stone Strike: the basic attack of the Geomancer. A stone hits one target (range 3), power x 0.9 to 1.3.
-- With a gem in the ammo slot half of the damage becomes the element of the gem (see data/lib/378-geomancer.lua).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.crush   = {damage}               single target damage: the strike deals `damage` times more
--   glyph.cracked = {percent, duration}    debuff: the monster loses `percent` resistance to every element for `duration` ms (before the hit)
local config = {damage = {0.9, 1.3}, range = 3}

function onCastSpell(cid, var)
	local target = Geomancer.target(cid, config.range)
	if(not target) then
		return false
	end

	local glyph = Geomancer.glyph(cid, "stone strike")
	if(glyph and glyph.cracked) then
		Geomancer.weaken(target, glyph.cracked.percent, glyph.cracked.duration)
	end

	local to = getCreaturePosition(target)
	doSendDistanceShoot(getCreaturePosition(cid), to, CONST_ANI_SMALLSTONE)
	doSendMagicEffect(to, CONST_ME_STONES)
	Geomancer.hit(cid, target, config.damage[1], config.damage[2], {multiplier = glyph and glyph.crush and glyph.crush.damage or 1})
	return true
end
