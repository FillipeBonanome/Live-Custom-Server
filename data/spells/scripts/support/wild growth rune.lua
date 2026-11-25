-- Wild Growth: a barrier of rush wood (item 1499, decays after 45 seconds).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.thorns  = {ticks, interval}   the wild growth hurts the creatures around it (3x3) with earth damage: `ticks` pulses, one
--                                       every `interval` ms, while the item is there
--   glyph.lasting = true                the wild growth is renewed once before it decays, so it lasts about twice as long
local KEY = "support/wild growth rune"
local FIELD = 1499
local RENEW_AFTER = 40000 -- ms; the item decays at 45000

-- the damage of a pulse (the rune has no damage of its own): level / 5 + magic * 1 to level / 5 + magic * 2
local function values(cid)
	local level, magic = getPlayerLevel(cid), getPlayerMagLevel(cid)
	return level / 5 + magic * 1, level / 5 + magic * 2
end

local around = createCombatArea(AREA_SQUARE1X1)

local function thorn(cid, pos, left, interval)
	if(left <= 0 or not isCreature(cid) or getCreatureHealth(cid) <= 0 or getTileItemById(pos, FIELD).uid <= 0) then
		return
	end

	local min, max = values(cid)
	doAreaCombatHealth(cid, COMBAT_EARTHDAMAGE, pos, around, SpellBalance.scale(cid, KEY, -min), SpellBalance.scale(cid, KEY, -max),
		CONST_ME_SMALLPLANTS)
	addEvent(thorn, interval, cid, pos, left - 1, interval)
end

-- puts a new wild growth where the old one still is, which starts its decay again
local function renew(pos)
	local field = getTileItemById(pos, FIELD)
	if(field.uid > 0) then
		doRemoveItem(field.uid)
		doCreateItem(FIELD, 1, pos)
		doSendMagicEffect(pos, CONST_ME_SMALLPLANTS)
	end
end

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_EARTH)
setCombatParam(combat, COMBAT_PARAM_CREATEITEM, FIELD)

function onCastSpell(cid, var)
	local ret = doCombat(cid, combat, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not ret or not glyph) then
		return ret
	end

	local target = Glyphs.aimed(var)
	local pos = target > 0 and getCreaturePosition(target) or variantToPosition(var)
	if(not pos or not pos.x or pos.x == 0) then
		return ret
	end

	pos = {x = pos.x, y = pos.y, z = pos.z}
	if(glyph.thorns) then
		addEvent(thorn, glyph.thorns.interval, cid, pos, glyph.thorns.ticks, glyph.thorns.interval)
	end

	if(glyph.lasting) then
		addEvent(renew, RENEW_AFTER, pos)
	end

	return ret
end
