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
local heardRaces = {} -- who already heard the parables of the peoples (needed before choosing)
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
			"Welcome back, |NAME|. I see the dust of the {maze} still clings to you: the Labyrinth of the Mind, where you wandered lost, a faint light with no name.",
			"The voices spoke, and you did not yield to them. You walked to the end and set yourself free. Few do. Be glad, for what is freed is not easily bound again."
		},
		pt = {
			"Bem-vindo de volta, |NAME|. Vejo que o po do {labirinto} ainda te cobre: o Labirinto da Mente, onde vagaste perdido, uma luz fraca sem nome.",
			"As vozes falaram, e tu nao cedeste a elas. Caminhaste ate o fim e te libertaste. Poucos o fazem. Alegra-te, pois o que se liberta nao e facilmente atado outra vez."
		}
	},
	greet = {
		en = "Peace be with you, |NAME|. You were absent, and now you return. Ask, and it shall be answered: about the {world}, about the {night}, or about the {called}.",
		pt = "Paz seja contigo, |NAME|. Eras ausente, e agora retornas. Pergunta, e te sera respondido: sobre o {mundo}, sobre a {noite}, ou sobre o {chamado}."
	},
	finished = {
		en = "Your path is already written, |NAME|. Follow it.",
		pt = "O teu caminho ja foi escrito, |NAME|. Segue-o."
	},
	needLineages = {
		en = "You have not yet heard the {lineages}. Hear them first, for one does not choose what one does not know.",
		pt = "Ainda nao ouviste as {linhagens}. Ouve-as primeiro, pois nao se escolhe o que nao se conhece."
	},
	declined = {
		en = "May doubt be wise to you. Hear the {lineages} again, or tell me the name of a people.",
		pt = "Que a duvida te seja sabia. Ouve outra vez as {linhagens}, ou diz-me o nome de um povo."
	},
	unknown = {
		en = "I do not understand those words, |NAME|. Ask me about the {world}, the {night}, the {called} or the {lineages}.",
		pt = "Nao entendo essas palavras, |NAME|. Pergunta-me sobre o {mundo}, a {noite}, o {chamado} ou as {linhagens}."
	},
	lineagesIntro = {
		en = "It is written, and I repeat it:",
		pt = "Esta escrito, e eu o repito:"
	},
	lineagesOutro = {
		en = "Tell me the name of the people in which you recognize yourself, and I will tell you what it keeps.",
		pt = "Diz-me o nome do povo em que te reconheces, e eu te direi o que ele guarda."
	},
	confirm = {
		en = "The {RACE} people... Do you wish to be marked so? The garments you now wear will be exchanged for those of the new lineage. {yes} or {no}?",
		pt = "O povo {RACE}... Assim queres ser marcado? Os trajes que ora vestes serao trocados pelos da nova linhagem. {yes} ou {no}?"
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
		en = "Quest log updated: at the temple, speak with Brannoc and ask about training (say basics).",
		pt = "Quest log atualizado: no templo, fale com Brannoc e pergunte sobre o treino (diga basics)."
	}
}

-- topics: the words that open them and their lines
local TOPICS = {
	maze = {
		words = {"labirinto", "maze"},
		lines = {
			en = {
				"The Labyrinth of the Mind is where those who return from the dark are first cast: a house of walls that shift, and of voices in tongues no one remembers. Many wander there until they forget even the wandering.",
				"You heard them, and yet you found the door. Do not ask who raised those walls, |NAME|. Ask rather why they were made so easy to leave for you alone, and so hard for the others."
			},
			pt = {
				"O Labirinto da Mente e para onde caem primeiro os que retornam da escuridao: uma casa de muros que mudam, e de vozes em linguas que ninguem recorda. Muitos vagam ali ate esquecerem ate o vagar.",
				"Ouviste-as, e ainda assim encontraste a porta. Nao perguntes quem ergueu aqueles muros, |NAME|. Pergunta antes por que foram feitos tao faceis de deixar para ti, e tao duros para os outros."
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
				"Do you ask whether you have walked here before? Do not remember. The shepherd guards the flock, and the flock does not ask who built the pen.",
				"Before you depart, hear the {lineages}, for the road is made of blood."
			},
			pt = {
				"Em verdade te digo: nao vieste por acaso. Quem renasce como tu renasce com uma tarefa, e a tarefa precede a lembranca.",
				"Perguntas se ja caminhaste por aqui? Nao te recordes. O pastor guarda o rebanho, e o rebanho nao pergunta quem ergueu o curral.",
				"Antes de partires, ouve as {linhagens}, pois e do sangue que se faz o caminho."
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

local RACE_WORDS = {"linhagem", "linhagens", "lineage", "lineages", "raca", "racas", "povo", "povos", "race", "races", "help"}

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
	local parables = PARABLES[Language.list[Language.get(cid)].key] or PARABLES.en
	local lines = {text(cid, TEXTS.lineagesIntro)}
	for _, race in ipairs(RACES) do
		table.insert(lines, parables[race.name] or ("{" .. race.name .. "}."))
	end

	table.insert(lines, text(cid, TEXTS.lineagesOutro))
	for _, line in ipairs(lines) do -- one message for each lineage
		sayLines(cid, {line})
	end
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
		heardRaces[cid] = true
		sayRaces(cid)
		return true
	end

	local index, race = getRaceByName(msg)
	if(index) then
		if(not heardRaces[cid]) then
			say(cid, TEXTS.needLineages)
			return true
		end

		choices[cid] = index
		doShowTextDialog(cid, 1982, getRaceDescription(index))
		npcHandler:say((text(cid, TEXTS.confirm):gsub("RACE", race.name)), cid)
		return true
	end

	say(cid, TEXTS.unknown)
	return true
end

local function onFarewell(cid)
	choices[cid] = nil
	heardRaces[cid] = nil
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
