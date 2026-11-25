-- Bone Abomination (Lich): when it dies it explodes in death (5x5, P x 2.0 to 3.5, Frenzy included). The damage is dealt in the name of
-- the owner. It does not explode when it is consumed (Dragon Skeleton, Soul Sacrifice, Bone Shell) because that is not a death.
-- Glyph of the owner (Summon Bone Abomination B, data/lib/403-glyphs.lua): glyph.blast = {damage} bigger explosion (7x7) with more damage.
local area = createCombatArea(AREA_CIRCLE2X2)
local bigArea = createCombatArea(AREA_CIRCLE3X3)

function onDeath(cid, corpse, lastHitKiller, mostDamageKiller)
	local master = getCreatureMaster(cid)
	if(not master or not isPlayer(master)) then
		return true
	end

	local glyph = Necro.glyph(master, "summon bone abomination")
	local blast = glyph and glyph.blast
	local pos = getCreaturePosition(cid)
	local min, max = Necro.summonValues(cid, 2.0, 3.5)
	if(blast) then
		min, max = math.floor(min * blast.damage), math.floor(max * blast.damage)
	end

	doAreaCombatHealth(master, COMBAT_DEATHDAMAGE, pos, blast and bigArea or area, -min, -max, CONST_ME_MORTAREA)
	VFX.Explosion(pos, CONST_ANI_DEATH, {radius = blast and 4 or 3, points = 12, rings = 2, ringInterval = 120, skipVoid = true})
	return true
end
