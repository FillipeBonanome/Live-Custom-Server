--[[
	RingAttack - biblioteca generica pra magias em formato de anel (donut) centradas no
	caster: um buraco vazio de `holeRadius` sqm no meio, cercado por um anel de
	`ringThickness` sqm de espessura.

	Pensada pra resolver um problema especifico das magias de anel: dano "instantaneo" (toda
	a area de uma vez, via doAreaCombatHealth) fica dessincronizado de uma animacao que gira
	visualmente ao redor do caster (CALLBACK_PARAM_TARGETTILE + addEvent por angulo, ver
	Ignistaurus Ring antes desta lib existir). Aqui dano e efeito acontecem JUNTOS, tile a
	tile, exatamente no instante em que o "giro" alcanca aquele tile - ninguem recebe dano
	antes de o fogo (ou o que for) visualmente passar por cima dele.

	Suporta varios elementos (cada um com seu proprio par CombatType_t/CONST_ME, ver
	config.elements) - mesma regra do RainAttack (data/lib/073-rainattack.lua): se houver N
	elementos, o dano total configurado por tile e dividido igualmente entre eles (cada um
	aplicado de verdade, somando o total configurado), mas o efeito visual (CONST_ME) exibido
	em cada tile e sorteado entre os elementos - tiles vizinhos do mesmo anel podem mostrar
	efeitos diferentes.

	Uso (ver data/spells/scripts/custom/ignistaurus/ring.lua):
		RingAttack.execute(cid, {
			holeRadius = 2,
			ringThickness = 3,
			elements = {
				{combatType = COMBAT_FIREDAMAGE, effect = CONST_ME_FIREATTACK},
				{combatType = COMBAT_ENERGYDAMAGE, effect = CONST_ME_ENERGYHIT},
			},
			damageMin = 70,
			damageMax = 100,
			sweepDuration = 1200,
		})

	Alternativa pra classes skill-based (melee/distancia, dano = skill da arma + attack, nao
	magic level) - a formula delas so existe dentro de um CALLBACK_PARAM_SKILLVALUE, o engine
	nao devolve esse "skill da arma equipada" pra nenhuma funcao Lua fora desse callback (ver
	src/combat.cpp, Combat::getMinMaxValues), entao nao da pra pre-calcular damageMin/damageMax
	como no exemplo acima. Nesse caso passe um Combat ja pronto (area = RingAttack.singleTileArea,
	com o callback de formula normal) em vez de elements/damageMin/damageMax - RingAttack so
	executa esse combat em cada tile do anel, no momento certo, e usa `effect` (um CONST_ME so)
	pro efeito visual (ver data/spells/scripts/dragon knight/draconic ascension.lua):
		RingAttack.execute(cid, {
			holeRadius = 0,
			ringThickness = 2,
			combat = meuCombatComAreaDeUmTileSo,
			effect = CONST_ME_FIREATTACK,
			sweepDuration = 900,
		})

	Pra criar uma magia de anel nova, basta chamar RingAttack.execute com os numeros dela -
	nao precisa reescrever a matriz da area nem a logica de addEvent por angulo.
]]--

RingAttack = { }

-- area de 1 tile so (centro = o proprio tile atingido), reusada pra aplicar o dano de cada
-- tile do anel individualmente, no momento certo - ver getBasicAttackArea em src/combat.cpp
-- (mesma ideia do "nivel 1" de area, so o tile central). Publica (RingAttack.singleTileArea)
-- pra quem for montar o proprio Combat pra usar com config.combat (ver cabecalho do arquivo).
local SINGLE_TILE_AREA = createCombatArea({ {3} })
RingAttack.singleTileArea = SINGLE_TILE_AREA

-- cache dos offsets (relativos ao centro) de cada formato de anel ja calculado, pra nao
-- recalcular a mesma geometria (holeRadius/ringThickness) em toda chamada - varias magias
-- de anel podem compartilhar o mesmo formato.
local ringOffsetCache = { }

