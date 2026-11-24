# IA de monstros e bosses

Sistema de IA no estilo do WoL: **máquina de estados** (fases) + **árvore de decisão** por estado. A IA **nunca ataca diretamente**: ela só **decide qual magia lançar** e manda para `doCreatureCastSpell`. As magias são magias normais do `spells.xml`, então cada boss pode ter magias totalmente customizadas (áreas telegrafadas com `CONST_ME_TUTORIALSQUARE`, invocações, escudos...) e a mesma magia pode ser reaproveitada por vários monstros.

Libs: `data/lib/391-monster-ai.lua` (IA), `data/lib/392-telegraph.lua` (ataques telegrafados), `data/lib/393-bosses.lua` (IA dos bosses do tier I), `data/lib/394-boss-spells.lua` (mecânicas dos bosses do tier II em diante) e `data/lib/395-bosses-tier2.lua`.

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
| `Berserk` | +60 de velocidade para sempre, **Blade Cross**, Warcry maior (9x9, 60-120); com 15% de vida **Last Stand** cura 15% **uma única vez** |

| Magia | O que faz |
|---|---|
| `Ruzad Warcry` | Quadrado 7x7 em volta dele (9x9 no berserk) marcado, golpe físico 1,2 s depois (50-100) |
| `Ruzad Axe Storm` | 4 marcas 3x3 caindo em sequência sobre jogadores sorteados (40-80, 1,5 s) |
| `Ruzad Blade Cross` | 3 estrelas (centro + 8 braços de 6 sqm com 1 de largura: 4 retos e 4 diagonais) marcadas sobre jogadores; machados giram no centro e saem pelos braços (70-130, 1,6 s) |
| `Ruzad Charge` | Marca 3x3 em volta do alvo; 1 s depois ele pula ao lado e acerta a área (60-110) |
| `Ruzad Call Guards` | 2 Orc Warriors (máximo de 4 summons vivos) |
| `Ruzad Rally` | Escudo e 3 Berserkers + 3 Warriors |
| `Ruzad Last Stand` | Cura 15% (uma vez, controlado por `memory.lastStand`) |

Os números são estimativas para o tier I; ajuste em `data/lib/393-bosses.lua` e nos scripts de `data/spells/scripts/ai/`.

## Bosses prontos do tier I
Cada invasão do tier I tem um boss próprio (monstro novo, com nome único e `AI Think` no XML). `Telegraph.directionTo(de, para)` dá a direção (N/L/S/O) usada pelos cones.

