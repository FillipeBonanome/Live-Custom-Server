-- Tutorial of the first login.
-- A new character (never received the first items) is sent to TUTORIAL_POSITION, where the NPC "Guardian of Origins"
-- (data/npc/scripts/tutorial.lua) gives the player a race. After the race is chosen the player goes to the temple of
-- his town. !resettutorial (data/talkactions/scripts/resettutorial.lua) restarts it for testing.
--
-- TUTORIAL_STORAGE: -1 = never started, 1 = in progress (the player returns to the tutorial place on login), 2 = finished

TUTORIAL_STORAGE = 52210
TUTORIAL_POSITION = {x = 938, y = 890, z = 7}
-- Maze where the new character (a lost Wisp) starts.
-- Stepping on actionid 56099 (maze exit) sends the player to TUTORIAL_POSITION (the Guardian).
TUTORIAL_MAZE_POSITION = {x = 962, y = 856, z = 7}
TUTORIAL_MAZE_STORAGE = 52212 -- 1 = maze already finished
TUTORIAL_FIRSTITEMS_STORAGE = 30001 -- set by firstitems.lua; characters that already have it are not new

-- Quest log of the tutorial (data/XML/quests.xml, quest "Tutorial"). One storage holds the step:
--   1 = talk to the Guardian of Origins (choose the race)   2 = talk to Brannoc (keyword "basics": training and tasks)
--   3 = talk to Durnok Runebrand (keyword "basics": runes)   4 = talk to Huntmaster Kael (keyword "basics": prey, daily, bestiary)
--   5 = talk to Brannoc (keyword "vocation": explains the vocation the player already has)
--   6 = first hunt: take a task from Brannoc, kill the creatures and say "reward" (then he explains !autoloot and death)
--   7 = finished
-- The NPCs only move the quest forward from the previous step, but their explanation can be heard again any time.
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
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_FIREWORK_YELLOW) -- a part of the tutorial is complete
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

	-- first the maze; once it is finished (relogin) straight to the Guardian
	local mazeDone = (tonumber(getPlayerStorageValue(cid, TUTORIAL_MAZE_STORAGE)) or -1) == 1
	local from = getCreaturePosition(cid)
	if(doTeleportThing(cid, mazeDone and TUTORIAL_POSITION or TUTORIAL_MAZE_POSITION, true)) then
		doSendMagicEffect(from, CONST_ME_POFF)
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_TELEPORT)
	end

	-- the language is only chosen with the Guardian, so before that the message goes in both
	local texts = {
		en = "You do not remember who you were. Perhaps a human, a dwarf, an orc? Your mind is a penumbra before the vastness it longs for.",
		pt = "Voce nao se lembra de quem foi. Talvez um humano, um anao, um orc? Sua mente parece uma penumbra perante a vastidao que almeja."
	}
	if(Language.getChosen(cid)) then
		Language.send(cid, MESSAGE_STATUS_CONSOLE_BLUE, texts)
		Language.send(cid, MESSAGE_EVENT_ADVANCE, texts)
	else
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, texts.en)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, texts.pt)
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, texts.en)
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, texts.pt)
	end
end

-- maze exit: sends the player to the Guardian of Origins
function doPlayerGoToGuardian(cid)
	local from = getCreaturePosition(cid)
	if(doTeleportThing(cid, TUTORIAL_POSITION, true)) then
		doSendMagicEffect(from, CONST_ME_POFF)
		doSendMagicEffect(getCreaturePosition(cid), CONST_ME_TELEPORT)
	end


	-- the player complains about the voices and is glad to have found a way out (language not chosen yet: both)
	doCreatureSay(cid, "Que vozes malditas... Finalmente, uma saida!", TALKTYPE_ORANGE_1)
	doCreatureSay(cid, "Those cursed voices... At last, a way out!", TALKTYPE_ORANGE_1)
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
	doCreatureSetStorage(cid, TUTORIAL_MAZE_STORAGE, -1)
	doPlayerApplyRaceBonus(cid) -- without a race this only removes the bonus condition
	doPlayerStartTutorial(cid)
