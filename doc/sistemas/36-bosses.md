# IA de monstros e bosses

Sistema de IA no estilo do WoL: **máquina de estados** (fases) + **árvore de decisão** por estado. A IA **nunca ataca diretamente**: ela só **decide qual magia lançar** e manda para `doCreatureCastSpell`. As magias são magias normais do `spells.xml`, então cada boss pode ter magias totalmente customizadas (áreas telegrafadas com `CONST_ME_TUTORIALSQUARE`, invocações, escudos...) e a mesma magia pode ser reaproveitada por vários monstros.

Libs: `data/lib/391-monster-ai.lua` (IA), `data/lib/392-telegraph.lua` (ataques telegrafados), `data/lib/393-bosses.lua` (IA dos bosses).

## Como funciona
1. O XML do monstro tem um ataque `<attack name="AI Think" interval="1000" chance="100"/>`. Como todo ataque de monstro, ele só roda enquanto o monstro tem alvo.
2. `AI Think` é uma magia do `spells.xml` que chama `MonsterAI.think(cid)`.
3. A cada think: (a) a **máquina de estados** confere as `transitions` do estado atual (a primeira verdadeira vence); (b) a **árvore de decisão** do estado escolhe o nome de uma magia; (c) se ela está pronta (cooldown da IA, cooldown de grupo e alcance), a IA lança com `doCreatureCastSpell(cid, nome, true)`.
4. O `force = true` ignora cooldown, mana e alcance do `spells.xml`, então **a IA controla os cooldowns** (campo `spells` da definição) e o `globalCooldown` entre duas magias quaisquer.

## Registrar a IA de um monstro
```lua
MonsterAI.register("Warlord Ruzad", {            -- nome do monstro (sem diferenciar maiúsculas)
	initialState = "Assault",
	globalCooldown = 2500,                       -- ms entre duas magias (padrão 1500)
	spells = {                                   -- metadados das magias usadas
		["Ruzad Warcry"] = {cooldown = 6000, range = 6, say = "RANAT ULDEREK!", group = "area", groupCooldown = 3000},
	},
	states = {
		Assault = {
			onEnter = function(monster, target, memory) end,   -- opcional
			onExit  = function(monster, target, memory) end,   -- opcional
			cooldowns = {["Ruzad Warcry"] = 10000},            -- opcional: só ALONGA o cooldown da magia neste estado
			transitions = {
				{to = "Rally", condition = Cond.hpBelow(66)}
			},
			tree = DecisionTree.priority({"Ruzad Warcry", "Ruzad Axe Storm"}),
		},
	},
	onDeath = function(monster) end,             -- opcional
})
```
`monster` e `target` são ids de criatura (este servidor não tem objetos de criatura) e `memory` é uma tabela livre, uma por monstro (guarde flags nela).

**Metadados da magia (`spells[nome]`)**: `cooldown` (ms), `range` (a magia só é escolhida com o alvo a até esse alcance), `say` (o monstro grita ao lançar), `group` + `groupCooldown` (todas as magias do mesmo grupo esperam esse tempo depois de qualquer uma delas).

Uma magia que **falha** (retorna `false`: sem alvo, sem espaço...) entra num cooldown curto (`MonsterAI.retryCooldown`, 2 s) para não travar as magias seguintes de uma `priority`.

## Árvore de decisão
| Nó | Significado |
|---|---|
| `DecisionTree.action("Magia")` | Lança esta magia |
| `DecisionTree.branch(cond, seVerdadeiro, seFalso)` | `cond(monster, target, memory)` decide o lado; cada lado é um nó ou `nil` ("nenhuma magia por este caminho") |
| `DecisionTree.priority({"A", "B", "C"})` | A **primeira** magia da lista que está pronta e no alcance |
| `DecisionTree.chance(p, seVerdadeiro, seFalso)` | `branch` com p% de chance |
| `DecisionTree.custom(function(monster, target, memory) return "Magia" end)` | Escape: devolve o nome da magia (ou `nil`) |

**Cuidado**: um `action` cuja magia está em cooldown **gasta o tick sem lançar nada**. Para cair na próxima opção, proteja o `action` com `Cond.ready("Magia")` no `branch`, ou use `priority`.

