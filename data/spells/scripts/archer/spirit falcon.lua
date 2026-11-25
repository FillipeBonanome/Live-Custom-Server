-- Spirit Falcon (Ranger): a falcon fights with you for 15s and strikes every 1.5s (power x 0.5 to 0.8) your target, or the nearest enemy within
-- 6 tiles, with the element of the enchantment of the moment. It is not a summon (it does not use a summon slot and cannot be hurt).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.fast  = {interval}              the falcon strikes every `interval` ms
--   glyph.focus = {amp, critical}         +`amp`% damage and +`critical`% critical chance while the falcon lasts (buff "Falcon's Focus", subId 8716)
local config = {damage = {0.5, 0.8}, interval = 1500, range = 7, search = 6}
local tokens = {}

function onCastSpell(cid, var)
	local glyph = Archer.glyph(cid, "spirit falcon")
	local interval = (glyph and glyph.fast and glyph.fast.interval) or config.interval
	Archer.addBuff(cid, "falcon")
	if(glyph and glyph.focus) then
		Archer.empower(cid, "Falcon's Focus", 8716, glyph.focus.amp, glyph.focus.critical, Archer.buffs.falcon.duration)
	end

	local token = (tokens[cid] or 0) + 1
	tokens[cid] = token

	local function strike()
		if(not isCreature(cid) or tokens[cid] ~= token or not hasCreatureBuff(cid, "Spirit Falcon")) then
			return
		end

		local from = getCreaturePosition(cid)
		local victim = getCreatureTarget(cid)
		if(victim == 0 or not Archer.valid(cid, victim) or getDistanceBetween(from, getCreaturePosition(victim)) > config.range
			or not isSightClear(from, getCreaturePosition(victim), true)) then
			victim = nil
			local bestDistance
			for _, tid in ipairs(Archer.enemies(cid, from, config.search)) do
				local distance = getDistanceBetween(from, getCreaturePosition(tid))
				if(not bestDistance or distance < bestDistance) then
					victim, bestDistance = tid, distance
				end
			end
		end

		if(victim) then
			local element = Archer.element(cid)
			Archer.fx("archer_falcon", victim, {from = from, element = element})
			Archer.hit(cid, victim, config.damage[1], config.damage[2], element)
		end

		addEvent(strike, interval)
	end

	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
	addEvent(strike, 500)
	return true
end
