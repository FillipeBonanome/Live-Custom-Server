-- Brannoc, the Drillmaster. Speaks the language chosen by the player (data/lib/202-language.lua): every text is a table
-- {en = "...", pt = "..."} read by Language.text. Creature names are never translated (they are the keys of the tasks).
-- The player can use the keywords of any language: they are converted to the english one by ALIASES.
-- Texts have no accents on purpose (encoding of the files).
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- task key the player is being asked to accept
local talks = {}

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end

-- portuguese keyword -> english keyword
local ALIASES = {
	["missao"] = "task", ["missoes"] = "task", ["tarefa"] = "task", ["tarefas"] = "task",
	["basico"] = "basics", ["basicos"] = "basics", ["tutorial"] = "basics",
	["vocacao"] = "vocation", ["classe"] = "vocation",
	["proximo"] = "next", ["proxima"] = "next", ["etapa"] = "next", ["passo"] = "next", ["proximo passo"] = "next", ["proxima etapa"] = "next",
	["curiosidade"] = "curiosity", ["informacao"] = "curiosity",
	["profissao"] = "profession", ["trabalho"] = "profession",
	["historia"] = "lore", ["nome"] = "lore",
	["tempo"] = "time", ["tempo de treino"] = "training time",
	["treinar"] = "train", ["treino"] = "train",
	["sim"] = "yes", ["nao"] = "no",
	["lista"] = "list", ["criaturas"] = "list", ["monstros"] = "list",
	["recompensa"] = "reward", ["terminar"] = "reward", ["completar"] = "reward", ["pronto"] = "reward",
	["pontos"] = "points", ["rank"] = "points", ["pontos de tarefa"] = "points", ["patente"] = "points",
	["progresso"] = "status", ["estado"] = "status"
}

