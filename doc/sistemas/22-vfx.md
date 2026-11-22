# VFX (biblioteca de efeitos visuais)

## Como funciona
- A lib `data/lib/360-vfx.lua` define a tabela global `VFX` com animações customizadas feitas só de **distance shoots** (`CONST_ANI_*`) e **magic effects** (`CONST_ME_*`). Os efeitos só desenham: não causam dano nem condição, então podem ser chamados de qualquer script (spells, monstros, NPCs, eventos).
- Todo efeito recebe um **alvo** (posição `{x=, y=, z=}` ou id de criatura) e uma tabela de **opções** (opcional), e devolve um **handle** (ou `false` se os parâmetros forem inválidos). `VFX.stop(handle)` cancela o que ainda estiver pendente.
- Limites por causa do campo de visão do client: altura e raio vão até 5 tiles (`VFX.maxHeight`, `VFX.maxRadius`), no máximo 50 repetições (`VFX.maxCount`) e 64 pontos (`VFX.maxPoints`).
- Teste rápido no jogo com `/vfx` (acesso 4).

```lua
VFX.SkyFall(cid, CONST_ANI_FIRE)
VFX.Rain(getCreaturePosition(cid), "ice", {radius = 4, duration = 3000, drops = 40})
local h = VFX.Orbit(cid, CONST_ANI_ENERGYBALL, {duration = 10000})
VFX.stop(h) -- cancela
```

## Opções comuns a todos os efeitos
| Opção | Padrão | O que faz |
|---|---|---|
| `delay` | 0 | Milissegundos até o efeito começar |
| `skipVoid` | false | Não desenha em tiles sem chão. O servidor registra "Tile not found" no console para tiles que não existem; não detecta paredes |
| `handle` | novo | Reusa o handle de outro efeito (assim `VFX.stop` cancela os dois); é como os combinados funcionam por dentro |

