-- Shield of Faith: for 6 seconds the target gets extra armor and defense; when the buff ends, the shield bursts and heals the
-- target. Works on an ally ("utamo lux" "name", or the current target); to protect yourself, use your own name.
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.reinforced = {duration, armor, defense}   longer shield with more armor and defense
--   glyph.burst      = {radius, share}              when it ends, the other allies within `radius` sqm are healed `share` of the heal
--                                                   and the enemies take that much holy damage
local KEY = "support/shield of faith"

local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)

local SUB_ID = 8313
local config = {duration = 6000, armor = 8, defense = 6, heal = {5, 5, 3.0, 4.5}}
local burstAreas = {[1] = createCombatArea(AREA_SQUARE1X1), [2] = createCombatArea(AREA_CIRCLE2X2)}

function onTargetCreature(cid, target)
	if(not isPlayer(target)) then
		return false
	end

	local glyph = Glyphs.get(cid, KEY)
	local duration, armor, defense = config.duration, config.armor, config.defense
	if(glyph and glyph.reinforced) then
		duration, armor, defense = glyph.reinforced.duration, glyph.reinforced.armor, glyph.reinforced.defense
	end

	local min, max = Cleric.values(cid, unpack(config.heal))
	local burst = glyph and glyph.burst or nil
	return addCreatureBuff(target, {
		name = "Shield of Faith", category = "Shield of Faith", duration = duration,
		description = "+" .. armor .. " armor and +" .. defense .. " defense; heals when it ends.",
		onActivate = function(id, stacks)
			local condition = createConditionObject(CONDITION_ATTRIBUTES, duration, true, SUB_ID)
			setConditionParam(condition, CONDITION_PARAM_ARMOR, armor)
			setConditionParam(condition, CONDITION_PARAM_DEFENSE, defense)
			doAddCondition(id, condition)
		end,
		onRemove = function(id)
			if(isCreature(id)) then
				doRemoveCondition(id, CONDITION_ATTRIBUTES, SUB_ID)
				doCreatureAddHealth(id, math.random(min, max))
				doSendMagicEffect(getCreaturePosition(id), CONST_ME_HOLYAREA)

				if(burst and isCreature(cid) and getCreatureHealth(cid) > 0) then
					local pos = getCreaturePosition(id)
					local others = {}
					for _, tid in ipairs(Cleric.allies(cid, pos, burst.radius)) do
						if(tid ~= id) then
							table.insert(others, tid)
						end
					end

					Cleric.heal(cid, others, math.floor(min * burst.share), math.floor(max * burst.share), CONST_ME_MAGIC_BLUE)
					doAreaCombatHealth(cid, COMBAT_HOLYDAMAGE, pos, burstAreas[burst.radius] or burstAreas[2], -math.floor(min * burst.share),
						-math.floor(max * burst.share), CONST_ME_HOLYAREA)
				end
			end
		end
	})
end
setCombatCallback(combat, CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")

function onCastSpell(cid, var)
	return doCombat(cid, combat, var)
end
