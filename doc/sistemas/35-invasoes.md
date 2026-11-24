# Invasões

Evento de mundo: ondas de monstros nascem ao redor de uma cidade e os jogadores precisam rechaçá-las. Roda em Lua (`data/lib/390-invasions.lua`), não usa o `raids.xml` do motor porque ele não acompanha progresso nem contribuição dos jogadores.

## Como funciona
- **A cada 2 horas** (horas pares: 00:00, 02:00, ... horário do servidor; `intervalHours`) o agendador sorteia uma invasão e começa a **contagem (prelúdio)** 5 minutos antes (`preludeMinutes`), de modo que a invasão começa de fato na hora cheia.
- **Prelúdio**: uma mensagem diferente no broadcast a cada minuto. Com 5 e 4 minutos as mensagens são vagas (batedores, alarme dos guardas), com **3 minutos revela qual invasão vem** (a frase `intro` dela, o tier e o level recomendado), com 2 minutos manda se preparar e com 1 minuto avisa que é o último. As frases ficam em `Invasions.preludeMessages` e cada invasão pode trocá-las com `prelude = {[5] = "...", ...}`. O `!invasion` e o login mostram o tempo que falta. O `/invasion start` pula o prelúdio (e cancela um que esteja rodando); o `/invasion stop` também cancela o prelúdio.
- **Força pelo nível médio dos jogadores online** (contas staff, access 3 ou mais, não contam): cada invasão tem um *tier* e uma faixa de level (`minLevel`..`maxLevel`). O agendador só sorteia invasões cuja faixa contém o level médio (nunca a mesma de duas vezes seguidas). Quanto maior a média, mais forte o tier. Dentro da faixa, a quantidade de monstros sobe de 0,85x (média no `minLevel`) a 1,5x (80 levels acima). Se a média não cabe em nenhuma faixa, vale a mais próxima. A quantidade também sobe 5% por jogador online além do primeiro (até 1,5x). Bosses não escalam.
- **Ondas com nascimento gradual**: cada onda anuncia uma frase e dispara um **evento** (veja abaixo) logo no começo, mas os monstros **vão nascendo aos poucos**, em ordem aleatória (os tipos vêm misturados), durante `waveSpawnTime` (60 s). A onda dura `waveDuration` (120 s). Ou seja, nasce por 1 minuto e a onda segue por 2. Pelo menos um monstro nasce na hora. A próxima onda só vem depois que **todos** os monstros da atual nasceram **e** passaram 120 s desde o início dela, **ou** sobraram só 20% dos que nasceram (`waveClearRatio`, para não deixar jogadores rápidos esperando). Cada onda pode definir `spawnTime` e `duration` próprios; a do boss nasce de uma vez (`spawnTime = 0`). O evento `haste` também vale para os monstros da onda que ainda vão nascer.
- **Boss**: cada invasão tem um boss com **35% de chance** (`bossChance`, ou `boss.chance` da invasão) de vir como uma onda extra depois da última. A vitória exige derrotar o boss. Os bosses atuais são monstros comuns de `monsters.xml`, servindo de placeholder até o sistema de boss (árvore de decisão / máquina de estados) ser criado.
- **Bônus do servidor**: ao derrotar o boss, **todos os jogadores online** (e quem entrar enquanto durar) ganham um bônus sorteado por 60 minutos: **+25% de experiência**, **+30% de loot** (chance de loot adicional) ou **+50% de treino de skills e magic level**. Um bônus novo do mesmo tipo substitui o anterior. Aparece no `!buffs` ("Invasion bonus"), no `!invasion` e no login. O boss pode definir `bonuses`, `percent` e `minutes`.
- **Perdeu**: se ninguém causa dano nem mata um invasor por 5 minutos (`idleTimeout`), ou se a duração acaba (22 a 30 minutos, conforme o tier), os invasores **somem**. Na derrota, quem fez o mínimo de dano ganha só 25% do ouro e da exp, sem itens e sem bônus de servidor.
- **Invasores sem alvo** vão até o jogador mais próximo fora de PZ (até 40 sqm).
- **Score**: cada jogador ganha o dano que causa aos invasores (limitado à vida de cada um; o dano dos summons conta para o dono). Quem está online no fim e fez o `minScore` do tier recebe a recompensa; o top 1/2/3 ganha +50% / +30% / +15%. A exp da recompensa é `exp x level` do jogador, com o level limitado ao `maxLevel` da invasão.
- Os invasores dropam o loot normal. O estado fica na memória: reiniciar o servidor cancela a invasão em andamento e o bônus. Quem não está online no fim não recebe a recompensa.

