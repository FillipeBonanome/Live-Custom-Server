-- Shield of Faith: for 6 seconds the target gets extra armor and defense; when it ends, the shield bursts and heals the
-- target. Works on an ally ("utamo lux" "name", or the current target); to protect yourself, use your own name.
local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)

local config = {heal = {5, 5, 3.0, 4.5}}

function onTargetCreature(cid, target)
	if(not isPlayer(target)) then
		return false
	end

	local added = Buffs.add(target, "faith_shield")
	-- set after Buffs.add: renewing the shield removes the old one, which clears the stored heal
	Cleric.shieldHeal[target] = {Cleric.values(cid, unpack(config.heal))}
	return added
end
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
