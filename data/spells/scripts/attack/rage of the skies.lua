-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.rain = {radius, drops, ...}   replaces the blast by a rain of lightning that falls around the caster (Glyphs.rain)
--   glyph.buff = {duration, critical, dodge, amp, haste}   after the blast the caster gets a buff (!buffs "Storm Rage")
local KEY = "attack/rage of the skies"
local BUFF_SUBID = 8801

-- setAttackFormula(5, 5, 5, 12): damage between level / 5 + magic * 5 and level / 5 + magic * 12
local function values(cid)
	local level, magic = getPlayerLevel(cid), getPlayerMagLevel(cid)
	return level / 5 + magic * 5, level / 5 + magic * 12
end

local boltArea = createCombatArea(AREA_CROSS1X1)

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_BIGCLOUDS)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 5, 12)
setCombatArea(combat, createCombatArea(AREA_CROSS6X6))

local function giveBuff(cid, config)
	addCreatureBuff(cid, {
		name = "Storm Rage", category = "Storm Rage", duration = config.duration,
		description = "+" .. config.critical .. "% critical chance, +" .. config.dodge .. "% dodge, +" .. config.amp
			.. "% energy damage and a lot more speed.",
		onActivate = function(id)
			local condition = createConditionObject(CONDITION_ATTRIBUTES, config.duration, true, BUFF_SUBID)
			setConditionParam(condition, CONDITION_PARAM_CRITICALCHANCE, config.critical)
			setConditionParam(condition, CONDITION_PARAM_DODGE, config.dodge)
			setConditionParam(condition, CONDITION_PARAM_ELEMENTAL_AMP_ENERGY, config.amp)
			doAddCondition(id, condition)

			-- the speed bonus is a normal haste (a longer haste that is already running is not replaced by the engine)
			local haste = createConditionObject(CONDITION_HASTE)
			setConditionParam(haste, CONDITION_PARAM_TICKS, config.duration)
			setConditionFormula(haste, config.haste, -56, config.haste, -56)
			doAddCondition(id, haste)
			doSendMagicEffect(getCreaturePosition(id), CONST_ME_ENERGYAREA)
		end,
		onRemove = function(id)
			if(isCreature(id)) then
				doRemoveCondition(id, CONDITION_ATTRIBUTES, BUFF_SUBID)
			end
		end
	})
end

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.rain) then
		Glyphs.rain(cid, KEY, values, glyph.rain, boltArea)
		return true
	end

	local ret = doCombat(cid, combat, var)
	if(ret and glyph and glyph.buff) then
		giveBuff(cid, glyph.buff)
	end

	return ret
end
