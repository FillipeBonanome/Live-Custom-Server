-- Durnok Runebrand, the runesmith. Carves the enchantment runes (blank rune + gold + gems, see lib/399-runecarving.lua).
-- Tier 1 runes for everybody; the next tiers need the respect of the NPC, earned delivering the items of his missions.
-- Speaks the language chosen by the player (data/lib/202-language.lua). Names of runes, items, tiers and ranks are not translated.
-- Texts have no accents on purpose (encoding of the files).
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- what each player is being asked: {name = "Flaming"}
local talks = {}

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end

-- portuguese keyword -> english keyword
local ALIASES = {
	["nome"] = "name", ["basico"] = "basics", ["encantamento"] = "enchantment", ["encantamentos"] = "enchantments",
	["profissao"] = "profession", ["ferreiro"] = "runesmith", ["runa em branco"] = "blank rune", ["runa"] = "blank rune",
	["runas"] = "runes", ["esculpir"] = "carve", ["respeito"] = "respect", ["missao"] = "mission", ["missoes"] = "missions",
	["tarefa"] = "task", ["entregar"] = "deliver", ["pronto"] = "done", ["lista"] = "list", ["preco"] = "price",
	["precos"] = "prices", ["custo"] = "cost", ["sim"] = "yes", ["nao"] = "no"
}

