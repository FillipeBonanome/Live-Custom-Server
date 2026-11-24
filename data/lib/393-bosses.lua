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
--   Berserk    at 33%: faster for good, blade cross, bigger warcry; with 15% he heals once (Last Stand)
-- ---------------------------------------------------------------------------------------------------------------------------
MonsterAI.register("Warlord Ruzad", {
	initialState = "Assault",
	globalCooldown = 1800,

	-- base cooldowns (the states can only make them longer)
	spells = {
		["Ruzad Warcry"] = {cooldown = 4500, say = "RANAT ULDEREK!"},
		["Ruzad Call Guards"] = {cooldown = 15000, say = "Guards! To me!"},
		["Ruzad Charge"] = {cooldown = 8000, range = 8, say = "Orc buta bana!"},
		["Ruzad Axe Storm"] = {cooldown = 6000},
		["Ruzad Blade Cross"] = {cooldown = 7000, say = "Axes of ruin!"},
		["Ruzad Last Stand"] = {cooldown = 1000},
		["Ruzad Rally"] = {cooldown = 1000}
	},

	states = {
		Assault = {
			cooldowns = {["Ruzad Warcry"] = 6000, ["Ruzad Axe Storm"] = 7000},
			transitions = {
				{to = "Rally", condition = Cond.hpBelow(66)}
			},
			tree = tree.branch(Cond.all(Cond.playersAround(3, 4), ready("Ruzad Warcry")),
				tree.action("Ruzad Warcry"),
				tree.branch(Cond.all(Cond.summonsBelow(2), Cond.chance(35), ready("Ruzad Call Guards")),
					tree.action("Ruzad Call Guards"),
					tree.branch(Cond.targetFar(4),
						tree.priority({"Ruzad Charge", "Ruzad Axe Storm"}),
						tree.chance(50, tree.priority({"Ruzad Axe Storm"})))))
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
			cooldowns = {["Ruzad Warcry"] = 6000},
			transitions = {
				-- every guard dead (2 s to appear first) or 45 s, so the fight never gets stuck
				{to = "Bloodlust", condition = Cond.all(Cond.inState(2000), Cond.noSummons())},
				{to = "Bloodlust", condition = Cond.inState(45000)}
			},
			-- the shield only keeps him safe: he still crushes whoever gets close
			tree = tree.branch(Cond.all(Cond.playersAround(2, 3), ready("Ruzad Warcry")), tree.action("Ruzad Warcry"))
		},

		Bloodlust = {
			cooldowns = {["Ruzad Warcry"] = 6000},
			transitions = {
				{to = "Berserk", condition = Cond.hpBelow(33)}
			},
			tree = tree.branch(Cond.all(Cond.playersAround(3, 4), ready("Ruzad Warcry")),
				tree.action("Ruzad Warcry"),
				tree.branch(Cond.all(Cond.summonsBelow(2), Cond.chance(40), ready("Ruzad Call Guards")),
					tree.action("Ruzad Call Guards"),
					tree.branch(Cond.targetFar(4),
						tree.priority({"Ruzad Charge", "Ruzad Axe Storm"}),
						tree.chance(65, tree.priority({"Ruzad Axe Storm"})))))
		},

		Berserk = {
			onEnter = function(monster, target, memory)
				memory.berserk = true
				MonsterAI.say(monster, "GRAAAAH! I WILL CLEAVE YOU ALL!", TALKTYPE_MONSTER_YELL)
				doChangeSpeed(monster, 60)
				doSendMagicEffect(getCreaturePosition(monster), CONST_ME_MAGIC_RED)
			end,
			tree = tree.branch(Cond.all(Cond.hpBelow(15), Cond.no(Cond.flag("lastStand")), ready("Ruzad Last Stand")),
				tree.action("Ruzad Last Stand"),
				tree.branch(Cond.all(Cond.chance(70), ready("Ruzad Blade Cross")),
					tree.action("Ruzad Blade Cross"),
					tree.branch(Cond.all(Cond.playersAround(2, 4), ready("Ruzad Warcry")),
						tree.action("Ruzad Warcry"),
						tree.branch(Cond.targetFar(3),
							tree.priority({"Ruzad Charge"}),
							tree.branch(Cond.all(Cond.noSummons(), Cond.chance(40)), tree.priority({"Ruzad Call Guards"}))))))
		}
	},

	onDeath = function(monster)
		doCreatureSay(monster, "Ranat... Ulderek...", TALKTYPE_MONSTER)
	end
})

