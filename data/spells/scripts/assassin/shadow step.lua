-- Shadow Step: teleports behind the target (range 5), looks at it (and turns it away) and gets +25% dodge for 1.5s,
-- which lets Backstab work for 3s. Gives 1 Momentum.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.longDodge = true                  the dodge buff is +40% for 3s (buff shadow_dodge_long)
--   glyph.paralyze  = {percent, duration}   slows the target after the teleport
local function sign(n)
	return n > 0 and 1 or (n < 0 and -1 or 0)
end

function onCastSpell(cid, var)
	local target = Assassin.target(cid, 5)
	if(not target) then
		return false
	end

	local from, to = getCreaturePosition(cid), getCreaturePosition(target)
	if(not isSightClear(from, to, true)) then
		doPlayerSendDefaultCancel(cid, RETURNVALUE_CANNOTTHROW)
		doSendMagicEffect(from, CONST_ME_POFF)
		return false
	end

	local behind = {x = to.x + sign(to.x - from.x), y = to.y + sign(to.y - from.y), z = to.z}
	local dest = getClosestFreeTile(cid, behind, false, true)
	if(not dest or getDistanceBetween(dest, to) > 1) then
		dest = getClosestFreeTile(cid, to, false, true)
	end

	if(not dest or getDistanceBetween(dest, to) > 1) then
		doPlayerSendCancel(cid, "There is no room behind your target.")
		doSendMagicEffect(from, CONST_ME_POFF)
		return false
	end

	Assassin.fx("assassin_step", dest, {from = from})
	doTeleportThing(cid, dest)
	local facing = getDirectionTo(dest, to)
	doCreatureSetLookDirection(cid, facing)
	doCreatureSetLookDirection(target, facing)
	Assassin.stepped[cid] = {target = target, time = os.time()}
	local glyph = Assassin.glyph(cid, "shadow step")
	Assassin.addBuff(cid, glyph and glyph.longDodge and "shadow_dodge_long" or "shadow_dodge")
	if(glyph and glyph.paralyze) then
		Glyphs.paralyze(cid, target, glyph.paralyze.percent, glyph.paralyze.duration)
	end

	Assassin.momentum(cid)
	return true
end