local TEXTS = {
	greet = {
		en = "Ha! Another pair of hands that wants the stone to sing, |NAME|? I am Durnok Runebrand. Bring me a {blank rune}, gold and gems and I will {carve} you a rune. Or earn my {respect} and I will teach you the old, mighty ones. New to runes? Ask me about the {basics}.",
		pt = "Ha! Mais um par de maos que quer fazer a pedra cantar, |NAME|? Eu sou Durnok Runebrand. Traga-me uma {runa em branco}, ouro e gemas e eu {esculpirei} uma runa para ti. Ou ganhe o meu {respeito} e eu te ensinarei as antigas e poderosas. Novo nas runas? Pergunte sobre o {basico}."
	},
	farewell = {
		en = "Strike true and stand tall, |NAME|! The mountain remembers those who do not flinch.",
		pt = "Golpeie com firmeza e erga-se, |NAME|! A montanha lembra dos que nao recuam."
	},
	walkaway = {
		en = "Even the finest chisel rests sometimes. Come back when you are ready.",
		pt = "Ate o melhor cinzel descansa as vezes. Volte quando estiver pronto."
	},
	carved = {
		en = "Hah! Listen to it hum. A {RUNE} rune, fresh from the anvil. Use it on gear with a free slot, and make the enemy regret it!",
		pt = "Hah! Ouca-a zumbir. Uma runa {RUNE}, fresquinha da bigorna. Use-a em um equipamento com slot livre, e faca o inimigo se arrepender!"
	},
	comeBack = {
		en = " Come back when you have it all, I am not going anywhere.",
		pt = " Volte quando tiver tudo, eu nao vou a lugar nenhum."
	},
	declined = {
		en = "No shame in thinking twice. A rushed rune is a broken rune.",
		pt = "Nao ha vergonha em pensar duas vezes. Runa apressada e runa quebrada."
	},
	name = {
		en = "Durnok Runebrand, last keeper of the Brand-Forge. My beard is older than this city's walls, and my chisel is older than my beard.",
		pt = "Durnok Runebrand, ultimo guardiao da Forja-Brand. Minha barba e mais velha que as muralhas desta cidade, e meu cinzel e mais velho que minha barba."
	},
	basics1 = {
		en = "Hear me, young one. Runes here are not spells: nobody casts them anymore. A rune is an {enchantment} carved in stone, and once it sits on a piece of gear, it stays there forever.",
		pt = "Escute, jovem. As runas aqui nao sao magias: ninguem mais as conjura. Uma runa e um {encantamento} esculpido na pedra, e uma vez posta em um equipamento, la fica para sempre."
	},
	basics2 = {
		en = "Gear with a rarity (uncommon, rare, epic or legendary) has free slots, the higher the rarity the more slots. Use a carved rune on the item and a slot is filled with a permanent bonus.",
		pt = "Equipamentos com raridade (uncommon, rare, epic ou legendary) tem slots livres, e quanto maior a raridade, mais slots. Use uma runa esculpida no item e um slot e preenchido com um bonus permanente."
	},
	basics3 = {
		en = "I do not hand them out. Buy a {blank rune} from the rune merchants, bring gold and gems of the element, and say the name of a rune, like {Flaming}. I will explain it and carve it for you.",
		pt = "Eu nao as distribuo. Compre uma {runa em branco} com os mercadores de runas, traga ouro e gemas do elemento, e diga o nome de uma runa, como {Flaming}. Eu a explicarei e a esculpirei para ti."
	},
	basics4 = {
		en = "The simple runes are for everyone. The mighty ones need my {respect}, earned with {missions}. Say {list} for what I carve for you, {price} for what it costs.",
		pt = "As runas simples sao para todos. As poderosas exigem o meu {respeito}, ganho com {missoes}. Diga {lista} para o que esculpo para ti, {preco} para o que custa."
	},
	questDone = {
		en = "Quest updated: tutorial complete! You know the races, training, tasks and runes.",
		pt = "Quest atualizada: tutorial completo! Voce conhece as racas, o treino, as tasks e as runas."
	},
	basicsEnd = {
		en = "That is all, young one. The mountain thanks you for listening.",
		pt = "E tudo, jovem. A montanha agradece por ouvir."
	},
	job = {
		en = "I wake the sleeping power in blank stone. Anyone can swing a sword, but a rune carries a piece of the mountain's heart. That is craft!",
		pt = "Eu desperto o poder adormecido na pedra em branco. Qualquer um balanca uma espada, mas uma runa carrega um pedaco do coracao da montanha. Isso e oficio!"
	},
	blank = {
		en = "Bring me a {blank rune} (the rune merchants sell them), some gold and gems of the element, and say the name of the rune you want, I will tell you what it does. Say {list} to hear which ones I know.",
		pt = "Traga-me uma {runa em branco} (os mercadores de runas as vendem), um pouco de ouro e gemas do elemento, e diga o nome da runa que quer, eu direi o que ela faz. Diga {lista} para ouvir quais eu conheco."
	},
	respectText = {
		en = "Your rank is {RANK} with RESPECT respect. I carve {TIER} runes and the ones below.",
		pt = "Seu rank e {RANK} com RESPECT de respeito. Eu esculpo runas {TIER} e as abaixo dela."
	},
	respectNext = {
		en = " MISSING more respect and I will carve TIER runes for you.",
		pt = " Mais MISSING de respeito e eu esculpirei runas TIER para ti."
	},
	respectMax = {
		en = " There is nothing left I can teach you, the stone itself bows to you.",
		pt = " Nao ha mais nada que eu possa te ensinar, a propria pedra se curva a ti."
	},
	noMissions = {
		en = "You have delivered everything I asked. I have no more missions, only respect for you.",
		pt = "Voce entregou tudo o que pedi. Nao tenho mais missoes, apenas respeito por ti."
	},
	missionTail = {
		en = " Say {deliver} when you have them. It is worth RESPECT respect.",
		pt = " Diga {entregar} quando os tiver. Vale RESPECT de respeito."
	},
	deliverOk = {
		en = "Now THAT is quality! You earned {GAINED respect}.",
		pt = "Agora ISSO e qualidade! Voce ganhou {GAINED de respeito}."
	},
	deliverRank = {
		en = " From today you are {RANK}, and the stronger runes are yours to command. Say {list} to see them!",
		pt = " A partir de hoje voce e {RANK}, e as runas mais fortes sao suas para comandar. Diga {lista} para ve-las!"
	},
	listTier = {
		en = "TIER runes:",
		pt = "Runas TIER:"
	},
	listMore = {
		en = "There are mightier runes, but you have not earned my {respect} for them yet.",
		pt = "Existem runas mais poderosas, mas voce ainda nao ganhou o meu {respeito} para elas."
	},
	price = {
		en = "The price of a rune: LINES The gem depends on the element.",
		pt = "O preco de uma runa: LINES A gema depende do elemento."
	},
	priceLine = {
		en = "TIER: GOLD gold, GEMS gems.",
		pt = "TIER: GOLD de ouro, GEMS gemas."
	},
	runeIntro = {
		en = "The {RUNE} rune, TIER work. DESCRIPTION",
		pt = "A runa {RUNE}, trabalho TIER. DESCRIPTION"
	},
	needRespect = {
		en = "But I do not hand such power to someone who has not earned my {respect}. Ask me for a {mission}!",
		pt = "Mas nao entrego tal poder a quem nao ganhou o meu {respeito}. Peca-me uma {missao}!"
	},
	offer = {
		en = "I need 1 blank rune, GEMS ITEMs and GOLD gold coins. Shall I start? {yes} or {no}.",
		pt = "Preciso de 1 blank rune, GEMS ITEMs e GOLD moedas de ouro. Devo comecar? {sim} ou {nao}."
	},
	errBlank = {
		en = "You need a blank rune.",
		pt = "Voce precisa de uma blank rune."
	},
	errNoRune = {
		en = "There is no rune with this name.",
		pt = "Nao existe runa com esse nome."
	},
	errRoom = {
		en = "You have no room (or capacity) for the rune.",
		pt = "Voce nao tem espaco (ou capacidade) para a runa."
	},
	errNeedGold = {
		en = "You need AMOUNT gold coins.",
		pt = "Voce precisa de AMOUNT moedas de ouro."
	},
	errNeedItem = {
		en = "You need AMOUNT ITEM.",
		pt = "Voce precisa de AMOUNT ITEM."
	},
	errNoMissions = {
		en = "You have no missions left.",
		pt = "Voce nao tem mais missoes."
	}
}

