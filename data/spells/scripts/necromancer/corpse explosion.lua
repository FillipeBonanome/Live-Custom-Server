-- Corpse Explosion (Lich): consumes a corpse (up to 4 SQM from you; with a target, the one closest to it) and blows it up in a 5x5 area:
-- death and poison, P x 2.5 to 4.0 in total (half of each). A corpse is also what you need to raise summons, so choose well.
local area = createCombatArea(AREA_CIRCLE2X2)
local config = {range = 4, damage = {1.25, 2.0}} -- each element: half of the total

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	local near = (target ~= 0 and isCreature(target)) and getCreaturePosition(target) or nil
	local pos, corpse = Necro.findCorpse(cid, config.range, near)
	if(not pos) then
		doPlayerSendCancel(cid, "You need a corpse near you.")
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
		return false
	end

	doRemoveItem(corpse)
	local min, max = Necro.values(cid, unpack(config.damage))
	doAreaCombatHealth(cid, COMBAT_DEATHDAMAGE, pos, area, -min, -max, CONST_ME_NONE)
	doAreaCombatHealth(cid, COMBAT_EARTHDAMAGE, pos, area, -min, -max, CONST_ME_NONE)

	VFX.Explosion(pos, CONST_ANI_DEATH, {radius = 2, points = 12, rings = 2, ringInterval = 120, effect = CONST_ME_MORTAREA, skipVoid = true})
	VFX.Explosion(pos, CONST_ANI_POISON, {radius = 3, points = 12, rings = 2, ringInterval = 120, delay = 150, effect = CONST_ME_POISONAREA, skipVoid = true})
	return true
end
