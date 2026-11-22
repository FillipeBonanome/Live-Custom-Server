-- Soul Siphon (Lich): death damage in 1 target (P x 2.0 to 3.0) that heals you for 40% of the damage dealt and your summons (not the Dragon
-- Skeleton) for 10%. If the target dies from it (and it is a monster) you absorb 1 soul.
local config = {damage = {2.0, 3.0}, selfHeal = 0.40, summonHeal = 0.10, soul = 1}

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
		return false
	end

	local from, to = getCreaturePosition(cid), getCreaturePosition(target)
	local isMonsterTarget = isMonster(target) and not getCreatureMaster(target)
	local before = getCreatureHealth(target)
	local min, max = Necro.values(cid, unpack(config.damage))

	doSendDistanceShoot(from, to, CONST_ANI_DEATH)
	doTargetCombatHealth(cid, target, COMBAT_DEATHDAMAGE, -min, -max, CONST_ME_MORTAREA)

	local dead = not isCreature(target) or getCreatureHealth(target) <= 0
	local dealt = math.max(0, before - (dead and 0 or getCreatureHealth(target)))
	if(dealt > 0) then
		doSendDistanceShoot(to, from, CONST_ANI_DEATH)
		doCreatureAddHealth(cid, math.floor(dealt * config.selfHeal))
		doSendMagicEffect(from, CONST_ME_MAGIC_GREEN)

		local heal = math.floor(dealt * config.summonHeal)
		if(heal > 0) then
			for _, sid in ipairs(Necro.summons(cid, true, true)) do
				doCreatureAddHealth(sid, heal)
				doSendMagicEffect(getCreaturePosition(sid), CONST_ME_MAGIC_GREEN)
			end
		end
	end

	if(dead and isMonsterTarget) then
		doPlayerAddSoul(cid, config.soul)
		doSendMagicEffect(from, CONST_ME_MORTAREA)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You absorbed " .. config.soul .. " soul.")
	end

	return true
end
