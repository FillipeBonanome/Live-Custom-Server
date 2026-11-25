-- Rain of Light: zone of light on the target for 3 seconds (1 pulse per second): damages enemies and heals party members.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.longer = {ticks, share}   `ticks` pulses, each one with `share` of the normal damage and healing
--   glyph.mana   = {percent}        every player inside the rain recovers `percent`% of the maximum mana on each pulse
local KEY = "attack/rain of light"

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

	local glyph = Glyphs.get(cid, KEY)
	local ticks, share = config.ticks, 1
	if(glyph and glyph.longer) then
		ticks, share = glyph.longer.ticks, glyph.longer.share
	end

	local dmin, dmax = Cleric.values(cid, unpack(config.damage))
	local hmin, hmax = Cleric.values(cid, unpack(config.heal))
	local extra
	if(glyph and glyph.mana) then
		local percent = glyph.mana.percent
		extra = function(caster, allies)
			for _, tid in ipairs(allies) do
				doCreatureAddMana(tid, math.max(1, math.floor(getCreatureMaxMana(tid) * percent / 100)))
				doSendMagicEffect(getCreaturePosition(tid), CONST_ME_MAGIC_BLUE)
			end
		end
	end

	Cleric.zone{
		cid = cid, pos = getCreaturePosition(target), area = area, radius = config.radius,
		damage = {math.floor(dmin * share), math.floor(dmax * share)}, heal = {math.floor(hmin * share), math.floor(hmax * share)},
		effect = CONST_ME_HOLYAREA, ticks = ticks, interval = config.interval, extra = extra
	}

	Cleric.faith(cid)
	return true
end
