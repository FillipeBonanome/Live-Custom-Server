-- Pillar of Light: area attack around the ENEMY (replaces the old area runes). Hits a 3x3 area around the target
-- and leaves a circle of light for 4 seconds (pulse every second): enemies inside take damage, party members heal.
-- If the central target dies while the circle is active, the pillar explodes once (radius 2, 50% of the first hit).
local area = createCombatArea(AREA_SQUARE1X1)
local explosionArea = createCombatArea(AREA_CIRCLE2X2)

local config = {
	pulses = 4, interval = 1000, radius = 1,
	first = {5, 5, 2.6, 4.0, 30, 60}, -- level divisor (min, max), magic level multiplier (min, max), constants (min, max)
	pulse = {5, 5, 0.5, 0.8},
	heal = {5, 5, 0.6, 1.0}
}

local function pulse(cid, target, pos, left, explodeMax)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	if(not isCreature(target) or getCreatureHealth(target) <= 0) then
		-- center target died: explode once and end the circle
		doAreaCombatHealth(cid, COMBAT_HOLYDAMAGE, pos, explosionArea, -math.floor(explodeMax / 2), -explodeMax, CONST_ME_HOLYAREA)
		return
	end

	local min, max = Cleric.values(cid, unpack(config.pulse))
	doAreaCombatHealth(cid, COMBAT_HOLYDAMAGE, pos, area, -min, -max, CONST_ME_HOLYAREA)
	local hmin, hmax = Cleric.values(cid, unpack(config.heal))
	Cleric.heal(cid, Cleric.allies(cid, pos, config.radius), hmin, hmax, CONST_ME_MAGIC_BLUE)

	if(left > 1) then
		addEvent(pulse, config.interval, cid, target, pos, left - 1, explodeMax)
	end
end

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
		return false
	end

	local pos = getCreaturePosition(target)
	local min, max = Cleric.values(cid, unpack(config.first))
	doAreaCombatHealth(cid, COMBAT_HOLYDAMAGE, pos, area, -min, -max, CONST_ME_HOLYAREA)
	doSendMagicEffect(pos, CONST_ME_FIREWORK_YELLOW)

	-- the circle stays where the pillar fell; the explosion value is half of the first hit's max
	addEvent(pulse, config.interval, cid, target, pos, config.pulses, math.floor(max / 2))
	Cleric.faith(cid)
	return true
end
