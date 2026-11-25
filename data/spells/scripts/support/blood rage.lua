-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.melee = 150                          the melee bonus of the rage (135 = +35%, the normal one)
--   glyph.regen = {percent, ticks, interval}   the caster recovers `percent`% of its maximum health every `interval` ms
--   glyph.leech = 5                            life leech (% of the damage dealt that comes back as health) while the rage lasts
local KEY = "support/blood rage"

local function build(melee, leech)
	local combat = createCombatObject()
	setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
	setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)

	local condition = createConditionObject(CONDITION_ATTRIBUTES)
	setConditionParam(condition, CONDITION_PARAM_TICKS, 10000)
	setConditionParam(condition, CONDITION_PARAM_SKILL_MELEEPERCENT, melee)
	setConditionParam(condition, CONDITION_PARAM_SKILL_SHIELDPERCENT, -100)
	if(leech) then
		setConditionParam(condition, CONDITION_PARAM_LIFELEECH, leech)
	end

	setConditionParam(condition, CONDITION_PARAM_BUFF, true)
	setCombatCondition(combat, condition)
	return combat
end

local spell = Glyphs.spellByKey(KEY)
local meleeConfig = spell and spell.glyphs.A and spell.glyphs.A.melee or 150
local leechConfig = spell and spell.glyphs.B and spell.glyphs.B.leech or 5

local combat = build(135)
local combatHeart = build(meleeConfig)
local combatFrenzy = build(135, leechConfig)

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	if(not glyph) then
		return doCombat(cid, combat, var)
	end

	local used = combat
	if(glyph.melee) then
		used = combatHeart
	elseif(glyph.leech) then
		used = combatFrenzy
	end

	local ret = doCombat(cid, used, var)
	if(ret and glyph.regen) then
		Glyphs.regen(cid, glyph.regen.percent, glyph.regen.ticks, glyph.regen.interval)
	end

	return ret
end