-- monta a lista de offsets {x, y, angle} que formam o anel: todo tile cuja distancia
-- euclidiana ao centro esteja entre holeRadius (exclusive) e holeRadius + ringThickness
-- (inclusive). `angle` (0 a 2*pi, sentido anti-horario padrao de math.atan2) e usado depois
-- pra calcular o delay de cada tile na varredura circular.
local function buildRingOffsets(holeRadius, ringThickness)
	local outerRadius = holeRadius + ringThickness
	local offsets = { }

	for dy = -outerRadius, outerRadius do
		for dx = -outerRadius, outerRadius do
			if not (dx == 0 and dy == 0) then
				local distance = math.sqrt(dx * dx + dy * dy)
				if distance > holeRadius and distance <= outerRadius then
					local angle = math.atan2(dy, dx)
					if angle < 0 then
						angle = angle + 2 * math.pi
					end

					offsets[#offsets + 1] = {x = dx, y = dy, angle = angle}
				end
			end
		end
	end

	return offsets
end

local function getRingOffsets(holeRadius, ringThickness)
	local key = holeRadius .. ":" .. ringThickness
	local offsets = ringOffsetCache[key]
	if not offsets then
		offsets = buildRingOffsets(holeRadius, ringThickness)
		ringOffsetCache[key] = offsets
	end

	return offsets
end

--- Executa uma magia em anel ao redor do caster - dano e efeito visual disparados JUNTOS,
--- tile a tile, em ordem circular (por angulo), nunca tudo de uma vez.
-- @param cid    cid do caster (o anel se forma ao redor da posicao dele, capturada no
--               instante da chamada - nao acompanha o caster se ele se mover durante o giro)
-- @param config table de configuracao:
--   config.holeRadius     (number) raio (sqm) do buraco vazio no meio (padrao 2)
--   config.ringThickness  (number) espessura (sqm) do anel (padrao 3)
--   config.elements       (table)  lista de {combatType=, effect=} - obrigatorio SE config.combat
--                                  nao for passado. Se houver N elementos, o dano de cada tile e
--                                  dividido igualmente entre eles (1/N cada, todos aplicados de
--                                  verdade), mas o CONST_ME exibido naquele tile e sorteado
--                                  entre os elementos configurados
--   config.damageMin      (number) dano minimo TOTAL por tile atingido, positivo (padrao 0)
--   config.damageMax      (number) dano maximo TOTAL por tile atingido, positivo (padrao 0)
--   config.combat         (Combat) alternativa a elements/damageMin/damageMax, pra classes
--                                  skill-based (ver cabecalho do arquivo) - precisa ter area
--                                  = RingAttack.singleTileArea e o proprio CALLBACK_PARAM_SKILLVALUE
--                                  configurado. Quando presente, RingAttack so chama
--                                  doCombat(cid, config.combat, positionToVariant(tile)) em
--                                  cada tile do anel (elements/damageMin/damageMax sao ignorados)
--   config.effect         (CONST_ME) efeito exibido em cada tile - so usado junto de config.combat
--                                    (com elements, o efeito vem sorteado da lista deles)
--   config.sweepDuration  (number) ms pra o anel completar uma volta cheia (padrao 1200)
--   config.onTile         (function) opcional, function(position) chamada no exato
--                                    instante em que aquele tile e atingido, alem do
--                                    dano/efeito padrao (ex: aplicar uma condition extra)
function RingAttack.execute(cid, config)
	config = config or { }
	if not isCreature(cid) then
		return
	end

	local elements = config.elements
	local combat = config.combat
	if not combat and (not elements or #elements == 0) then
		return
	end

	local holeRadius = config.holeRadius or 2
	local ringThickness = config.ringThickness or 3
	local sweepDuration = config.sweepDuration or 1200
	local share = elements and (1 / #elements) or 1
	local shareMin, shareMax = (config.damageMin or 0) * share, (config.damageMax or 0) * share

	local origin = getCreaturePosition(cid)
	local offsets = getRingOffsets(holeRadius, ringThickness)

	for _, offset in ipairs(offsets) do
		local position = {x = origin.x + offset.x, y = origin.y + offset.y, z = origin.z}
		local delay = math.floor((offset.angle / (2 * math.pi)) * sweepDuration)

		addEvent(function()
			if not isCreature(cid) then
				return
			end

			-- tile sem linha de visao livre a partir do centro (parede no meio do caminho)
			-- nao e atingido - sem isso o anel passava por dentro de paredes, acertando
			-- quem estivesse do outro lado (mesmo isSightClear de 074-randomwalkattack.lua)
			if not isSightClear(origin, position, false) then
				return
			end

			if combat then
				doSendMagicEffect(position, config.effect or CONST_ME_NONE)
				doCombat(cid, combat, positionToVariant(position))
			else
				-- o efeito exibido nesse tile e sorteado entre os elementos, mas o dano de
				-- TODOS eles (1/N cada) e aplicado de verdade, independente de qual apareceu
				-- visualmente
				doSendMagicEffect(position, elements[math.random(#elements)].effect)
				for _, element in ipairs(elements) do
					doAreaCombatHealth(cid, element.combatType, position, SINGLE_TILE_AREA, -shareMax, -shareMin, CONST_ME_NONE)
				end
			end

			if config.onTile then
				config.onTile(position)
			end
		end, delay)
	end
end
