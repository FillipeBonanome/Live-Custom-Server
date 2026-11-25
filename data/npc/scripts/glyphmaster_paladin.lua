-- Lysander Lightbinder, the paladin master of the glyphs. Same system as Thalion Glyphweaver (data/lib/403-glyphs.lua, doc/sistemas/42-glifos.md).
-- The first glyph of a spell costs bestiary points; swapping to the other glyph costs only gold. Prices, levels and the rest are in config.lua.
-- This one only teaches the paladin spells (and works for the staff, to test); the sorcerers talk to Thalion.
-- Speaks the language chosen by the player (data/lib/202-language.lua). The names and descriptions of the glyphs are in english.
-- Texts have no accents on purpose (encoding of the files).
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- base vocation whose spells this master rewrites (1 = sorcerer, 3 = paladin); the staff talks to all of them
local MASTER_VOCATION = 3
local MASTER = {vocation = MASTER_VOCATION}

-- what each player is talking about: {spell = spell entry, letter = "A" | "B" | nil (when there is an offer to confirm)}
local talks = {}

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end

-- portuguese keyword -> english keyword
local ALIASES = {
	["glifo"] = "glyph", ["glifos"] = "glyphs", ["basico"] = "basics", ["pontos"] = "points", ["ponto"] = "points",
	["lista"] = "list", ["magias"] = "list", ["nome"] = "name", ["profissao"] = "job", ["preco"] = "price",
	["precos"] = "price", ["troca"] = "swap", ["trocar"] = "swap", ["sim"] = "yes", ["nao"] = "no"
}

local TEXTS = {
	greet = {
		en = "Greetings, |NAME|. I am Lysander Lightbinder. Every prayer is a sentence of the First Word, and I can rewrite one of its syllables: a {glyph}. Ask me about the {basics}, your {points} or say {list}.",
		pt = "Saudacoes, |NAME|. Eu sou Lysander Lightbinder. Toda prece e uma frase da Primeira Palavra, e eu posso reescrever uma de suas silabas: um {glifo}. Pergunte sobre o {basico}, seus {pontos} ou diga {lista}."
	},
	farewell = {
		en = "May the First Word echo kindly in you, |NAME|.",
		pt = "Que a Primeira Palavra ecoe com bondade em ti, |NAME|."
	},
	walkaway = {
		en = "Silence is also a syllable. Come back when you wish to speak.",
		pt = "O silencio tambem e uma silaba. Volte quando quiser falar."
	},
	name = {
		en = "Lysander Lightbinder, keeper of the holy syllables. I carried a spear for thirty years before I understood that the light was also a sentence.",
		pt = "Lysander Lightbinder, guardiao das silabas sagradas. Carreguei uma lanca por trinta anos antes de entender que a luz tambem era uma frase."
	},
	job = {
		en = "I rewrite spells. Each one has two glyphs, A and B, and you keep one of them. Say {basics} and I will explain.",
		pt = "Eu reescrevo magias. Cada uma tem dois glifos, A e B, e voce fica com um deles. Diga {basico} e eu explico."
	},
	basics1 = {
		en = "Long ago Azuriel spoke the First Word, and every spell is an echo of it. A {glyph} rewrites one syllable of that echo, and the spell changes for good.",
		pt = "Ha muito tempo Azuriel pronunciou a Primeira Palavra, e toda magia e um eco dela. Um {glifo} reescreve uma silaba desse eco, e a magia muda para sempre."
	},
	basics2 = {
		en = "Each spell has two glyphs, A and B, and you may keep only one. The first one costs bestiary points: what you learned hunting is the ink. Say {points} to see yours, {list} for the spells.",
		pt = "Cada magia tem dois glifos, A e B, e voce so pode ficar com um. O primeiro custa pontos de bestiario: o que voce aprendeu cacando e a tinta. Diga {pontos} para ver os seus, {lista} para as magias."
	},
	basics3 = {
		en = "Swapping to the other glyph needs no points, only gold, and a lot of it: an erased syllable never sounds the same. Say the name of a spell, like {Divine Missile}, and I will tell you what its glyphs do.",
		pt = "Trocar para o outro glifo nao exige pontos, so ouro, e muito: uma silaba apagada nunca soa igual. Diga o nome de uma magia, como {Divine Missile}, e eu direi o que seus glifos fazem."
	},
	notSorcerer = {
		en = "I only know the syllables of the spears and the holy light of the paladins. Other masters will teach yours in time.",
		pt = "Eu so conheco as silabas das lancas e da luz sagrada dos paladinos. Outros mestres ensinarao as suas com o tempo."
	},
	points = {
		en = "You have FREE bestiary points to spend (EARNED earned, SPENT spent). Hunt and learn about more creatures to earn more.",
		pt = "Voce tem FREE pontos de bestiario para gastar (EARNED ganhos, SPENT gastos). Cace e aprenda sobre mais criaturas para ganhar mais."
	},
	listIntro = {
		en = "Spells and what you need (level, points for the first glyph):",
		pt = "Magias e o que voce precisa (nivel, pontos do primeiro glifo):"
	},
	listMore = {
		en = "Say the name of a spell to hear its glyphs.",
		pt = "Diga o nome de uma magia para ouvir seus glifos."
	},
	spellIntro = {
		en = "SPELL needs level LEVEL. The first glyph costs PRICE bestiary points, swapping costs GOLD gold coins.",
		pt = "SPELL exige nivel LEVEL. O primeiro glifo custa PRICE pontos de bestiario, trocar custa GOLD moedas de ouro."
	},
	glyphLine = {
		en = "Glyph LETTER, NAME: DESCRIPTION",
		pt = "Glifo LETTER, NAME: DESCRIPTION"
	},
	glyphMissing = {
		en = "Glyph LETTER: I have not learned how to write it yet.",
		pt = "Glifo LETTER: ainda nao aprendi a escreve-lo."
	},
	spellChoose = {
		en = "Say {A} or {B} to choose.",
		pt = "Diga {A} ou {B} para escolher."
	},
	spellCurrent = {
		en = "You carry glyph CURRENT on it.",
		pt = "Voce tem o glifo CURRENT nela."
	},
	offerBuy = {
		en = "Carve glyph LETTER (NAME) into SPELL for PRICE bestiary points? You have FREE. {yes} or {no}.",
		pt = "Esculpir o glifo LETTER (NAME) em SPELL por PRICE pontos de bestiario? Voce tem FREE. {sim} ou {nao}."
	},
	offerSwap = {
		en = "Swap SPELL to glyph LETTER (NAME) for GOLD gold coins? The old syllable is lost. {yes} or {no}.",
		pt = "Trocar SPELL pelo glifo LETTER (NAME) por GOLD moedas de ouro? A silaba antiga se perde. {sim} ou {nao}."
	},
	declined = {
		en = "A word spoken in haste is hard to take back. Think it over.",
		pt = "Uma palavra dita com pressa e dificil de desdizer. Pense com calma."
	},
	unknown = {
		en = "I do not know that spell. Say {list} to hear the ones I can rewrite.",
		pt = "Eu nao conheco essa magia. Diga {lista} para ouvir as que posso reescrever."
	},
	pickFirst = {
		en = "Tell me the spell first, for example {Divine Missile}.",
		pt = "Diga primeiro a magia, por exemplo {Divine Missile}."
	},
	done = {
		en = "Done. The syllable is written: RESULT",
		pt = "Pronto. A silaba esta escrita: RESULT"
	},
	failed = {
		en = "I cannot do it: REASON",
		pt = "Nao posso fazer isso: REASON"
	}
}

