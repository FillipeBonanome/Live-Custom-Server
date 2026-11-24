-- SpellBalance: multiplicadores de dano/cura das magias (data/spells/scripts), num lugar so.
--
-- COMO FUNCIONA
--   Todo script de magia em data/spells/scripts passa por aqui automaticamente, sem editar o script:
--     * setCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE / CALLBACK_PARAM_SKILLVALUE, "funcao") ganha um
--       "wrapper" que multiplica o min/max devolvido pela funcao da magia;
--     * setCombatFormula / setAttackFormula / setHealingFormula com COMBAT_FORMULA_LEVELMAGIC viram um callback
--       equivalente (mesma conta do servidor: (level / minl + maglevel * minm) * mina + minb, com piso), tambem
--       multiplicado.
--     * as mesmas funcoes com COMBAT_FORMULA_SKILL / VALUE (dano de arma) ficam como estao.
--   O multiplicador final e a multiplicacao de:
--     global * (damage ou healing) * group[pasta] * vocation[voc] * spells[chave] * spellVocation[chave][voc]
--   Cura = resultado positivo, dano = resultado negativo.
--
-- A "chave" de uma magia e o caminho do script sem a extensao, a partir de data/spells/scripts, ex.:
--   "attack/death strike", "healing/light healing", "berserker/cleave". A "pasta" e a primeira parte ("attack").
--   Vocacoes promovidas usam o valor da vocacao base quando nao tem valor proprio (ex.: 8 usa o de 4).
--
-- MAGIAS QUE CAUSAM DANO DIRETO PELA LUA (doTargetCombatHealth, doAreaCombatHealth...) nao passam por callback:
--   use  SpellBalance.scale(cid, "berserker/rampage", valor [, "damage" | "healing"])  no script para aplicar.
--
-- Depois de mudar este arquivo: /reload spells (ou reinicie o servidor).

SpellBalance = {
	enabled = true,

	global = 1.0,
	damage = 1.0,
	healing = 1.0,

	-- por pasta de data/spells/scripts ("attack", "healing", "support", "berserker", "assassin", ...)
	group = {
		-- attack = 1.0,
	},

	-- por vocacao (id de data/XML/vocations.xml). Quem nao esta aqui usa a vocacao base, e se tambem nao tiver, 1.0
	vocation = {
		-- [1] = 1.0,  -- Sorcerer
		-- [2] = 1.0,  -- Druid
		-- [3] = 1.0,  -- Paladin
		-- [4] = 1.0,  -- Knight
	},

	-- por magia
	spells = {
		-- ["attack/death strike"] = 0.9,
		["berserker/cleave"] = 1.0
	},

	-- por magia e vocacao: spellVocation["attack/death strike"] = {[1] = 0.8, [2] = 1.1}
	spellVocation = {
	}
}

-- ---------------------------------------------------------------------------------------------------------------
-- implementacao

local SB = SpellBalance
local counter = 0

