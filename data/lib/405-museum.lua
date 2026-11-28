-- Salao de exposicao dos uniques (museu).
-- O salao e criado do zero pelo script, a partir de Museum.origin (so o chao, o resto fica no void): cada unique de
-- data/XML/uniques.xml vira um item exposto no chao. A lista e lida do XML a cada build, entao adicionar, remover ou
-- renomear um unique so exige reiniciar o servidor (ou usar /museum, access 5) para o salao se ajustar.
-- Nenhum item da area pode ser movido por jogadores (creaturescripts/scripts/museum_moveitem.lua).
-- Ao pisar no teleporte de saida o jogador volta ao templo da propria cidade (movements/scripts/museum_exit.lua).
--
-- Layout: a origem e onde o jogador chega (coloque o teleporte do templo para essa posicao). Os itens ficam em fileiras
-- de Museum.columns itens com 1 sqm livre entre eles, agrupados por tipo (capacetes, armaduras, espadas...), com uma
-- fileira vazia entre os grupos. O chao cobre toda a area e cresce sozinho conforme o numero de uniques.

Museum = {
	-- posicao em que os jogadores chegam (o teleporte do templo deve apontar para ca)
	origin = {x = 1412, y = 505, z = 7},
	-- id do chao (406 = white marble tile)
	ground = 406,
	-- id do chao "void" do mapa: tiles que tem so esse chao sao trocados por Museum.ground
	voidGround = 100,
	-- itens por fileira (numero impar, para a fileira ficar centralizada na origem)
	columns = 9,
	-- distancia entre os itens, em sqm (2 = 1 sqm livre entre eles)
	spacing = 2,
	-- sqm entre a origem e a primeira fileira
	firstRowOffset = 3,
	-- pedestal colocado embaixo de cada unique (0 = nao coloca). Ordem na pilha: pedestal -> unique -> cover
	pedestal = 1642,
	-- item colocado por cima de cada unique, para ninguem conseguir pega-lo (0 = nao coloca)
	cover = 8047,
	-- uniques que NAO entram no salao (nomes exatos)
	exclude = {},

	-- actionid dos itens expostos e do teleporte de saida
	itemActionId = 51501,
	exitActionId = 51500,
	-- item do teleporte de saida (1387 = magic forcefield)
	exitItem = 1387,

	-- ordem e nome dos grupos
	groups = {"Helmets", "Necklaces", "Armors", "Legs", "Boots", "Rings", "Shields", "Swords", "Axes", "Clubs",
		"Distance", "Wands & Rods", "Ammunition", "Others"}
}

-- area ocupada (preenchida no build): {x1, y1, x2, y2, z}
Museum.area = nil
-- uids dos itens expostos / teleporte de saida criados no ultimo build
local placed = {}

local function hasBit(value, bit)
	return math.floor(value / bit) % 2 == 1
end

local function decodeEntities(text)
	return (text:gsub("&apos;", "'"):gsub("&quot;", "\""):gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&"))
end

-- nomes de todos os uniques de uniques.xml (na ordem do arquivo)
function Museum.readUniqueNames()
	local names = {}
	local file = io.open(getDataDir() .. "XML/uniques.xml", "r")
	if(not file) then
		return nil
	end

	local content = file:read("*a")
	file:close()

	content = content:gsub("<!%-%-.-%-%->", "")
	for attributes in content:gmatch("<unique%s([^>]*)>") do
		local name = attributes:match("name=\"([^\"]*)\"")
		if(name) then
			table.insert(names, decodeEntities(name))
		end
	end

	return names
end

-- indice do grupo (Museum.groups) de um item
function Museum.getGroup(itemId)
	local info = getItemInfo(itemId)
	if(not info) then
		return #Museum.groups
	end

	local weaponType = info.weaponType or 0
	if(weaponType == WEAPON_SWORD) then return 8 end
	if(weaponType == WEAPON_AXE) then return 9 end
	if(weaponType == WEAPON_CLUB) then return 10 end
	if(weaponType == WEAPON_SHIELD) then return 7 end
	if(weaponType == WEAPON_DIST) then return 11 end
	if(weaponType == WEAPON_WAND) then return 12 end
	if(weaponType == WEAPON_AMMO) then return 13 end

	local slot = info.slotPosition or 0
	if(hasBit(slot, 1)) then return 1 end -- head
	if(hasBit(slot, 2)) then return 2 end -- necklace
	if(hasBit(slot, 8)) then return 3 end -- armor
	if(hasBit(slot, 64)) then return 4 end -- legs
	if(hasBit(slot, 128)) then return 5 end -- feet
	if(hasBit(slot, 256)) then return 6 end -- ring
	if(hasBit(slot, 512)) then return 13 end -- ammo
	return #Museum.groups
end

function Museum.isInside(pos)
	local area = Museum.area
	if(not area or not pos or pos.z ~= area.z) then
		return false
	end

	return pos.x >= area.x1 and pos.x <= area.x2 and pos.y >= area.y1 and pos.y <= area.y2
end

-- garante o chao do salao no tile: cria o tile se nao existe, troca o void pelo chao do museu e nao mexe em outro chao
local function prepareGround(pos)
	local thing = getThingFromPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}, false)
	if(type(thing) ~= "table" or not thing.uid or thing.uid <= 0) then
		doCreateItem(Museum.ground, 1, pos)
	elseif(thing.itemid == Museum.voidGround) then
		doTransformItem(thing.uid, Museum.ground)
	end