-- ---------------------------------------------------------------------------------------------------------------------------
-- Queen Silkara (boss of the Spider Nest invasion, tier I)
--
--   Hunt ──(hp < 66%)──> Brood ──(brood dead or 45 s)──> Swarm ──(hp < 33%)──> Frenzy
--
--   Hunt     normal fight: venom spit at who is far, venom rain and web trap (slow) close up, calls poison spiders
--   Brood    SHIELDED (takes no damage) while 4 poison spiders and 2 tarantulas protect her: kill the brood to break the shield
--   Swarm    the same fight with the brood coming back more often and more venom rain
--   Frenzy   at 33%: faster for good, 6 venom drops per rain and the Toxic Nova (stay glued to her or leave the circle)
-- ---------------------------------------------------------------------------------------------------------------------------
MonsterAI.register("Queen Silkara", {
	initialState = "Hunt",
	globalCooldown = 1800,

	spells = {
		["Silkara Venom Rain"] = {cooldown = 6500},
		["Silkara Web Trap"] = {cooldown = 9000, range = 8, say = "Sssstay with me..."},
		["Silkara Venom Spit"] = {cooldown = 5500, range = 7},
		["Silkara Call Brood"] = {cooldown = 14000, say = "My children... feed!"},
		["Silkara Egg Sac"] = {cooldown = 1000},
		["Silkara Toxic Nova"] = {cooldown = 9000, say = "SSSKREEEEE!"}
	},

	states = {
		Hunt = {
			transitions = {
				{to = "Brood", condition = Cond.hpBelow(66)}
			},
			tree = tree.branch(Cond.all(Cond.summonsBelow(2), Cond.chance(35), ready("Silkara Call Brood")),
				tree.action("Silkara Call Brood"),
				tree.branch(Cond.targetFar(3),
					tree.priority({"Silkara Venom Spit", "Silkara Web Trap"}),
					tree.chance(60, tree.priority({"Silkara Venom Rain", "Silkara Web Trap", "Silkara Venom Spit"}))))
		},

		Brood = {
			onEnter = function(monster)
				doCreatureCastSpell(monster, "Silkara Egg Sac", true)
			end,
			onExit = function(monster)
				MonsterAI.setImmune(monster, false)
				MonsterAI.say(monster, "You squashed my children!")
				doSendMagicEffect(getCreaturePosition(monster), CONST_ME_MAGIC_RED)
			end,
			transitions = {
				{to = "Swarm", condition = Cond.all(Cond.inState(2000), Cond.noSummons())},
				{to = "Swarm", condition = Cond.inState(45000)}
			},
			-- the shield only keeps her safe: whoever stays under her gets a venom rain
			tree = tree.branch(Cond.all(Cond.chance(60), ready("Silkara Venom Rain")), tree.action("Silkara Venom Rain"))
		},

		Swarm = {
			cooldowns = {["Silkara Call Brood"] = 11000},
			transitions = {
				{to = "Frenzy", condition = Cond.hpBelow(33)}
			},
			tree = tree.branch(Cond.all(Cond.summonsBelow(3), Cond.chance(45), ready("Silkara Call Brood")),
				tree.action("Silkara Call Brood"),
				tree.branch(Cond.targetFar(3),
					tree.priority({"Silkara Venom Spit", "Silkara Web Trap"}),
					tree.chance(75, tree.priority({"Silkara Venom Rain", "Silkara Web Trap", "Silkara Venom Spit"}))))
		},

		Frenzy = {
			onEnter = function(monster, target, memory)
				memory.frenzy = true
				MonsterAI.say(monster, "SSSKREEEEEE! I WILL BURY YOU IN SILK!", TALKTYPE_MONSTER_YELL)
				doChangeSpeed(monster, 60)
				doSendMagicEffect(getCreaturePosition(monster), CONST_ME_MAGIC_RED)
			end,
			tree = tree.branch(Cond.all(Cond.chance(65), ready("Silkara Toxic Nova")),
				tree.action("Silkara Toxic Nova"),
				tree.branch(Cond.all(Cond.noSummons(), Cond.chance(30), ready("Silkara Call Brood")),
					tree.action("Silkara Call Brood"),
					tree.branch(Cond.targetFar(3),
						tree.priority({"Silkara Venom Spit", "Silkara Web Trap"}),
						tree.priority({"Silkara Venom Rain", "Silkara Web Trap", "Silkara Venom Spit"}))))
		}
	},

	onDeath = function(monster)
		doCreatureSay(monster, "My... children...", TALKTYPE_MONSTER)
	end
})

