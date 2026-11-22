-- Shield of Faith: for 6 seconds the target gets extra armor and defense; when the buff ends, the shield bursts and heals the
-- target. Works on an ally ("utamo lux" "name", or the current target); to protect yourself, use your own name.
local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)

local DURATION = 6000
local SUB_ID = 8313
local config = {heal = {5, 5, 3.0, 4.5}}

function onTargetCreature(cid, target)
	if(not isPlayer(target)) then
		return false
	end

	local min, max = Cleric.values(cid, unpack(config.heal))
	return addCreatureBuff(target, {
		name = "Shield of Faith", category = "Shield of Faith", duration = DURATION,
		description = "+8 armor and +6 defense; heals when it ends.",
		onActivate = function(id, stacks)
			local condition = createConditionObject(CONDITION_ATTRIBUTES, DURATION, true, SUB_ID)
			setConditionParam(condition, CONDITION_PARAM_ARMOR, 8)
			setConditionParam(condition, CONDITION_PARAM_DEFENSE, 6)
			doAddCondition(id, condition)
		end,
		onRemove = function(id)
			if(isCreature(id)) then
				doRemoveCondition(id, CONDITION_ATTRIBUTES, SUB_ID)
				doCreatureAddHealth(id, math.random(min, max))
				doSendMagicEffect(getCreaturePosition(id), CONST_ME_HOLYAREA)
			end
		end
	})
end
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
