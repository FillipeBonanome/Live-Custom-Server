local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- conversation state of each player: {step = "monster"|"type"|"strength"|"confirm", monster, type, strength}
local talks = {}

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end

-- tutorial texts, already in both languages ({en, pt}, read by Language.text). No accents on purpose (encoding of the files).
local BASICS = {
	basics1 = {
		en = "A hunter without a plan is just prey. Here you can buy a {prey}: pick one monster, a bonus (experience, loot, damage or defense) and a strength, and that monster will favor you for a while. Say {prey} to start.",
		pt = "Um cacador sem plano e apenas presa. Aqui voce compra uma {prey}: escolha um monstro, um bonus (experiencia, loot, dano ou defesa) e uma forca, e esse monstro favorecera voce por um tempo. Diga {prey} para comecar."
	},
	basics2 = {
		en = "Every day the board offers {contracts}: kill a number of a monster and be paid in experience or gold. Type !daily in the chat to see them. They renew every morning, so do not forget them.",
		pt = "Todo dia o quadro oferece {contratos}: mate certo numero de um monstro e seja pago em experiencia ou ouro. Digite !daily no chat para ve-los. Eles renovam toda manha, nao se esqueca deles."
	},
	basics3 = {
		en = "Every creature you kill is also written in the {bestiary}. Type !bestiary in the chat to read what you learned about each one: its attacks, its weaknesses and its loot. Knowing the prey is half of the hunt.",
		pt = "Toda criatura que voce mata tambem fica registrada no {bestiary}. Digite !bestiary no chat para ler o que aprendeu sobre cada uma: seus ataques, fraquezas e loot. Conhecer a presa e metade da cacada."
	},
	basicsGo = {
		en = "Now go back to Brannoc, the Drillmaster, and ask him about your {vocation}.",
		pt = "Agora volte a Brannoc, o Mestre de Treino, e pergunte a ele sobre a sua {vocacao}."
	},
	basicsAgain = {
		en = "Say {basics} whenever you need to hear it again.",
		pt = "Diga {basics} sempre que precisar ouvir de novo."
	},
	noTutorial = {
		en = "You are not in the tutorial. Say {prey} to hunt with an advantage, or ask me about the {basics}.",
		pt = "Voce nao esta no tutorial. Diga {prey} para cacar com vantagem, ou pergunte sobre o {basics}."
	},
	questBrannoc = {
		en = "Quest log updated: go back to Brannoc and ask about your vocation (say vocation).",
		pt = "Quest log atualizado: volte a Brannoc e pergunte sobre a sua vocacao (diga vocation)."
	}
}

local function typeList()
	local names = {}
	for _, preyType in ipairs(Prey.types) do
		table.insert(names, "{" .. preyType.name .. "}")
	end

	return table.concat(names, ", ")
end

local function strengthList()
	local entries = {}
	for _, strength in ipairs(Prey.strengths) do
		table.insert(entries, "{" .. strength.name .. "} (+" .. Prey.getBonus(strength) .. "%, " .. Prey.getPrice(strength) .. " gold)")
	end

	return table.concat(entries, ", ")
end

local function hours()
	return Prey.formatTime(Prey.getDuration())
end