-- the text of the language of cid with |NAME| replaced and the markers (SPELL, PRICE...) filled with the values
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

-- the failure messages of Glyphs.choose (english) in the language of the player
local function translateError(cid, message)
	if(not isPt(cid)) then
		return message
	end

	if(message == "Choose glyph A or B.") then
		return "Escolha o glifo A ou B."
	elseif(message == "The glyph system is disabled.") then
		return "O sistema de glifos esta desligado."
	elseif(message == "Your vocation cannot use the glyphs of this spell.") then
		return "Sua vocacao nao pode usar os glifos desta magia."
	elseif(message == "This glyph is not available yet.") then
		return "Este glifo ainda nao esta disponivel."
	elseif(message == "You already have this glyph.") then
		return "Voce ja tem este glifo."
	end

	local level, spell = message:match("^You need level (%d+) to use a glyph of (.+)%.$")
	if(level) then
		return "Voce precisa de nivel " .. level .. " para usar um glifo de " .. spell .. "."
	end

	local needed, have = message:match("^You need (%d+) bestiary points %(you have (%d+)%)%.$")
	if(needed) then
		return "Voce precisa de " .. needed .. " pontos de bestiario (voce tem " .. have .. ")."
	end

	local swapSpell, gold = message:match("^Swapping the glyph of (.+) costs (%d+) gold coins%.$")
	if(swapSpell) then
		return "Trocar o glifo de " .. swapSpell .. " custa " .. gold .. " moedas de ouro."
	end

	return message
end

local function pointsText(cid)
	return text(cid, TEXTS.points, {FREE = Glyphs.freePoints(cid), EARNED = Glyphs.earnedPoints(cid), SPENT = Glyphs.spentPoints(cid)})
end

