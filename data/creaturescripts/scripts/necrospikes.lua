-- Spiked Bones (glyph B of Bone Armor): while the buff lasts, a monster that hits a summon of the necromancer takes part of the damage back
-- (glyph.spikes = % of the damage, physical, dealt in the name of the owner). The event is registered on the summons by Bone Armor
-- (Necro.buffs.bone_armor) and by Necro.applyGlyph (summons raised during the buff).
local busy = false

function onStatsChange(cid, attacker, type, combat, value, origin)
	if(busy or type ~= STATSCHANGE_HEALTHLOSS or not attacker or attacker == 0 or not isCreature(attacker)
		or not isMonster(attacker) or getCreatureMaster(attacker)) then
		return true
	end

	local master = getCreatureMaster(cid)
	if(not master or master == cid or not isPlayer(master) or not hasCreatureBuff(master, "Bone Armor")) then
		return true
	end

	local armor = Necro.glyph(master, "bone armor")
	if(not armor or not armor.spikes) then
		return true
	end

	local back = math.ceil(value * armor.spikes / 100)
	if(back > 0) then
		busy = true -- the damage goes through this event again
		doTargetCombatHealth(master, attacker, COMBAT_PHYSICALDAMAGE, -back, -back, CONST_ME_HITAREA)
		busy = false
	end

	return true
end