local function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	-- next step of the tutorial quest
	local said = msg:lower():trim()
	if(said == "next" or said == "step") then
		npcHandler:say(getPlayerTutorialHint(cid, "Huntmaster Kael") or Language.text(cid, BASICS.noTutorial), cid)
		return true
	end

	-- explanation of prey, daily contracts and bestiary (step 4 of the tutorial quest, see data/lib/201-tutorial.lua)
	if(msg:lower():trim() == "basics") then
		talks[cid] = nil
		for _, key in ipairs({"basics1", "basics2", "basics3"}) do
			npcHandler:say(Language.text(cid, BASICS[key]), cid)
		end

		if(doPlayerAdvanceTutorialQuest(cid, 4, BASICS.questBrannoc)) then
			npcHandler:say(Language.text(cid, BASICS.basicsGo), cid)
		else
			npcHandler:say(Language.text(cid, BASICS.basicsAgain), cid)
		end

		return true
	end

	if(not Prey.isEnabled()) then
		npcHandler:say("The prey system is disabled.", cid)
		return true
	end

	msg = msg:lower():trim()
	local talk = talks[cid]

	if(msg == "cancel") then
		talks[cid] = nil
		npcHandler:say("Alright, nothing was changed.", cid)
		return true
	end

	if(msg == "clear" or msg == "remove" or msg == "reset") then
		talks[cid] = nil
		if(Prey.clear(cid)) then
			npcHandler:say("Your prey was cleared for free. Say {prey} when you want a new one.", cid)
		else
			npcHandler:say("You have no active prey.", cid)
		end

		return true
	end

	if(msg == "status" or msg == "time") then
		local prey = Prey.get(cid)
		npcHandler:say(prey and ("Your prey: " .. Prey.describe(prey)) or "You have no active prey. Say {prey} to get one.", cid)
		return true
	end

	if(not talk) then
		if(msg == "prey" or msg == "hunt" or msg == "bonus" or msg == "help") then
			local prey = Prey.get(cid)
			if(prey) then
				npcHandler:say("You already have a prey. " .. Prey.describe(prey) .. " Say {clear} to remove it for free and pick another one.", cid)
				return true
			end

			talks[cid] = {step = "monster"}
			npcHandler:say("Which monster do you want to hunt? Tell me its name (or {cancel}). The bonus lasts " .. hours() .. ".", cid)
			return true
		end

		return false
	end

	if(talk.step == "monster") then
		local monster = Prey.findMonster(msg)
		if(not monster) then
			npcHandler:say("I do not know any huntable creature called " .. msg .. ". Tell me another name or say {cancel}.", cid)
			return true
		end

		talk.monster, talk.step = monster, "type"
		npcHandler:say("Which bonus do you want against " .. monster.name .. "? " .. typeList() .. ".", cid)
		return true
	end

	if(talk.step == "type") then
		local preyType = Prey.getType(msg)
		if(not preyType) then
			npcHandler:say("Choose one of: " .. typeList() .. ".", cid)
			return true
		end

		talk.type, talk.step = preyType, "strength"
		npcHandler:say("How strong? " .. strengthList() .. ".", cid)
		return true
	end

	if(talk.step == "strength") then
		local strength = Prey.getStrength(msg)
		if(not strength) then
			npcHandler:say("Choose one of: " .. strengthList() .. ".", cid)
			return true
		end

		talk.strength, talk.step = strength, "confirm"
		npcHandler:say(talk.type.label .. " +" .. Prey.getBonus(strength) .. "% against " .. talk.monster.name .. " for " .. hours() ..
			" costs " .. Prey.getPrice(strength) .. " gold. Do you accept? {yes} or {no}.", cid)
		return true
	end

	if(talk.step == "confirm") then
		talks[cid] = nil
		if(msg ~= "yes") then
			npcHandler:say("Alright, nothing was bought. Say {prey} to choose again.", cid)
			return true
		end

		local ok, reason = Prey.set(cid, talk.monster.name, talk.type.name, talk.strength.name)
		if(ok) then
			doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
			npcHandler:say("Done! Good hunt. " .. Prey.describe(Prey.get(cid)), cid)
		else
			npcHandler:say(reason, cid)
		end

		return true
	end

	return false
end

local function onFarewell(cid)
	talks[cid] = nil
	return true
end

-- tells the next step of the tutorial, if the player is in it
local function onGreet(cid)
	doNpcTutorialHintLater(npcHandler, cid, "Huntmaster Kael")
	return true
end

npcHandler:setCallback(CALLBACK_GREET, onGreet)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_CREATURE_DISAPPEAR, onFarewell)
npcHandler:setCallback(CALLBACK_FAREWELL, onFarewell)
npcHandler:addModule(FocusModule:new())

Language.install()
