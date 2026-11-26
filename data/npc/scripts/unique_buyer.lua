-- Aurelius, the collector of unique items. He buys the unique items (data/XML/uniques.xml) in the backpack of the player,
-- paying far more than the normal merchants. Say "sell" with the uniques in the main backpack. "price <name>" tells the price.
-- Prices below: monster uniques = ~30% of the gold per kill of the monster divided by the unique drop rate; boss uniques = by tier.
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()				npcHandler:onThink()					end

local PRICES = {
	["emberscale mail"] = 250000,
	["frostbound scale mail"] = 220000,
	["duskscale mail"] = 250000,
	["wraithvenom scale mail"] = 250000,
	["helm of cinders"] = 200000,
	["rimecrest helmet"] = 220000,
	["grumbak's frostcleaver"] = 20000,
	["frozen chieftain's furs"] = 20000,
	["moonfang blade"] = 20000,
	["alpha's pelt mail"] = 20000,
	["silkara's venom fang"] = 20000,
	["brood mother's crown"] = 20000,
	["ruzad's warbrand"] = 20000,
	["warlord's crushing helm"] = 20000,
	["blackreef cutlass"] = 40000,
	["captain's sea coat"] = 40000,
	["aethra's spearbow"] = 40000,
	["empress circlet"] = 40000,
	["brokk's forgehammer"] = 40000,
	["forgemaster's plate"] = 40000,
	["mokthar's hex staff"] = 40000,
	["hexlord horns"] = 40000,
	["ssurrak's sunblade"] = 40000,
	["hierarch's scale shield"] = 40000,
	["korg's boulder maul"] = 40000,
	["titan's greaves"] = 40000,
	["khalzar's lamp wand"] = 40000,
	["vizier's slippers"] = 40000,
	["vorthrax icebrand"] = 80000,
	["glaciarch's plate"] = 80000,
	["kragmor's overclock axe"] = 80000,
	["overseer's servo boots"] = 80000,
	["mortheus' harvest rod"] = 80000,
	["harvester's amulet"] = 80000,
	["syrelith's dreamthread"] = 80000,
	["nightmare greaves"] = 80000,
	["pyrothane's cinderblade"] = 80000,
	["cinderlord's shield"] = 80000,
	["sanguessa's bloodthorn"] = 150000,
	["countess' crimson mantle"] = 150000,
	["vexmar's plaguehammer"] = 150000,
	["plagueforged legs"] = 150000,
	["ignaria's embertongue"] = 150000,
	["matriarch's flamecrown"] = 150000,
	["zhardakkan's drakebreaker"] = 150000,
	["draken warplate"] = 150000,
	["azhrakar's wyrmfang"] = 150000,
	["wyrmlord's aegis"] = 150000,
	["zulkarath's hellbrand"] = 250000,
	["archfiend's demonplate"] = 250000,
	["nekhrazul's grave staff"] = 250000,
	["deathwyrm crown"] = 250000,
	["malgorath's hellmaul"] = 250000,
	["overlord's hellshield"] = 250000,
	["tuskbound mail"] = 150,
	["rattling helm"] = 530,
	["spearhead greaves"] = 150,
	["slimebound bulwark"] = 240,
	["leafwoven bow"] = 660,
	["prospector's bulwark"] = 1500,
	["bullhorn mail"] = 460,
	["tusked mail"] = 200,
	["bladesister blade"] = 150,
	["taut mail"] = 720,
	["carrion mail"] = 900,
	["riveted crossbow"] = 1100,
	["featherlight bow"] = 290,
	["tattered helm"] = 950,
	["wingbound cleaver"] = 500,
	["salvaged band"] = 980,
	["hexed cleaver"] = 2300,
	["cyclopean helm"] = 500,
	["wrapped blade"] = 8900,
	["horned cleaver"] = 560,
	["rune-forged cleaver"] = 1900,
	["moonleaf pendant"] = 2300,
	["drone-forged cleaver"] = 870,
	["anvilborn helm"] = 640,
	["crimson blade"] = 3800,
	["venomous blade"] = 3000,
	["rib-forged mail"] = 2600,
	["ember-scaled maul"] = 12000,
	["gilded mail"] = 5100,
	["mireborn garb"] = 13000,
	["geode maul"] = 4100,
	["charged helm"] = 12000,
	["silkbound helm"] = 11000,
	["phylactery pendant"] = 6300,
	["molten garb"] = 15000,
	["legion greaves"] = 28000,
	["valorous crown"] = 18000,
	["renegade cleaver"] = 11000,
	["piston maul"] = 21000,
	["high guard's treads"] = 16000,
	["moonfang greaves"] = 3400,
	["emerald garb"] = 12000,
	["tarnished cleaver"] = 11000,
	["hydra-scaled helm"] = 26000,
	["tidal maul"] = 14000,
	["warbanner treads"] = 12000,
	["tuskhide wand"] = 17000,
	["ruinous maul"] = 45000,
	["brimstone maul"] = 16000,
	["siege-forged maul"] = 50000,
	["withered garb"] = 74000,
	["corroded greaves"] = 8000,
	["ashen band"] = 12000,
	["stonegaze garb"] = 89000,
	["dawnfire helm"] = 15000,
	["moonlit rod"] = 19000,
	["scythe-touched blade"] = 70000,
	["cruel cleaver"] = 100000,
	["bone-plated cleaver"] = 38000,
	["champion garb"] = 120000,
	["demonbound blade"] = 160000,
	["sealed blade"] = 49000,
	["cinderfang blade"] = 49000,
	["ironheart mail"] = 190000,
}

