-- Backstab: heavy cut (power x 2.6 to 3.6) that only works when you are behind the target (it must be looking away from you).
-- Shadow Step puts you behind the target and makes it look away for about 3s, so the two spells combo. Gives 1 Momentum.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.buff = true   after the hit: +15% critical chance for 6s (buff assassins_prey)
--   glyph.side = true   the sides of the target count too, only its front is refused
local config = {damage = {2.6, 3.6}}

function onCastSpell(cid, var)
	local target = Assassin.target(cid, 1)
	if(not target) then
		return false
	end

	local glyph = Assassin.glyph(cid, "backstab")
	if(not Assassin.isBehind(cid, target, glyph and glyph.side)) then
		doPlayerSendCancel(cid, glyph and glyph.side and "You cannot be in front of your target." or "You must be behind your target.")
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
		return false
	end

	Assassin.hit(cid, target, config.damage[1], config.damage[2], COMBAT_PHYSICALDAMAGE, CONST_ME_DRAWBLOOD)
	if(glyph and glyph.buff) then
		Assassin.addBuff(cid, "assassins_prey")
	end

	Assassin.momentum(cid)
	return true
end
