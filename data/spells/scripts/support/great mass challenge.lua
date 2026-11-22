-- Great Mass Challenge (exeta gran mas res): challenges every monster within 5 SQM (disc with 5 SQM of radius, bigger than the Mass Challenge)
-- and keeps them at range 1 for 20s (doMonsterChangeRange). Summons of players are not affected.
local config = {range = 1, duration = 20000, radius = 5}

local rows = {}
for y = -config.radius, config.radius do
	local row = {}
	for x = -config.radius, config.radius do
		if(x == 0 and y == 0) then
			table.insert(row, 3)
		elseif(x * x + y * y <= config.radius * config.radius + config.radius) then
			table.insert(row, 1)
		else
			table.insert(row, 0)
		end
	end

	table.insert(rows, row)
end

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_RED)
setCombatArea(combat, createCombatArea(rows))

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