### Condições prontas (`Cond.*`, funções `(monster, target, memory) -> boolean`)
`all(a, b, ...)` (E), `any(a, b, ...)` (OU), `no(cond)`, `hpBelow(p)`, `hpAbove(p)`, `playersAround(quantidade, alcance)`, `targetFar(d)`, `targetNear(d)`, `summonsBelow(n)`, `noSummons()`, `ready("Magia")`, `inState(ms)`, `age(ms)`, `chance(p)`, `flag("nome")` (olha `memory[nome]`).

### Funções para condições e magias (`MonsterAI.*`, com o id da criatura)
`hpPercent(cid)`, `distance(cid, target)`, `playersAround(cid, alcance)` (jogadores fora de PZ), `summonCount(cid)`, `getMemory(cid)`, `getState(cid)`, `setState(cid, "Estado")` (as magias também podem trocar de estado), `stateAge(cid)`, `age(cid)`, `isReady(cid, "Magia")`, `setCooldown(cid, "Magia", ms)`, `say(cid, texto[, tipo])`, `after(cid, ms, fn)`, `heal(cid, %)`, `setImmune(cid, true/false)` (escudo: bloqueia todo o dano), `summon(cid, "Monstro", quantidade[, max])`.

## Criar uma magia
1. Script em `data/spells/scripts/ai/nome.lua` com `onCastSpell(cid, var)`.
2. Entrada no `data/spells/spells.xml`:
```xml
<instant name="Ruzad Warcry" words="ai ruzad warcry" lvl="1" mana="0" prem="0" needlearn="1" event="script" value="ai/ruzad warcry.lua"/>
```
`needlearn="1"` impede jogadores de usar; `needtarget="1"` quando a magia precisa do alvo atual (o script lê `getCreatureTarget(cid)`). O nome da magia é o que a árvore devolve.

### Magias telegrafadas (`Telegraph`)
`Telegraph.strike{...}` marca os tiles com `CONST_ME_TUTORIALSQUARE` (reenviado a cada 1 s enquanto espera) e, depois de `delay` ms, causa o dano em quem **ainda estiver** neles, então dá para desviar. Se o caster morrer antes, nada acontece.
```lua
function onCastSpell(cid, var)
	Telegraph.strike{
		caster = cid, tiles = Telegraph.square(getCreaturePosition(cid), 3), delay = 1200,
		combat = COMBAT_PHYSICALDAMAGE, min = 50, max = 100, effect = CONST_ME_EXPLOSIONAREA
	}
	return true
end
```
| Opção | Significado |
|---|---|
| `caster` | Criatura que causa o dano |
| `tiles` | Lista de posições |
| `delay` | ms entre a marca e o golpe (padrão 1500) |
| `combat`, `min`, `max` | Tipo de dano e valores (positivos). Sem `combat`, só o visual |
| `effect` | Efeito que aparece em cada tile no golpe |
| `warn` | Efeito de aviso (padrão `CONST_ME_TUTORIALSQUARE`) |
| `onLand(tiles)` | Roda quando o golpe cai, antes do dano (ex.: teletransportar o caster) |
| `onHit(pid, pos)` | Roda para cada jogador atingido (ex.: aplicar uma condition) |

Formas: `Telegraph.square(centro, raio)`, `ring(centro, raio)` (só a borda), `disc(centro, raio)`, `line(origem, direção, comprimento[, largura])`, `cross(centro, comprimento)`, `cone(origem, direção, comprimento)` e `merge(a, b, ...)` para juntar listas. Tiles que não existem no mapa ficam de fora.

`Telegraph.strikes(opções, quantidade, function(índice) return tiles end, intervalo)` dispara vários golpes escalonados, por exemplo uma chuva de marcas sobre jogadores sorteados.

## Ligar a IA a um monstro
Em `data/lib/393-bosses.lua` fica o `MonsterAI.register`. O XML do monstro precisa do cérebro (como no WoL): `<attack name="AI Think" interval="1000" chance="100"/>`. Para um boss novo, crie o monstro em `monsters.xml` e acrescente esse ataque. O boss da invasão (`boss = {name = "..."}` em `Invasions.list`) funciona com a IA de qualquer monstro que a tenha; os que ainda não têm continuam como monstros comuns.

Na primeira vez que pensa, a IA registra no monstro os eventos `AIShield` (escudo) e `AIDeath` (as invocações somem com o boss e roda o `onDeath` da definição).

