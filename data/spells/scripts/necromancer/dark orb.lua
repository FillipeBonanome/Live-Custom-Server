-- Dark Orb: ball of death on the target, 7x7 circle (P x 1.0 to 1.8). The area itself draws no effect: the animation is made with the
-- VFX library (data/lib/360-vfx.lua): only an Explosion, rings of death shots leaving the target.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.damage = x                      damage multiplier (applied by SpellBalance)
--   glyph.feed   = {percent, targets}     your summons recover `percent`% of their health for each enemy hit (up to `targets`)
local KEY = "necromancer/dark orb"

local hitsOfCast = {} -- caster -> number of enemies hit, filled by the target callback during doCombat

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_NONE)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_DEATH)
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, Necro.formula(1.0, 1.8))
setCombatArea(combat, createCombatArea(AREA_CIRCLE3X3))
Glyphs.setCallback(combat, CALLBACK_PARAM_TARGETCREATURE, function(cid, target)
	if(hitsOfCast[cid] and Glyphs.isEnemy(cid, target)) then
		hitsOfCast[cid] = hitsOfCast[cid] + 1
	end

	return true
end)

local function animate(pos)
	VFX.Explosion(pos, CONST_ANI_DEATH, {radius = 3, points = 12, rings = 2, ringInterval = 120, effect = CONST_ME_MORTAREA, skipVoid = true})
end

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local target = getCreatureTarget(cid)
	local pos = (target ~= 0 and isCreature(target)) and getCreaturePosition(target) or nil

	hitsOfCast[cid] = 0
	local ret = doCombat(cid, combat, var)
	local hits = hitsOfCast[cid]
	hitsOfCast[cid] = nil
	if(not ret) then
		return false
	end

	if(pos) then
		animate(pos)
	end

	if(glyph and glyph.feed and hits and hits > 0) then
		local percent = glyph.feed.percent * math.min(hits, glyph.feed.targets)
		for _, sid in ipairs(Necro.summons(cid, true, true)) do
			doCreatureAddHealth(sid, math.max(1, math.floor(getCreatureMaxHealth(sid) * percent / 100)))
			doSendMagicEffect(getCreaturePosition(sid), CONST_ME_MAGIC_GREEN)
		end
	end

	return true
end
