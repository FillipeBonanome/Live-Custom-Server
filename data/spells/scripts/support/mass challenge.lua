-- Mass Challenge (exeta mas res): challenges every monster within 3 SQM (AREA_CIRCLE3X3, bigger than the Challenge) and keeps them at range 1 for 12s
-- (doMonsterChangeRange: ranged monsters have to come to melee and their ranged attacks are capped to 1 SQM).
-- Summons of players are not affected.
local config = {range = 1, duration = 12000}

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_RED)
setCombatArea(combat, createCombatArea(AREA_CIRCLE3X3))

function onTargetCreature(cid, target)
	if(isMonster(target) and not getCreatureMaster(target)) then
		doChallengeCreature(cid, target)
		doMonsterChangeRange(target, config.range, config.duration)
	end

	return true
end
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
