-- Magister Cassian Vael: changes the race of the player. Speaks the language chosen by the player (data/lib/202-language.lua).
-- Race names are never translated. Texts have no accents on purpose (encoding of the files).
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local choices = {}

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end

-- portuguese keyword -> english keyword
local ALIASES = {
	["raca"] = "race", ["racas"] = "races", ["ajuda"] = "help", ["sim"] = "yes", ["nao"] = "no"
}

local TEXTS = {
	greet = {
		en = "Ah, |NAME|. Welcome, welcome. I am Magister Cassian Vael, scholar of the bloodlines and their curious histories. Should you wish to change your {race}, you have come to the right library.",
		pt = "Ah, |NAME|. Bem-vindo, bem-vindo. Eu sou o Magister Cassian Vael, estudioso das linhagens e de suas curiosas historias. Se desejas mudar a tua {raca}, vieste a biblioteca certa."
	},
	farewell = {
		en = "Farewell, |NAME|. May your curiosity outlast your doubts.",
		pt = "Adeus, |NAME|. Que a tua curiosidade dure mais que as tuas duvidas."
	},
	wait = {
		en = "Patience, my friend: the blood needs time to settle. You must wait TIME before changing your race again.",
		pt = "Paciencia, meu amigo: o sangue precisa de tempo para assentar. Deves esperar TIME antes de mudar de raca outra vez."
	},
	done = {
		en = "Fascinating... it is done. You are now a RACE! Your old outfits are gone, and the garments of your new lineage are yours.",
		pt = "Fascinante... esta feito. Agora es um RACE! Teus antigos trajes se foram, e as vestes da tua nova linhagem sao tuas."
	},
	declined = {
		en = "A wise pause; every great treatise begins with doubt. Which lineage shall it be, then? LIST.",
		pt = "Uma pausa sabia; todo grande tratado comeca com a duvida. Qual linhagem sera, entao? LIST."
	},
	helpWait = {
		en = "I would gladly change your race at no charge, but the ritual forbids it for now: you must wait TIME. The lineages I have catalogued: LIST.",
		pt = "Mudaria a tua raca de bom grado e sem custo, mas o ritual o proibe por ora: deves esperar TIME. As linhagens que catalogei: LIST."
	},
	help = {
		en = "My research allows me to change your race at no cost. Mind you, after each change one must wait TIME before changing again, though your first choice has no wait. The lineages I have catalogued: LIST.",
		pt = "Minha pesquisa me permite mudar a tua raca sem custo. Atenta: apos cada mudanca, deve-se esperar TIME antes de mudar de novo, embora a primeira escolha nao tenha espera. As linhagens que catalogei: LIST."
	},
	already = {
		en = "But you already are a RACE, dear friend! A fine choice, if I may say so.",
		pt = "Mas tu ja es um RACE, caro amigo! Uma bela escolha, se me permites dizer."
	},
	recent = {
		en = "You changed your race only recently. Science demands restraint: wait TIME before another change.",
		pt = "Mudaste de raca ha pouco tempo. A ciencia exige comedimento: espera TIME antes de outra mudanca."
	},
	footnote = {
		en = " A footnote: you will only be able to change again in TIME.",
		pt = " Uma nota de rodape: so poderas mudar de novo apos TIME."
	},
	confirm = {
		en = "Ah, the {RACE}! A remarkable lineage. Are you certain you wish to become one? Know that you will lose all your current outfits.WARNING {yes} or {no}?",
		pt = "Ah, o {RACE}! Uma linhagem notavel. Tens certeza de que desejas tornar-te um? Sabe que perderas todos os teus trajes atuais.WARNING {sim} ou {nao}?"
	}
}

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

local function raceList()
	local names = {}
	for _, race in ipairs(RACES) do
		table.insert(names, "{" .. race.name .. "}")
	end

	return table.concat(names, ", ")
end

-- the cooldown with the units of the language ("2d 3h" is the same in both, only "min" is kept)
local function cooldown(seconds)
	return formatRaceCooldown(seconds)
end

local function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	msg = msg:lower():trim()
	msg = ALIASES[msg] or msg
	local choice = choices[cid]
	if(choice) then
		if(msg == "yes") then
			choices[cid] = nil
			local left = getPlayerRaceCooldownLeft(cid)
			if(left > 0) then
				say(cid, TEXTS.wait, {TIME = cooldown(left)})
				return true
			end

			local hadRace = getPlayerRace(cid)
			if(doPlayerSetRace(cid, choice)) then
				if(hadRace) then
					doPlayerStartRaceCooldown(cid)
				end

				doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
				say(cid, TEXTS.done, {RACE = RACES[choice].name})
			end
		else
			choices[cid] = nil
			say(cid, TEXTS.declined, {LIST = raceList()})
		end

		return true
	end

	if(msg == "race" or msg == "races" or msg == "help") then
		local left = getPlayerRaceCooldownLeft(cid)
		if(left > 0) then
			say(cid, TEXTS.helpWait, {TIME = cooldown(left), LIST = raceList()})
		else
			say(cid, TEXTS.help, {TIME = cooldown(getRaceChangeCooldown()), LIST = raceList()})
		end

		return true
	end

	local index, race = getRaceByName(msg)
	if(not index) then
		return false
	end

	local current = getPlayerRace(cid)
	if(current == index) then
		say(cid, TEXTS.already, {RACE = race.name})
		return true
	end

	local left = getPlayerRaceCooldownLeft(cid)
	if(left > 0) then
		say(cid, TEXTS.recent, {TIME = cooldown(left)})
		return true
	end

	choices[cid] = index
	doShowTextDialog(cid, 1982, getRaceDescription(index))
	local warning = ""
	if(getPlayerRace(cid) and getRaceChangeCooldown() > 0) then
		warning = text(cid, TEXTS.footnote, {TIME = cooldown(getRaceChangeCooldown())})
	end

	say(cid, TEXTS.confirm, {RACE = race.name, WARNING = warning})
	return true
end

local function onFarewell(cid)
	choices[cid] = nil
	return true
end

-- greeting and farewell depend on the language of who is talking
local function onGreet(cid)
	npcHandler:setMessage(MESSAGE_GREET, text(cid, TEXTS.greet))
	npcHandler:setMessage(MESSAGE_FAREWELL, text(cid, TEXTS.farewell))
	return true
end

npcHandler:setCallback(CALLBACK_GREET, onGreet)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_CREATURE_DISAPPEAR, onFarewell)
npcHandler:setCallback(CALLBACK_FAREWELL, onFarewell)
npcHandler:addModule(FocusModule:new())
