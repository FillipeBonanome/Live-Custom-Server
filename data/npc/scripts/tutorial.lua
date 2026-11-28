-- Guardian of Origins: tutorial NPC of the first login. The first thing he asks is the language (data/lib/202-language.lua),
-- then he tells the (biblical, ambiguous) lore through keywords, gives a race (the same races of Magister Cassian Vael, but
-- with no cooldown) and sends to the temple. Every text is a table {en = "...", pt = "..."} read by Language.text.
--
-- Lore: the player believes to be the "Chamado", reborn to defend a world invaded by beasts. The truth, revealed only at the
-- endgame, is that the beasts were captured by the player himself and are kept in the hunts to be hunted. This NPC only
-- plants hints (the "cast down", the "pen", the memory that is not to be recalled): never say it plainly here.
-- Never use the word "player"/"jogador" in what the NPC says. Texts have no accents on purpose (encoding of the files).
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local choices = {}
local greeted = {}
local TELEPORT_DELAY = 4000

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end

-- words in {braces} are highlighted by the client and can be said. |NAME| is replaced by the name of who is talking
local TEXTS = {
	-- before the language is known: both languages
	askLanguage = "Peace be with you, |NAME|. Paz seja contigo. In which tongue do you speak? Em que lingua falas? {English} / {Portugues}",
	languageSet = {
		en = "So be it: we shall speak in English.",
		pt = "Que assim seja: falaremos em portugues."
	},
	mazeIntro = {
		en = {
			"Welcome back, |NAME|. I see the dust of the {maze} still clings to you, where you wandered lost, a faint light with no name."
		},
		pt = {
			"Bem-vindo de volta, |NAME|. Vejo que o po do {labirinto} ainda te cobre, onde vagaste perdido, uma luz fraca sem nome."
		}
	},
	greet = {
		en = "Peace be with you, |NAME|. You were absent, and now you return. Ask, and it shall be answered. Begin with the {world}, if you wish to know where you stand.",
		pt = "Paz seja contigo, |NAME|. Eras ausente, e agora retornas. Pergunta, e te sera respondido. Comeca pelo {mundo}, se queres saber onde pisas."
	},
	finished = {
		en = "Your path is already written, |NAME|. Follow it.",
		pt = "O teu caminho ja foi escrito, |NAME|. Segue-o."
	},
	declined = {
		en = "May doubt be wise to you. Ask about the {peoples} again, or tell me the name of one.",
		pt = "Que a duvida te seja sabia. Pergunta outra vez pelos {povos}, ou diz-me o nome de um."
	},
	unknown = {
		en = "I do not understand those words, |NAME|. Ask me about the {world}, the {night}, the {called} or the {peoples}.",
		pt = "Nao entendo essas palavras, |NAME|. Pergunta-me sobre o {mundo}, a {noite}, o {chamado} ou os {povos}."
	},
	lineagesList = {
		en = "Many peoples walk this world, and each keeps something of its own blood: LIST. Name the one in which you recognize yourself, and I will tell you what it keeps.",
		pt = "Muitos povos andam por este mundo, e cada um guarda algo do proprio sangue: LIST. Diz o nome daquele em que te reconheces, e eu te direi o que ele guarda."
	},
	confirm = {
		en = "Do you wish to be marked {RACE}? The garments you now wear will be exchanged for those of the new lineage. {yes} or {no}?",
		pt = "Queres ser marcado {RACE}? Os trajes que ora vestes serao trocados pelos da nova linhagem. {yes} ou {no}?"
	},
	chosen = {
		en = "It is written: your blood is RACE.",
		pt = "Esta escrito: o teu sangue e RACE."
	},
	chosenGo = {
		en = "Go to the temple, and may the flock recognize you. Go, and fulfill what was given to you.",
		pt = "Vai ao templo, e que o rebanho te reconheca. Vai, e cumpre o que te foi dado."
	},
	questBrannoc = {
		en = "Quest log updated: at the temple, speak with Brannoc and ask him what a recruit must learn.",
		pt = "Quest log atualizado: no templo, fale com Brannoc e pergunte a ele o que um recruta deve aprender."
	}
}

