-- Ghoul: Taunt, makes the monsters around it (1 SQM) attack the ghoul (same effect as the Challenge spell).
local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_RED)
setCombatArea(combat, createCombatArea(AREA_SQUARE1X1))

function onTargetCreature(cid, target)
	-- only real monsters (never players or summons of players)
	if(isMonster(target) and not getCreatureMaster(target)) then
		doChallengeCreature(cid, target)
	end

	return true
end
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
