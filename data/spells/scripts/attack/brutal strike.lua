-- Brutal Strike: heavy physical blow on an adjacent target (Knight line), like the global one.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.execute = {below, damage}              the hit deals `damage` times more against a target with `below`% of its health or less
--   glyph.resist  = {percent, duration}          lowers the physical resistance of the monster (before the hit)
--   glyph.bleed   = {percent, ticks, interval}   the target bleeds for `percent`% of the damage of the hit, paid in `ticks` hits
local KEY = "attack/brutal strike"

local rolls = {} -- caster -> damage rolled by the callback (only when the glyph needs it)

local function build(scale)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
	setCombatParam(combat, COMBAT_PARAM_BLOCKARMOR, true)
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)
	setCombatParam(combat, COMBAT_PARAM_USECHARGES, true)

	Glyphs.setCallback(combat, CALLBACK_PARAM_SKILLVALUE, function(cid, level, skill, attack, factor)
		local skillTotal, levelTotal = skill + attack, level / 5
		local min, max = -(skillTotal * 1.0 + levelTotal), -(skillTotal * 1.8 + levelTotal)

		local glyph = Glyphs.get(cid, KEY)
		if(glyph and glyph.bleed) then
			-- rolled here, so the bleeding knows how much the hit did
			local value = math.random(math.floor(math.min(min, max)), math.floor(math.max(min, max)))
			rolls[cid] = value
			return value * scale, value * scale
		end

		return min * scale, max * scale
	end)
	return combat
end

local spell = Glyphs.spellByKey(KEY)
local executeConfig = spell and spell.glyphs.A and spell.glyphs.A.execute or {}

local combat = build(1)
local executeCombat = build(executeConfig.damage or 1.5)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph) then
		return doCombat(cid, combat, var)
	end

	local target = Glyphs.aimed(var)
	if(target > 0 and glyph.resist) then
		Glyphs.reduceResistance(target, COMBAT_PHYSICALDAMAGE, glyph.resist.percent, glyph.resist.duration)
	end

	local used = combat
	if(target > 0 and glyph.execute and getCreatureHealth(target) * 100 <= getCreatureMaxHealth(target) * glyph.execute.below) then
		used = executeCombat
	end

	rolls[cid] = nil
	local ret = doCombat(cid, used, var)
	local value = rolls[cid]
	rolls[cid] = nil

	if(ret and glyph.bleed and value and target > 0 and isCreature(target) and getCreatureHealth(target) > 0) then
		local total = math.abs(SpellBalance.scale(cid, KEY, value)) * glyph.bleed.percent / 100
		Glyphs.bleed(cid, target, total, glyph.bleed.ticks, glyph.bleed.interval)
	end

	return ret
end