-- the missions of lib/399-runecarving.lua, by position (the english text is in the lib). Item names are not translated
local MISSIONS_PT = {
	"Minhas botas estao gastas de andar na pedra fria. Traga-me {30 minotaur leathers} e as consertarei.",
	"Uma boa ferramenta de esculpir precisa de um cabo escamado. Traga-me {30 lizard scales} dos pantanos.",
	"O inverno esta chegando e a forja esta fria. Traga-me {40 wolf paws}, farei amuletos com elas.",
	"Uma runa deve ser atada com seda que nunca rompe. Traga-me {25 giant spider silks}.",
	"Preciso de olhos que vejam o que a pedra esconde. Traga-me {20 beholder eyes}.",
	"O fogo de dragao tempera os melhores cinzeis. Traga-me {10 red dragon scales}.",
	"Meu estandarte queimou no ultimo incendio. Traga-me {15 red pieces of cloth}.",
	"Agora o trabalho de verdade. Os poderes antigos se escondem no osso de demonio. Traga-me {10 demon horns}.",
	"Runas lendarias bebem essencia. Traga-me {30 demonic essences}.",
	"So as feras mais fortes deixam tais trofeus. Traga-me {5 perfect behemoth fangs}.",
	"A maior prova de todas: mate o senhor das chamas e traga-me {3 Morgaroth's hearts}.",
	"Uma ultima coisa, e entao a propria montanha conhecera o seu nome: {10 soul orbs}."
}