### Queen Silkara (Spider Nest) — 12000 de vida
```
Hunt ──(vida < 66%)──> Brood ──(ninhada morta ou 45 s)──> Swarm ──(vida < 33%)──> Frenzy
```
| Estado | O que acontece |
|---|---|
| `Hunt` | **Venom Spit** em quem está longe, **Venom Rain**/**Web Trap** de perto, chama Poison Spiders (35%) |
| `Brood` | **Escudo** enquanto 4 Poison Spiders e 2 Tarantulas a protegem (a magia `Silkara Egg Sac` invoca e liga o escudo); sem isso, 45 s |
| `Swarm` | Igual ao Hunt, com a ninhada voltando mais (45%) e mais Venom Rain |
| `Frenzy` | +60 de velocidade para sempre, Venom Rain com 6 gotas, **Toxic Nova** |

### Chief Grumbak (Troll Warband) — 14000 de vida
```
Warband ──(vida < 60%)──> Blizzard ──(vida < 30%)──> Rage
```
| Estado | O que acontece |
|---|---|
| `Warband` | **Quake** com 3+ jogadores a 3 sqm, **Boulder Toss** em quem está longe, **Frost Lines**, chama Frost Trolls (30%) |
| `Blizzard` | Lança o **Blizzard** assim que entra; Blizzard (50%) e Frost Lines bem mais frequentes |
| `Rage` | +50 de velocidade para sempre, Quake 9x9 (60-120), 2 pedras no Boulder Toss, Frost Lines também nas diagonais e **Avalanche** |

### Fenrak Moonfang (Wolf Pack) — 11000 de vida
```
Stalk ──(vida < 66%)──> Moonrise ──(vida < 33%)──> Bloodmoon
```
| Estado | O que acontece |
|---|---|
| `Stalk` | **Pounce** em quem está longe, **Claw Rake** de perto, **Moonfall** de vez em quando |
| `Moonrise` | +30 de velocidade, uivo ao entrar e depois (35%) chamando 3 War Wolves, Moonfall mais frequente |
| `Bloodmoon` | +40 de velocidade, Claw Rake nos dois lados, **Blood Rend** (60%), Pounce mais rápido |

### Magias por boss
| Boss | Magia | O que faz |
|---|---|---|
| Queen Silkara | `Silkara Venom Rain` | 4 marcas 3x3 (6 no frenzy) sobre jogadores sorteados, terra 35-70 (1,6 s) |
| | `Silkara Web Trap` | Círculo de raio 2 no alvo; terra 20-40 e **lentidão** de 4 s (1,4 s) |
| | `Silkara Venom Spit` | Cone de 6 sqm na direção do alvo, terra 50-95 (1,3 s) |
| | `Silkara Call Brood` | 3 Poison Spiders (máximo de 6 summons) |
| | `Silkara Egg Sac` | Escudo + 4 Poison Spiders + 2 Tarantulas |
| | `Silkara Toxic Nova` | Círculo de raio 5 **menos o 3x3 colado nela**, terra 70-130 (1,9 s) |
| Chief Grumbak | `Grumbak Quake` | Círculo de raio 3 (4 na rage) em volta dele, físico 50-100 (60-120 na rage) (1,6 s) |
| | `Grumbak Boulder Toss` | Pedra 3x3 no alvo (outra em outro jogador na rage), físico 55-105 (1,6 s) |
| | `Grumbak Frost Lines` | 4 linhas de 7 sqm (8 na rage, com as diagonais), gelo 60-110 (1,5 s) |
| | `Grumbak Blizzard` | 6 marcas 3x3 sobre jogadores sorteados, gelo 40-80 (1,6 s) |
| | `Grumbak Call Trolls` | 3 Frost Trolls (máximo de 5 summons) |
| | `Grumbak Avalanche` | Faixas de 2 sqm com corredor de 1 sqm entre elas, na vertical ou horizontal, gelo 70-130 (2 s) |
| Fenrak Moonfang | `Fenrak Pounce` | Marca 3x3 no alvo, ele pula ao lado e acerta a área, físico 60-110 (1,4 s) |
| | `Fenrak Claw Rake` | Cone de 5 sqm na direção do alvo (e no lado oposto no bloodmoon), físico 70-120 (1,3 s) |
| | `Fenrak Pack Howl` | 2 War Wolves (3 depois da lua, máximo de 6 summons) |
| | `Fenrak Moonfall` | 5 marcas 3x3 sobre jogadores sorteados, morte 40-80 (1,5 s) |
| | `Fenrak Blood Rend` | Primeiro as 4 diagonais, 0,8 s depois as 4 retas (7 sqm), físico 60-110 cada |

Os monstros novos não estão em `302-monsterlevels.lua`: o nível é calculado pela fórmula (use `/monsterlevels` para gerar as linhas).

## Bosses do tier II e a biblioteca de mecânicas
Do tier II em diante os bosses usam `data/lib/394-boss-spells.lua` (`BossSpell`): a mecânica de cada magia é definida **uma vez**, em Lua, em `data/lib/395-bosses-tier2.lua` (`BossSpell.define("Nome", function(cid, memory, alvo) ... end)`), e o script da magia (`data/spells/scripts/ai/<nome>.lua`) só faz `return BossSpell.cast(cid, "Nome")`. Para criar uma magia: `define` no arquivo do tier, script de 3 linhas e entrada no `spells.xml`.

A dificuldade sobe com o tier. O tier I tem 3 fases e ataques que só se desvia saindo da marca. O tier II tem **4 fases** (uma delas com escudo), marcas que perseguem jogadores, ondas que se expandem, linhas em etapas, dano contínuo e uma **zona segura** na última fase. Os tiers seguintes devem combinar essas mecânicas e acrescentar outras.

| Mecânica (`BossSpell.*`) | Como funciona | Como desviar |
|---|---|---|
| `rain` | Marcas (raio, dispersão) caindo uma a uma sobre jogadores sorteados | Sair da marca |
| `cone` / `lanes` | Cone ou faixas paralelas na direção do alvo (`turns` bate nos outros lados) | Ficar entre as faixas ou fora da direção |
| `nova` | Disco em volta do boss com um quadrado seguro colado nele (`safe`) | Ficar colado ou fora do disco |
| `waves` | Anéis que acertam em sequência (`bands`, `reverse` = de fora para dentro) | Entrar no anel que já acertou |
| `arms` | Linhas retas e diagonais em etapas (`stages`); o lugar seguro de uma etapa é atingido na seguinte | Não parar de se mexer |
| `stripes` | Faixas de 2 sqm com 1 sqm livre entre elas (vertical ou horizontal) | Achar o corredor |
| `bait` | A marca **segue** `count` jogadores (efeito vermelho) e trava depois de `follow` ms | Quem é marcado afasta-se do grupo |
| `chain` | Acerta um jogador e pula para o mais próximo que ainda não foi atingido (`hops`, `hop`) | Manter distância entre os jogadores |
| `leap` | Marca a área, pula ao lado e acerta; `after(cid, centro)` encadeia outro golpe | Sair da marca |
| `safeSpots` | A arena toda é marcada, **menos** quadrados 3x3 em verde (`spots`) | Entrar num quadrado verde |
| `summon` / `shield` | Invoca guardas; o escudo bloqueia todo o dano até os guardas morrerem (ou 40 s) | Matar os guardas |

Efeitos nos jogadores, em qualquer mecânica: `slow = {percentual, ms}` (lentidão) e `dot = {combat, damage, ticks, interval, effect}` (dano contínuo; um novo substitui o anterior).

Os 7 bosses seguem o mesmo esqueleto: `Fase 1` ─(vida < ~68%)─> **fase de escudo** ─(guardas mortos ou 40 s)─> `Fase 3` ─(vida < 35%)─> `Fase final` (`memory.final`, velocidade e a magia de zonas seguras). Em `rage` (fases 3 e final) as magias ficam maiores (mais marcas, mais saltos...).

| Invasão | Boss (vida) | Fases | Magias (dano) |
|---|---|---|---|
| Dwarven Uprising | **Forgemaster Brokk** (24000) | Forge → Overheat → Meltdown → Cataclysm | `Hammer Slam` cone, nos dois lados na rage (90-150) · `Powder Keg` isca raio 2 + queimadura (110-180) · `Anvil Waves` 4 ondas, ao contrário no final (80-140) · `Molten Rain` 6-8 marcas + queimadura (70-120) · `Forge Guards` escudo + 4 Dwarf Guards e 2 Geomancers · `Cataclysm` 3 zonas seguras (160-260) |
| Minotaur Warband | **Hexlord Mokthar** (22000) | Ritual → Warded → Unbound → Overload | `Arcane Lines` retas/diagonais em 3 etapas (80-140) · `Hex Bolt` isca + lentidão (110-170) · `Chain Lightning` 4-6 saltos (90-150) · `Overload` disco raio 7 com 5x5 seguro (120-190) · `Call Herd` guardas e arqueiros · `Mystic Ward` escudo + 3 Mages e 2 Guards |
| Amazon Assault | **Empress Aethra** (23000) | Skirmish → Phalanx → Onslaught → Last Stand | `Spear Barrage` 3-5 faixas (90-150) · `Javelin Rain` 5-7 marcas + lentidão (70-120) · `Mark of Prey` isca raio 2 (160-260) · `Phalanx Charge` salto + cone logo depois (90-150 + 90-140) · `Shield Wall` escudo + 3 Valkyries e 2 Amazons · `Last Stand` cura 12% uma vez |
| Pirate Raid | **Captain Blackreef** (25000) | Broadside → Boarding → Powder Hold → Scuttle | `Cannon Barrage` 6-8 marcas (80-140) · `Broadside` faixas (90-150) · `Grapple Hook` **puxa** um jogador e corta em cone (120-190) · `Sea Mines` 7-9 marcas de 3,8 s (100-160) · `Boarding Party` escudo + 6 piratas · `Scuttle` 2 zonas seguras (170-270) |
| Cyclops Rampage | **Titan Korg** (28000) | Smash → Stone Skin → Rockfall → Titanfall | `Ground Slam` 3-4 ondas (90-150) · `Boulder Barrage` 5-7 marcas 5x5 (100-170) · `Rock Chain` 4-5 saltos (100-160) · `Stomp` salto 5x5 (110-180) · `Stone Skin` escudo + 3 Cyclops e 2 Smiths · `Titanfall` 3 zonas seguras (170-270) |
| Lizard Legion | **Hierarch Ssurrak** (22000) | Ambush → Shed Skin → Venom → Sunscale | `Spear Volley` 3-5 faixas (90-150) · `Venom Cloud` 4-6 nuvens + veneno (60-100) · `Tail Sweep` cone nos 4 lados, curto (100-160) · `Marked Prey` isca + veneno (110-170) · `Snake Charm` invoca · `Shed Skin` escudo + 3 Sentinels e 2 Legionnaires · `Sunfire` 3 zonas seguras (160-260) |
| Djinn War | **Vizier Khalzar** (26000) | Court → Lamp Guard → Wrath → Wishbreaker | `Lightning Chain` 5-7 saltos (90-150) · `Flame Waves` 4 ondas, ao contrário no final (80-140) · `Genie Lines` diagonais/retas/diagonais (90-150) · `Sand Prison` isca + lentidão de 90% (100-160) · `Lamp Guards` escudo + 3 Green e 3 Blue Djinns · `Wish Storm` 3 zonas seguras (170-270) |

Os nomes das magias levam o prefixo do boss (`Brokk`, `Mokthar`, `Aethra`, `Blackreef`, `Korg`, `Ssurrak`, `Khalzar`). Os valores são estimativas: ajuste os números em `395-bosses-tier2.lua`.

## Bosses do tier III
Definidos em `data/lib/396-bosses-tier3.lua` com 5 fases cada (uma com escudo) e 8 magias. Aqui os jogadores passam a **depender uns dos outros** e da **arena**. Além das mecânicas do tier II, a biblioteca ganhou:

| Mecânica (`BossSpell.*`) | Como funciona | Como lidar |
|---|---|---|
| `tether` | Liga `pairs` pares de jogadores por 5 s com um raio visível (azul/vermelho). Modo `together`: ao fim, a distância tem de ser **no máximo** `distance`; modo `apart`: **no mínimo** `distance`. Quem quebra a regra leva dano (os dois do par) | Combinar com o par e se posicionar |
| `stack` | Como a isca, mas a área é para ser **dividida**: o dano `total` é repartido pelos jogadores dentro (no máximo `maxEach` cada). Sozinho, o marcado leva `maxEach` | Correr **para** o marcado |
| `cleanse` | Marca `count` jogadores (vermelho) e mostra quadrados verdes; no fim, quem está marcado e fora de um quadrado verde leva dano e dano contínuo | Marcados vão ao quadrado verde |
| `field` | Perigo que **fica**: `ticks` golpes (um por `interval`) num anel `inner`..`outer` em volta do boss (sem `inner`, o quadrado todo) | Ficar do lado seguro (dentro, fora ou colado no boss) |
| `beam` | Raios que **giram** em volta do boss (`arms` 1, 2 ou 4, `width` 1 ou 3, `reverse`) | Acompanhar o giro |
| `siphon` | Durante `ticks` s cada summon vivo cura o boss `percent`% por segundo | Matar os adds depressa |
| `pull` | Arrasta todos os jogadores para o anel de raio `to` em volta do boss (junto com um `nova`) | Sair do círculo na hora |
| `later(cid, ms, fn)` | Encadeia golpes: ecos, segundo golpe depois do primeiro | Ler a sequência |

As magias de adds (`... Call`) e os escudos (`... Cage/Shell/Carapace/Plating/Dreamveil`) agora têm `siphon`: os adds curam o boss enquanto viverem. Em todas as últimas fases (`memory.final`) o boss fica 40 de velocidade mais rápido e sua magia final combina mecânicas, por exemplo `safeSpots` seguido de outro golpe que pega quem está escondido.

| Invasão | Boss (vida) | Fases | Magias (dano) |
|---|---|---|---|
| Undead Uprising | **Necrarch Mortheus** (48000) | Gravecall → Harvest → Deathbound → Requiem → Oblivion | `Grave Hands` 5-7 marcas, com eco na rage (140-220) · `Soul Tether` juntos ≤ 4 sqm (260-380) · `Death Mark` cleanse + dano contínuo (300-420) · `Bone Beam` 2 raios girando (170-260) · `Raise Dead` Skeletons/Ghouls + siphon · `Bone Cage` escudo + 6 mortos + siphon · `Requiem` stack, 1100 dividido (máx. 480) · `Oblivion` zonas seguras duas vezes (330-480, 250-380) |
| Elemental Surge | **Pyrothane the Cinderlord** (50000) | Smolder → Inferno Shell → Wildfire → Supernova → Cinderstorm | `Magma Ring` anel de fogo por fora (90-140 por segundo) · `Ember Stack` 1200 dividido (máx. 500) · `Flare Beam` raio largo girando (160-240) · `Repel` separados ≥ 5 sqm (250-360) · `Eruption` 6 nuvens + fogo contínuo, com eco (150-230) · `Elemental Call` + siphon · `Inferno Shell` escudo + siphon · `Supernova` **puxa todos** e explode o círculo (280-400) |
| Frost Siege | **Glaciarch Vorthrax** (54000) | Chill → Carapace → Whiteout → Deep Freeze → Absolute Zero | `Frost Breath` cone de 9 sqm, volta depois no alvo (180-280) · `Whiteout` faixa de gelo 3..6 sqm: só dá para ficar colado ou longe (100-150 por segundo) · `Ice Tether` juntos ≤ 3 sqm (250-360) · `Shatter` stack 1100 (máx. 480) · `Hail Grid` duas grades de faixas seguidas (150-230) · `Rime Call` + siphon · `Crystal Carapace` escudo + siphon · `Absolute Zero` zonas seguras e logo depois um sopro (330-480 + 220-330) |
| Golem Foundry | **Iron Overseer Kragmor** (52000) | Assembly → Armor Plating → Overclock → Magnetize → Meltdown | `Piston Slam` faixas que se **invertem** (os vãos da 1ª grade são a 2ª) (170-260) · `Steam Vents` perigo colado no boss (90-140 por segundo) · `Magnet Pull` puxa e explode (240-340) · `Overcharge` separados ≥ 5 sqm (260-380) · `Gear Beam` 4 raios girando (160-250) · `Scrap Call` + siphon · `Armor Plating` escudo + siphon · `Meltdown` 2 zonas seguras e depois um stack (350-480 + 1000 dividido) |
| Nightmare Horde | **Nightmare Weaver Syrelith** (50000) | Twilight → Dreamveil → Terror → Lucid Dream → Nightfall | `Nightmare Beam` 2 raios largos girando (170-260) · `Dread Mark` cleanse + dano contínuo (280-400) · `Shadow Step` salta num jogador e explode em volta logo depois (150-230 + 170-260) · `Terror Tether` separados ≥ 6 sqm (260-380) · `Dream Eater` stack 1200 em raio 3 (máx. 520) · `Nightmare Call` + siphon · `Dreamveil` escudo + siphon · `Nightfall` anel de sombra longo + cleanse ao mesmo tempo (100-150 por segundo + 320-450) |

Se há menos de 2 jogadores, o `tether` falha e a IA escolhe outra magia. Os valores são estimativas: ajuste em `396-bosses-tier3.lua`.

## Bosses do tier IV
Definidos em `data/lib/397-bosses-tier4.lua`: 5 fases (uma com escudo), 9 a 11 magias cada e um **temporizador de enrage**. Os golpes são mais longos, combinam duas mecânicas e há efeitos que **acumulam** durante a luta. A biblioteca ganhou:

| Mecânica | Como funciona | Como lidar |
|---|---|---|
| `stack = {extra, max, ms, name}` (opção de qualquer golpe) | Cada acerto dá 1 pilha ao jogador (até `max`, por `ms`) e, a cada acerto seguinte, ele leva `extra` a mais **por pilha**. O jogador vê "Nome: n/max" na tela (`BossSpell.stackCount(pid)`) | Evitar ser acertado repetidamente e esperar as pilhas caírem |
| `linger = {ticks, interval, min, max, effect}` (opção de qualquer golpe) | Os tiles marcados viram **poças** que continuam causando dano depois do golpe | Sair da poça e não voltar |
| `polarity` | Os jogadores se dividem em **vermelho e azul** (efeito sobre eles) e duas zonas, uma de cada cor, aparecem. No fim, quem não está **na zona da sua cor** leva dano e dano contínuo | Combinar quem vai para qual zona |
| `bombs` | Invoca bombas (orbes) com contagem regressiva sobre elas: as que sobrarem explodem (raio 4-5, 450-600), curam o boss em 4-5% **cada** e somem | Matar as bombas antes do zero |

**Enrage:** depois de 8 minutos de vida (`C.age`), todo boss vai para a fase final e fica nela. Para ajustar, mude `ENRAGE_MS` em `397-bosses-tier4.lua`.

Orbes (`data/monster/Traps/`): `Doomfire Orb`, `Bloodmoon Orb`, `Drakenfire Totem`, `Dawnfire Ember` e `Plague Pod`. Têm 5000 de vida, velocidade 1 (praticamente imóveis), 0 de experiência e não atacam.

| Invasão | Boss (vida) | Fases | Magias (dano) |
|---|---|---|---|
| Dragon Siege | **Wyrmlord Azhrakar** (90000) | Descent → Bone Aegis → Dragonfire → Undying Wrath → Calamity | `Doom Breath` cone de 10 sqm + pilhas "Scorched", volta na rage (280-420) · `Wing Gale` 5 ondas (230-350) · `Ember Rain` 7-9 marcas + poças (200-300) · `Soul Rend` polaridade (420-560) · `Doom Orbs` 2-3 bombas · `Tail Lash` círculo curto (260-380) · `Dread Brood` + siphon · `Bone Aegis` escudo + siphon · `Calamity` zonas seguras e um sopro logo depois (480-680 + 320-460) |
| Blood Moon | **Countess Sanguessa** (85000) | Court → Veil of Blood → Blood Moon → Eclipse → Bloodbath | `Crimson Bats` 8-10 marcas + pilhas "Bleeding" (180-280) · `Blood Link` juntos ≤ 3 sqm (380-520) · `Hemorrhage` cleanse + dano contínuo (400-550) · `Blood Pool` nova com poças (250-380) · `Moonlit Sweep` 4 raios largos girando (220-320) · `Crimson Pact` polaridade · `Blood Orbs` bombas · `Vampire Brood` + siphon · `Veil of Blood` escudo + siphon · `Eclipse` zonas seguras + stack de 1500 (480-680) |
| Draken Legion | **Warlord Zhardakkan** (92000) | Onslaught → Drakeguard → Drakefire → Frenzy → Last Dragon | `Fire Volley` duas grades que se invertem + "Burning" (260-380) · `Leaping Slam` salto + explosão (280-400 + 260-380) · `War Drums` anel por fora (110-170) · `Dragonfire Rain` 7-9 marcas + poças (200-300) · `Banner Bearers` bombas · `Blood Oath` separados ≥ 6 sqm (380-520) · `Frenzy Chain` 6-8 saltos (250-350) · `Legion Call` + siphon · `Drakeguard` escudo + siphon · `Dragonfall` zonas seguras, puxa e explode (500-700 + 380-540) |
| Asura Onslaught | **Matriarch Ignaria** (85000) | Dawn → Pyre Barrier → Noon → Dusk → Dawnbreak | `Dawn Beam` 2 raios largos girando + "Dawnfire" (230-340) · `Flame Shackles` separados ≥ 6 sqm (380-520) · `Ember Mark` cleanse + dano contínuo (400-550) · `Sunburst` nova com poças (300-440) · `Rite of Dawn` polaridade · `Phoenix Pyre` bombas · `Asura Call` + siphon · `Pyre Barrier` escudo + siphon · `Burning Pact` stack de 1500 · `Dawnbreak` zonas seguras, ondas de fora para dentro e um stack |
| Plague Legion | **Forgelord Vexmar** (90000) | Forging → Bile Armor → Contagion → Epidemic → Pandemic | `Toxic Hammer` cone dos dois lados + "Plague" (280-400) · `Spore Burst` nuvens com poças + "Plague" (190-290) · `Plague Pods` bombas (cura 5%) · `Rot Link` juntos ≤ 3 sqm (380-520) · `Purge` cleanse + dano contínuo (400-550) · `Corrosion Waves` 5 ondas + "Plague" (230-350) · `Blight Beam` 4 raios girando (220-320) · `Antidote` polaridade · `Plague Call` + siphon · `Bile Armor` escudo + siphon · `Pandemic` duas rodadas de zonas seguras e depois puxa e explode |

Os valores são estimativas: ajuste em `397-bosses-tier4.lua`.

## Bosses do tier V
Definidos em `data/lib/398-bosses-tier5.lua`: os mais difíceis, com **6 fases** (uma com escudo), 13 a 14 magias, enrage de **7 minutos** (`ENRAGE_MS`) e 3 mecânicas novas além de todas as anteriores:

| Mecânica | Como funciona | Como lidar |
|---|---|---|
| `sectors` | A arena (raio 10-12) é cortada em fatias, como uma pizza. `count` fatias são marcadas e acertam; depois (`complement`) as fatias que estavam **seguras** acertam `gap` ms depois | Cruzar a arena entre os dois golpes |
| `seeker` | `count` marcas saem do boss e andam `steps` tiles (um a cada 450 ms) em direção à posição **atual** de um jogador, explodindo onde pararem | Levar a marca para longe do grupo (kite) |
| `channel` | **Checagem de DPS**: o boss canaliza por 10 s (um contador com o progresso, em %, aparece sobre ele). Se o grupo não tirar `percent`% (4%) da vida total dele nesse tempo, todos em alcance levam 1500-2000 de dano. Se tirar, ele é interrompido | Todo o grupo no boss, sem curar nele (os adds com siphon atrapalham) |
| `gravity` (`pull` + `pull` + `nova`) | Todos são jogados na borda (raio 7), 1,6 s depois arrastados para perto do boss (raio 2) e o círculo explode | Sair do círculo logo depois de ser puxado |

O `channel` não é usado nas fases de escudo, porque o boss não toma dano.

Todos os bosses do tier V têm: `stack` (pilhas), `linger` (poças), `polarity`, `bombs`, `tether`, `cleanse`, `siphon` nos adds e uma última magia que encadeia 3 mecânicas. Bombas: `Hellfire Idol`, `Soulbound Skull` e `Hellforged Core` (`data/monster/Traps/`).

| Invasão | Boss (vida) | Fases | Magias (dano) |
|---|---|---|---|
| Demonic Rift | **Archfiend Zulkarath** (200000) | Rift → Infernal Gate → Hellfire → Soulstorm → Abyss → Armageddon | `Hellfire Breath` cone de 11 sqm + pilhas "Hellburn", volta na rage (450-650) · `Rift Beams` 4 raios largos (400-580) · `Brimstone Rain` 9-11 marcas + poças (380-560) · `Chains of Torment` separados ≥ 6 sqm (600-850) · `Damnation` cleanse (650-900) · `Demonic Pact` polaridade (700-950) · `Hellfire Idols` 3-4 bombas (700-950) · `Rift Sectors` 8 fatias × 2 · `Flame Seekers` 3-4 perseguidores · `Abyssal Gravity` · `Annihilation` checagem de DPS (1500-2000) · `Infernal Gate` escudo + siphon · `Armageddon` zonas seguras + fatias + perseguidores (800-1100) |
| Dead Dragons | **Deathwyrm Nekhrazul** (200000) | Awakening → Bone Citadel → Deathstorm → Soulfeast → Tomb of Ages → Final Requiem | `Grave Breath` cone de 12 sqm + "Withering" (450-650) · `Wing Storm` 6 ondas (400-580) · `Bone Rain` 10-12 marcas + poças (380-560) · `Soul Chains` juntos ≤ 3 sqm (600-850) · `Marked for Death` cleanse · `Twin Souls` polaridade · `Soul Phylacteries` bombas · `Tomb Sectors` 6 fatias × 2 · `Wraith Seekers` perseguidores + "Withering" · `Tomb Gravity` · `Death Knell` checagem de DPS · `Bone Citadel` escudo + siphon · `Final Requiem` zonas seguras + fatias + stack de 2600 |
| Hell's Legion | **Hellforged Overlord Malgorath** (220000) | Muster → Legion Barrier → Siege → Conquest → Overrun → Final Verdict | `Hellstorm Volley` duas grades que se invertem + "Overcharged" (450-650) · `Arc Chain` 8-10 saltos (400-580) · `Legion Beams` 2 raios largos (400-580) · `Doom Rain` + poças · `Binding Sigils` separados ≥ 7 sqm (600-850) · `Mark of the Legion` cleanse · `Dual Allegiance` polaridade · `Hellforged Cores` bombas · `Phalanx Sectors` 12 fatias × 2 · `Hunter Drones` perseguidores · `Siege Gravity` · `Judgement` checagem de DPS · `Legion Barrier` escudo + siphon · `Final Verdict` zonas seguras + cadeia + fatias |

Sobre a checagem de DPS: com 200000 de vida, 4% são 8000 de dano em 10 s (cerca de 800 de dano por segundo do grupo). Ajuste `percent` e `time` em cada `BS.channel` para o poder de fogo real dos jogadores. O mesmo vale para a vida, o enrage e todos os valores de dano.

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
| `data/lib/393-bosses.lua` | IA dos bosses do tier I (Warlord Ruzad, Queen Silkara, Chief Grumbak, Fenrak Moonfang) |
| `data/lib/394-boss-spells.lua` | `BossSpell`: biblioteca de mecânicas (isca, cadeia, ondas, zonas seguras...) |
| `data/lib/395-bosses-tier2.lua` | Magias e IA dos 7 bosses do tier II |
| `data/lib/396-bosses-tier3.lua` | Magias e IA dos 5 bosses do tier III |
| `data/lib/397-bosses-tier4.lua` | Magias e IA dos 5 bosses do tier IV (e o enrage) |
| `data/lib/398-bosses-tier5.lua` | Magias e IA dos 3 bosses do tier V |
| `data/spells/scripts/ai/*.lua` | `ai think.lua` e as magias dos bosses |
| `data/spells/spells.xml` | Magias `AI Think`, `Ruzad ...`, `Silkara ...`, `Grumbak ...` e `Fenrak ...` |
| `data/creaturescripts/scripts/ai_shield.lua`, `ai_death.lua` | Eventos `AIShield` e `AIDeath` |
| `data/talkactions/scripts/boss.lua` | Comando `/boss` |
| `data/monster/Orcs/Warlord Ruzad.xml`, `Arachnids/Queen Silkara.xml`, `Trolls/Chief Grumbak.xml`, `Canines/Fenrak Moonfang.xml` | Os bosses (com o ataque `AI Think`), registrados em `monsters.xml` |

Storages de criatura reservados: `54730` (espelho do estado) e `54731` (escudo).