local function normalize(path)
	path = tostring(path or ""):gsub("\\", "/"):lower()
	local pos = path:find("spells/scripts/", 1, true)
	if(not pos) then
		return nil
	end

	return (path:sub(pos + #"spells/scripts/"):gsub("%.lua$", ""))
end

-- chave da magia que esta sendo carregada: sobe a pilha ate achar o script em data/spells/scripts que chamou
-- (setAttackFormula / setHealingFormula passam por setCombatFormula, entao o script pode estar uns niveis acima)
local function callerKey()
	if(not debug or not debug.getinfo) then
		return nil
	end

	for level = 3, 8 do
		local info = debug.getinfo(level, "S")
		if(not info) then
			return nil
		end

		local key = normalize(info.source)
		if(key) then
			return key
		end
	end

	return nil
end

function SpellBalance.groupOf(key)
	return key and key:match("^([^/]+)/") or ""
end

local function baseVocation(voc)
	local info = getVocationInfo(voc)
	if(info and info.fromVocation and info.fromVocation ~= voc) then
		return info.fromVocation
	end

	return voc
end

local function vocValue(map, voc)
	if(not map) then
		return nil
	end

	return map[voc] or map[baseVocation(voc)]
end

-- multiplicador de uma magia para um jogador. kind = "damage" | "healing"
function SpellBalance.multiplier(cid, key, kind)
	if(not SB.enabled) then
		return 1
	end

	local mult = (SB.global or 1) * ((kind == "healing" and SB.healing or SB.damage) or 1)
	if(key) then
		mult = mult * ((SB.group[SB.groupOf(key)]) or 1) * (SB.spells[key] or 1)
	end

	if(cid and isPlayer(cid)) then
		local voc = getPlayerVocation(cid)
		mult = mult * (vocValue(SB.vocation, voc) or 1)
		if(key) then
			mult = mult * (vocValue(SB.spellVocation[key], voc) or 1)
		end
	end

	return mult
end

-- aplica o multiplicador a um valor (positivo = cura, negativo = dano; kind e opcional)
function SpellBalance.scale(cid, key, value, kind)
	kind = kind or (value > 0 and "healing" or "damage")
	return math.floor(value * SpellBalance.multiplier(cid, key, kind))
end

local function scaled(cid, key, min, max)
	min, max = tonumber(min) or 0, tonumber(max) or 0
	local kind = ((min + max) > 0) and "healing" or "damage"
	local mult = SpellBalance.multiplier(cid, key, kind)
	return math.floor(min * mult), math.floor(max * mult)
end

-- --- wrap de setCombatCallback ---------------------------------------------------------------------------------

local originalSetCombatCallback = setCombatCallback
function setCombatCallback(combat, key, functionName)
	local scriptKey = callerKey()
	if(scriptKey and (key == CALLBACK_PARAM_LEVELMAGICVALUE or key == CALLBACK_PARAM_SKILLVALUE)) then
		local original = _G[functionName]
		if(type(original) == "function") then
			counter = counter + 1
			local wrapperName = "__spellBalance" .. counter
			_G[wrapperName] = function(...)
				local min, max = original(...)
				return scaled(select(1, ...), scriptKey, min, max)
			end

			return originalSetCombatCallback(combat, key, wrapperName)
		end
	end

	return originalSetCombatCallback(combat, key, functionName)
end

-- --- wrap de setCombatFormula (usado direto pelos scripts e por setAttackFormula / setHealingFormula) -----------

-- Combat::getMinMaxValues (FORMULA_LEVELMAGIC):
--   min = (level / minl + maglevel * minm) * mina + minb   (idem max); minc/maxc = piso (vale quando o valor e menor)
-- vira um callback equivalente, com o multiplicador. COMBAT_FORMULA_SKILL / VALUE ficam como estao.
local originalSetCombatFormula = setCombatFormula

function setCombatFormula(...)
	local combat, formulaType, mina, minb, maxa, maxb, minl, maxl, minm, maxm, minc, maxc = ...
	local scriptKey = callerKey()
	if(not scriptKey or formulaType ~= COMBAT_FORMULA_LEVELMAGIC) then
		-- repassa os argumentos exatamente como vieram (o servidor usa a quantidade deles)
		return originalSetCombatFormula(...)
	end

	local defaultLevel = tonumber(getConfigValue("formulaLevel")) or 5
	local defaultMagic = tonumber(getConfigValue("formulaMagic")) or 1
	mina, minb, maxa, maxb = tonumber(mina) or 0, tonumber(minb) or 0, tonumber(maxa) or 0, tonumber(maxb) or 0
	minl, maxl = tonumber(minl) or defaultLevel, tonumber(maxl) or tonumber(minl) or defaultLevel
	minm, maxm = tonumber(minm) or defaultMagic, tonumber(maxm) or tonumber(minm) or defaultMagic
	minc, maxc = tonumber(minc) or 0, tonumber(maxc) or 0

	counter = counter + 1
	local name = "__spellBalance" .. counter
	_G[name] = function(cid, level, maglevel)
		local min = (level / minl + maglevel * minm) * mina + minb
		local max = (level / maxl + maglevel * maxm) * maxa + maxb
		if(minc ~= 0 and math.abs(min) < math.abs(minc)) then
			min = minc
		end

		if(maxc ~= 0 and math.abs(max) < math.abs(maxc)) then
			max = maxc
		end

		return scaled(cid, scriptKey, min, max)
	end

	return originalSetCombatCallback(combat, CALLBACK_PARAM_LEVELMAGICVALUE, name)
end
