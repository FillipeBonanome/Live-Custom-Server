-- AI of the bosses (system in data/lib/391-monster-ai.lua, telegraphs in data/lib/392-telegraph.lua, documentation in
-- doc/sistemas/36-bosses.md). The monster keeps the attacks of its XML; the XML also needs the brain: <attack name="AI Think" interval="1000" chance="100"/>.
-- The spells that the AI casts are in data/spells/spells.xml (scripts in data/spells/scripts/ai/).

local tree, ready = DecisionTree, Cond.ready

-- ---------------------------------------------------------------------------------------------------------------------------
-- Warlord Ruzad (boss of the Orc Horde invasion, tier I)
--
--   Assault ──(hp < 66%)──> Rally ──(guards dead or 45 s)──> Bloodlust ──(hp < 33%)──> Berserk
--
--   Assault    normal fight: warcry when surrounded, calls guards, charges at who stays far, axe storm
--   Rally      SHIELDED (takes no damage) while 3 berserkers and 3 warriors protect him: kill the guards to break the shield
--   Bloodlust  the same fight with the guards coming back and the axe storm more often
--   Berserk    at 33%: faster for good, fire storms, bigger warcry; with 15% he heals once (Last Stand)
-- ---------------------------------------------------------------------------------------------------------------------------
MonsterAI.register("Warlord Ruzad", {
	initialState = "Assault",
	globalCooldown = 2500,

	-- base cooldowns (the states can only make them longer)
	spells = {
		["Ruzad Warcry"] = {cooldown = 6000, say = "RANAT ULDEREK!"},
		["Ruzad Call Guards"] = {cooldown = 20000, say = "Guards! To me!"},
		["Ruzad Charge"] = {cooldown = 12000, range = 8, say = "Orc buta bana!"},
		["Ruzad Axe Storm"] = {cooldown = 9000},
		["Ruzad Fire Storm"] = {cooldown = 10000, say = "Burn it all!"},
		["Ruzad Last Stand"] = {cooldown = 1000},
		["Ruzad Rally"] = {cooldown = 1000}
	},

	states = {
		Assault = {
			cooldowns = {["Ruzad Warcry"] = 10000, ["Ruzad Axe Storm"] = 14000},
			transitions = {
				{to = "Rally", condition = Cond.hpBelow(66)}
			},
			tree = tree.branch(Cond.all(Cond.playersAround(3, 4), ready("Ruzad Warcry")),
				tree.action("Ruzad Warcry"),
				tree.branch(Cond.all(Cond.summonsBelow(2), Cond.chance(35), ready("Ruzad Call Guards")),
					tree.action("Ruzad Call Guards"),
					tree.branch(Cond.targetFar(4),
						tree.priority({"Ruzad Charge", "Ruzad Axe Storm"}),
						tree.chance(30, tree.priority({"Ruzad Axe Storm"})))))
		},

		Rally = {
			onEnter = function(monster)
				doCreatureCastSpell(monster, "Ruzad Rally", true)
			end,
			onExit = function(monster)
				MonsterAI.setImmune(monster, false)
				MonsterAI.say(monster, "You will pay for this!")
				doSendMagicEffect(getCreaturePosition(monster), CONST_ME_MAGIC_RED)
			end,
			cooldowns = {["Ruzad Warcry"] = 10000},
			transitions = {
				-- every guard dead (2 s to appear first) or 45 s, so the fight never gets stuck
				{to = "Bloodlust", condition = Cond.all(Cond.inState(2000), Cond.noSummons())},
				{to = "Bloodlust", condition = Cond.inState(45000)}
			},
			-- the shield only keeps him safe: he still crushes whoever gets close
			tree = tree.branch(Cond.all(Cond.playersAround(2, 3), ready("Ruzad Warcry")), tree.action("Ruzad Warcry"))
		},

		Bloodlust = {
			cooldowns = {["Ruzad Warcry"] = 10000},
			transitions = {
				{to = "Berserk", condition = Cond.hpBelow(33)}
			},
			tree = tree.branch(Cond.all(Cond.playersAround(3, 4), ready("Ruzad Warcry")),
				tree.action("Ruzad Warcry"),
				tree.branch(Cond.all(Cond.summonsBelow(2), Cond.chance(40), ready("Ruzad Call Guards")),
					tree.action("Ruzad Call Guards"),
					tree.branch(Cond.targetFar(4),
						tree.priority({"Ruzad Charge", "Ruzad Axe Storm"}),
						tree.chance(45, tree.priority({"Ruzad Axe Storm"})))))
		},

		Berserk = {
			onEnter = function(monster, target, memory)
				memory.berserk = true
				MonsterAI.say(monster, "GRAAAAH! I WILL BURN YOU ALL!", TALKTYPE_MONSTER_YELL)
				doChangeSpeed(monster, 60)
				doSendMagicEffect(getCreaturePosition(monster), CONST_ME_MAGIC_RED)
			end,
			tree = tree.branch(Cond.all(Cond.hpBelow(15), Cond.no(Cond.flag("lastStand")), ready("Ruzad Last Stand")),
				tree.action("Ruzad Last Stand"),
				tree.branch(Cond.all(Cond.chance(50), ready("Ruzad Fire Storm")),
					tree.action("Ruzad Fire Storm"),
					tree.branch(Cond.all(Cond.playersAround(2, 4), ready("Ruzad Warcry")),
						tree.action("Ruzad Warcry"),
						tree.branch(Cond.targetFar(3),
							tree.priority({"Ruzad Charge"}),
							tree.branch(Cond.all(Cond.noSummons(), Cond.chance(30)), tree.priority({"Ruzad Call Guards"}))))))
		}
	},

	onDeath = function(monster)
		doCreatureSay(monster, "Ranat... Ulderek...", TALKTYPE_MONSTER)
	end
})