-- topics: the words that open them and their lines
local TOPICS = {
	maze = {
		words = {"labirinto", "maze"},
		lines = {
			en = {
				"The Labyrinth of the Mind is where those who return from the dark are first cast: a house of walls that shift, and of voices in tongues no one remembers. You heard them, and you did not yield.",
				"Do not ask who raised those walls, |NAME|. Ask rather why they were made so easy to leave for you alone, and so hard for the others."
			},
			pt = {
				"O Labirinto da Mente e para onde caem primeiro os que retornam da escuridao: uma casa de muros que mudam, e de vozes em linguas que ninguem recorda. Ouviste-as, e nao cedeste.",
				"Nao perguntes quem ergueu aqueles muros, |NAME|. Pergunta antes por que foram feitos tao faceis de deixar para ti, e tao duros para os outros."
			}
		}
	},
	world = {
		words = {"mundo", "world"},
		lines = {
			en = {
				"In the beginning the world was whole, and the lands gave fruit with neither wall nor fence. The peoples walked in peace, and none lacked pasture, nor shade, nor water.",
				"So it was for many ages, until the {night} came."
			},
			pt = {
				"No principio, o mundo era inteiro, e as terras davam fruto sem cerco e sem cerca. Os povos andavam em paz, e a nenhum faltava pasto, nem sombra, nem agua.",
				"Assim foi por muitas eras, ate que veio a {noite}."
			}
		}
	},
	night = {
		words = {"noite", "night"},
		lines = {
			en = {
				"And the Nameless Night came, and the beasts descended upon the lands like locusts. The elders say they were cast down from above, but none saw the hand that cast them.",
				"Blessed is he who holds them back, for on his shoulders rests the peace of the just. Ask me, if you wish, who the {called} is."
			},
			pt = {
				"E veio a Noite sem Nome, e as feras desceram sobre as terras como gafanhotos. Dizem os anciaos que foram lancadas do alto, mas nenhum viu a mao que as lancou.",
				"Bem-aventurado aquele que as detem, pois sobre os seus ombros repousa a paz dos justos. Pergunta-me, se queres, quem e o {chamado}."
			}
		}
	},
	called = {
		words = {"chamado", "called"},
		lines = {
			en = {
				"Verily I say unto you: you did not come by chance. One who is reborn as you are is reborn with a task, and the task comes before the memory.",
				"Do you ask whether you have walked here before? Do not remember. The shepherd guards the flock, and the flock does not ask who built the pen. Tell me instead which of the {peoples} runs in your blood, for the road is made of blood."
			},
			pt = {
				"Em verdade te digo: nao vieste por acaso. Quem renasce como tu renasce com uma tarefa, e a tarefa precede a lembranca.",
				"Perguntas se ja caminhaste por aqui? Nao te recordes. O pastor guarda o rebanho, e o rebanho nao pergunta quem ergueu o curral. Diz-me antes qual dos {povos} corre no teu sangue, pois e do sangue que se faz o caminho."
			}
		}
	}
}

-- one parable for each race (the race name closes it). A new race without a parable gets a generic line.
local PARABLES = {
	en = {
		["Human"] = "There was a people with no claw, no scale and no horn, who had nothing of their own and learned everything. They called them {Human}.",
		["Orc"] = "There was a mountain people who measure honor in scars, and whose arm is law. They called them {Orc}.",
		["Dwarf"] = "There was a people who went down into the stone and found fire there; they bent the steel and never bent the spine. They called them {Dwarf}.",
		["Undead"] = "There were those whom death refused, who walk between two worlds and belong to neither. They called them {Undead}.",
		["Elf"] = "There was a forest people, light as a leaf, whose arrow finds what the eye has not yet seen. They called them {Elf}.",
		["Minotaur"] = "There was a people born of the labyrinths, wide of stride and hard of brow, who never retreated before a wall. They called them {Minotaur}.",
		["Goblin"] = "There was a small people who find treasure where others see ashes, and whom fortune follows uncalled. They called them {Goblin}.",
		["Lizard"] = "There was a people of the southern swamps, heirs of a forgotten kingdom, who drink the power of the very earth. They called them {Lizard}."
	},
	pt = {
		["Human"] = "Houve um povo sem garra, sem escama e sem chifre, que nada tinha de seu e tudo aprendeu. Chamaram-no {Human}.",
		["Orc"] = "Houve um povo da montanha que mede a honra em cicatrizes, e cujo braco e lei. Chamaram-no {Orc}.",
		["Dwarf"] = "Houve um povo que desceu a pedra e la encontrou o fogo; dobrou o aco e nunca dobrou a espinha. Chamaram-no {Dwarf}.",
		["Undead"] = "Houve os que a morte recusou, e que caminham entre dois mundos sem pertencer a nenhum. Chamaram-nos {Undead}.",
		["Elf"] = "Houve um povo da floresta, leve como a folha, cuja flecha encontra o que o olho ainda nao viu. Chamaram-no {Elf}.",
		["Minotaur"] = "Houve um povo nascido dos labirintos, de passo largo e fronte dura, que nunca recuou diante do muro. Chamaram-no {Minotaur}.",
		["Goblin"] = "Houve um povo pequeno que acha tesouro onde outros veem cinzas, e que a sorte segue sem ser chamada. Chamaram-no {Goblin}.",
		["Lizard"] = "Houve um povo dos pantanos do sul, herdeiro de um reino esquecido, que bebe o poder da propria terra. Chamaram-no {Lizard}."
	}
}

local RACE_WORDS = {"linhagem", "linhagens", "lineage", "lineages", "raca", "racas", "povo", "povos", "race", "races", "peoples", "people", "help"}

-- the text of the language of cid with |NAME| replaced
local function text(cid, texts)
	local value = Language.text(cid, texts)
	return (value:gsub("|NAME|", getCreatureName(cid)))
end

local function say(cid, texts)
	npcHandler:say(text(cid, texts), cid)
end