-- what each enchantment does, in portuguese (the english ones are in the lib)
local DESCRIPTIONS_PT = {
	["Venomous"] = "Seus golpes envenenam o inimigo com um pouco de dano de terra (armas).",
	["Blight"] = "Seus ataques perfuram a resistencia a terra (elmo, armadura, calcas, botas).",
	["Stoneskin"] = "Endurece seu equipamento com +2 de armadura (elmo, armadura, calcas, botas, escudo).",
	["Flaming"] = "Seus golpes queimam com um pouco de dano de fogo (armas).",
	["Inferno"] = "Seus ataques perfuram a resistencia a fogo (elmo, armadura, calcas, botas).",
	["Fireball"] = "+4 de ataque (espadas, clavas, machados).",
	["Shocking"] = "Seus golpes chocam com um pouco de dano de energia (armas).",
	["Storm"] = "Seus ataques perfuram a resistencia a energia (elmo, armadura, calcas, botas).",
	["Frost"] = "Seus golpes gelam com um pouco de dano de gelo (armas).",
	["Glacial"] = "Seus ataques perfuram a resistencia a gelo (elmo, armadura, calcas, botas).",
	["Clearing"] = "Pes leves: +20 de velocidade (botas).",
	["Holy"] = "Seus golpes carregam dano sagrado (armas).",
	["Purity"] = "Uma pequena chance de esquiva (elmo, armadura, calcas, botas, escudo).",
	["Vitality"] = "+40 de vida maxima (elmo, armadura, calcas, botas).",
	["Piercing"] = "Seus tiros perfuram a resistencia fisica (armas de distancia e varinhas).",
	["Toxic"] = "Veneno mais forte nos golpes e alguma penetracao de terra (armas).",
	["Earthen"] = "+2 de armadura bonus e +30 de vida maxima (elmo, armadura, calcas, botas, escudo).",
	["Overgrowth"] = "+25 de vida maxima e +1 de defesa bonus (elmo, armadura, calcas, botas).",
	["Scorching"] = "Fogo mais forte nos golpes e alguma penetracao de fogo (armas).",
	["Soulburn"] = "Rouba mana e da +30 de mana maxima (colar, anel).",
	["Overload"] = "Energia mais forte nos golpes e alguma penetracao de energia (armas).",
	["Thunder"] = "Golpes de energia com chance de critico (varinhas e armas de distancia).",
	["Warding"] = "+3 de defesa e bloqueia mais um golpe (escudo, armadura).",
	["Charm"] = "Um bonus na experiencia que voce ganha (colar, anel).",
	["Necrotic"] = "Rouba vida do inimigo (armas).",
	["Disintegrating"] = "Seus ataques perfuram a resistencia fisica (espadas, clavas, machados).",
	["Chameleon"] = "Mais chance de esquiva (elmo, armadura, calcas).",
	["Heavy Piercing"] = "Penetracao fisica mais forte e +3 de ataque (armas de distancia e varinhas).",
	["Explosive"] = "Mais chance de golpes criticos (espadas, clavas, machados, distancia).",
	["Meteor"] = "+7 de ataque e +5 de dano critico (espadas, clavas, machados).",
	["Combustion"] = "Fogo forte nos golpes e um pouco de chance de critico (armas).",
	["Lightning"] = "Energia forte nos golpes e +1 de skill de distancia (armas de distancia e varinhas).",
	["Prison"] = "Bloqueia mais 2 golpes (escudo, armadura, calcas).",
	["Rejuvenating"] = "+80 de vida maxima e mais cura critica (elmo, armadura, calcas, botas).",
	["Paralyzing"] = "Mais chance de critico e um pouco de esquiva (espadas, clavas, machados, distancia).",
	["Drunken"] = "+2 de skill de clava e machado (clavas, machados).",
	["Deadly"] = "Dano de morte nos golpes e +10 de dano critico (armas).",
	["Shadow"] = "Maior esquiva e +20 de velocidade (elmo, armadura, calcas, botas).",
	["Arcane"] = "+1 de nivel magico (varinhas, colar, anel)."
}

