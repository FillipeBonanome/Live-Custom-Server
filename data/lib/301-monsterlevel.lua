-- Monster level. The monster files have no level, so it is calculated from what the monster really does:
--   * health (healthMax x rateMonsterHealth)
--   * damage of its attacks (getMonsterList(): damagePerSecond, burst and maxHit, with rateMonsterAttack applied)
--       damagePerSecond = average damage per second (average of each attack x chance x attacks per second)
--       burst           = sum of the highest hit of every attack (the worst case, all of them firing together)
--
--   offense = damagePerSecond * horizon * (1 - burstWeight) + burst * burstWeight
--   score   = sqrt(health * offense)
--   level   = floor(score ^ exponent * multiplier)
--
-- The defaults (horizon 10s, burstWeight 0.4, exponent 0.655, multiplier 0.61) were fitted so the levels stay in the same scale as the
-- old formula (experience ^ 0.6), which the contracts, prey and tasks were balanced with, but they no longer depend on the experience
-- (monsters with a lot of experience and no danger, like Magebomb, or the opposite, do not distort the level anymore).
-- A monster without any damage information (no attack, or only scripted attacks without min/max) falls back to the old formula:
-- floor(experience ^ dailyQuestMonsterLevelExponent * dailyQuestMonsterLevelMultiplier).
--
-- The formula only produces the numbers: the levels used by the other systems are HARDCODED in data/lib/302-monsterlevels.lua (MonsterLevels),
-- so a monster can be balanced one by one. MonsterLevel.get(name [, monster]) is what the systems call: it returns the hardcoded level and,
-- for a monster that is not in the table yet (a new monster), the calculated one.
--
-- Options (config.lua): monsterLevelHorizon, monsterLevelBurstWeight, monsterLevelExponent, monsterLevelMultiplier.
-- MonsterLevel.calculate(monster) receives one entry of getMonsterList() and returns the level and a table with the details
-- {health, offense, score, source = "stats" or "experience"}.

MonsterLevel = {}

local function cfg(key, default)
	local value = getConfigValue(key)
	if(value == nil) then
		return default
	end

	return value
end

function MonsterLevel.experienceLevel(experience)
	local level = math.floor((math.max(0, experience or 0) ^ cfg('dailyQuestMonsterLevelExponent', 0.6)) * cfg('dailyQuestMonsterLevelMultiplier', 1.0))
	return math.max(1, level)
end

-- level of the monster in use: the hardcoded one (MonsterLevels) or, if it is missing, the calculated one (monster = entry of getMonsterList())
function MonsterLevel.get(name, monster, experience)
	local hardcoded = MonsterLevels and MonsterLevels[tostring(name):lower()]
	if(hardcoded) then
		return hardcoded
	end

	if(monster) then
		return (MonsterLevel.calculate(monster))
	end

	return MonsterLevel.experienceLevel(experience or (monster and monster.experience))
end

function MonsterLevel.calculate(monster)
	local damagePerSecond, burst = monster.damagePerSecond or 0, monster.burst or 0
	local health = (monster.healthMax or monster.health or 0) * cfg('rateMonsterHealth', 1.0)
	if(health <= 0 or (damagePerSecond <= 0 and burst <= 0)) then
		return MonsterLevel.experienceLevel(monster.experience), {health = health, offense = 0, score = 0, source = "experience"}
	end

	local weight = math.max(0, math.min(1, cfg('monsterLevelBurstWeight', 0.4)))
	local offense = damagePerSecond * cfg('monsterLevelHorizon', 10) * (1 - weight) + burst * weight
	local score = math.sqrt(health * offense)
	local level = math.floor((score ^ cfg('monsterLevelExponent', 0.655)) * cfg('monsterLevelMultiplier', 0.61))
	return math.max(1, level), {health = health, offense = offense, score = score, source = "stats"}
end
