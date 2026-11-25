-- Tutorial maze: whispers in Caesar-ciphered languages (pt, de, en, ru written in latin letters).
-- Put these actionIds on the maze tiles:
--   56001..56020 = whisper tiles (each id is one message, see MAZE_WHISPERS)
--   56099        = maze exit (sends the player to the Guardian of Origins)
-- Registered in movements.xml (fromaid/toaid + 56099).

local MAZE_FIRST_AID = 56001
local MAZE_EXIT_AID = 56099
local MAZE_SHIFT = 3

-- plain texts; the player only sees the ciphered version (A->D, B->E ...)
local MAZE_WHISPERS = {
	-- portugues
	[1] = "Onde estou? Tudo aqui parece respirar.",
	[2] = "As paredes mudam quando ninguem olha.",
	[3] = "Siga a luz que nao projeta sombra.",
	[4] = "Quem entra sem nome sai sem lembranca.",
	[5] = "Cada passo que voce da ja foi dado antes.",
	-- deutsch
	[6] = "Der Weg nach vorne fuehrt oft zurueck.",
	[7] = "Hoerst du das Fluestern der Waende?",
	[8] = "Ein Irrlicht findet nie allein hinaus.",
	[9] = "Die Nacht hat dich hierher gerufen.",
	[10] = "Vergiss nicht, wer dich hier eingesperrt hat.",
	-- english
	[11] = "You are not the first to wander here.",
	[12] = "The exit is a door that remembers you.",
	[13] = "Do not trust the corridors that feel familiar.",
	[14] = "Something waits where the maze ends.",
	[15] = "Lost things always glow a little.",
	-- russian (transliterated, the client has no cyrillic)
	[16] = "Gde ya? Etot svet ne greet.",
	[17] = "Stseny pomnyat kazhdogo, kto prokhodil.",
	[18] = "Vykhod blizko, no ty ne gotov.",
	[19] = "Tishina zdes govorit gromche slov.",
	[20] = "Idi vpered, malenkiy ogonek."
}

-- caesar cipher on A-Z / a-z only (everything else stays)
local function caesar(text, shift)
	return (text:gsub("%a", function(c)
		local base = (c:byte() < 97) and 65 or 97
		return string.char((c:byte() - base + shift) % 26 + base)
	end))
end

local MAZE_CIPHERED = {}
for id, text in pairs(MAZE_WHISPERS) do
	MAZE_CIPHERED[id] = caesar(text, MAZE_SHIFT)
end

function onStepIn(cid, item, position, fromPosition)
	if(not isPlayer(cid)) then
		return true
	end

	local aid = item.actionid
	if(aid == MAZE_EXIT_AID) then
		if(getPlayerTutorialState(cid) == 1) then
			doCreatureSetStorage(cid, TUTORIAL_MAZE_STORAGE, 1)
			doPlayerGoToGuardian(cid)
		end
		return true
	end

	local text = MAZE_CIPHERED[aid - MAZE_FIRST_AID + 1]
	if(text) then
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, text) -- middle of the screen
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text) -- blue, in the chat
	end

	return true
end
