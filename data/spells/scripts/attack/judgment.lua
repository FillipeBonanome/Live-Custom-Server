-- Judgment: marks the target; after 1.5 seconds the sentence falls (big holy hit) and heals party members around it.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.delay = ms   the sentence falls after `delay` ms instead of 1500
--   glyph.mass  = {radius, share}   every other enemy within `radius` sqm of the target takes `share` of the damage too
local KEY = "attack/judgment"

local config = {
	delay = 1500, radius = 3,
	damage = {5, 5, 4.0, 5.5, 20, 40},
	heal = {5, 5, 1.0, 1.6}
}

local function sentence(cid, target, mass)
	if(not isCreature(cid) or not isCreature(target) or getCreatureHealth(target) <= 0) then
		return
	end

	local pos = getCreaturePosition(target)
	local min, max = Cleric.values(cid, unpack(config.damage))
	doTargetCombatHealth(cid, target, COMBAT_HOLYDAMAGE, -min, -max, CONST_ME_HOLYDAMAGE)
	doSendMagicEffect(pos, CONST_ME_HOLYAREA)

	if(mass) then
		for _, tid in ipairs(getSpectators(pos, mass.radius, mass.radius, false) or {}) do
			if(tid ~= target and isCreature(tid) and Glyphs.isEnemy(cid, tid) and getDistanceBetween(pos, getCreaturePosition(tid)) <= mass.radius) then
				doTargetCombatHealth(cid, tid, COMBAT_HOLYDAMAGE, -math.floor(min * mass.share), -math.floor(max * mass.share), CONST_ME_HOLYDAMAGE)
			end
		end
	end

	local hmin, hmax = Cleric.values(cid, unpack(config.heal))
	Cleric.heal(cid, Cleric.allies(cid, pos, config.radius), hmin, hmax, CONST_ME_MAGIC_BLUE)
end

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
		return false
	end

	local glyph = Glyphs.get(cid, KEY)
	doSendMagicEffect(getCreaturePosition(target), CONST_ME_YELLOW_RINGS)
	addEvent(sentence, (glyph and glyph.delay) or config.delay, cid, target, glyph and glyph.mass or nil)
	Cleric.faith(cid)
	return true
end
