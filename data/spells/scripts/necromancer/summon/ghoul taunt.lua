-- Ghoul and Bone Abomination: Taunt, makes the monsters around it (1 SQM) attack the summon (same effect as the Challenge spell).
-- Glyphs of the owner (data/lib/403-glyphs.lua): Summon Ghoul B glyph.taunt = {radius, slow, duration} (bigger radius, the challenged monsters
-- are slowed); Summon Bone Abomination A glyph.tauntRadius.
local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_RED)
setCombatArea(combat, createCombatArea(AREA_SQUARE1X1))

function onTargetCreature(cid, target)
	-- only real monsters (never players or summons of players)
	if(isMonster(target) and not getCreatureMaster(target)) then
		doChallengeCreature(cid, target)
	end

	return true
end
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")

function onCastSpell(cid, var)
	local glyph = Necro.ownerGlyph(cid)
	local radius = glyph and (glyph.tauntRadius or (glyph.taunt and glyph.taunt.radius))
	if(not radius) then
		return doCombat(cid, combat, var)
	end

	for _, tid in ipairs(Necro.enemiesAround(getCreaturePosition(cid), radius)) do
		doChallengeCreature(cid, tid)
		doSendMagicEffect(getCreaturePosition(tid), CONST_ME_MAGIC_RED)
		if(glyph.taunt and glyph.taunt.slow) then
			Glyphs.paralyze(cid, tid, glyph.taunt.slow, glyph.taunt.duration)
		end
	end

	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_RED)
	return true
end
