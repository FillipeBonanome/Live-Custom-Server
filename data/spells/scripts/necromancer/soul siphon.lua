-- Soul Siphon (Lich): death damage in 1 target (P x 2.0 to 3.0) that heals you for 40% of the damage dealt and your summons (not the Dragon
-- Skeleton) for 10%. If the target dies from it (and it is a monster) you absorb 1 soul.
-- Glyphs (data/lib/403-glyphs.lua): glyph.selfHeal / glyph.summonHeal replace the 0.40 / 0.10; glyph.execute = {below, damage} the hit deals
-- `damage` times more against a target with `below`% of its health or less; glyph.soul = soul given for a kill.
local KEY = "necromancer/soul siphon"
local config = {damage = {2.0, 3.0}, selfHeal = 0.40, summonHeal = 0.10, soul = 1}

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
		return false
	end

	local glyph = Glyphs.get(cid, KEY) or {}
	local selfHeal, summonHeal, soul = glyph.selfHeal or config.selfHeal, glyph.summonHeal or config.summonHeal, glyph.soul or config.soul

	local from, to = getCreaturePosition(cid), getCreaturePosition(target)
	local isMonsterTarget = isMonster(target) and not getCreatureMaster(target)
	local before = getCreatureHealth(target)
	local min, max = Necro.values(cid, unpack(config.damage))
	if(glyph.execute and before * 100 <= getCreatureMaxHealth(target) * glyph.execute.below) then
		min, max = math.floor(min * glyph.execute.damage), math.floor(max * glyph.execute.damage)
	end

	doSendDistanceShoot(from, to, CONST_ANI_DEATH)
	doTargetCombatHealth(cid, target, COMBAT_DEATHDAMAGE, -min, -max, CONST_ME_MORTAREA)

	local dead = not isCreature(target) or getCreatureHealth(target) <= 0
	local dealt = math.max(0, before - (dead and 0 or getCreatureHealth(target)))
	if(dealt > 0) then
		doSendDistanceShoot(to, from, CONST_ANI_DEATH)
		doCreatureAddHealth(cid, math.floor(dealt * selfHeal))
		doSendMagicEffect(from, CONST_ME_MAGIC_GREEN)

		local heal = math.floor(dealt * summonHeal)
		if(heal > 0) then
			for _, sid in ipairs(Necro.summons(cid, true, true)) do
				doCreatureAddHealth(sid, heal)
				doSendMagicEffect(getCreaturePosition(sid), CONST_ME_MAGIC_GREEN)
			end
		end
	end

	if(dead and isMonsterTarget) then
		doPlayerAddSoul(cid, soul)
		doSendMagicEffect(from, CONST_ME_MORTAREA)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You absorbed " .. soul .. " soul.")
	end

	return true
end