local function spellEntries(cid)
	local entries = {}
	for _, spell in ipairs(Glyphs.spells) do
	if(spell.vocation == MASTER_VOCATION) then
		local mark = ""
		local letter = Glyphs.chosenLetter(cid, spell)
		if(letter) then
			mark = " [" .. letter .. "]"
		end

		table.insert(entries, "{" .. spell.name .. "} (" .. Glyphs.requiredLevel(spell) .. ", " .. Glyphs.cost(spell) .. ")" .. mark .. ",")
	end
	end

	return entries
end

local function explainSpell(cid, spell)
	say(cid, TEXTS.spellIntro, {SPELL = spell.name, LEVEL = Glyphs.requiredLevel(spell), PRICE = Glyphs.cost(spell), GOLD = Glyphs.swapGold(spell)})
	for _, letter in ipairs({"A", "B"}) do
		local glyph = spell.glyphs[letter]
		if(glyph) then
			say(cid, TEXTS.glyphLine, {LETTER = letter, NAME = glyph.name, DESCRIPTION = Glyphs.description(cid, glyph)})
		else
			say(cid, TEXTS.glyphMissing, {LETTER = letter})
		end
	end

	local current = Glyphs.chosenLetter(cid, spell)
	if(current) then
		say(cid, TEXTS.spellCurrent, {CURRENT = current})
	end

	say(cid, TEXTS.spellChoose)
	talks[cid] = {spell = spell}
end

local function offer(cid, spell, letter)
	local glyph = spell.glyphs[letter]
	if(not glyph) then
		say(cid, TEXTS.glyphMissing, {LETTER = letter})
		return
	end

	local current = Glyphs.chosenLetter(cid, spell)
	if(current == letter) then
		npcHandler:say(translateError(cid, "You already have this glyph."), cid)
		return
	end

	talks[cid] = {spell = spell, letter = letter}
	if(current) then
		say(cid, TEXTS.offerSwap, {SPELL = spell.name, LETTER = letter, NAME = glyph.name, GOLD = Glyphs.swapGold(spell)})
	else
		say(cid, TEXTS.offerBuy, {SPELL = spell.name, LETTER = letter, NAME = glyph.name, PRICE = Glyphs.cost(spell), FREE = Glyphs.freePoints(cid)})
	end
end

local function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	msg = msg:lower():trim()
	msg = ALIASES[msg] or msg

	if(not Glyphs.canUse(cid, MASTER)) then
		say(cid, TEXTS.notSorcerer)
		return true
	end

	-- answering an offer
	local talk = talks[cid]
	if(talk and talk.letter) then
		if(msg == "yes") then
			talks[cid] = nil
			local ok, result = Glyphs.choose(cid, talk.spell, talk.letter)
			if(ok) then
				say(cid, TEXTS.done, {RESULT = result})
				doSendMagicEffect(getCreaturePosition(cid), CONST_ME_FIREWORK_YELLOW)
			else
				say(cid, TEXTS.failed, {REASON = translateError(cid, result)})
			end

			return true
		elseif(msg == "no") then
			talks[cid] = nil
			say(cid, TEXTS.declined)
			return true
		end
	end

	if(msg == "name" or msg == "lysander") then
		say(cid, TEXTS.name)
	elseif(msg == "job" or msg == "occupation" or msg == "profession" or msg == "lightbinder") then
		say(cid, TEXTS.job)
	elseif(msg == "basics" or msg == "glyph" or msg == "glyphs" or msg == "help" or msg == "swap" or msg == "price") then
		say(cid, TEXTS.basics1)
		say(cid, TEXTS.basics2)
		say(cid, TEXTS.basics3)
	elseif(msg == "points" or msg == "bestiary") then
		npcHandler:say(pointsText(cid), cid)
	elseif(msg == "list" or msg == "spells") then
		sayList(cid, text(cid, TEXTS.listIntro), spellEntries(cid))
		say(cid, TEXTS.listMore)
	elseif((msg == "a" or msg == "b") and talk) then
		offer(cid, talk.spell, msg:upper())
	else
		-- the name of a spell, optionally followed by the glyph: "flame strike" or "flame strike a"
		local name, letter = msg:match("^(.-)%s+([ab])$")
		local spell = Glyphs.spell(name or msg)
		if(not spell and name) then
			spell, letter = Glyphs.spell(msg), nil
		end

		if(spell and spell.vocation ~= MASTER_VOCATION) then
			spell = nil
		end

		if(not spell) then
			if(msg == "a" or msg == "b") then
				say(cid, TEXTS.pickFirst)
				return true
			end

			return false
		end

		if(letter) then
			offer(cid, spell, letter:upper())
		else
			explainSpell(cid, spell)
		end
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
