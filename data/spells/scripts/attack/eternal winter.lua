-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.rain   = {radius, drops, ...}   replaces the blast by a rain of ice that falls around the caster (Glyphs.rain)
--   glyph.ring   = {radius, sweep, turns} replaces the blast by a full disc of ice (no hole) that sweeps around the caster tile by tile
--                                         in `sweep` ms, `turns` times in a row (RingAttack, data/lib/069-ringattack.lua); one hit per tile per turn, it holds nobody
--   glyph.damage                          multiplier of the damage of EACH turn (applied by SpellBalance)
local KEY = "attack/eternal winter"

-- setAttackFormula(6, 9, 10, 12): damage between level / 6 + magic * 10 and level / 9 + magic * 12
local function values(cid)
	local level, magic = getPlayerLevel(cid), getPlayerMagLevel(cid)
	return level / 6 + magic * 10, level / 9 + magic * 12
end

local shardArea = createCombatArea(AREA_CROSS1X1)
local effects = {CONST_ME_ICEAREA, CONST_ME_ICETORNADO, CONST_ME_ICEATTACK}

-- one turn of the disc, around where the caster is when it starts. The damage is read again at each turn (glyph multiplier included)
local function sweep(cid, ring)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	local min, max = values(cid)
	RingAttack.execute(cid, {
		holeRadius = 0, ringThickness = ring.radius, sweepDuration = ring.sweep,
		elements = {{combatType = COMBAT_ICEDAMAGE, effect = CONST_ME_NONE}},
		damageMin = math.abs(SpellBalance.scale(cid, KEY, -min)), damageMax = math.abs(SpellBalance.scale(cid, KEY, -max)),
		onTile = function(position)
			doSendMagicEffect(position, effects[math.random(#effects)])
		end
	})
end

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 6, 9, 10, 12)
setCombatArea(combat, createCombatArea(AREA_CROSS5X5))

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.rain) then
		Glyphs.rain(cid, KEY, values, glyph.rain, shardArea)
		return true
	end

	if(glyph and glyph.ring) then
		for turn = 0, (glyph.ring.turns or 1) - 1 do
			addEvent(sweep, turn * glyph.ring.sweep, cid, glyph.ring)
		end

		return true
	end

	return doCombat(cid, combat, var)
end
