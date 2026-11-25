-- Group Blessing: heals the caster and the party members around (radius 2) and gives them Holy Grace (category holy_grace).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.radius  = n                          radius `n` instead of 2
--   glyph.healing                              multiplier of the healing (applied here)
--   glyph.regen   = {percent, ticks, interval} everyone blessed recovers `percent`% of the maximum health every `interval` ms
local KEY = "healing/group blessing"

local config = {radius = 2, heal = {5, 5, 4.0, 5.5}, buff = "divine_grace"}

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local radius = (glyph and glyph.radius) or config.radius
	local pos = getCreaturePosition(cid)
	local allies = Cleric.allies(cid, pos, radius)
	local min, max = Cleric.values(cid, unpack(config.heal))
	local multiplier = Glyphs.multiplier(cid, KEY, "healing")
	Cleric.heal(cid, allies, math.floor(min * multiplier), math.floor(max * multiplier), CONST_ME_MAGIC_BLUE)
	for _, tid in ipairs(allies) do
		Cleric.addBuff(tid, config.buff)
		if(glyph and glyph.regen) then
			Glyphs.regen(tid, glyph.regen.percent, glyph.regen.ticks, glyph.regen.interval)
		end
	end

	doSendMagicEffect(pos, CONST_ME_HOLYAREA)
	Cleric.faith(cid)
	return true
end