-- the text of the language of cid with |NAME| replaced and the markers (RUNE, TIER...) filled with the values
local function text(cid, texts, replaces)
	local value = Language.text(cid, texts):gsub("|NAME|", function() return getCreatureName(cid) end)
	for key, replace in pairs(replaces or {}) do
		value = value:gsub(key, function() return tostring(replace) end)
	end

	return value
end

local function say(cid, texts, replaces)
	npcHandler:say(text(cid, texts, replaces), cid)
end

local function isPt(cid)
	return Language.get(cid) == LANGUAGE_PORTUGUESE
end

-- says "prefix" and the entries, splitting in several messages to keep each one short
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

-- the failure messages of the lib (english) in the language of the player
local function translateError(cid, message)
	if(not isPt(cid)) then
		return message
	end

	if(message == "You need a blank rune.") then
		return text(cid, TEXTS.errBlank)
	elseif(message == "There is no rune with this name.") then
		return text(cid, TEXTS.errNoRune)
	elseif(message == "You have no room (or capacity) for the rune.") then
		return text(cid, TEXTS.errRoom)
	elseif(message == "You have no missions left.") then
		return text(cid, TEXTS.errNoMissions)
	end

	local amount = message:match("^You need (%d+) gold coins%.$")
	if(amount) then
		return text(cid, TEXTS.errNeedGold, {AMOUNT = amount})
	end

	local count, item = message:match("^You need (%d+) (.+)%.$")
	if(count) then
		return text(cid, TEXTS.errNeedItem, {AMOUNT = count, ITEM = item})
	end

	return message
end

local function respectText(cid)
	local respect = RuneCarving.getRespect(cid)
	local rank = RuneCarving.getRank(cid)
	local value = text(cid, TEXTS.respectText, {RANK = RuneCarving.ranks[rank].name, RESPECT = respect, TIER = RuneCarving.tiers[rank].name})
	local nextRank = RuneCarving.ranks[rank + 1]
	if(nextRank) then
		return value .. text(cid, TEXTS.respectNext, {MISSING = nextRank.respect - respect, TIER = RuneCarving.tiers[rank + 1].name})
	end

	return value .. text(cid, TEXTS.respectMax)
end

local function missionText(cid)
	local index = RuneCarving.currentMission(cid)
	if(not index) then
		return text(cid, TEXTS.noMissions)
	end

	local mission = RuneCarving.missions[index]
	local description = mission.text
	if(isPt(cid) and MISSIONS_PT[index]) then
		description = MISSIONS_PT[index]
	end

	return description .. text(cid, TEXTS.missionTail, {RESPECT = mission.respect})
end

local function runesOfTier(tierIndex)
	local names = {}
	for name, data in pairs(RuneCarving.recipes) do
		if(data[2] == tierIndex) then
			table.insert(names, name)
		end
	end

	table.sort(names)
	for index, name in ipairs(names) do
		names[index] = "{" .. name .. "},"
	end

	return names
end

local function runeDescription(cid, name)
	if(isPt(cid) and DESCRIPTIONS_PT[name]) then
		return DESCRIPTIONS_PT[name]
	end

	return RuneCarving.description(name)
end