local talks = {}

local TEXTS = {
	greet = {
		en = "Greetings, |NAME|! I am Aurelius, a collector of {unique} items. Put them in your main backpack and say {sell}: I pay far better than any merchant. Ask {price} and the name of an item to know what I pay.",
		pt = "Saudacoes, |NAME|! Eu sou Aurelius, colecionador de itens {unicos}. Coloque-os na sua mochila principal e diga {vender}: pago muito mais que qualquer mercador. Pergunte {preco} e o nome de um item para saber quanto eu pago."
	},
	farewell = {en = "Come back when you find more treasures, |NAME|.", pt = "Volte quando encontrar mais tesouros, |NAME|."},
	walkaway = {en = "Rare things wait for no one. Farewell.", pt = "Coisas raras nao esperam ninguem. Adeus."},
	unique = {
		en = "A unique item has its own name and bonuses. Monsters drop them rarely instead of the normal item. I buy them all, but only from your main backpack, not the ones you are wearing.",
		pt = "Um item unico tem nome e bonus proprios. Os monstros os largam raramente no lugar do item normal. Eu compro todos, mas so da sua mochila principal, nao os que voce esta usando."
	},
	none = {en = "You have no unique item in your main backpack.", pt = "Voce nao tem nenhum item unico na sua mochila principal."},
	offer = {en = "I can pay |TOTAL| gold coins for: |LIST|. Do you want to sell {yes}?", pt = "Posso pagar |TOTAL| moedas de ouro por: |LIST|. Quer vender {sim}?"},
	sold = {en = "A pleasure! |TOTAL| gold coins for |COUNT| unique item(s).", pt = "Um prazer! |TOTAL| moedas de ouro por |COUNT| item(ns) unico(s)."},
	declined = {en = "Very well. The offer stands whenever you want.", pt = "Muito bem. A oferta continua de pe quando quiser."},
	price = {en = "For the |NAME| I pay |PRICE| gold coins.", pt = "Pelo |NAME| eu pago |PRICE| moedas de ouro."},
	noprice = {en = "I do not know an unique item with this name.", pt = "Nao conheco nenhum item unico com esse nome."}
}

local function text(cid, texts, replaces)
	local value = Language.text(cid, texts):gsub("|NAME|", function() return getCreatureName(cid) end)
	for key, replace in pairs(replaces or {}) do
		value = value:gsub("|" .. key .. "|", function() return tostring(replace) end)
	end

	return value
end

local function say(cid, texts, replaces)
	npcHandler:say(text(cid, texts, replaces), cid)
end

-- every unique (with a price) in the main backpack
local function collect(container, found)
	for i = 0, getContainerSize(container) - 1 do
		local item = getContainerItem(container, i)
		if(item.itemid > 0) then
			local unique = getItemUnique(item.uid)
			local price = unique and PRICES[unique:lower()]
			if(price) then
				table.insert(found, {uid = item.uid, name = unique, price = price})
			end

			if(isContainer(item.uid)) then
				collect(item.uid, found)
			end
		end
	end
end

local function findUniques(cid)
	local found = {}
	local backpack = getPlayerSlotItem(cid, CONST_SLOT_BACKPACK)
	if(backpack.uid > 0 and isContainer(backpack.uid)) then
		collect(backpack.uid, found)
	end

	return found
end

local function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	msg = msg:lower():trim()
	if(talks[cid]) then
		if(msg == "yes" or msg == "sim") then
			talks[cid] = nil
			local found = findUniques(cid)
			if(#found == 0) then
				say(cid, TEXTS.none)
				return true
			end

			local total = 0
			for _, entry in ipairs(found) do
				doRemoveItem(entry.uid)
				total = total + entry.price
			end

			doPlayerAddMoney(cid, total)
			doSendMagicEffect(getCreaturePosition(cid), CONST_ME_FIREWORK_YELLOW)
			say(cid, TEXTS.sold, {TOTAL = total, COUNT = #found})
			return true
		elseif(msg == "no" or msg == "nao") then
			talks[cid] = nil
			say(cid, TEXTS.declined)
			return true
		end
	end

	if(msg == "sell" or msg == "vender" or msg == "trade") then
		local found = findUniques(cid)
		if(#found == 0) then
			say(cid, TEXTS.none)
			return true
		end

		local total, names = 0, {}
		for _, entry in ipairs(found) do
			total = total + entry.price
			table.insert(names, entry.name .. " (" .. entry.price .. ")")
		end

		talks[cid] = true
		say(cid, TEXTS.offer, {TOTAL = total, LIST = table.concat(names, ", ")})
	elseif(msg == "unique" or msg == "uniques" or msg == "unico" or msg == "unicos") then
		say(cid, TEXTS.unique)
	elseif(msg:sub(1, 6) == "price " or msg:sub(1, 6) == "preco ") then
		local name = msg:sub(7):trim()
		local price = PRICES[name]
		if(price) then
			say(cid, TEXTS.price, {NAME = name, PRICE = price})
		else
			say(cid, TEXTS.noprice)
		end
	else
		return false
	end

	return true
end

local function onFarewell(cid)
	talks[cid] = nil
	return true
end

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
