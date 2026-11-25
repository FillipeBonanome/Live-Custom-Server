-- Purify: removes poison, fire, energy, cursed and paralysis from the caster and the party around (radius 2)
-- and deals a little holy damage to enemies in the same area.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.radius  = n      radius `n` instead of 2
--   glyph.cleanse = true   removes every harmful condition (also dazzle, freezing, drowning...)
--   glyph.damage           multiplier of the damage (applied here)
--   glyph.immune  = {duration}   the players cleaned cannot get those conditions for `duration` ms
local KEY = "healing/purify"

local areas = {[2] = createCombatArea(AREA_CIRCLE2X2), [3] = createCombatArea(AREA_CIRCLE3X3)}
local conditions = {CONDITION_POISON, CONDITION_FIRE, CONDITION_ENERGY, CONDITION_CURSED, CONDITION_PARALYZE}

-- the conditions are removed every 400 ms (same trick as Iron Will)
local function immuneTick(tid, left)
	if(left <= 0 or not isCreature(tid)) then
		return
	end

	for _, condition in ipairs(conditions) do
		if(hasCondition(tid, condition)) then
			doRemoveCondition(tid, condition)
		end
	end

	addEvent(immuneTick, 400, tid, left - 1)
end

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local radius = (glyph and glyph.radius) or 2
	local pos = getCreaturePosition(cid)
	for _, tid in ipairs(Cleric.allies(cid, pos, radius)) do
		for _, condition in ipairs(conditions) do
			if(hasCondition(tid, condition)) then
				doRemoveCondition(tid, condition)
			end
		end

		if(glyph and glyph.cleanse) then
			Glyphs.cleanse(tid)
		end

		if(glyph and glyph.immune) then
			immuneTick(tid, math.ceil(glyph.immune.duration / 400))
		end

		doSendMagicEffect(getCreaturePosition(tid), CONST_ME_MAGIC_GREEN)
	end

	local min, max = Cleric.values(cid, 5, 5, 0.8, 1.3)
	local multiplier = Glyphs.multiplier(cid, KEY, "damage")
	doAreaCombatHealth(cid, COMBAT_HOLYDAMAGE, pos, areas[radius], -math.floor(min * multiplier), -math.floor(max * multiplier), CONST_ME_HOLYAREA)
	Cleric.faith(cid)
	return true
end
