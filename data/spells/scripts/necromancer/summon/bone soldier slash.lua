-- Bone Soldier (Army of the Dead): Slash, physical melee hit (P x 0.5 to 1.0).
-- Glyph of the owner (Army of the Dead B, data/lib/403-glyphs.lua): glyph.slow = {percent, duration} every hit slows the target.
local combat = createCombatObject()

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	if(target == 0 or not isCreature(target)) then
		return false
	end

	local ret = Necro.hit(cid, target, COMBAT_PHYSICALDAMAGE, 0.5, 1.0, CONST_ME_HITAREA)
	local glyph = Necro.ownerGlyph(cid)
	if(ret and glyph and glyph.slow and isCreature(target)) then
		Glyphs.paralyze(cid, target, glyph.slow.percent, glyph.slow.duration)
	end

	return ret
end