local TEXTS = {
	greet = {
		en = "Attention, |NAME|! I am Brannoc, the Drillmaster. Ask me for a {task} to earn {training time}, or tell me my {lore}, {profession} or a {curiosity}. New here? Ask me about the {basics}.",
		pt = "Atencao, |NAME|! Eu sou Brannoc, o Mestre de Treino. Peca-me uma {tarefa} para ganhar {tempo de treino}, ou pergunte sobre minha {historia}, {profissao} ou uma {curiosidade}. Novo aqui? Pergunte sobre o {basico}."
	},
	farewell = {
		en = "Dismissed, |NAME|. Keep your guard up!",
		pt = "Dispensado, |NAME|. Mantenha a guarda alta!"
	},
	basics1 = {
		en = "Listen well, recruit. Every swing you land trains your weapon, but a drillmaster can do more: spend {training time} with me, say {train}, and the skill of the weapon in your hand grows.",
		pt = "Ouca bem, recruta. Cada golpe que voce acerta treina sua arma, mas um mestre de treino pode mais: gaste {tempo de treino} comigo, diga {treinar}, e a habilidade da arma em sua mao cresce."
	},
	basics2 = {
		en = "Training time is earned with {tasks}. Tell me the name of a creature, or say {list}, and I will ask you to kill a number of them. Come back and say {reward} to be paid in training time.",
		pt = "O tempo de treino e ganho com {tarefas}. Diga-me o nome de uma criatura, ou diga {lista}, e eu pedirei que mate um numero delas. Volte e diga {recompensa} para ser pago em tempo de treino."
	},
	basics3 = {
		en = "Every task also gives {task points}. Points raise your rank, and ranks unlock harder tasks, with me and with the other task masters, like old Garrick in the caves.",
		pt = "Toda tarefa tambem da {pontos de tarefa}. Os pontos elevam seu rank, e os ranks liberam tarefas mais dificeis, comigo e com os outros mestres de tarefas, como o velho Garrick nas cavernas."
	},
	questDurnok = {
		en = "Quest log updated: now speak with Durnok Runebrand, the dwarf runesmith, and ask about runes (say basics).",
		pt = "Quest log atualizado: agora fale com Durnok Runebrand, o anao das runas, e pergunte sobre as runas (diga basics)."
	},
	basicsGo = {
		en = "That is all I teach for free. Now go see Durnok Runebrand, the dwarf runesmith, and learn how runes work in this land.",
		pt = "Isso e tudo que ensino de graca. Agora va ver Durnok Runebrand, o anao das runas, e aprenda como as runas funcionam nesta terra."
	},
	basicsAgain = {
		en = "Say {basics} whenever you need to hear it again.",
		pt = "Diga {basico} sempre que precisar ouvir de novo."
	},
	noTutorial = {
		en = "You are not in the tutorial. Ask me for a {task} or about the {basics}.",
		pt = "Voce nao esta no tutorial. Peca-me uma {tarefa} ou pergunte sobre o {basico}."
	},
	questFirstHunt = {
		en = "Quest log updated: your first hunt! Ask Brannoc for a task (say the name of a creature, like rotworm), kill them and come back to say reward.",
		pt = "Quest log atualizado: a sua primeira caca! Peca uma task a Brannoc (diga o nome de uma criatura, como rotworm), mate-as e volte para dizer reward."
	},
	vocationGo = {
		en = "Enough talk. Ask me for a {task}, say the name of a creature, go hunt it and come back for your {reward}. That is your first hunt.",
		pt = "Chega de conversa. Peca-me uma {tarefa}, diga o nome de uma criatura, va cacar e volte para a sua {recompensa}. Essa e a sua primeira cacada."
	},
	vocationTail = {
		en = "Say !spells in the chat to see everything your vocation can cast. Say {vocation} whenever you need to hear this again.",
		pt = "Diga !spells no chat para ver tudo o que a sua vocacao pode conjurar. Diga {vocacao} sempre que precisar ouvir isto de novo."
	},
	questDone = {
		en = "Quest log updated: tutorial complete! You know the races, training, tasks, runes, prey, contracts and your vocation, and you finished your first hunt.",
		pt = "Quest log atualizado: tutorial completo! Voce conhece as racas, o treino, as tasks, as runas, a prey, os contratos e a sua vocacao, e terminou a sua primeira cacada."
	},
	tips1 = {
		en = "Well hunted, recruit. One last lesson: type !autoloot add gold coin in the chat and what you list is taken from the corpses by itself. Use !autoloot to see the other options.",
		pt = "Bem cacado, recruta. Uma ultima licao: digite !autoloot add gold coin no chat e o que voce listar sera pego dos corpos sozinho. Use !autoloot para ver as outras opcoes."
	},
	tips2 = {
		en = "And be warned: dying costs experience and may cost items. Do not hunt what you cannot beat. Type !help in the chat for a guide to every system of this land, from glyphs to enchantments.",
		pt = "E fique avisado: morrer custa experiencia e pode custar itens. Nao cace o que voce nao pode vencer. Digite !help no chat para um guia de todos os sistemas desta terra, dos glifos aos encantamentos."
	},
	curiosity = {
		en = "A curiosity, eh? Out in the hunting grounds there is an old warrior called Garrick who hands out tasks for every beast of the caves. The more task points you earn, the more tasks he unlocks. Even the ranks you earn are shared with the other task masters!",
		pt = "Uma curiosidade, hein? La fora, nas terras de caca, ha um velho guerreiro chamado Garrick que passa tarefas para cada fera das cavernas. Quanto mais pontos de tarefa voce ganha, mais tarefas ele libera. Ate os ranks que voce conquista sao compartilhados com os outros mestres de tarefas!"
	},
	profession = {
		en = "I am a Drillmaster: I turn sweat into skill. I do not teach moves, I trade {training time} for hunts. Bring me proof of your work and I will drill you with the weapon in your hands.",
		pt = "Sou um Mestre de Treino: transformo suor em habilidade. Nao ensino golpes, troco {tempo de treino} por cacadas. Traga-me prova do seu trabalho e eu o treinarei com a arma em suas maos."
	},
	lore = {
		en = "I am Brannoc Ironhand, once the sergeant of the Styller guard. We trained recruits in this very temple yard, until the guard was disbanded. Since then I keep the old drills alive, for anyone willing to earn them.",
		pt = "Eu sou Brannoc Ironhand, outrora sargento da guarda de Styller. Treinavamos recrutas neste mesmo patio do templo, ate a guarda ser dissolvida. Desde entao mantenho os velhos treinos vivos, para quem estiver disposto a merece-los."
	},
	timeStored = {
		en = "You have TIME of training time stored. Say {train} to use it with the weapon you are holding.",
		pt = "Voce tem TIME de tempo de treino guardado. Diga {treinar} para usa-lo com a arma que esta segurando."
	},
	noTime = {
		en = "You have no training time. Ask me for a {task} to earn some.",
		pt = "Voce nao tem tempo de treino. Peca-me uma {tarefa} para ganhar um pouco."
	},
	trained = {
		en = "Hup, hup! Your training with SKILL is done: you gained TOTAL skill tries MANA. You have LEFT left.",
		pt = "Hup, hup! Seu treino de SKILL terminou: voce ganhou TOTAL tentativas de skill MANA. Restam LEFT."
	},
	trainedMana = {
		en = " (MANA mana spent)",
		pt = " (MANA de mana gasta)"
	},
	taskIntro = {
		en = "Missions, eh? I have drills for those who hunt {rotworm}, {minotaur}, {amazon} and {orc}. Each of them gives you 15 minutes of {training time}, but only once! Tell me the creature or say {list}.",
		pt = "Missoes, hein? Tenho treinos para quem caca {rotworm}, {minotaur}, {amazon} e {orc}. Cada um deles da 15 minutos de {tempo de treino}, mas so uma vez! Diga-me a criatura ou diga {lista}."
	},
	accepted = {
		en = "Task accepted! Kill {KILLS NAME} and come back to receive your reward.",
		pt = "Tarefa aceita! Mate {KILLS NAME} e volte para receber sua recompensa."
	},
	declined = {
		en = "Alright, nothing changed.",
		pt = "Certo, nada mudou."
	},
	rewardOk = {
		en = "Well done! Here is your reward: REWARD and {POINTS task points}.",
		pt = "Muito bem! Aqui esta sua recompensa: REWARD e {POINTS pontos de tarefa}."
	},
	newRank = {
		en = " You are now a RANK! New tasks were unlocked, say {list} to see them.",
		pt = " Agora voce e RANK! Novas tarefas foram liberadas, diga {lista} para ve-las."
	},
	anotherTask = {
		en = " Tell me another creature if you want a new task.",
		pt = " Diga-me outra criatura se quiser uma nova tarefa."
	},
	noFinished = {
		en = "You have no finished task.",
		pt = "Voce nao tem nenhuma tarefa terminada."
	},
	noRoom = {
		en = "You do not have room (or capacity) for the reward. Make some space and talk to me again.",
		pt = "Voce nao tem espaco (ou capacidade) para a recompensa. Abra espaco e fale comigo de novo."
	},
	points = {
		en = "You have POINTS task points and your rank is RANK.",
		pt = "Voce tem POINTS pontos de tarefa e seu rank e RANK."
	},
	pointsNext = {
		en = " MISSING more points to become NEXT and unlock new tasks.",
		pt = " Faltam MISSING pontos para se tornar NEXT e liberar novas tarefas."
	},
	pointsMax = {
		en = " You reached the highest rank!",
		pt = " Voce alcancou o maior rank!"
	},
	available = {
		en = "Available tasks:",
		pt = "Tarefas disponiveis:"
	},
	locked = {
		en = "There are more creatures I could send you after, but you are not strong enough yet. Raise your rank with more task points and I will unlock new tasks for you.",
		pt = "Ha mais criaturas atras das quais eu poderia mandar voce, mas voce ainda nao e forte o bastante. Suba seu rank com mais pontos de tarefa e eu liberarei novas tarefas."
	},
	noTask = {
		en = "You have no task. Tell me the name of a creature, or say {list} to see all of them.",
		pt = "Voce nao tem tarefa. Diga-me o nome de uma criatura, ou diga {lista} para ver todas."
	},
	taskDone = {
		en = "You finished the task of NAMEs! Say {reward} to receive REWARD.",
		pt = "Voce terminou a tarefa de NAMEs! Diga {recompensa} para receber REWARD."
	},
	taskProgress = {
		en = "Your task: kill KILLS NAMEs. Progress: DONE/KILLS.",
		pt = "Sua tarefa: matar KILLS NAMEs. Progresso: DONE/KILLS."
	},
	alreadyDone = {
		en = "You already did that drill, NAMEs are done. I do not repeat missions. Try another creature, say {list}.",
		pt = "Voce ja fez esse treino, os NAMEs estao feitos. Nao repito missoes. Tente outra criatura, diga {lista}."
	},
	notReady = {
		en = "You are not ready to hunt NAMEs yet. You need REQUIRED task points (you have POINTS). Finish easier tasks to earn more, say {list} to see them.",
		pt = "Voce ainda nao esta pronto para cacar NAMEs. Precisa de REQUIRED pontos de tarefa (voce tem POINTS). Termine tarefas mais faceis para ganhar mais, diga {lista} para ve-las."
	},
	alreadyHunting = {
		en = "You are already hunting NAMEs (KILLS/TOTAL).",
		pt = "Voce ja esta cacando NAMEs (KILLS/TOTAL)."
	},
	offer = {
		en = "Do you want to start the task: {kill KILLS NAMEs} for the reward of {REWARD} and POINTS task points? {yes} or {no}.",
		pt = "Quer comecar a tarefa: {matar KILLS NAMEs} pela recompensa de {REWARD} e POINTS pontos de tarefa? {sim} ou {nao}."
	},
	warning = {
		en = " WARNING: your current task (NAMEs, STATE) will be reset if you accept this one!",
		pt = " AVISO: sua tarefa atual (NAMEs, STATE) sera perdida se voce aceitar esta!"
	},
	stateDone = {
		en = "finished, reward not delivered",
		pt = "terminada, recompensa nao entregue"
	}
}

