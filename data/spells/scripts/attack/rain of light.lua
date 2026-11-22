-- Rain of Light: zone of light on the target for 3 seconds (1 pulse per second): damages enemies and heals party members.
local area = createCombatArea(AREA_CIRCLE2X2)

local config = {
	ticks = 3, interval = 1000, radius = 2,
	damage = {5, 5, 1.0, 1.6}, -- level divisor (min, max), magic level multiplier (min, max)
	heal = {5, 5, 0.9, 1.4}
}

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
		return false
	end

	local dmin, dmax = Cleric.values(cid, unpack(config.damage))
	local hmin, hmax = Cleric.values(cid, unpack(config.heal))
	Cleric.zone{
		cid = cid, pos = getCreaturePosition(target), area = area, radius = config.radius,
		damage = {dmin, dmax}, heal = {hmin, hmax}, effect = CONST_ME_HOLYAREA,
		ticks = config.ticks, interval = config.interval
	}

	Cleric.faith(cid)
	return true
end
