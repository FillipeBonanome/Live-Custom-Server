-- Glyphs (data/lib/403-glyphs.lua): glyph.damage is applied by SpellBalance, glyph.push = {chance = %} pushes the target
-- 1 sqm away from the caster (data/lib/404-push.lua) and glyph.area = "plus" hits the target and its 4 neighbours.
local KEY = "attack/flame strike"

local function build(area)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_FIREATTACK)
	setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FIRE)
	setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, -1, -10, -1, -20, 5, 5, 1.4, 2.1)
	if(area) then
		setCombatArea(combat, createCombatArea(area))
	end

	return combat
end

local combat = build()
local combatPlus = build({
	{0, 1, 0},
	{1, 3, 1},
	{0, 1, 0}
})

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local target = glyph and glyph.push and Glyphs.aimed(var) or 0

	local ret = doCombat(cid, (glyph and glyph.area == "plus") and combatPlus or combat, var)
	if(ret and target > 0 and isCreature(target) and getCreatureHealth(target) > 0) then
		Push.away(cid, target, glyph.push.chance)
	end

	return ret
end