-- what each vocation is about (keys are the base vocations: a promoted one uses the one it comes from). Two lines each.
local VOCATIONS = {
	[0] = {
		en = {"You have no calling yet. Train your fists and your wits, and the road will show you one.", "Until then, hunt the weak ones and learn how each creature fights."},
		pt = {"Voce ainda nao tem um chamado. Treine os punhos e a mente, e o caminho lhe mostrara um.", "Ate la, cace os fracos e aprenda como cada criatura luta."}
	},
	[1] = {
		en = {"A sorcerer lives by raw magic: great damage from a distance, with fire, energy and death. Few hit points, so keep your distance.", "Your mana is your weapon: watch it, and drink a potion before it runs dry."},
		pt = {"O sorcerer vive da magia bruta: muito dano a distancia, com fogo, energia e morte. Pouca vida, entao mantenha a distancia.", "A sua mana e a sua arma: vigie-a e beba uma pocao antes que ela acabe."}
	},
	[2] = {
		en = {"A druid heals and controls with ice and earth. Your spells mend you and your allies and slow or hold the enemy.", "You hit less than a sorcerer, but you last much longer."},
		pt = {"O druid cura e controla com gelo e terra. Suas magias curam voce e seus aliados e retardam ou prendem o inimigo.", "Voce bate menos que o sorcerer, mas dura muito mais."}
	},
	[3] = {
		en = {"A paladin fights from afar with distance weapons and holy magic. Keep a supply of ammunition and never let the enemy reach you.", "Retreating and shooting again is the whole art."},
		pt = {"O paladin luta de longe com armas de distancia e magia sagrada. Tenha sempre municao e nunca deixe o inimigo chegar em voce.", "Recuar e atirar de novo e toda a arte."}
	},
	[4] = {
		en = {"A knight stands in front: lots of hit points, heavy armor and strong blows in melee. You take the hits so that the others do not.", "Choose a weapon, a sword, an axe or a club, and train it with me."},
		pt = {"O knight fica na frente: muita vida, armadura pesada e golpes fortes no corpo a corpo. Voce leva os golpes para que os outros nao levem.", "Escolha uma arma, espada, machado ou clava, e treine-a comigo."}
	},
	[9] = {
		en = {"A cleric is the holy mage of the group. Almost every spell of yours does two things at once: it hurts the enemy and helps an ally.", "Medium range and medium areas: stay close to your friends, and the spells do the rest."},
		pt = {"O cleric e o mago sagrado do grupo. Quase toda magia sua faz duas coisas ao mesmo tempo: fere o inimigo e ajuda um aliado.", "Alcance medio e areas medias: fique perto dos amigos, e as magias fazem o resto."}
	},
	[11] = {
		en = {"A necromancer raises the dead. Spells of death and poison, and summons raised from corpses and souls that fight at your side.", "Souls do not come back by themselves: they come only from your passive, so spend them with care."},
		pt = {"O necromancer levanta os mortos. Magias de morte e veneno, e invocacoes levantadas de corpos e souls que lutam ao seu lado.", "As souls nao voltam sozinhas: vem so da sua passiva, entao gaste-as com cuidado."}
	},
	[13] = {
		en = {"An assassin is a duelist of twin blades: fragile, fast and deadly in bursts. You are the only one who can wield two swords at once.", "You win by Momentum, dodging and finishing blows, not by taking damage."},
		pt = {"O assassin e um duelista de laminas gemeas: fragil, rapido e mortal em rajadas. Voce e o unico que pode empunhar duas espadas ao mesmo tempo.", "Voce vence pelo Momentum, pela esquiva e pelos golpes finais, nao por aguentar dano."}
	},
	[15] = {
		en = {"A berserker is an axe warrior with two-handed weapons, and can even carry a shield with them. Your spells cost hit points, not mana.", "You leech life on every blow and hit harder the less life you have. Stay on the edge."},
		pt = {"O berserker e um guerreiro de machado com armas de duas maos, e ainda pode levar um escudo junto. Suas magias custam vida, nao mana.", "Voce rouba vida a cada golpe e bate mais forte quanto menos vida tem. Viva na beira do abismo."}
	},
	[17] = {
		en = {"An archer is an elemental bowman. Your arrows are physical, but you can choose an enchantment (fire, poison, ice or lightning) and all your spells change with it.", "Weak up close: win by position, stepping back, trapping and controlling the enemy."},
		pt = {"O archer e um arqueiro elemental. Suas flechas sao fisicas, mas voce pode escolher um encantamento (fogo, veneno, gelo ou raio) e todas as suas magias mudam com ele.", "Fragil de perto: vence pelo posicionamento, recuando, prendendo e controlando o inimigo."}
	},
	[19] = {
		en = {"A geomancer is a heavy mage-tank of stone. Most of your damage is physical, and a gem in the arrow slot turns half of it into the element of the gem.", "You raise crystals that block the way, even for your friends, and they fade after a while."},
		pt = {"O geomancer e um mago-tanque pesado de pedra. Quase todo o seu dano e fisico, e uma gema no slot da flecha transforma metade dele no elemento da gema.", "Voce levanta cristais que bloqueiam o caminho, ate dos amigos, e eles somem depois de um tempo."}
	}
}

