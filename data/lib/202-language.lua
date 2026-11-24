-- Language system. The language is kept in a player storage (LANGUAGE_STORAGE, the same number is read by the C++ code:
-- Player::LANGUAGE_STORAGE in src/player.h, which translates the combat messages "You lose...", "You deal...").
--   storage -1 = never chosen (the first question of the Guardian of Origins), 1 = English, 2 = Portuguese
--
-- Texts for scripts (NPCs, messages) are tables with one entry for each language:
--   Language.text(cid, {en = "Hello", pt = "Ola"})
-- A language missing in the table falls back to English. To translate a new NPC, write its lines this way
-- (see data/npc/scripts/tutorial.lua). NPCs without translation keep speaking English.
-- To add a language: new id here, its words in "words", and a new key in the texts.
-- Texts have no accents on purpose (encoding of the files).

LANGUAGE_STORAGE = 52220
LANGUAGE_ENGLISH = 1
LANGUAGE_PORTUGUESE = 2

Language = {
	default = LANGUAGE_ENGLISH,
	-- id = {key used in the text tables, name shown to the players, words that choose it (lowercase)}
	list = {
		[LANGUAGE_ENGLISH] = {key = "en", name = "English", words = {"english", "en", "ingles", "ing"}},
		[LANGUAGE_PORTUGUESE] = {key = "pt", name = "Portugues", words = {"portugues", "portuguese", "pt", "br", "portugu\234s"}}
	}
}

-- id of the language chosen by the player, or nil when he never chose one
function Language.getChosen(cid)
	local id = tonumber(getPlayerStorageValue(cid, LANGUAGE_STORAGE))
	if(id and Language.list[id]) then
		return id
	end

	return nil
end

-- id of the language to use (English when none was chosen)
function Language.get(cid)
	return Language.getChosen(cid) or Language.default
end

function Language.set(cid, id)
	if(not Language.list[id]) then
		return false
	end

	doCreatureSetStorage(cid, LANGUAGE_STORAGE, id)
	return true
end

function Language.clear(cid)
	doCreatureSetStorage(cid, LANGUAGE_STORAGE, -1)
end

-- id of the language a word chooses ("english", "portugues"...), or nil
function Language.find(word)
	word = tostring(word):lower():trim()
	for id, language in pairs(Language.list) do
		if(isInArray(language.words, word)) then
			return id
		end
	end

	return nil
end

-- the text of the player's language from a table {en = "...", pt = "..."}
function Language.text(cid, texts)
	return texts[Language.list[Language.get(cid)].key] or texts[Language.list[Language.default].key] or ""
end

-- sends a text message of the player's language
function Language.send(cid, messageType, texts)
	doPlayerSendTextMessage(cid, messageType, Language.text(cid, texts))
end

-- NPC TRANSLATION LAYER -------------------------------------------------------------------------------------------------
-- NPCs that were written in English only are translated without rewriting them: Language.install() at the END of the NPC
-- script wraps selfSay (every line the NPC says goes through it) and onCreatureSay (what the player says):
--   * a line in english is replaced by its portuguese version when the player chose portuguese (entries, see 203-npc-texts.lua);
--   * a portuguese word said by the player is converted to the english keyword the script understands (aliases).
-- Entries are written with Language.add(en, pt): "@" in the english text is any text (a name, a number...) and is
-- put back in the portuguese text as %1, %2... Texts without an entry stay in english. Names of creatures and items are never translated.

Language.entries = {}
Language.aliases = {}

local MAGIC = "[%^%$%(%)%%%.%[%]%*%+%-%?]"

function Language.add(en, pt)
	local pattern = "^" .. en:gsub(MAGIC, "%%%0"):gsub("@", "(.-)") .. "$"
	table.insert(Language.entries, {pattern = pattern, pt = pt})
end

-- aliases: Language.alias({"sim"}, "yes") or Language.alias({sim = "yes", nao = "no"})
function Language.alias(words, en)
	if(type(words) == "table" and en == nil) then
		for word, target in pairs(words) do
			Language.aliases[word] = target
		end

		return
	end

	for _, word in ipairs(type(words) == "table" and words or {words}) do
		Language.aliases[word] = en
	end
end

-- the portuguese version of a line of an NPC (the same line when there is no entry)
function Language.translateLine(message)
	for _, entry in ipairs(Language.entries) do
		if(message:find(entry.pattern)) then
			return (message:gsub(entry.pattern, entry.pt))
		end
	end

	return message
end

-- wraps selfSay and onCreatureSay of the NPC script. Call it at the end of the script
function Language.install()
	local rawSelfSay = selfSay
	selfSay = function(message, focus, ...)
		if(focus and isPlayer(focus) and Language.get(focus) == LANGUAGE_PORTUGUESE) then
			message = Language.translateLine(message)
		end

		return rawSelfSay(message, focus, ...)
	end

	local rawOnCreatureSay = onCreatureSay
	onCreatureSay = function(cid, type, msg)
		if(isPlayer(cid) and Language.get(cid) == LANGUAGE_PORTUGUESE) then
			local key = tostring(msg):lower():trim()
			if(Language.aliases[key]) then
				msg = Language.aliases[key]
			end
		end

		return rawOnCreatureSay(cid, type, msg)
	end
end