-- all the lines go in ONE message (one line of chat), joined by a space
local function sayLines(cid, lines)
	npcHandler:say((table.concat(lines, " "):gsub("|NAME|", getCreatureName(cid))), cid)
end

local function sayRaces(cid)
	local names = {}
	for _, race in ipairs(RACES) do
		table.insert(names, "{" .. race.name .. "}")
	end

	npcHandler:say((text(cid, TEXTS.lineagesList):gsub("LIST", function() return table.concat(names, ", ") end)), cid)
end

local function getTopic(msg)
	for _, topic in pairs(TOPICS) do
		if(isInArray(topic.words, msg)) then
			return topic
		end
	end

	return nil
end

local function finishTutorial(cid)
	if(isPlayer(cid) and getPlayerTutorialState(cid) == 1) then
		doPlayerFinishTutorial(cid)
	end
end

local function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	msg = msg:lower():trim()

	-- the language comes first, and can be changed any time by saying the name of another one
	local languageId = Language.find(msg)
	if(languageId) then
		local first = not Language.getChosen(cid)
		choices[cid] = nil
		Language.set(cid, languageId)
		if(first and getPlayerTutorialState(cid) == 1) then
			local lines = {Language.text(cid, TEXTS.languageSet)}
			for _, line in ipairs(Language.text(cid, TEXTS.mazeIntro)) do
				table.insert(lines, line)
			end

			table.insert(lines, Language.text(cid, TEXTS.greet))
			sayLines(cid, lines)
		else
			say(cid, TEXTS.languageSet)
		end

		return true
	end

	if(not Language.getChosen(cid)) then
		npcHandler:say((TEXTS.askLanguage:gsub("|NAME|", getCreatureName(cid))), cid)
		return true
	end

	if(getPlayerTutorialState(cid) ~= 1) then
		say(cid, TEXTS.finished)
		local hint = getPlayerTutorialHint(cid, "Guardian of Origins") -- next step of the tutorial quest, if still in it
		if(hint) then
			npcHandler:say(hint, cid)
		end

		return true
	end

	local choice = choices[cid]
	if(choice) then
		choices[cid] = nil
		if(msg == "yes" or msg == "sim" or msg == "amem" or msg == "amen") then
			if(doPlayerSetRace(cid, choice)) then
				doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
				sayLines(cid, {(Language.text(cid, TEXTS.chosen):gsub("RACE", RACES[choice].name)), Language.text(cid, TEXTS.chosenGo)})
				doPlayerAdvanceTutorialQuest(cid, 1, TEXTS.questBrannoc)
				addEvent(finishTutorial, TELEPORT_DELAY, cid)
			end
		else
			say(cid, TEXTS.declined)
		end

		return true
	end

	local topic = getTopic(msg)
	if(topic) then
		sayLines(cid, Language.text(cid, topic.lines))
		return true
	end

	if(isInArray(RACE_WORDS, msg)) then
		sayRaces(cid)
		return true
	end

	local index, race = getRaceByName(msg)
	if(index) then
		local parables = PARABLES[Language.list[Language.get(cid)].key] or PARABLES.en
		choices[cid] = index
		npcHandler:say(parables[race.name] or ("{" .. race.name .. "}."), cid)
		doShowTextDialog(cid, 1982, getRaceDescription(index))
		npcHandler:say((text(cid, TEXTS.confirm):gsub("RACE", race.name)), cid)
		return true
	end

	say(cid, TEXTS.unknown)
	return true
end

local function onFarewell(cid)
	choices[cid] = nil
	return true
end

-- the greeting depends on the language: before it is chosen the NPC asks for it in both
local function onGreet(cid)
	if(Language.getChosen(cid)) then
		npcHandler:setMessage(MESSAGE_GREET, text(cid, TEXTS.greet))
	else
		npcHandler:setMessage(MESSAGE_GREET, (TEXTS.askLanguage:gsub("|NAME|", "|PLAYERNAME|")))
	end

	return true
end

-- greets by himself who is in the tutorial and near him
local function onThinkCallback()
	for pid in pairs(greeted) do
		if(not isPlayer(pid) or getPlayerTutorialState(pid) ~= 1) then
			greeted[pid] = nil -- finished or restarted (!resettutorial): greeted again next time
		end
	end

	for _, pid in ipairs(getSpectators(getCreaturePosition(getNpcId()), npcHandler.talkRadius, npcHandler.talkRadius)) do
		if(isPlayer(pid) and not greeted[pid] and not npcHandler:isFocused(pid) and getPlayerTutorialState(pid) == 1) then
			greeted[pid] = true
			npcHandler:onGreet(pid)
			if(npcHandler:isFocused(pid)) then
				npcHandler.talkStart[pid] = os.time() -- normally set when someone speaks; onThink needs it for the idle timeout
			end
		end
	end

	return true
end

npcHandler:setCallback(CALLBACK_GREET, onGreet)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_CREATURE_DISAPPEAR, onFarewell)
npcHandler:setCallback(CALLBACK_FAREWELL, onFarewell)
npcHandler:setCallback(CALLBACK_ONTHINK, onThinkCallback)
npcHandler:addModule(FocusModule:new())