local function getVocationBrief(cid)
	local vocation = getPlayerVocation(cid)
	local info = getVocationInfo(vocation)
	local base = info and info.fromVocation or vocation
	return VOCATIONS[base] or VOCATIONS[vocation] or VOCATIONS[0]
end

-- replaces the markers (KILLS, NAME...) of a text by the values of the table. Values are plain (no pattern characters)
local function fill(value, replaces)
	for key, replace in pairs(replaces) do
		value = value:gsub(key, function() return tostring(replace) end)
	end

	return value
end

-- the text of the language of cid, with |NAME| replaced and the optional markers filled
local function text(cid, texts, replaces)
	local value = Language.text(cid, texts):gsub("|NAME|", function() return getCreatureName(cid) end)
	if(replaces) then
		value = fill(value, replaces)
	end

	return value
end

local function say(cid, texts, replaces)
	npcHandler:say(text(cid, texts, replaces), cid)
end

local function isPt(cid)
	return Language.get(cid) == LANGUAGE_PORTUGUESE
end

-- says "prefix" followed by the entries, splitting in several messages to keep each one short
local function sayList(cid, prefix, entries)
	local part = prefix
	for _, entry in ipairs(entries) do
		if(#part + #entry + 2 > 200) then
			npcHandler:say(part, cid)
			part = ""
		end

		part = part .. " " .. entry
	end

	npcHandler:say(part, cid)
end

local function timeText(cid, seconds)
	if(not isPt(cid)) then
		return Training.timeText(seconds)
	end

	local minutes, secs = math.floor(seconds / 60), seconds % 60
	if(minutes > 0 and secs > 0) then
		return minutes .. " minutos e " .. secs .. " segundos"
	elseif(minutes > 0) then
		return minutes .. " minutos"
	end

	return secs .. " segundos"
end

local function rewardText(cid, reward)
	if(not isPt(cid)) then
		return Tasks.rewardText(reward)
	end

	if(reward.type == "gold") then
		return reward.amount .. " moedas de ouro"
	elseif(reward.type == "experience") then
		return reward.amount .. " pontos de experiencia"
	elseif(reward.type == "training") then
		return reward.minutes .. " minutos de tempo de treino"
	end

	return reward.amount .. "x " .. (reward.label or "itens")
end

local function pointsText(cid)
	local value = text(cid, TEXTS.points, {POINTS = Tasks.getPoints(cid), RANK = Tasks.getRank(cid)})
	local missing, nextRank = Tasks.getNextTier(cid)
	if(missing) then
		return value .. text(cid, TEXTS.pointsNext, {MISSING = missing, NEXT = nextRank})
	end

	return value .. text(cid, TEXTS.pointsMax)
end

-- the messages Tasks.finish returns on failure are in english: translated here
local function finishError(cid, message)
	if(message == "You have no finished task.") then
		return text(cid, TEXTS.noFinished)
	elseif(message:find("room", 1, true)) then
		return text(cid, TEXTS.noRoom)
	end

	return message
end

-- task of the trainer by what the player said ("rotworm", "rotworms"...). The keys of his tasks are "trainer <creature>"
local function findTask(value)
	local key, task = Tasks.find("trainer " .. value:lower():trim())
	if(key) then
		return key, task
	end
end

local function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	msg = msg:lower():trim()
	msg = ALIASES[msg] or msg
	local key, task, kills, done = Tasks.get(cid)

	-- "mission(s)" works like "task"
	if(msg == "mission" or msg == "missions") then
		msg = "task"
	end

	-- explanation of the training and the tasks (step 2 of the tutorial quest, see data/lib/201-tutorial.lua)
	if(msg == "basics") then
		say(cid, TEXTS.basics1)
		say(cid, TEXTS.basics2)
		say(cid, TEXTS.basics3)
		if(doPlayerAdvanceTutorialQuest(cid, 2, TEXTS.questDurnok)) then
			say(cid, TEXTS.basicsGo)
		else
			say(cid, TEXTS.basicsAgain)
		end

		return true
	end

	-- next step of the tutorial quest
	if(msg == "next" or msg == "step") then
		local hint = getPlayerTutorialHint(cid, "Brannoc")
		npcHandler:say(hint or Language.text(cid, TEXTS.noTutorial), cid)
		return true
	end

	-- explanation of the vocation the player already has (step 5 of the tutorial quest)
	if(msg == "vocation" or msg == "class") then
		for _, line in ipairs(Language.text(cid, getVocationBrief(cid))) do
			npcHandler:say(line, cid)
		end

		if(doPlayerAdvanceTutorialQuest(cid, 5, TEXTS.questFirstHunt)) then
			say(cid, TEXTS.vocationGo)
		else
			say(cid, TEXTS.vocationTail)
		end

		return true
	end

	if(msg == "information" or msg == "info" or msg == "curiosity") then
		say(cid, TEXTS.curiosity)
		return true
	elseif(msg == "profession" or msg == "job" or msg == "occupation") then
		say(cid, TEXTS.profession)
		return true
	elseif(msg == "lore" or msg == "story" or msg == "history" or msg == "name") then
		say(cid, TEXTS.lore)
		return true
	elseif(msg == "time" or msg == "training time") then
		say(cid, TEXTS.timeStored, {TIME = timeText(cid, Training.getTime(cid))})
		return true
	elseif(msg == "train" or msg == "training") then
		local weapon = Training.getType(cid)
		local tries, skill, total = Training.use(cid)
		if(not tries) then
			say(cid, TEXTS.noTime)
		else
			doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
			local mana = ""
			if(weapon.skill == SKILL__MAGLEVEL) then
				mana = text(cid, TEXTS.trainedMana, {MANA = total * Training.manaPerTry})
			end

			say(cid, TEXTS.trained, {SKILL = skill, TOTAL = total, MANA = mana, LEFT = timeText(cid, Training.getTime(cid))})
		end

		return true
	elseif(msg == "task" and not key) then
		say(cid, TEXTS.taskIntro)
		return true
	end

	-- answering the offer
	if(talks[cid]) then
		local offered = talks[cid]
		if(msg == "yes") then
			talks[cid] = nil
			Tasks.start(cid, offered)
			local t = Tasks.list[offered]
			say(cid, TEXTS.accepted, {KILLS = t.kills, NAME = t.name .. "s"})
			return true
		elseif(msg == "no") then
			talks[cid] = nil
			say(cid, TEXTS.declined)
			return true
		end
	end

	-- finished task: deliver it
	-- (also when the player says the name of the creature of the finished task)
	if(done and (msg == "task" or msg == "reward" or msg == "finish" or msg == "done" or msg == "complete" or findTask(msg) == key)) then
		talks[cid] = nil
		local ok, points, newRank = Tasks.finish(cid)
		if(ok) then
			doSendMagicEffect(getCreaturePosition(cid), CONST_ME_FIREWORK_YELLOW)
			local value = text(cid, TEXTS.rewardOk, {REWARD = rewardText(cid, task.reward), POINTS = points})
			if(newRank) then
				value = value .. text(cid, TEXTS.newRank, {RANK = newRank})
			else
				value = value .. text(cid, TEXTS.anotherTask)
			end

			npcHandler:say(value, cid)
			-- the first finished task closes the tutorial quest (step 6)
			if(doPlayerAdvanceTutorialQuest(cid, 6, TEXTS.questDone)) then
				say(cid, TEXTS.tips1)
				say(cid, TEXTS.tips2)
			end
		else
			npcHandler:say(finishError(cid, points), cid)
		end

		return true
	end

	if(msg == "points" or msg == "rank" or msg == "task points") then
		npcHandler:say(pointsText(cid), cid)
		return true
	end

	if(msg == "list" or msg == "tasks" or msg == "creatures" or msg == "monsters") then
		local available, locked = {}, {}
		for _, k in ipairs(Tasks.order) do
			local t = Tasks.list[k]
			if(Tasks.offeredBy("trainer", k)) then
				if(t.once and Training.isDone(cid, k)) then
					-- already completed, never offered again
				elseif(Tasks.isUnlocked(cid, k)) then
					table.insert(available, "{" .. t.name .. "},")
				else
					table.insert(locked, t.name .. " (" .. Tasks.tiers[t.tier].required .. "),")
				end
			end
		end

		sayList(cid, text(cid, TEXTS.available), available)
		if(#locked > 0) then
			say(cid, TEXTS.locked)
		end

		npcHandler:say(pointsText(cid), cid)
		return true
	end

	if(msg == "status" or msg == "progress" or msg == "task") then
		if(not key) then
			npcHandler:say(text(cid, TEXTS.noTask) .. " " .. pointsText(cid), cid)
		elseif(done) then
			say(cid, TEXTS.taskDone, {NAME = task.name, REWARD = rewardText(cid, task.reward)})
		else
			say(cid, TEXTS.taskProgress, {KILLS = task.kills, NAME = task.name, DONE = kills})
		end

		return true
	end

	local newKey, newTask = findTask(msg)
	if(not newKey or not Tasks.offeredBy("trainer", newKey)) then
		return false
	end

	if(newTask.once and Training.isDone(cid, newKey)) then
		say(cid, TEXTS.alreadyDone, {NAME = newTask.name})
		return true
	end

	if(not Tasks.isUnlocked(cid, newKey)) then
		say(cid, TEXTS.notReady, {NAME = newTask.name, REQUIRED = Tasks.tiers[newTask.tier].required, POINTS = Tasks.getPoints(cid)})
		return true
	end

	if(key == newKey and not done) then
		say(cid, TEXTS.alreadyHunting, {NAME = task.name, KILLS = kills, TOTAL = task.kills})
		return true
	end

	talks[cid] = newKey
	local value = text(cid, TEXTS.offer, {KILLS = newTask.kills, NAME = newTask.name, REWARD = rewardText(cid, newTask.reward), POINTS = Tasks.tiers[newTask.tier].points})
	if(key) then
		local state = done and text(cid, TEXTS.stateDone) or (kills .. "/" .. task.kills)
		value = value .. text(cid, TEXTS.warning, {NAME = task.name, STATE = state})
	end

	npcHandler:say(value, cid)
	return true
end

local function onFarewell(cid)
	talks[cid] = nil
	return true
end

-- greeting and farewell depend on the language of who is talking
local function onGreet(cid)
	npcHandler:setMessage(MESSAGE_GREET, (text(cid, TEXTS.greet):gsub("%%", "%%%%")))
	npcHandler:setMessage(MESSAGE_FAREWELL, (text(cid, TEXTS.farewell):gsub("%%", "%%%%")))
	doNpcTutorialHintLater(npcHandler, cid, "Brannoc") -- tells the next step of the tutorial, if the player is in it
	return true
end

npcHandler:setCallback(CALLBACK_GREET, onGreet)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_FAREWELL, onFarewell)
npcHandler:addModule(FocusModule:new())
