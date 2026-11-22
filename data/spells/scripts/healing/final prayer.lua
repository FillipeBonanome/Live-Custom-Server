-- Final Prayer: long cooldown. For 6 seconds (a pulse every 2s) it heals the caster and the party (radius 3) and damages
-- enemies around the caster. The area follows the caster.
local area = createCombatArea(AREA_CIRCLE3X3)

local config = {
	ticks = 3, interval = 2000, radius = 3,
	damage = {5, 5, 2.0, 3.2},
	heal = {5, 5, 4.5, 6.0}
}

function onCastSpell(cid, var)
	local dmin, dmax = Cleric.values(cid, unpack(config.damage))
	local hmin, hmax = Cleric.values(cid, unpack(config.heal))
	Cleric.zone{
		cid = cid, follow = true, area = area, radius = config.radius,
		damage = {dmin, dmax}, heal = {hmin, hmax}, effect = CONST_ME_HOLYAREA,
		ticks = config.ticks, interval = config.interval
	}

	return true
end