## Boss pronto: Warlord Ruzad (invasão Orc Horde, tier I)
```
Assault ──(vida < 66%)──> Rally ──(guardas mortos ou 45 s)──> Bloodlust ──(vida < 33%)──> Berserk
```
| Estado | O que acontece |
|---|---|
| `Assault` | Luta normal: **Warcry** com 3+ jogadores a 4 sqm; chama guardas (35%) com menos de 2 summons; **Charge** se o alvo está a mais de 4 sqm; **Axe Storm** (30%) |
| `Rally` | **Escudo**: não toma dano enquanto 3 Orc Berserkers e 3 Orc Warriors o protegem (a magia `Ruzad Rally` invoca e liga o escudo). Matar os guardas quebra o escudo; sem isso, 45 s |
| `Bloodlust` | Igual ao Assault, com os guardas voltando (40%) e o Axe Storm mais frequente (45%) |
| `Berserk` | +60 de velocidade para sempre, **Fire Storm**, Warcry maior (9x9, 60-120); com 15% de vida **Last Stand** cura 15% **uma única vez** |

| Magia | O que faz |
|---|---|
| `Ruzad Warcry` | Quadrado 7x7 em volta dele (9x9 no berserk) marcado, golpe físico 1,2 s depois (50-100) |
| `Ruzad Axe Storm` | 4 marcas 3x3 caindo em sequência sobre jogadores sorteados (40-80, 1,5 s) |
| `Ruzad Fire Storm` | 6 marcas 3x3 de fogo (50-100) |
| `Ruzad Charge` | Marca 3x3 em volta do alvo; 1 s depois ele pula ao lado e acerta a área (60-110) |
| `Ruzad Call Guards` | 2 Orc Warriors (máximo de 4 summons vivos) |
| `Ruzad Rally` | Escudo e 3 Berserkers + 3 Warriors |
| `Ruzad Last Stand` | Cura 15% (uma vez, controlado por `memory.lastStand`) |

Os números são estimativas para o tier I; ajuste em `data/lib/393-bosses.lua` e nos scripts de `data/spells/scripts/ai/`.

## Comandos
| Comando | Quem | O que faz |
|---|---|---|
| `/boss` | staff (access 4) | Mostra os monstros com IA a até 12 sqm: estado, última magia e vida |

## Detalhes técnicos
- **Estados Lua**: a magia `AI Think` e as magias que ela lança rodam no estado Lua das magias, onde ficam os dados de cada monstro (`MonsterAI.runtime`, `memory`, cooldowns). Os eventos de criatura (`AIShield`, `AIDeath`) rodam em outro estado, então o que eles precisam fica em storages de criatura: o escudo (`54731`) e o espelho `"B:estado|última magia"` (`54730`), lido pelo `/boss`. Os dados dos monstros mortos são limpos aos poucos (a cada 120 thinks de qualquer monstro com IA).
- Os cooldowns usam `os.mtime()` (milissegundos).
- As invocações usam `doSummonMonster`, que as liga ao dono: `getCreatureSummons` funciona em qualquer estado e elas somem quando o boss morre.
- O escudo bloqueia o dano inteiro (não existe dano reduzido). Os minions não contam como invasores da invasão.
- A IA só roda com alvo (é um ataque de monstro) e é procurada pelo nome do monstro; monstros epic ou com nome alterado não casam.

## Arquivos
| Arquivo | Função |
|---|---|
| `data/lib/391-monster-ai.lua` | `DecisionTree`, `Cond`, `MonsterAI` (registro, estados, cooldowns, think, escudo, summons) |
| `data/lib/392-telegraph.lua` | `Telegraph`: formas e golpes telegrafados |
| `data/lib/393-bosses.lua` | IA dos bosses (por enquanto Warlord Ruzad) |
| `data/spells/scripts/ai/*.lua` | `ai think.lua` e as magias do Ruzad |
| `data/spells/spells.xml` | Magias `AI Think` e `Ruzad ...` |
| `data/creaturescripts/scripts/ai_shield.lua`, `ai_death.lua` | Eventos `AIShield` e `AIDeath` |
| `data/talkactions/scripts/boss.lua` | Comando `/boss` |
| `data/monster/Orcs/Warlord Ruzad.xml` | Ataque `AI Think` |

Storages de criatura reservados: `54730` (espelho do estado) e `54731` (escudo).
