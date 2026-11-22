-- Venom Orb: ball of poison on the target, 3x3 area (P x 0.8 to 1.4) that poisons everything it hits. The area itself draws no
-- effect: the animation is made with the VFX library (data/lib/360-vfx.lua): only an Explosion, rings of poison shots leaving the target.
local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_NONE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_POISON)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, Necro.formula(0.8, 1.4))
setCombatArea(combat, createCombatArea(AREA_CIRCLE3X3))

-- poison over time (10s) on everything that is hit: damage per tick = level/15 + magic level/3
function onTargetCreature(cid, target)
	doTargetCombatCondition(cid, target, Necro.poisonCondition(cid), CONST_ME_NONE)
	return true
end
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")

local function animate(pos)
	VFX.Explosion(pos, CONST_ANI_POISON, {radius = 3, points = 12, rings = 2, ringInterval = 120, effect = CONST_ME_POISONAREA, skipVoid = true})
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