local function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	msg = msg:lower():trim()
	msg = ALIASES[msg] or msg

	-- answering an offer
	local talk = talks[cid]
	if(talk) then
		if(msg == "yes") then
			talks[cid] = nil
			local ok, reason = RuneCarving.carve(cid, talk.name)
			if(ok) then
				say(cid, TEXTS.carved, {RUNE = talk.name})
			else
				npcHandler:say(translateError(cid, reason) .. text(cid, TEXTS.comeBack), cid)
			end

			return true
		elseif(msg == "no") then
			talks[cid] = nil
			say(cid, TEXTS.declined)
			return true
		end
	end

	if(msg == "name" or msg == "durnok") then
		say(cid, TEXTS.name)
	elseif(msg == "basics" or msg == "tutorial" or msg == "enchantment" or msg == "enchantments") then
		-- explanation of the modified rune system (step 3 of the tutorial quest, see data/lib/201-tutorial.lua)
		say(cid, TEXTS.basics1)
		say(cid, TEXTS.basics2)
		say(cid, TEXTS.basics3)
		say(cid, TEXTS.basics4)
		if(doPlayerAdvanceTutorialQuest(cid, 3, TEXTS.questDone)) then
			doSendMagicEffect(getCreaturePosition(cid), CONST_ME_FIREWORK_YELLOW)
			say(cid, TEXTS.basicsEnd)
		end
	elseif(msg == "job" or msg == "occupation" or msg == "profession" or msg == "runesmith") then
		say(cid, TEXTS.job)
	elseif(msg == "blank rune" or msg == "blank" or msg == "runes" or msg == "carve") then
		say(cid, TEXTS.blank)
	elseif(msg == "respect" or msg == "rank" or msg == "status") then
		npcHandler:say(respectText(cid), cid)
	elseif(msg == "mission" or msg == "missions" or msg == "task") then
		npcHandler:say(missionText(cid), cid)
	elseif(msg == "deliver" or msg == "done" or msg == "finish" or msg == "complete") then
		local ok, gained, newRank = RuneCarving.deliver(cid)
		if(ok) then
			doSendMagicEffect(getThingPosition(cid), CONST_ME_FIREWORK_YELLOW)
			local value = text(cid, TEXTS.deliverOk, {GAINED = gained})
			if(newRank) then
				value = value .. text(cid, TEXTS.deliverRank, {RANK = newRank})
			else
				value = value .. " " .. missionText(cid)
			end

			npcHandler:say(value, cid)
		else
			npcHandler:say(translateError(cid, gained) .. " " .. (RuneCarving.currentMission(cid) and missionText(cid) or ""), cid)
		end
	elseif(msg == "list" or msg == "rune list") then
		local rank = RuneCarving.getRank(cid)
		for index = 1, rank do
			sayList(cid, text(cid, TEXTS.listTier, {TIER = RuneCarving.tiers[index].name}), runesOfTier(index))
		end

		if(rank < #RuneCarving.tiers) then
			say(cid, TEXTS.listMore)
		end
	elseif(msg == "price" or msg == "prices" or msg == "cost") then
		local lines = {}
		for _, tier in ipairs(RuneCarving.tiers) do
			table.insert(lines, text(cid, TEXTS.priceLine, {TIER = tier.name, GOLD = tier.gold, GEMS = tier.gems}))
		end

		say(cid, TEXTS.price, {LINES = table.concat(lines, " ")})
	else
		-- the name of a rune
		local recipe = RuneCarving.recipe(msg)
		if(not recipe) then
			return false
		end

		-- every rune is explained on its own before the offer
		say(cid, TEXTS.runeIntro, {RUNE = recipe.name, TIER = recipe.tier, DESCRIPTION = runeDescription(cid, recipe.name)})

		local tierIndex = RuneCarving.recipes[recipe.name][2]
		if(tierIndex > RuneCarving.getRank(cid)) then
			say(cid, TEXTS.needRespect)
			return true
		end

		talks[cid] = {name = recipe.name}
		say(cid, TEXTS.offer, {GEMS = recipe.gems, ITEM = getItemNameById(recipe.material), GOLD = recipe.gold})
	end

	return true
end

local function onFarewell(cid)
	talks[cid] = nil
	return true
end

-- greeting, farewell and walk away messages depend on the language of who is talking
local function onGreet(cid)
	npcHandler:setMessage(MESSAGE_GREET, text(cid, TEXTS.greet))
	npcHandler:setMessage(MESSAGE_FAREWELL, text(cid, TEXTS.farewell))
	npcHandler:setMessage(MESSAGE_WALKAWAY, text(cid, TEXTS.walkaway))
	return true
end

npcHandler:setCallback(CALLBACK_GREET, onGreet)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_FAREWELL, onFarewell)
npcHandler:addModule(FocusModule:new())
