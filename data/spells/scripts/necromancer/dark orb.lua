-- Dark Orb: ball of death on the target, 3x3 area (P x 1.0 to 1.8). The area itself draws no effect: the animation is made with the
-- VFX library (data/lib/360-vfx.lua): only an Explosion, rings of death shots leaving the target.
local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_NONE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_DEATH)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, Necro.formula(1.0, 1.8))
setCombatArea(combat, createCombatArea(AREA_CIRCLE3X3))

local function animate(pos)
	VFX.Explosion(pos, CONST_ANI_DEATH, {radius = 3, points = 12, rings = 2, ringInterval = 120, effect = CONST_ME_MORTAREA, skipVoid = true})
end

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	local pos = (target ~= 0 and isCreature(target)) and getCreaturePosition(target) or nil
	if(not doCombat(cid, combat, var)) then
		return false
	end

	if(pos) then
		animate(pos)
	end

	return true
end
