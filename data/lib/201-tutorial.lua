-- Tutorial of the first login.
-- A new character (never received the first items) is sent to TUTORIAL_POSITION, where the NPC "Guardian of Origins"
-- (data/npc/scripts/tutorial.lua) gives the player a race. After the race is chosen the player goes to the temple of
-- his town. !resettutorial (data/talkactions/scripts/resettutorial.lua) restarts it for testing.
--
-- TUTORIAL_STORAGE: -1 = never started, 1 = in progress (the player returns to the tutorial place on login), 2 = finished

TUTORIAL_STORAGE = 52210
TUTORIAL_POSITION = {x = 938, y = 890, z = 7}
TUTORIAL_FIRSTITEMS_STORAGE = 30001 -- set by firstitems.lua; characters that already have it are not new

-- Quest log of the tutorial (data/XML/quests.xml, quest "Tutorial"). One storage holds the step:
--   1 = talk to the Guardian of Origins (choose the race)   2 = talk to Brannoc (keyword "basics": training and tasks)
--   3 = talk to Durnok Runebrand (keyword "basics": runes)   4 = finished
-- Brannoc and Durnok only move the quest forward from the previous step, but their explanation can be heard again any time.
TUTORIAL_QUEST_STORAGE = 52211

function getPlayerTutorialState(cid)
	return tonumber(getPlayerStorageValue(cid, TUTORIAL_STORAGE)) or -1
end

function getPlayerTutorialQuestStep(cid)
	return tonumber(getPlayerStorageValue(cid, TUTORIAL_QUEST_STORAGE)) or -1
end

-- moves the quest from step "fromStep" to the next one and tells the player (the quest log shows the new text).
-- "message" is a text table {en = "...", pt = "..."} (see data/lib/202-language.lua).
-- Returns false (and does nothing) when the player is not at "fromStep".
function doPlayerAdvanceTutorialQuest(cid, fromStep, message)
	if(getPlayerTutorialQuestStep(cid) ~= fromStep) then
		return false
	end

	doCreatureSetStorage(cid, TUTORIAL_QUEST_STORAGE, fromStep + 1)
	if(message) then
		Language.send(cid, MESSAGE_STATUS_CONSOLE_BLUE, message) -- blue, in the default chat
		Language.send(cid, MESSAGE_EVENT_ADVANCE, message) -- white, in the middle of the screen
	end

	return true
end

-- sends the player to the tutorial place (as a Wisp, with no outfit to choose) and marks the tutorial as in progress
function doPlayerStartTutorial(cid)
	doCreatureSetStorage(cid, TUTORIAL_STORAGE, 1)
	doCreatureSetStorage(cid, TUTORIAL_QUEST_STORAGE, 1)

	-- everybody starts as the default outfit (Wisp), the only one the outfit window offers until the race is chosen
	local outfit = getCreatureOutfit(cid)
	outfit.lookType = RACE_DEFAULT_OUTFIT
	outfit.lookAddons = 0
	doCreatureChangeOutfit(cid, outfit)

	local from = getCreaturePosition(cid)
	if(doTeleportThing(cid, TUTORIAL_POSITION, true)) then
		doSendMagicEffect(from, CONST_ME_POFF)
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_TELEPORT)
	end

	-- the language is only chosen with the Guardian, so before that the message goes in both
	local texts = {
		en = "You have no race and the shape of a Wisp. Speak with the Guardian of Origins to choose your race. (see the Quest Log)",
		pt = "Voce esta sem raca, na forma de um Wisp. Fale com o Guardian of Origins para escolher a sua raca. (veja o Quest Log)"
	}
	if(Language.getChosen(cid)) then
		Language.send(cid, MESSAGE_STATUS_CONSOLE_BLUE, texts)
	else
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, texts.en)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, texts.pt)
	end
end

-- marks the tutorial as finished and sends the player to the temple of his town
function doPlayerFinishTutorial(cid)
	doCreatureSetStorage(cid, TUTORIAL_STORAGE, 2)
	-- getTownTemplePosition takes only the town id in this server (an extra argument is read as the town id)
	local pos = getTownTemplePosition(getPlayerTown(cid))
	if(not pos or pos.x == 0 or pos.y == 0) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "O templo da sua cidade nao foi encontrado. Avise um administrador.")
		return false
	end

	pos = getClosestFreeTile(cid, pos)
	if(not pos or pos.x == 0 or pos.y == 0) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Nao ha espaco livre no templo. Avise um administrador.")
		return false
	end

	local from = getCreaturePosition(cid)
	if(doTeleportThing(cid, pos, true)) then
		doSendMagicEffect(from, CONST_ME_POFF)
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_TELEPORT)
	end

	return true
end

-- forgets the race (and its cooldown) and starts the tutorial again
function doPlayerResetTutorial(cid)
	-- the outfits of the old race go away too, so the outfit window shows only the Wisp again
	for _, race in ipairs(RACES) do
		for _, lookType in ipairs(race.outfits) do
			doPlayerRemoveOutfitId(cid, lookType)
		end
	end

	Language.clear(cid) -- the Guardian asks the language again
	doCreatureSetStorage(cid, RACE_STORAGE, -1)
	doCreatureSetStorage(cid, RACE_COOLDOWN_STORAGE, -1)
	doPlayerApplyRaceBonus(cid) -- without a race this only removes the bonus condition
	doPlayerStartTutorial(cid)
end
