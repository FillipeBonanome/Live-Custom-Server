-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.summon = {duration, max, tiers, effect}   every enemy hit gets a creature of the forest next to it for `duration` ms; the kind
--                                                   depends on the level of the caster (the blast still happens)
--   glyph.buff   = {duration, amp, regen}           after the blast the caster gets +`amp`% earth damage and `regen`% of the maximum
--                                                   health back every second (buff "Primal Fury" in !buffs)
local KEY = "attack/wrath of nature"
local BUFF_SUBID = 8812

local hitsOfCast = {} -- caster -> positions of the enemies hit, filled by the target callback during doCombat

-- every creature the blast really hit (after the damage)
local function onTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and glyph.summon and hitsOfCast[cid] and Glyphs.isEnemy(cid, target)) then
		table.insert(hitsOfCast[cid], getCreaturePosition(target))
	end

	return true
end

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_PLANTATTACK)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 5, 10)
setCombatArea(combat, createCombatArea(AREA_CROSS6X6))
Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph) then
		return doCombat(cid, combat, var)
	end

	hitsOfCast[cid] = {}
	local ret = doCombat(cid, combat, var)
	local positions = hitsOfCast[cid]
	hitsOfCast[cid] = nil

	if(ret and glyph.summon and positions and #positions > 0) then
		Glyphs.summonAt(cid, positions, glyph.summon)
	end

	if(ret and glyph.buff) then
		local config = glyph.buff
		Glyphs.statBuff(cid, {
			name = "Primal Fury", duration = config.duration, subId = BUFF_SUBID, effect = CONST_ME_PLANTATTACK,
			description = "+" .. config.amp .. "% earth damage and " .. config.regen .. "% of your health back every second.",
			params = {[CONDITION_PARAM_ELEMENTAL_AMP_EARTH] = config.amp}
		})
		Glyphs.regen(cid, config.regen, math.floor(config.duration / 1000), 1000)
	end

	return ret
end