-- ---------------------------------------------------------------------------------------------------------------------------
-- Chief Grumbak (boss of the Troll Warband invasion, tier I)
--
--   Warband ──(hp < 60%)──> Blizzard ──(hp < 30%)──> Rage
--
--   Warband   normal fight: quake when surrounded, boulder toss at who is far, frost lines, calls frost trolls
--   Blizzard  at 60% he calls the storm right away; blizzard (6 ice marks) and frost lines much more often
--   Rage      at 30%: faster for good, bigger quake, 2 boulders, diagonal frost lines and the Avalanche (find the lane)
-- ---------------------------------------------------------------------------------------------------------------------------
MonsterAI.register("Chief Grumbak", {
	initialState = "Warband",
	globalCooldown = 1900,

	spells = {
		["Grumbak Quake"] = {cooldown = 5000, say = "GRUMBAK SMASH!"},
		["Grumbak Boulder Toss"] = {cooldown = 6500, range = 8},
		["Grumbak Frost Lines"] = {cooldown = 7500},
		["Grumbak Blizzard"] = {cooldown = 12000, say = "Winter come for you!"},
		["Grumbak Call Trolls"] = {cooldown = 16000, say = "Warband! To Grumbak!"},
		["Grumbak Avalanche"] = {cooldown = 14000}
	},

	states = {
		Warband = {
			transitions = {
				{to = "Blizzard", condition = Cond.hpBelow(60)}
			},
			tree = tree.branch(Cond.all(Cond.playersAround(3, 3), ready("Grumbak Quake")),
				tree.action("Grumbak Quake"),
				tree.branch(Cond.all(Cond.summonsBelow(2), Cond.chance(30), ready("Grumbak Call Trolls")),
					tree.action("Grumbak Call Trolls"),
					tree.branch(Cond.targetFar(4),
						tree.priority({"Grumbak Boulder Toss", "Grumbak Frost Lines"}),
						tree.chance(55, tree.priority({"Grumbak Frost Lines", "Grumbak Quake", "Grumbak Boulder Toss"})))))
		},

		Blizzard = {
			onEnter = function(monster)
				MonsterAI.say(monster, "FROST MAKE GRUMBAK STRONG!", TALKTYPE_MONSTER_YELL)
				doCreatureCastSpell(monster, "Grumbak Blizzard", true)
			end,
			cooldowns = {["Grumbak Blizzard"] = 9000},
			transitions = {
				{to = "Rage", condition = Cond.hpBelow(30)}
			},
			tree = tree.branch(Cond.all(Cond.chance(50), ready("Grumbak Blizzard")),
				tree.action("Grumbak Blizzard"),
				tree.branch(Cond.all(Cond.playersAround(2, 3), ready("Grumbak Quake")),
					tree.action("Grumbak Quake"),
					tree.branch(Cond.all(Cond.summonsBelow(2), Cond.chance(30), ready("Grumbak Call Trolls")),
						tree.action("Grumbak Call Trolls"),
						tree.branch(Cond.targetFar(4),
							tree.priority({"Grumbak Boulder Toss", "Grumbak Frost Lines"}),
							tree.chance(65, tree.priority({"Grumbak Frost Lines", "Grumbak Boulder Toss", "Grumbak Quake"}))))))
		},

		Rage = {
			onEnter = function(monster, target, memory)
				memory.rage = true
				MonsterAI.say(monster, "GRUMBAK ANGRY!!! EVERYBODY DIE!", TALKTYPE_MONSTER_YELL)
				doChangeSpeed(monster, 50)
				doSendMagicEffect(getCreaturePosition(monster), CONST_ME_MAGIC_RED)
			end,
			tree = tree.branch(Cond.all(Cond.chance(60), ready("Grumbak Avalanche")),
				tree.action("Grumbak Avalanche"),
				tree.branch(Cond.all(Cond.playersAround(2, 4), ready("Grumbak Quake")),
					tree.action("Grumbak Quake"),
					tree.branch(Cond.all(Cond.chance(50), ready("Grumbak Blizzard")),
						tree.action("Grumbak Blizzard"),
						tree.branch(Cond.targetFar(4),
							tree.priority({"Grumbak Boulder Toss", "Grumbak Frost Lines"}),
							tree.branch(Cond.all(Cond.noSummons(), Cond.chance(35)),
								tree.priority({"Grumbak Call Trolls"}),
								tree.priority({"Grumbak Frost Lines", "Grumbak Boulder Toss"}))))))
		}
	},

	onDeath = function(monster)
		doCreatureSay(monster, "Grumbak... cold...", TALKTYPE_MONSTER)
	end
})