end

local function clearPlaced()
	for _, uid in ipairs(placed) do
		doRemoveItem(uid)
	end

	placed = {}
end

-- cria (ou recria) o salao. Retorna o numero de uniques expostos (nil se uniques.xml nao pode ser lido)
function Museum.build()
	local names = Museum.readUniqueNames()
	if(not names) then
		print("[Warning - Museum] Could not read data/XML/uniques.xml.")
		return nil
	end

	clearPlaced()

	local excluded = {}
	for _, name in ipairs(Museum.exclude) do
		excluded[name:lower()] = true
	end

	-- separa por grupo, ordenando por nome dentro de cada um
	local byGroup = {}
	local total = 0
	for _, name in ipairs(names) do
		local itemId = getUniqueItemId(name)
		if(itemId and not excluded[name:lower()]) then
			local group = Museum.getGroup(itemId)
			if(not byGroup[group]) then
				byGroup[group] = {}
			end

			table.insert(byGroup[group], {name = name, id = itemId})
			total = total + 1
		end
	end

	local origin = Museum.origin
	local columns = math.max(1, Museum.columns)
	local spacing = math.max(1, Museum.spacing)
	local firstRowY = origin.y + Museum.firstRowOffset
	local half = math.floor((columns - 1) / 2)

	-- posicao de cada item (fileira a fileira, uma fileira vazia entre os grupos)
	local slots = {}
	local row = 0
	for group = 1, #Museum.groups do
		local list = byGroup[group]
		if(list) then
			table.sort(list, function(a, b) return a.name < b.name end)
			for index, entry in ipairs(list) do
				local column = (index - 1) % columns
				local currentRow = row + math.floor((index - 1) / columns)
				entry.pos = {
					x = origin.x + (column - half) * spacing,
					y = firstRowY + currentRow * spacing,
					z = origin.z
				}
				table.insert(slots, entry)
			end

			row = row + math.ceil(#list / columns) + 1
		end
	end

	-- area do chao: cobre todas as colunas e as fileiras, com 2 sqm de margem
	local lastRow = math.max(row - 1, 0)
	local area = {
		x1 = origin.x - half * spacing - 2,
		x2 = origin.x + half * spacing + 2,
		y1 = origin.y - 3,
		y2 = firstRowY + lastRow * spacing + 2,
		z = origin.z
	}

	-- se o salao encolheu, o chao antigo continua la, e vale para o bloqueio de movimento tambem
	if(Museum.area) then
		area.x1, area.x2 = math.min(area.x1, Museum.area.x1), math.max(area.x2, Museum.area.x2)
		area.y1, area.y2 = math.min(area.y1, Museum.area.y1), math.max(area.y2, Museum.area.y2)
	end

	Museum.area = area

	for x = area.x1, area.x2 do
		for y = area.y1, area.y2 do
			prepareGround({x = x, y = y, z = area.z})
		end
	end

	-- teleporte de saida (atras da origem)
	local exitPos = {x = origin.x, y = origin.y - 2, z = origin.z}
	local exitUid = doCreateItem(Museum.exitItem, 1, exitPos)
	if(exitUid and exitUid > 0) then
		doItemSetAttribute(exitUid, "aid", Museum.exitActionId)
		table.insert(placed, exitUid)
	end

	local exposed = 0
	for _, entry in ipairs(slots) do
		-- pedestal primeiro, para ficar embaixo do unique
		if(Museum.pedestal and Museum.pedestal > 0) then
			local pedestal = doCreateItem(Museum.pedestal, 1, entry.pos)
			if(pedestal and pedestal > 0) then
				doItemSetAttribute(pedestal, "aid", Museum.itemActionId)
				table.insert(placed, pedestal)
			end
		end

		local uid = doCreateItem(entry.id, 1, entry.pos)
		if(uid and uid > 0) then
			if(doItemSetUnique(uid, entry.name)) then
				doItemSetAttribute(uid, "aid", Museum.itemActionId)
				table.insert(placed, uid)
				exposed = exposed + 1

				-- por cima do unique (criado depois, fica no topo da pilha)
				if(Museum.cover and Museum.cover > 0) then
					local cover = doCreateItem(Museum.cover, 1, entry.pos)
					if(cover and cover > 0) then
						doItemSetAttribute(cover, "aid", Museum.itemActionId)
						table.insert(placed, cover)
					end
				end
			else
				doRemoveItem(uid)
				print("[Warning - Museum] Could not create the unique \"" .. entry.name .. "\".")
			end
		end
	end

	return exposed
end