## Distance shoots
Assinatura: `VFX.Nome(alvo, ani, opções)`. O `ani` é um `CONST_ANI_*` ou o nome de um [elemento](#elementos).

| Efeito | O que faz | Opções (padrão) |
|---|---|---|
| `SkyFall` | Ani caindo do céu no alvo | `height` (5), `offsetX` (-4: cai na diagonal; 0 cai reto), `count` (1), `interval` (150), `radius` (0), `effect`, `effectDelay` (200) |
| `Rain` | Muitos `SkyFall` em área, em momentos aleatórios | `radius` (3), `duration` (2000), `drops` (20), `height`, `offsetX` (0), `effect`, `effectDelay` |
| `Fountain` | Ani sobe e cai em volta, como um gêiser | `height` (4), `count` (1), `interval` (150), `radius` (1), `riseTime` (250), `effect`, `effectDelay` |
| `Spiral` | Ani saindo do centro em espiral | `radius` (4), `turns` (2), `points` (24), `duration` (1200), `clockwise` (true) |
| `Circle` | Ani desenhando um círculo | `radius` (3), `points` (12), `spin` (false), `duration` (600), `fromCenter` (false) |
| `Explosion` | Ani saindo do centro para todas as direções | `radius` (4), `points` (12), `rings` (1), `ringInterval` (150), `effect` (no centro) |
| `Implosion` | Ani vindo das bordas para o centro | `radius` (4), `points` (12), `flightTime` (200), `effect` (no centro, ao chegar) |
| `Beam(de, para, ani, opções)` | Corrente de ani (ou um tiro só) entre dois pontos. Com `para = nil` e uma criatura em `de`, vai à frente dela | `mode` ("chain" ou "bolt"), `interval` (60), `effect`, `range` (5, só sem destino) |
| `Orbit` | Ani orbitando uma criatura; acompanha e para sozinho se ela sumir | `radius` (2), `points` (8), `duration` (5000), `step` (150), `clockwise` (true) |
| `Lightning` | Raio em zigue-zague do céu até o alvo | `height` (5), `offsetX` (0), `segments` (4), `jitter` (1), `segDelay` (40), `count` (1), `interval` (200), `radius` (0), `effect` (`CONST_ME_ENERGYAREA`, false = nenhum) |
| `Tornado` | Funil de ani subindo em espiral (estreito embaixo, largo em cima) | `radius` (3), `height` (4), `turns` (3), `points` (30), `duration` (1500), `strands` (1) |
| `Helix` | Fitas de ani subindo, como um DNA | `radius` (2), `height` (4), `turns` (2), `points` (24), `duration` (1500), `strands` (2) |
| `Burst` | Ani vai até um anel e volta (escudo "respirando") | `radius` (3), `points` (12), `flightTime` (250), `pulses` (1), `interval`, `effect` |
| `Barrage` | Leque de ani saindo do alvo. A direção vem de `to`, de `direction` (0 a 7) ou de para onde a criatura olha | `rays` (7), `spread` (60 graus), `range` (5), `waves` (1), `interval` (150), `effect` |
| `Comet` | Ani cruzando a tela na diagonal até o alvo, com rastro | `span` (7), `rise` (3), `fromRight` (false), `flightTime` (500), `trail` (`CONST_ME_POFF`), `effect` (`CONST_ME_EXPLOSIONHIT`) |
| `Snow` | Queda lenta e com deriva (neve, cinzas, pétalas) | `radius` (4), `duration` (4000), `flakes` (30), `height` (5), `drift` (2), `stepTime` (250), `effect` |

## Magic effects
Assinatura: `VFX.Nome(alvo, effect, opções)`. O `effect` é um `CONST_ME_*` ou o nome de um elemento.

| Efeito | O que faz | Opções (padrão) |
|---|---|---|
| `Wave` | Anéis concêntricos se espalhando do alvo | `radius` (4), `startRadius` (0), `interval` (150), `inward` (false) |
| `Line` | Efeito andando em linha: `to` (posição/criatura), `direction` (0 a 7) ou, para criaturas, a direção do olhar | `length` (5), `interval` (80), `includeStart` (false) |
| `Pulse` | O mesmo efeito repetido no alvo; segue a criatura | `times` (5), `interval` (500), `follow` (true) |
| `Cross` | Formato de cruz (4 direções); com `diagonal = true` vira estrela | `size` (3), `interval` (0), `includeCenter` (true), `diagonal` (false) |
| `Star` | Igual à `Cross`, com 8 direções | as da `Cross` |
| `Ring` | Anel fixo em volta do alvo, repetível; segue a criatura | `radius` (3), `times` (1), `interval` (500), `follow` (true) |

## Efeitos combinados
Assinatura: `VFX.Nome(alvo, opções)`.

| Efeito | O que faz | Opções (padrão) |
|---|---|---|
| `Meteor` | `SkyFall` diagonal com impacto e estilhaços | `ani` (`CONST_ANI_FIRE`), `height` (5), `offsetX` (4), `flightTime` (250), `count` (1), `interval` (300), `radius` (0), `effect` (`CONST_ME_FIREAREA`), `impactEffect`, `shardAni` (`CONST_ANI_SMALLSTONE`, false = nenhum), `shardRadius` (2) |
| `Summon` | Ani convergindo para o alvo e efeito final (spawn de boss/NPC) | `ani` (`CONST_ANI_ENERGY`), `radius` (4), `points` (12), `flightTime` (300), `effect` (`CONST_ME_TELEPORT`), `waveEffect` (`CONST_ME_MAGIC_BLUE`, false = nenhum) |
| `LevelUp` | Espiral de ani, efeito sagrado e fogos de artifício | `ani` (`CONST_ANI_SMALLHOLY`), `radius` (3), `duration` (1000) |
| `Teleport(de, para, opções)` | Efeito de saída, ani caindo no destino e efeito de chegada. **Só visual**: não move ninguém, use `doTeleportThing` | `ani` (`CONST_ANI_ENERGY`), `height` (3), `travel` (300), `outEffect`/`inEffect` (`CONST_ME_TELEPORT`, false = nenhum) |
| `Warning` | Mecânica de boss: anel vermelho piscando no chão e depois o impacto | `radius` (2), `warnTime` (1500), `blink` (300), `markEffect` (`CONST_ME_MAGIC_RED`), `impact` ("explosion", "meteor" ou "none"), `ani`, `effect` |
| `Death` | Efeito de morte: explosão central, 3 anéis de ani, onda e fogos de artifício | `radius` (4), `ani` (`CONST_ANI_DEATH`), `effect` (`CONST_ME_MORTAREA`), `finale` (true) |
| `Storm` | Chuva + raios aleatórios + ondas no chão | `radius` (4), `duration` (6000), `rainAni` (`CONST_ANI_SMALLICE`), `drops` (duration/100), `lightningAni`, `strikes` (duration/1500), `waveEffect` (`CONST_ME_MAGIC_BLUE`, false = nenhum), `waveInterval` (2500) |
| `Buff` | Hélice colorida em volta do alvo | `type` ("attack" vermelho, "mana" azul, "defense" verde, "heal" sagrado), `radius` (2), `height` (3), `duration` (1200) |

## Recursos da lib
### Sequências
`VFX.Sequence(passos, opções)` roda vários efeitos em ordem dentro de um handle só (`VFX.stop` cancela tudo). Cada passo é `{fn = "Nome", args = {...}, wait = ms}`: `wait` conta a partir do passo anterior; `at` marca o tempo absoluto. A tabela de opções no fim de `args` é opcional (a sequência acrescenta `delay` e `handle`). Se o alvo for um id de criatura, a posição é lida quando a sequência é chamada.

```lua
VFX.Sequence({
	{fn = "Warning", args = {pos, {impact = "none"}}},
	{fn = "Meteor", args = {pos, {count = 3, radius = 2}}, wait = 1500},
	{fn = "Wave", args = {pos, CONST_ME_FIREAREA, {radius = 3}}, wait = 600}
})
```

### Perfis nomeados
`VFX.register(nome, perfil)` guarda uma combinação e `VFX.play(nome, alvo, opções)` toca; as opções passadas sobrescrevem as do perfil. O perfil é uma função `function(alvo, opções)` ou uma tabela `{effect = "Rain", id = CONST_ANI_FIRE, options = {...}}` (sem `id` para efeitos que não recebem ani/effect, como `Meteor`). Já vêm registrados: `fire_meteor`, `ice_storm`, `holy_buff`, `boss_death` e `boss_warning`.

```lua
VFX.register("fire_rain", {effect = "Rain", id = CONST_ANI_FIRE, options = {radius = 4, effect = CONST_ME_FIREAREA}})
VFX.play("fire_rain", getCreaturePosition(cid))
```

### Elementos
Em vez de um número, qualquer efeito que recebe ani ou effect aceita o nome de um elemento (`VFX.Rain(cid, "ice")`, `VFX.Wave(cid, "fire")`). `Meteor`, `Warning` e `Death` aceitam `element` nas opções e usam o ani/effect do elemento quando eles não forem informados. Tabela em `VFX.elements`:

| Elemento | Ani | Effect |
|---|---|---|
| fire | `CONST_ANI_FIRE` | `CONST_ME_FIREAREA` |
| ice | `CONST_ANI_ICE` | `CONST_ME_ICEAREA` |
| energy | `CONST_ANI_ENERGY` | `CONST_ME_ENERGYAREA` |
| earth | `CONST_ANI_EARTH` | `CONST_ME_STONES` |
| holy | `CONST_ANI_HOLY` | `CONST_ME_HOLYAREA` |
| death | `CONST_ANI_DEATH` | `CONST_ME_MORTAREA` |

### Helpers
`VFX.resolvePosition(alvo)`, `VFX.isPosition(valor)`, `VFX.isVoid(pos)`, `VFX.lookPosition(cid, distância)` (posição à frente da criatura), `VFX.circlePoints(pos, raio, pontos, ânguloInicial)`, `VFX.linePoints(de, para)`, `VFX.ringTiles(pos, raio)`, `VFX.randomInDisc(pos, raio)` e `VFX.at(handle, delay, fn, ...)` (agenda um passo dentro de um handle).

## Comando de teste `/vfx` (acesso 4)
- `/vfx list`: lista efeitos e perfis. `/vfx stop`: cancela os seus efeitos ainda ativos.
- `/vfx <efeito> [id ou elemento] [opção=valor ...]`, na sua posição. `orbit`, `barrage`, `line`, `pulse` e `ring` usam você como criatura (seguem você, e `barrage`/`line` vão para onde você olha); `beam` sai de você para a frente e `teleport` vai 4 tiles à frente.
- `/vfx <nome de perfil>` toca um perfil registrado.
- Exemplos: `/vfx skyfall 3 count=10 radius=3 effect=6`, `/vfx rain ice radius=4 duration=3000 drops=40`, `/vfx meteor element=fire count=4 radius=3`, `/vfx buff type=mana`, `/vfx fire_meteor`.

## Para criar um efeito novo
Em `data/lib/360-vfx.lua`, crie `function VFX.MeuEfeito(alvo, ...)`: resolva o alvo com `VFX.resolvePosition`, abra um handle com `begin(options)` e agende cada passo com `shoot`/`fx`/`VFX.at`, terminando com `return finish(id, owned)`. Para o efeito aceitar elementos, inclua o nome nas listas do final do arquivo.

## Onde mexer
- `data/lib/360-vfx.lua`: a biblioteca (cada efeito tem as opções documentadas no comentário acima da função).
- `data/talkactions/scripts/vfx.lua` e a linha `/vfx` em `data/talkactions/talkactions.xml`: comando de teste.
