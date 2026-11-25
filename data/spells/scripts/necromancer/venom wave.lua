-- Venom Wave: wave of poison like Vis Hur (P x 1.0 to 1.7) that poisons everything it hits.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.poison = {ticks, mult}          longer poison / more damage per tick (Necro.poisonTarget)
--   glyph.push   = {chance}               every creature hit is pushed 1 sqm away from you (data/lib/404-push.lua)
local KEY = "necromancer/venom wave"

local hitsOfCast = {} -- caster -> creatures hit, filled by the target callback during doCombat (only while a glyph needs it)

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_POISONAREA)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_POISON)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, Necro.formula(1.0, 1.7))
setCombatArea(combat, createCombatArea(AREA_SQUAREWAVE5, AREADIAGONAL_SQUAREWAVE5))

-- poison over time (10s) on everything that is hit: damage per tick = level/15 + magic level/3
Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, function(cid, target)
	Necro.poisonTarget(cid, target, Glyphs.get(cid, KEY))
	if(hitsOfCast[cid] and Glyphs.isEnemy(cid, target)) then
		table.insert(hitsOfCast[cid], target)
	end

	return true
end)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph or not glyph.push) then
		return doCombat(cid, combat, var)
	end

	hitsOfCast[cid] = {}
	local ret = doCombat(cid, combat, var)
	local list = hitsOfCast[cid]
	hitsOfCast[cid] = nil

	if(ret and list and #list > 0) then
		Glyphs.pushAll(cid, list, glyph.push.chance)
	end

	return ret
end
