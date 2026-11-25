-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.tiers   = {{minimum level, "Monster Name"}, ...}   the kind of the raised creature depends on the level of the caster
--   glyph.harvest = {percent, max}                           each creature raised (up to `max`) gives the caster `percent`% of the
--                                                            maximum health and mana
local KEY = "summon/undead legion"

local raisedOfCast = {} -- caster -> creatures raised during doCombat

function onTargetTile(cid, pos)
	local getPos = pos
	getPos.stackpos = STACKPOS_TOP_MOVEABLE_ITEM_OR_CREATURE

	local corpse = getThingFromPos(getPos)
	if(corpse.uid > 0 and isCorpse(corpse.uid) and isMoveable(corpse.uid) and getCreatureSkullType(cid) ~= SKULL_BLACK) then
		doRemoveItem(corpse.uid)

		local glyph = Glyphs.get(cid, KEY)
		local name = (glyph and glyph.tiers) and Glyphs.summonTier(cid, glyph.tiers) or "Skeleton"
		local summon = doCreateMonster(name, pos)
		if(summon and not doConvinceCreature(cid, summon)) then
			doRemoveCreature(summon)
			summon = nil
		end

		if(summon and raisedOfCast[cid]) then
			raisedOfCast[cid] = raisedOfCast[cid] + 1
		end

		doSendMagicEffect(pos, CONST_ME_MAGIC_BLUE)
		return true
	end

	return false
end

local area, combat = createCombatArea(AREA_CIRCLE3X3), createCombatObject()
setCombatArea(combat, area)

setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatCallback(combat, CALLBACK_PARAM_TARGETTILE, "onTargetTile")

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph or not glyph.harvest) then
		return doCombat(cid, combat, var)
	end

	raisedOfCast[cid] = 0
	local ret = doCombat(cid, combat, var)
	local raised = math.min(raisedOfCast[cid] or 0, glyph.harvest.max)
	raisedOfCast[cid] = nil

	if(ret and raised > 0 and isCreature(cid)) then
		local percent = glyph.harvest.percent * raised
		doCreatureAddHealth(cid, math.floor(getCreatureMaxHealth(cid) * percent / 100))
		doPlayerAddMana(cid, math.floor(getCreatureMaxMana(cid) * percent / 100))
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
	end

	return ret
end
