-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.push   = {chance, range}   every enemy within `range` sqm of the caster is pushed 1 sqm away (data/lib/404-push.lua)
--   glyph.longer = {duration}        the speed lasts `duration` ms instead of 5000
local KEY = "support/charge"

local function build(duration)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
	setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)

	local condition = createConditionObject(CONDITION_HASTE)
	setConditionParam(condition, CONDITION_PARAM_TICKS, duration)
	setConditionFormula(condition, 0.9, -81, 0.9, -81)
	setCombatCondition(combat, condition)
	return combat
end

local combat = build(5000)
local spell = Glyphs.spellByKey(KEY)
local longerConfig = spell and spell.glyphs.B and spell.glyphs.B.longer or {}
local combatLonger = build(longerConfig.duration or 8000)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph) then
		return doCombat(cid, combat, var)
	end

	-- the enemies are pushed first, so the way is clear when the speed starts
	if(glyph.push) then
		local from, range, list = getCreaturePosition(cid), glyph.push.range, {}
		for _, tid in ipairs(getSpectators(from, range, range, false) or {}) do
			if(tid ~= cid and isCreature(tid) and Glyphs.isEnemy(cid, tid) and getDistanceBetween(from, getCreaturePosition(tid)) <= range) then
				table.insert(list, tid)
			end
		end

		Glyphs.pushAll(cid, list, glyph.push.chance)
	end

	return doCombat(cid, glyph.longer and combatLonger or combat, var)
end