## Eventos das ondas
| Evento | O que faz |
|---|---|
| `storm <elemento> xN` | N golpes elementais nos jogadores fora de PZ. Aparece uma marca mágica no chão e **1,5 s depois** o golpe cai num raio de 1 sqm (dá para desviar). Dano do tier. Elementos: physical, fire, energy, earth, ice, death |
| `ambush <monstro> xN` | N monstros extras nascem ao lado de um jogador sorteado |
| `haste +N` | Todos os invasores vivos ficam mais rápidos (+N de velocidade) |

## Tiers
| Tier | Levels | Ouro | Exp por level | Mínimo de dano (`minScore`) | Dano da `storm` |
|---|---|---|---|---|---|
| I | 8-40 | 10.000 | 120 | 300 | 30-70 |
| II | 30-80 | 25.000 | 200 | 1.000 | 80-160 |
| III | 60-130 | 50.000 | 300 | 2.500 | 150-300 |
| IV | 100-180 | 100.000 | 450 | 5.000 | 250-450 |
| V | 150+ | 200.000 | 700 | 9.000 | 400-700 |

## Invasões (24)
A coluna de ondas mostra `quantidade monstro` de cada onda e o evento dela entre parênteses (quantidades base, antes da escala). Todas usam a Blood City (`town = 1`, templo em `160, 51, 7`); os números são estimativas, ajuste conforme o balanceamento do servidor.

### Tier I: levels 8-40 (reward 10.000 gold + 120 exp por level, dano das tempestades 30-70)

| Key | Invasão | Level | Ondas (evento) | Boss (evento da onda do boss) |
|---|---|---|---|---|
| `orcs` | Orc Horde | 8-40 | 1. 12 Orc, 8 Orc Spearman, 8 Orc Warrior (haste +40)<br>2. 6 Orc Berserker, 4 Orc Shaman, 4 Orc Rider (ambush Orc Spearman x4)<br>3. 2 Orc Leader, 1 Orc Warlord (storm fire x5) | Warlord Ruzad (storm fire x5) |
| `spiders` | Spider Nest | 8-40 | 1. 14 Spider, 10 Poison Spider (storm earth x4)<br>2. 8 Tarantula, 4 Giant Spider (ambush Poison Spider x6)<br>3. 6 Giant Spider, 8 Tarantula (haste +50) | Crystal Spider (ambush Poison Spider x6) |
| `trolls` | Troll Warband | 8-40 | 1. 14 Troll, 10 Island Troll (storm physical x4)<br>2. 8 Swamp Troll, 8 Frost Troll (ambush Troll x6)<br>3. 12 Troll, 8 Frost Troll (haste +50) | Frost Troll (storm ice x5) |
| `wolves` | Wolf Pack | 8-40 | 1. 16 Wolf, 10 Winter Wolf (haste +60)<br>2. 8 Bear, 10 Winter Wolf (ambush Wolf x6)<br>3. 8 Bear, 12 Winter Wolf (storm ice x4) | Werewolf (haste +80) |

### Tier II: levels 30-80 (reward 25.000 gold + 200 exp por level, dano das tempestades 80-160)

