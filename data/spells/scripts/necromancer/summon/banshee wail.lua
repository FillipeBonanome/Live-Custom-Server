-- Banshee: Wail, death damage from a distance (P x 0.7 to 1.3).
-- Glyphs of the owner (Summon Banshee, data/lib/403-glyphs.lua): glyph.pierce = {length} the wail goes through the target and hits every
-- monster on the line, up to `length` sqm from the banshee; glyph.slow = {percent, duration} the target is slowed.
local combat = createCombatObject()

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		return false
	end

	local glyph = Necro.ownerGlyph(cid)
	if(not glyph) then
		return Necro.hit(cid, target, COMBAT_DEATHDAMAGE, 0.7, 1.3, CONST_ME_MORTAREA, CONST_ANI_DEATH)
	end

	local from, aim = getCreaturePosition(cid), getCreaturePosition(target)
	local min, max = Necro.summonValues(cid, 0.7, 1.3)
	doSendDistanceShoot(from, aim, CONST_ANI_DEATH)
	doTargetCombatHealth(cid, target, COMBAT_DEATHDAMAGE, -min, -max, CONST_ME_MORTAREA)

	if(glyph.slow and isCreature(target)) then
		Glyphs.paralyze(cid, target, glyph.slow.percent, glyph.slow.duration)
	end

	if(glyph.pierce) then
		for _, pos in ipairs(Glyphs.linePositions(from, aim, glyph.pierce.length)) do
			if(pos.x ~= aim.x or pos.y ~= aim.y) then
				local thing = getThingFromPos({x = pos.x, y = pos.y, z = pos.z, stackpos = STACKPOS_TOP_CREATURE})
				local tid = thing and thing.uid or 0
				if(tid > 0 and tid ~= target and isCreature(tid) and isMonster(tid) and not getCreatureMaster(tid)) then
					doTargetCombatHealth(cid, tid, COMBAT_DEATHDAMAGE, -min, -max, CONST_ME_MORTAREA)
				end
			end
		end
	end

	return true
end
