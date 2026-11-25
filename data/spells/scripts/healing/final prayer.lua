-- Final Prayer: long cooldown. For 6 seconds (a pulse every 2s) it heals the caster and the party (radius 3) and damages
-- enemies around the caster. The area follows the caster.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.ticks     = n                      `n` pulses instead of 3
--   glyph.salvation = {threshold, bonus}     on every pulse, players below `threshold`% of health are healed `bonus`% more
local KEY = "healing/final prayer"

local area = createCombatArea(AREA_CIRCLE3X3)

local config = {
	ticks = 3, interval = 2000, radius = 3,
	damage = {5, 5, 2.0, 3.2},
	heal = {5, 5, 4.5, 6.0}
}

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local dmin, dmax = Cleric.values(cid, unpack(config.damage))
	local hmin, hmax = Cleric.values(cid, unpack(config.heal))

	local extra
	if(glyph and glyph.salvation) then
		local threshold, bonus = glyph.salvation.threshold, glyph.salvation.bonus
		extra = function(caster, allies)
			local weak = {}
			for _, tid in ipairs(allies) do
				if(getCreatureHealth(tid) * 100 < getCreatureMaxHealth(tid) * threshold) then
					table.insert(weak, tid)
				end
			end

			Cleric.heal(caster, weak, math.floor(hmin * bonus / 100), math.floor(hmax * bonus / 100), CONST_ME_MAGIC_GREEN)
		end
	end

	Cleric.zone{
		cid = cid, follow = true, area = area, radius = config.radius,
		damage = {dmin, dmax}, heal = {hmin, hmax}, effect = CONST_ME_HOLYAREA,
		ticks = (glyph and glyph.ticks) or config.ticks, interval = config.interval, extra = extra
	}

	Cleric.faith(cid)
	return true
end
