-- Celestial Hammer: heavy holy hit on one target that also paralyzes it for 2 seconds (stun).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.cleave = {share}      the 4 sqm next to the target take `share` of the damage
--   glyph.stun   = {duration}   the paralysis lasts `duration` ms instead of 2000
--   glyph.damage                multiplier of the damage (applied by SpellBalance)
local KEY = "attack/celestial hammer"

local function build(stunTime)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HOLYDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_HOLY)
	setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 3.2, 4.6, 10, 25)

	local stun = createConditionObject(CONDITION_PARALYZE)
	setConditionParam(stun, CONDITION_PARAM_TICKS, stunTime)
	setConditionFormula(stun, -0.9, 0, -0.9, 0)
	setCombatCondition(combat, stun)
	return combat
end

local combat = build(2000)
local combatLong = build(3000)
local single = createCombatArea(AREA_BEAM1)

local neighbours = {{x = 0, y = -1}, {x = 1, y = 0}, {x = 0, y = 1}, {x = -1, y = 0}}

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local target = (glyph and glyph.cleave) and Glyphs.aimed(var) or 0
	local center = target > 0 and getCreaturePosition(target) or nil

	if(not doCombat(cid, (glyph and glyph.stun) and combatLong or combat, var)) then
		return false
	end

	Cleric.faith(cid)
	if(center) then
		-- same formula as the hammer, `share` of it, on each of the 4 sqm around the target
		local min, max = Cleric.values(cid, 5, 5, 3.2, 4.6, 10, 25)
		local share = glyph.cleave.share
		for _, offset in ipairs(neighbours) do
			local pos = {x = center.x + offset.x, y = center.y + offset.y, z = center.z}
			if(getTileInfo(pos) and isSightClear(center, pos, false)) then
				doAreaCombatHealth(cid, COMBAT_HOLYDAMAGE, pos, single, SpellBalance.scale(cid, KEY, -min * share),
					SpellBalance.scale(cid, KEY, -max * share), CONST_ME_HOLYDAMAGE)
			end
		end
	end

	return true
end
