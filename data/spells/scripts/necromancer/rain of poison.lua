-- Rain of Poison: rain of poison falling on the target (animation: VFX.Rain, data/lib/360-vfx.lua) over a 5x5 zone for 5s. The damage
-- is a fixed 5x5 area (1 pulse per second, P x 0.5 to 0.9 each) and does not draw any effect of its own. The Necromancer also gets the buff
-- "Venom Corrosion" (+25% poison penetration for 10s, the existing penetration attribute): the enemies resist less poison damage,
-- including the damage of his summons.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.ticks = n                       n pulses (n seconds) instead of 5
--   glyph.buff  = "key", glyph.party = r  another version of the buff in Necro.buffs, also given to the party within r sqm
local KEY = "necromancer/rain of poison"

local area = createCombatArea(AREA_CIRCLE2X2)
local config = {ticks = 5, interval = 1000, damage = {0.5, 0.9}, drops = 60, radius = 2,
	offset = -4, height = 4 -- the drops start 4 tiles to the left and 4 up, so they always fall diagonally
}

local function pulse(cid, pos, left)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	local min, max = Necro.values(cid, unpack(config.damage))
	doAreaCombatHealth(cid, COMBAT_EARTHDAMAGE, pos, area, -min, -max, CONST_ME_NONE)
	if(left > 1) then
		addEvent(pulse, config.interval, cid, pos, left - 1)
	end
end

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
		return false
	end

	local glyph = Glyphs.get(cid, KEY)
	local ticks = glyph and glyph.ticks or config.ticks
	local buff = glyph and glyph.buff or "venom_corrosion"
	local pos = getCreaturePosition(target)

	if(glyph and glyph.party) then
		for _, tid in ipairs(Glyphs.allies(cid, glyph.party)) do
			Necro.addBuff(tid, buff)
		end
	else
		Necro.addBuff(cid, buff)
	end

	VFX.Rain(pos, CONST_ANI_POISON, {
		radius = config.radius, duration = ticks * config.interval, drops = math.floor(config.drops * ticks / config.ticks),
		offsetX = config.offset, height = config.height, effect = CONST_ME_HITBYPOISON, skipVoid = true
	})
	pulse(cid, pos, ticks)
	return true
end
