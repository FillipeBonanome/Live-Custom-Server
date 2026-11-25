-- Corpse Explosion (Lich): consumes a corpse (up to 4 SQM from you; with a target, the one closest to it) and blows it up in a 5x5 area:
-- death and poison, P x 2.5 to 4.0 in total (half of each). A corpse is also what you need to raise summons, so choose well.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.chain = {corpses, share, radius}   up to `corpses` other corpses within `radius` sqm of the explosion explode too, `share` of the damage
--   glyph.slow  = {percent, duration}        every enemy within 2 sqm of the explosion is slowed
local KEY = "necromancer/corpse explosion"

local area = createCombatArea(AREA_CIRCLE2X2)
local config = {range = 4, damage = {1.25, 2.0}} -- each element: half of the total

local function explode(cid, pos, share)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	local min, max = Necro.values(cid, unpack(config.damage))
	min, max = math.max(1, math.floor(min * share)), math.max(1, math.floor(max * share))
	doAreaCombatHealth(cid, COMBAT_DEATHDAMAGE, pos, area, -min, -max, CONST_ME_NONE)
	doAreaCombatHealth(cid, COMBAT_EARTHDAMAGE, pos, area, -min, -max, CONST_ME_NONE)

	VFX.Explosion(pos, CONST_ANI_DEATH, {radius = 2, points = 12, rings = 2, ringInterval = 120, effect = CONST_ME_MORTAREA, skipVoid = true})
	VFX.Explosion(pos, CONST_ANI_POISON, {radius = 3, points = 12, rings = 2, ringInterval = 120, delay = 150, effect = CONST_ME_POISONAREA, skipVoid = true})
end

function onCastSpell(cid, var)
	local target = getCreatureTarget(cid)
	local near = (target ~= 0 and isCreature(target)) and getCreaturePosition(target) or nil
	local pos, corpse = Necro.findCorpse(cid, config.range, near)
	if(not pos) then
		doPlayerSendCancel(cid, "You need a corpse near you.")
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
		return false
	end

	local glyph = Glyphs.get(cid, KEY)
	doRemoveItem(corpse)
	explode(cid, pos, 1)

	if(glyph and glyph.chain) then
		-- the corpses closest to the explosion go off one after the other (each one is removed first, so the next search finds another)
		for i = 1, glyph.chain.corpses do
			local otherPos, other = Necro.findCorpse(cid, config.range, pos)
			if(not otherPos or getDistanceBetween(pos, otherPos) > glyph.chain.radius) then
				break
			end

			doRemoveItem(other)
			addEvent(explode, 250 * i, cid, otherPos, glyph.chain.share)
		end
	end

	if(glyph and glyph.slow) then
		for _, tid in ipairs(Necro.enemiesAround(pos, 2)) do
			Glyphs.paralyze(cid, tid, glyph.slow.percent, glyph.slow.duration)
		end
	end

	return true
end