end

-- What comes next in the tutorial quest, said by the tutorial NPCs (on the greeting and when the player says "next").
-- For each step: the NPC to talk to, and the line when it is another NPC (other) or the same one who is talking (same).
-- Every text is {en = "...", pt = "..."}. Words in {braces} are highlighted by the client.
TUTORIAL_NEXT = {
	[1] = {
		npc = "Guardian of Origins",
		other = {
			en = "Next step of your tutorial: speak with the Guardian of Origins and choose your race.",
			pt = "Proximo passo do seu tutorial: fale com o Guardian of Origins e escolha a sua raca."
		}
	},
	[2] = {
		npc = "Brannoc",
		other = {
			en = "Next step of your tutorial: speak with Brannoc, at the temple, and say {basics}.",
			pt = "Proximo passo do seu tutorial: fale com Brannoc, no templo, e diga {basics}."
		},
		same = {
			en = "Next step of your tutorial: say {basics} to me.",
			pt = "Proximo passo do seu tutorial: diga {basics} para mim."
		}
	},
	[3] = {
		npc = "Durnok Runebrand",
		other = {
			en = "Next step of your tutorial: speak with Durnok Runebrand, the dwarf runesmith, and say {basics}.",
			pt = "Proximo passo do seu tutorial: fale com Durnok Runebrand, o anao das runas, e diga {basics}."
		},
		same = {
			en = "Next step of your tutorial: say {basics} to me.",
			pt = "Proximo passo do seu tutorial: diga {basics} para mim."
		}
	},
	[4] = {
		npc = "Huntmaster Kael",
		other = {
			en = "Next step of your tutorial: speak with Huntmaster Kael, who stands to the left of the temple (not inside it), and say {basics}.",
			pt = "Proximo passo do seu tutorial: fale com Huntmaster Kael, que fica a esquerda do templo (nao dentro dele), e diga {basics}."
		},
		same = {
			en = "Next step of your tutorial: say {basics} to me.",
			pt = "Proximo passo do seu tutorial: diga {basics} para mim."
		}
	},
	[5] = {
		npc = "Brannoc",
		other = {
			en = "Next step of your tutorial: go back to Brannoc and say {vocation}.",
			pt = "Proximo passo do seu tutorial: volte a Brannoc e diga {vocation}."
		},
		same = {
			en = "Next step of your tutorial: say {vocation} to me.",
			pt = "Proximo passo do seu tutorial: diga {vocation} para mim."
		}
	},
	[6] = {
		npc = "Brannoc",
		other = {
			en = "Next step of your tutorial: your first hunt. Ask Brannoc for a task (say the name of a creature, like rotworm), kill them and say reward to him.",
			pt = "Proximo passo do seu tutorial: a sua primeira caca. Peca uma task a Brannoc (diga o nome de uma criatura, como rotworm), mate-as e diga reward a ele."
		},
		same = {
			en = "Next step of your tutorial: your first hunt. Ask me for a task (say the name of a creature, like rotworm), kill them and come back to say reward.",
			pt = "Proximo passo do seu tutorial: a sua primeira caca. Peca-me uma task (diga o nome de uma criatura, como rotworm), mate-as e volte para dizer reward."
		}
	}
}

-- the line that tells the player the next step of the tutorial, in his language, or nil when he is not in the tutorial quest.
-- npcName is the NPC who is talking (he says "to me" when the step is with him)
function getPlayerTutorialHint(cid, npcName)
	local step = TUTORIAL_NEXT[getPlayerTutorialQuestStep(cid)]
	if(not step) then
		return nil
	end

	return Language.text(cid, (step.npc == npcName and step.same) or step.other)
end

-- the NPC says the next step shortly after his greeting (the greeting itself is sent after the greet callback returns)
function doNpcTutorialHintLater(npcHandler, cid, npcName)
	addEvent(function()
		if(isPlayer(cid) and npcHandler:isFocused(cid)) then
			local hint = getPlayerTutorialHint(cid, npcName)
			if(hint) then
				npcHandler:say(hint, cid)
			end
		end
	end, 500)
end