| Key | Invasão | Level | Ondas (evento) | Boss (evento da onda do boss) |
|---|---|---|---|---|
| `dwarves` | Dwarven Uprising | 30-80 | 1. 14 Dwarf, 10 Dwarf Soldier, 8 Dwarf Guard (storm fire x5)<br>2. 6 Dwarf Geomancer, 4 Stone Golem (ambush Dwarf Soldier x6)<br>3. 10 Dwarf Guard, 2 War Golem (haste +50) | Stone Golem (storm physical x6) |
| `minotaurs` | Minotaur Warband | 30-80 | 1. 14 Minotaur, 8 Minotaur Archer (haste +50)<br>2. 8 Minotaur Guard, 6 Minotaur Mage (storm energy x5)<br>3. 10 Minotaur Guard, 6 Minotaur Mage (ambush Minotaur Archer x6) | Minotaur Mage (storm energy x6) |
| `amazons` | Amazon Assault | 30-80 | 1. 14 Amazon, 10 Valkyrie (haste +60)<br>2. 6 Witch, 8 Valkyrie (storm earth x5)<br>3. 10 Amazon, 10 Valkyrie (ambush Witch x4) | Hero (ambush Valkyrie x6) |
| `pirates` | Pirate Raid | 30-80 | 1. 10 Pirate Marauder, 8 Pirate Cutthroat (storm fire x5)<br>2. 8 Pirate Buccaneer, 6 Pirate Corsair (ambush Pirate Skeleton x6)<br>3. 10 Pirate Skeleton, 6 Pirate Corsair (haste +60) | Pirate Corsair (storm fire x6) |
| `cyclops` | Cyclops Rampage | 40-90 | 1. 10 Cyclops, 8 Cyclops Drone (storm physical x5)<br>2. 8 Cyclops Smith, 8 Cyclops (haste +50)<br>3. 12 Cyclops, 2 Behemoth (ambush Cyclops Drone x4) | Behemoth (storm physical x6) |
| `lizards` | Lizard Legion | 35-85 | 1. 10 Lizard Templar, 8 Lizard Sentinel (storm earth x5)<br>2. 8 Lizard Legionnaire, 6 Lizard Snakecharmer (ambush Lizard Templar x6)<br>3. 10 Lizard Legionnaire, 6 Lizard Snakecharmer (haste +60) | Lizard Legionnaire (storm earth x6) |
| `djinns` | Djinn War | 40-90 | 1. 8 Blue Djinn, 8 Green Djinn (storm energy x5)<br>2. 6 Efreet, 6 Marid (ambush Green Djinn x4)<br>3. 8 Efreet, 8 Marid (haste +60) | Marid (storm energy x7) |

### Tier III: levels 60-130 (reward 50.000 gold + 300 exp por level, dano das tempestades 150-300)

| Key | Invasão | Level | Ondas (evento) | Boss (evento da onda do boss) |
|---|---|---|---|---|
| `undead` | Undead Uprising | 60-130 | 1. 15 Skeleton, 10 Ghoul, 8 Zombie (storm death x5)<br>2. 8 Mummy, 6 Crypt Shambler, 6 BoneBeast (ambush Skeleton x8)<br>3. 6 Vampire, 3 Lich, 4 Banshee (haste +50) | Grim Reaper (storm death x7) |
| `elementals` | Elemental Surge | 60-130 | 1. 6 Fire Elemental, 6 Energy Elemental, 6 Water Elemental, 6 Earth Elemental (storm fire x5)<br>2. 3 Massive Fire Elemental, 3 Massive Energy Elemental (storm energy x6)<br>3. 3 Massive Water Elemental, 3 Massive Earth Elemental (ambush Earth Elemental x6) | Massive Fire Elemental (storm fire x8) |
| `frost` | Frost Siege | 60-130 | 1. 12 Winter Wolf, 6 Yeti, 6 Ice Witch (storm ice x5)<br>2. 6 Ice Golem, 4 Frost Giant (haste +50)<br>3. 4 Frost Dragon, 6 Ice Golem (ambush Yeti x4) | Frost Dragon (storm ice x8) |
| `golems` | Golem Foundry | 60-130 | 1. 10 Worker Golem, 6 Stone Golem (haste +50)<br>2. 6 War Golem, 8 Worker Golem (storm energy x5)<br>3. 8 War Golem (ambush Stone Golem x4) | War Golem (storm energy x8) |
| `nightmare` | Nightmare Horde | 70-140 | 1. 10 Gargoyle, 6 Nightstalker (storm death x5)<br>2. 6 Nightmare, 4 Betrayed Wraith (haste +50)<br>3. 4 Souleater, 6 Nightmare (ambush Nightstalker x4) | Betrayed Wraith (storm death x7) |