-- ---------------------------------------------------------------------------------------------------------------------------
-- Fenrak Moonfang (boss of the Wolf Pack invasion, tier I)
--
--   Stalk ──(hp < 66%)──> Moonrise ──(hp < 33%)──> Bloodmoon
--
--   Stalk      he hunts: pounces on who is far, claw rake close up, moonfall now and then
--   Moonrise   the moon rises: howls (calls war wolves, 3 at a time), faster for good and more moonfall
--   Bloodmoon  at 33%: faster again, the claw rake hits both sides and Blood Rend (diagonals, then straight lines)
-- ---------------------------------------------------------------------------------------------------------------------------
MonsterAI.register("Fenrak Moonfang", {
	initialState = "Stalk",
	globalCooldown = 1600,

	spells = {
		["Fenrak Pounce"] = {cooldown = 7000, range = 8, say = "Prey!"},
		["Fenrak Claw Rake"] = {cooldown = 4500, range = 5},
		["Fenrak Pack Howl"] = {cooldown = 16000, say = "AWOOOOOOO!"},
		["Fenrak Moonfall"] = {cooldown = 8000},
		["Fenrak Blood Rend"] = {cooldown = 9000}
	},

	states = {
		Stalk = {
			transitions = {
				{to = "Moonrise", condition = Cond.hpBelow(66)}
			},
			tree = tree.branch(Cond.targetFar(4),
				tree.priority({"Fenrak Pounce", "Fenrak Moonfall"}),
				tree.branch(Cond.all(Cond.chance(55), ready("Fenrak Claw Rake")),
					tree.action("Fenrak Claw Rake"),
					tree.chance(40, tree.priority({"Fenrak Moonfall", "Fenrak Pounce"}))))
		},

		Moonrise = {
			onEnter = function(monster, target, memory)
				memory.moonrise = true
				MonsterAI.say(monster, "The moon is mine! AWOOOOOO!", TALKTYPE_MONSTER_YELL)
				doChangeSpeed(monster, 30)
				doSendMagicEffect(getCreaturePosition(monster), CONST_ME_MAGIC_BLUE)
				doCreatureCastSpell(monster, "Fenrak Pack Howl", true)
			end,
			cooldowns = {["Fenrak Moonfall"] = 6000},
			transitions = {
				{to = "Bloodmoon", condition = Cond.hpBelow(33)}
			},
			tree = tree.branch(Cond.all(Cond.summonsBelow(2), Cond.chance(35), ready("Fenrak Pack Howl")),
				tree.action("Fenrak Pack Howl"),
				tree.branch(Cond.targetFar(4),
					tree.priority({"Fenrak Pounce", "Fenrak Moonfall"}),
					tree.branch(Cond.all(Cond.chance(50), ready("Fenrak Claw Rake")),
						tree.action("Fenrak Claw Rake"),
						tree.chance(55, tree.priority({"Fenrak Moonfall", "Fenrak Pounce"})))))
		},

		Bloodmoon = {
			onEnter = function(monster, target, memory)
				memory.bloodmoon = true
				MonsterAI.say(monster, "BLOOD! BLOOD! BLOOD!", TALKTYPE_MONSTER_YELL)
				doChangeSpeed(monster, 40)
				doSendMagicEffect(getCreaturePosition(monster), CONST_ME_MAGIC_RED)
			end,
			cooldowns = {["Fenrak Pounce"] = 5000},
			tree = tree.branch(Cond.all(Cond.chance(60), ready("Fenrak Blood Rend")),
				tree.action("Fenrak Blood Rend"),
				tree.branch(Cond.all(Cond.noSummons(), Cond.chance(30), ready("Fenrak Pack Howl")),
					tree.action("Fenrak Pack Howl"),
					tree.branch(Cond.targetFar(3),
						tree.priority({"Fenrak Pounce", "Fenrak Moonfall"}),
						tree.branch(Cond.all(Cond.chance(65), ready("Fenrak Claw Rake")),
							tree.action("Fenrak Claw Rake"),
							tree.priority({"Fenrak Moonfall", "Fenrak Pounce"})))))
		}
	},

	onDeath = function(monster)
		doCreatureSay(monster, "The pack... will avenge...", TALKTYPE_MONSTER)
	end
})
