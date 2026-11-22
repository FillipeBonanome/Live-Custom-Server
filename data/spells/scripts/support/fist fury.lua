-- Fist Fury: +20 fist fighting for 10 seconds (buff with addCreatureBuff, see data/lib/370-buffs.lua).
local DURATION = 10000
local SUB_ID = 8306

function onCastSpell(cid, var)
	return addCreatureBuff(cid, {
		name = "Fist Fury", category = "Fist Fury", duration = DURATION, description = "+20 fist fighting.",
		onActivate = function(id, stacks)
			local condition = createConditionObject(CONDITION_ATTRIBUTES, DURATION, true, SUB_ID)
			setConditionParam(condition, CONDITION_PARAM_SKILL_FIST, 20)
			doAddCondition(id, condition)
			doPlayerSendTextMessage(id, MESSAGE_STATUS_CONSOLE_BLUE, "Fist Fury activated: +20 fist fighting for 10 seconds.")
		end,
		onRemove = function(id)
			if(isCreature(id)) then
				doRemoveCondition(id, CONDITION_ATTRIBUTES, SUB_ID)
				doSendMagicEffect(getCreaturePosition(id), CONST_ME_POFF)
				doPlayerSendTextMessage(id, MESSAGE_STATUS_CONSOLE_ORANGE, "Fist Fury has ended.")
			end
		end
	})
end