### Tier IV: levels 100-180 (reward 100.000 gold + 450 exp por level, dano das tempestades 250-450)

| Key | Invasão | Level | Ondas (evento) | Boss (evento da onda do boss) |
|---|---|---|---|---|
| `dragons` | Dragon Siege | 100-180 | 1. 6 Wyvern, 8 Dragon (storm fire x6)<br>2. 6 Dragon Lord, 4 Frost Dragon (ambush Dragon x3)<br>3. 4 Wyrm, 4 Hydra (haste +50) | Undead Dragon (storm death x8) |
| `bloodmoon` | Blood Moon | 100-180 | 1. 8 Vampire, 6 Vampire Bride, 6 Werewolf (storm death x6)<br>2. 6 Banshee, 4 Lich (haste +50)<br>3. 10 Vampire, 8 Werewolf (ambush Vampire Bride x4) | Lich (storm death x8) |
| `drakens` | Draken Legion | 100-180 | 1. 6 Draken Warmaster, 6 Draken Spellweaver (storm fire x6)<br>2. 4 Draken Abomination, 6 Draken Warmaster (haste +50)<br>3. 6 Draken Abomination (ambush Draken Spellweaver x4) | Draken Abomination (storm fire x8) |
| `asuras` | Asura Onslaught | 100-180 | 1. 6 Midnight Asura, 6 Dawnfire Asura (storm fire x6)<br>2. 6 Hellfire Fighter, 4 Infernalist (haste +50)<br>3. 6 Midnight Asura, 6 Dawnfire Asura (ambush Hellfire Fighter x4) | Dawnfire Asura (storm fire x8) |
| `plague` | Plague Legion | 110-190 | 1. 6 Blightwalker, 4 Defiler, 4 Destroyer (storm earth x6)<br>2. 3 Plaguesmith, 6 Demon Skeleton (haste +50)<br>3. 3 Ghastly Dragon (ambush Defiler x3) | Plaguesmith (storm earth x8) |

### Tier V: levels 150+ (reward 200.000 gold + 700 exp por level, dano das tempestades 400-700)

| Key | Invasão | Level | Ondas (evento) | Boss (evento da onda do boss) |
|---|---|---|---|---|
| `demons` | Demonic Rift | 150+ | 1. 6 Hellhound, 6 Hellspawn, 6 Fury (storm fire x6)<br>2. 4 Dark Torturer, 3 Juggernaut, 4 Behemoth (haste +50)<br>3. 6 Demon (ambush Hellhound x4) | Orshabaal (storm fire x9) |
| `deaddragons` | Wrath of the Dead Dragons | 150+ | 1. 6 Ghastly Dragon, 4 Undead Dragon (storm death x6)<br>2. 8 Demon Skeleton, 6 Blightwalker (haste +50)<br>3. 4 Defiler, 4 Destroyer (ambush Demon Skeleton x4) | Morgaroth (storm death x9) |
| `hellslegion` | Hell's Legion | 150+ | 1. 8 Hellfire Fighter, 6 Infernalist, 6 Fury (storm fire x6)<br>2. 6 Demon, 4 Juggernaut (haste +50)<br>3. 2 Grim Reaper, 8 Hellhound (ambush Demon x2) | Ghazbaran (storm energy x9) |

