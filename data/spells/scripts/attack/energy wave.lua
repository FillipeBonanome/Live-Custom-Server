-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.push = {chance}                 every creature hit is pushed 1 sqm away from the caster (data/lib/404-push.lua)
--   glyph.siphon = {percent, targets}     mana back for each enemy hit (up to `targets`): a percent of the average damage of the wave
local KEY = "attack/energy wave"

local hitsOfCast = {} -- caster -> creatures hit, filled by the target callback during doCombat

-- called for every creature the wave really hit (after the damage)
local function onTarget(cid, target)
	local glyph = Glyphs.get(cid, KEY)
	if(glyph and (glyph.push or glyph.siphon) and hitsOfCast[cid]) then
		table.insert(hitsOfCast[cid], target)
	end

	return true
end

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_ENERGYAREA)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGY)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 4.5, 9)
setCombatArea(combat, createCombatArea(AREA_SQUAREWAVE5, AREADIAGONAL_SQUAREWAVE5))
Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, onTarget)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph or not (glyph.push or glyph.siphon)) then
		return doCombat(cid, combat, var)
	end

	hitsOfCast[cid] = {}
	local ret = doCombat(cid, combat, var)
	local hits = hitsOfCast[cid]
	hitsOfCast[cid] = nil
	if(not ret or not hits or #hits == 0) then
		return ret
	end

	if(glyph.siphon) then
		-- average of the damage of the spell: setAttackFormula(5, 5, 4.5, 9)
		local level, magic = getPlayerLevel(cid), getPlayerMagLevel(cid)
		local average = (level / 5 + magic * 4.5 + level / 5 + magic * 9) / 2
		local dealt = math.abs(SpellBalance.scale(cid, KEY, -average))
		local enemies = 0
		for _, tid in ipairs(hits) do
			if(enemies >= glyph.siphon.targets) then
				break
			end

			if(Glyphs.isEnemy(cid, tid)) then
				enemies = enemies + 1
			end
		end

		if(enemies > 0) then
			doPlayerAddMana(cid, math.floor(dealt * glyph.siphon.percent / 100 * enemies))
			doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
		end
	end

	if(glyph.push) then
		-- the farthest first, so the ones behind get out of the way of the ones in front
		local from, entries = getCreaturePosition(cid), {}
		for _, tid in ipairs(hits) do
			if(isCreature(tid) and getCreatureHealth(tid) > 0) then
				table.insert(entries, {id = tid, distance = getDistanceBetween(from, getCreaturePosition(tid))})
			end
		end

		table.sort(entries, function(a, b) return a.distance > b.distance end)
		for _, entry in ipairs(entries) do
			if(isCreature(entry.id)) then
				Push.away(cid, entry.id, glyph.push.chance)
			end
		end
	end

	return ret
end