## Adicionar uma invasão
Acrescente uma entrada em `Invasions.list` (`data/lib/390-invasions.lua`). Só `key`, `name`, `tier`, `waves` e `boss` são obrigatórios, o resto vem do tier:
```lua
{key = "bandits", name = "Bandit Raid", tier = 1, intro = "Bandits are robbing %s!", -- %s = nome da cidade
	boss = {name = "Assassin", message = "The bandit leader appears!", event = haste(60), chance = 40, bonuses = {"loot"}, percent = 40, minutes = 45},
	waves = {
		wave("Bandits storm the market!", {{"Bandit", 12}, {"Smuggler", 8}}, haste(50)),
		wave("Assassins strike from the shadows!", {{"Assassin", 8}}, ambush("Bandit", 6))
	}},
```
Campos opcionais: `minLevel`/`maxLevel` (padrão do tier), `town` ou `center = {x=, y=, z=}` (outro lugar), `minRadius`/`maxRadius` (14 e 26), `duration` (segundos), `minScore`, `reward = {gold=, exp=, items={{id, quantidade}}}` (`items` é bom para materiais de crafting). Os nomes de monstros precisam existir em `monsters.xml`. Se nenhum invasor puder ser colocado, a invasão não inicia e o `/invasion start` avisa.

## Comandos
| Comando | Quem | O que faz |
|---|---|---|
| `!invasion` | todos | Invasão atual (onda, vivos, tempo, seu dano, melhores), bônus ativos e a lista de invasões |
| `/invasion start [key ou número ou nome] [boss]` | staff (access 4) | Inicia uma invasão **na hora, sem o prelúdio**. Sem a key escolhe pelo nível médio, como o agendador. `boss` força a onda do boss |
| `/invasion stop` | staff | Cancela a invasão (ou o prelúdio) sem recompensa |
| `/invasion list` | staff | Lista as keys, tiers e bosses |

Os comandos rodam no dono da invasão em até 2 segundos e a resposta chega no console azul.

## Arquitetura (estados Lua)
Cada tipo de script (globalevent, creaturescripts, talkactions) roda num estado Lua separado e uma tabela comum não é vista pelos outros, como no sistema de buffs (`doc/sistemas/23-buffs.md`). O estado do globalevent `invasions` (`Invasions.tick`, a cada 2 s) é o **dono** da invasão. Os demais falam com ele pelo storage global (strings com prefixo `I:`): os scripts de kill e morte colocam eventos numa caixa de entrada (`D,guid,nome,id,dano` e `K,id`), o `/invasion` envia comandos, e o dono publica o status que o `!invasion` e o login leem. Os invasores são marcados no storage da criatura `54720` (1 = invasor, 2 = boss).

## Arquivos
| Arquivo | Função |
|---|---|
| `data/lib/390-invasions.lua` | Tabela `Invasions`: lista, agendador, ondas, eventos, score, recompensas e bônus de servidor |
| `data/globalevents/scripts/invasions.lua` | `onThink` a cada 2 s (evento `invasions`), o dono da invasão |
| `data/creaturescripts/scripts/invasion_kill.lua` | Dano por jogador (evento `InvasionKill`, registrado no login) |
| `data/creaturescripts/scripts/invasion_death.lua` | Morte dos invasores (evento `InvasionDeath`, registrado em cada invasor) |
| `data/creaturescripts/scripts/invasion_login.lua` | Registra o kill e avisa da invasão e dos bônus no login |
| `data/talkactions/scripts/invasion.lua` | Comandos |

## Configuração
`config.lua`: `invasionsEnabled` (padrão `true`). O resto fica no topo de `data/lib/390-invasions.lua`. Nada aqui precisa de recompilação, mas o `config.lua`, o `globalevents.xml`, o `creaturescripts.xml` e o `talkactions.xml` precisam do restart.

## Storages reservados
Global: `54700` a `54705` (status, ranking, scores, caixa de entrada, comando, prelúdio) e `54710` a `54712` (bônus de experiência, loot e skills). Criatura: `54720`. Conditions dos bônus: subId `9501` e `9502`.
