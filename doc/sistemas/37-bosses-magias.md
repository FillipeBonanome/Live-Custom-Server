# Catálogo de magias dos bosses de invasão

Gerado a partir do código (`data/lib/393` a `398` e a biblioteca `394-boss-spells.lua`): cada magia foi executada com a API simulada e as mecânicas, os parâmetros e os danos abaixo são os que o código usa de fato. Cooldown, alcance e fases vêm do registro de IA de cada boss. Para entender o funcionamento das mecânicas e da IA, veja [36-bosses.md](36-bosses.md).

**Como ler.** Dano entre parênteses ou depois de «—» no formato `tipo mín-máx`. «Golpe X s depois» é o tempo entre a marca no chão e o dano (dá para desviar). **Cd** é o cooldown da IA. **Alc.** é o alcance máximo até o alvo para a IA escolher a magia (— = sem limite). **Fases** são as fases em que a magia está na árvore de decisão. Quando uma magia muda na rage ou na fase final, a variação aparece em «Rage:» e «Final:». Valores de dano e vida são estimativas, ajuste nos arquivos indicados em cada seção.

## Índice dos bosses

| Tier | Invasão (`/invasion start`) | Boss | Vida | Exp | Magias |
|---|---|---|---|---|---|
| I | Troll Warband (`trolls`) | Chief Grumbak | 14.000 | 1.600 | 6 |
| I | Wolf Pack (`wolves`) | Fenrak Moonfang | 11.000 | 1.500 | 5 |
| I | Spider Nest (`spiders`) | Queen Silkara | 12.000 | 1.500 | 6 |
| I | Orc Horde (`orcs`) | Warlord Ruzad | 15.000 | 1.700 | 7 |
| II | Pirate Raid (`pirates`) | Captain Blackreef | 25.000 | 3.400 | 6 |
| II | Amazon Assault (`amazons`) | Empress Aethra | 23.000 | 3.200 | 6 |
| II | Dwarven Uprising (`dwarves`) | Forgemaster Brokk | 24.000 | 3.200 | 6 |
| II | Minotaur Warband (`minotaurs`) | Hexlord Mokthar | 22.000 | 3.000 | 6 |
| II | Lizard Legion (`lizards`) | Hierarch Ssurrak | 22.000 | 3.200 | 7 |
| II | Cyclops Rampage (`cyclops`) | Titan Korg | 28.000 | 3.400 | 6 |
| II | Djinn War (`djinns`) | Vizier Khalzar | 26.000 | 3.500 | 6 |
| III | Frost Siege (`frost`) | Glaciarch Vorthrax | 54.000 | 7.000 | 8 |
| III | Golem Foundry (`golems`) | Iron Overseer Kragmor | 52.000 | 6.800 | 8 |
| III | Undead Uprising (`undead`) | Necrarch Mortheus | 48.000 | 6.500 | 8 |
| III | Nightmare Horde (`nightmare`) | Nightmare Weaver Syrelith | 50.000 | 7.000 | 8 |
| III | Elemental Surge (`elementals`) | Pyrothane the Cinderlord | 50.000 | 6.800 | 8 |
| IV | Blood Moon (`bloodmoon`) | Countess Sanguessa | 85.000 | 12.500 | 10 |
| IV | Plague Legion (`plague`) | Forgelord Vexmar | 90.000 | 12.500 | 11 |
| IV | Asura Onslaught (`asuras`) | Matriarch Ignaria | 85.000 | 12.500 | 10 |
| IV | Draken Legion (`drakens`) | Warlord Zhardakkan | 92.000 | 12.500 | 10 |
| IV | Dragon Siege (`dragons`) | Wyrmlord Azhrakar | 90.000 | 12.000 | 9 |
| V | Demonic Rift (`demons`) | Archfiend Zulkarath | 200.000 | 30.000 | 13 |
| V | Wrath of the Dead Dragons (`deaddragons`) | Deathwyrm Nekhrazul | 200.000 | 30.000 | 13 |
| V | Hell's Legion (`hellslegion`) | Hellforged Overlord Malgorath | 220.000 | 32.000 | 14 |

Total: **24 bosses** e **197 magias**.

## Tier I

Definições em `393-bosses.lua` e `spells/scripts/ai/*.lua` (um script por magia).

### Chief Grumbak — Troll Warband

- **Vida / Exp / Velocidade:** 14.000 / 1.600 / 230 (monsterId 745)
- **Fases:** **Warband** ─(vida < 60%)→ **Blizzard** (escudo) ─(vida < 30%)→ **Rage** (+50 de velocidade)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Grumbak Blizzard` | 6 marcas 3x3 sobre jogadores sorteados — gelo 40-80 (1,6 s) | 12 s | — | Blizzard (ao entrar), Rage | Sair da marca. |
| `Grumbak Avalanche` | faixas de 2 sqm com corredor de 1 sqm, vertical ou horizontal — gelo 70-130 (2 s) | 14 s | — | Rage | Achar o corredor. |
| `Grumbak Boulder Toss` | pedra 3x3 no alvo (outra em outro jogador na rage) — físico 55-105 (1,6 s) | 6.5 s | 8 | Warband, Blizzard, Rage | Sair da marca. |
| `Grumbak Call Trolls` | invoca 3 Frost Trolls (máx. 5 summons) | 16 s | — | Warband, Blizzard, Rage | Matar os adds. |
| `Grumbak Frost Lines` | 4 linhas de 7 sqm (8 na rage, com as diagonais) — gelo 60-110 (1,5 s) | 7.5 s | — | Warband, Blizzard, Rage | Ficar entre as linhas. |
| `Grumbak Quake` | círculo de raio 3 (4 na rage) em volta dele — físico 50-100 (60-120 na rage) (1,6 s) | 5 s | — | Warband, Blizzard, Rage | Sair do círculo. |

### Fenrak Moonfang — Wolf Pack

- **Vida / Exp / Velocidade:** 11.000 / 1.500 / 330 (monsterId 746)
- **Fases:** **Stalk** ─(vida < 66%)→ **Moonrise** (escudo, +30 de velocidade) ─(vida < 33%)→ **Bloodmoon** (+40 de velocidade)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Fenrak Pack Howl` | invoca 2 War Wolves (3 depois da lua, máx. 6 summons) | 16 s | — | Moonrise (ao entrar), Bloodmoon | Matar os adds. |
| `Fenrak Blood Rend` | primeiro as 4 diagonais (7 sqm), 0,8 s depois as 4 retas — físico 60-110 cada | 9 s | — | Bloodmoon | Não parar de se mover. |
| `Fenrak Claw Rake` | cone de 5 sqm na direção do alvo (e no lado oposto no bloodmoon) — físico 70-120 (1,3 s) | 4.5 s | 5 | Stalk, Moonrise, Bloodmoon | Sair da direção do cone. |
| `Fenrak Moonfall` | 5 marcas 3x3 sobre jogadores sorteados — morte 40-80 (1,5 s) | 8 s | — | Stalk, Moonrise, Bloodmoon | Sair da marca. |
| `Fenrak Pounce` | marca 3x3 no alvo; ele pula ao lado e acerta — físico 60-110 (1,4 s) | 7 s | 8 | Stalk, Moonrise, Bloodmoon | Sair da marca. |

### Queen Silkara — Spider Nest

- **Vida / Exp / Velocidade:** 12.000 / 1.500 / 260 (monsterId 744)
- **Fases:** **Hunt** ─(vida < 66%)→ **Brood** (escudo) ─(guardas mortos ou 45 s)→ **Swarm** ─(vida < 33%)→ **Frenzy** (+60 de velocidade)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Silkara Egg Sac` | escudo (sem dano) + 4 Poison Spiders + 2 Tarantulas | 1 s | — | Brood (ao entrar) | Matar a ninhada. |
| `Silkara Call Brood` | invoca 3 Poison Spiders (máx. 6 summons) | 14 s | — | Hunt, Swarm, Frenzy | Matar os adds. |
| `Silkara Toxic Nova` | disco de raio 5, exceto o 3x3 colado nela — terra 70-130 (1,9 s) | 9 s | — | Frenzy | Ficar colado nela ou sair do disco. |
| `Silkara Venom Rain` | 4 marcas 3x3 (6 no frenzy) sobre jogadores sorteados — terra 35-70 (1,6 s) | 6.5 s | — | Hunt, Brood, Swarm, Frenzy | Sair da marca. |
| `Silkara Venom Spit` | cone de 6 sqm na direção do alvo — terra 50-95 (1,3 s) | 5.5 s | 7 | Hunt, Swarm, Frenzy | Sair da direção do cone. |
| `Silkara Web Trap` | círculo de raio 2 no alvo — terra 20-40 + lentidão de 60% por 4 s (1,4 s) | 9 s | 8 | Hunt, Swarm, Frenzy | Sair do círculo. |

### Warlord Ruzad — Orc Horde

- **Vida / Exp / Velocidade:** 15.000 / 1.700 / 270 (monsterId 423)
- **Fases:** **Assault** ─(vida < 66%)→ **Rally** (escudo) ─(guardas mortos ou 45 s)→ **Bloodlust** ─(vida < 33%)→ **Berserk** (+60 de velocidade)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Ruzad Rally` | escudo (sem dano) + 3 Orc Berserkers + 3 Orc Warriors | 1 s | — | Rally (ao entrar) | Matar os guardas. |
| `Ruzad Axe Storm` | 4 marcas 3x3 em sequência sobre jogadores sorteados — físico 40-80 (1,6 s) | 6 s | — | Assault, Bloodlust | Sair da marca. |
| `Ruzad Blade Cross` | 3 estrelas (centro + 8 braços de 6 sqm: 4 retas e 4 diagonais) sobre jogadores; machados giram e saem pelos braços — físico 70-130 (1,6 s) | 7 s | — | Berserk | Ficar entre os braços. |
| `Ruzad Call Guards` | invoca 2 Orc Warriors (máx. 4 summons) | 15 s | — | Assault, Bloodlust, Berserk | Matar os adds. |
| `Ruzad Charge` | marca 3x3 no alvo; ele pula ao lado e acerta a área — físico 60-110 (1,6 s) | 8 s | 8 | Assault, Bloodlust, Berserk | Sair da marca. |
| `Ruzad Last Stand` | cura 15% da vida, uma única vez | 1 s | — | Berserk | Guardar o burst para depois. |
| `Ruzad Warcry` | círculo de raio 3 (4 no berserk) em volta dele; golpe 1,6 s depois — físico 50-100 (60-120 no berserk) | 4.5 s | — | Assault, Rally, Bloodlust, Berserk | Sair do círculo. |

## Tier II

Definições em `395-bosses-tier2.lua`.

### Captain Blackreef — Pirate Raid

- **Vida / Exp / Velocidade:** 25.000 / 3.400 / 240 (monsterId 750)
- **Fases:** **Broadside** ─(vida < 68%)→ **Boarding** (escudo) ─(guardas mortos ou 40 s)→ **Powder Hold** (+30 de velocidade) ─(vida < 35%)→ **Scuttle** (+40 de velocidade, final)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Blackreef Boarding Party` | escudo (sem dano) + guardas: Pirate Marauder×3, Pirate Cutthroat×2, Pirate Buccaneer×1 | 1 s | — | Boarding (ao entrar) | Matar os guardas para quebrar o escudo. |
| `Blackreef Broadside` | faixas de 2 sqm com corredor de 1 sqm entre elas, vertical ou horizontal, golpe 1,9 s depois — fogo 90-150 | 11 s | — | Broadside, Boarding, Powder Hold, Scuttle | Achar o corredor livre. |
| `Blackreef Cannon Barrage` | 6 marcas 3x3 em jogadores sorteados (uma a cada 0,35 s), golpe 1,8 s depois — fogo 80-140 · **Rage:** quantidade 6→8 | 7.5 s | — | Broadside, Boarding, Powder Hold, Scuttle | Sair da marca antes do golpe; com poças, não voltar. |
| `Blackreef Grapple Hook` |  | 12 s | — | Broadside, Powder Hold, Scuttle |  |
| `Blackreef Scuttle` | arena de raio 8 inteira marcada, exceto 2 quadrados 3x3 verdes, golpe 2,6 s depois — fogo 170-270 | 20 s | — | Scuttle | Entrar num quadrado verde antes do golpe. |
| `Blackreef Sea Mines` | 7 marcas 3x3 em jogadores sorteados (uma a cada 0,20 s), golpe 3,8 s depois — fogo 100-160 · **Rage:** quantidade 7→9 | 13 s | — | Powder Hold, Scuttle | Sair da marca antes do golpe; com poças, não voltar. |

### Empress Aethra — Amazon Assault

- **Vida / Exp / Velocidade:** 23.000 / 3.200 / 260 (monsterId 749)
- **Fases:** **Skirmish** ─(vida < 68%)→ **Phalanx** (escudo) ─(guardas mortos ou 40 s)→ **Onslaught** (+40 de velocidade) ─(vida < 30%)→ **Last Stand** (final)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Aethra Shield Wall` | escudo (sem dano) + guardas: Valkyrie×3, Amazon×2 | 1 s | — | Phalanx (ao entrar) | Matar os guardas para quebrar o escudo. |
| `Aethra Javelin Rain` | 5 marcas 3x3 em jogadores sorteados (uma a cada 0,40 s), golpe 1,6 s depois — físico 70-120 + lentidão 40% por 3 s · **Rage:** quantidade 5→7 | 8 s | — | Skirmish, Phalanx, Onslaught, Last Stand | Sair da marca antes do golpe; com poças, não voltar. |
| `Aethra Last Stand` |  | 1 s | — | Last Stand |  |
| `Aethra Mark of Prey` | a marca segue 1 jogador(es) por 3 s e trava (raio 2), golpe 0,9 s depois — físico 160-260 · **Rage:** quantidade 1→2 | 14 s | — | Skirmish, Onslaught, Last Stand | Quem é marcado se afasta do grupo. |
| `Aethra Phalanx Charge` | marca 3x3 no alvo, o boss pula ao lado e acerta, golpe 1,4 s depois — físico 90-150 | 9 s | 8 | Skirmish, Onslaught, Last Stand | Sair da marca; o boss cai ao lado. |
| `Aethra Spear Barrage` | 3 faixas paralelas de 9 sqm na direção do alvo (vãos de 1 sqm), golpe 1,4 s depois — físico 90-150 · **Rage:** faixas 3→5 | 6.5 s | 9 | Skirmish, Phalanx, Onslaught, Last Stand | Ficar nos vãos entre as faixas (numa 2ª grade os vãos mudam). |

### Forgemaster Brokk — Dwarven Uprising

- **Vida / Exp / Velocidade:** 24.000 / 3.200 / 220 (monsterId 747)
- **Fases:** **Forge** ─(vida < 70%)→ **Overheat** (escudo) ─(guardas mortos ou 40 s)→ **Meltdown** ─(vida < 35%)→ **Cataclysm** (+50 de velocidade, final)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Brokk Forge Guards` | escudo (sem dano) + guardas: Dwarf Guard×4, Dwarf Geomancer×2 | 1 s | — | Overheat (ao entrar) | Matar os guardas para quebrar o escudo. |
| `Brokk Anvil Waves` | 4 ondas (anéis de 2 sqm) saindo do boss, uma a cada 0,65 s, golpe 1,2 s depois — físico 80-140 · **Final:** ordem do boss para fora→de fora para dentro | 9 s | — | Forge, Overheat, Meltdown, Cataclysm | Passar para o anel que já acertou. |
| `Brokk Cataclysm` | arena de raio 7 inteira marcada, exceto 3 quadrados 3x3 verdes, golpe 2,6 s depois — fogo 160-260 | 20 s | — | Cataclysm | Entrar num quadrado verde antes do golpe. |
| `Brokk Hammer Slam` | cone de 5 sqm na direção do alvo, golpe 1,3 s depois — físico 90-150 · **Rage:** lados 1→2 | 5 s | 5 | Forge, Meltdown, Cataclysm | Sair da direção do cone. |
| `Brokk Molten Rain` | 6 marcas 3x3 em jogadores sorteados (uma a cada 0,35 s), golpe 1,7 s depois — fogo 70-120 + dano contínuo fogo 15×3 · **Rage:** quantidade 6→8 | 8 s | — | Forge, Overheat, Meltdown, Cataclysm | Sair da marca antes do golpe; com poças, não voltar. |
| `Brokk Powder Keg` | a marca segue 2 jogador(es) por 2,4 s e trava (raio 2), golpe 0,9 s depois — fogo 110-180 + dano contínuo fogo 20×4 · **Rage:** quantidade 2→3 | 11 s | — | Forge, Meltdown, Cataclysm | Quem é marcado se afasta do grupo. |

### Hexlord Mokthar — Minotaur Warband

- **Vida / Exp / Velocidade:** 22.000 / 3.000 / 240 (monsterId 748)
- **Fases:** **Ritual** ─(vida < 70%)→ **Warded** (escudo) ─(guardas mortos ou 40 s)→ **Unbound** ─(vida < 35%)→ **Overload** (+40 de velocidade, final)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Mokthar Mystic Ward` | escudo (sem dano) + guardas: Minotaur Mage×3, Minotaur Guard×2 | 1 s | — | Warded (ao entrar) | Matar os guardas para quebrar o escudo. |
| `Mokthar Arcane Lines` | 3 etapas de linhas de 7 sqm (retas e diagonais alternadas), uma a cada 0,7 s, golpe 1,4 s depois — energia 80-140 · **Rage:** stages 3→4 | 7 s | — | Ritual, Warded, Unbound, Overload | Continuar se movendo: o lugar seguro de uma etapa é atingido na seguinte. |
| `Mokthar Call Herd` | invoca Minotaur Guard×2, Minotaur Archer×2 (máx. 6 summons) | 15 s | — | Ritual, Overload | Matar os adds. |
| `Mokthar Chain Lightning` | raio em cadeia: 4 saltos até 5 sqm, um a cada 0,80 s — energia 90-150 · **Rage:** saltos 4→6 | 9 s | — | Ritual, Warded, Unbound, Overload | Manter distância entre os jogadores (o raio pula para o mais próximo). |
| `Mokthar Hex Bolt` | a marca segue 2 jogador(es) por 2,2 s e trava (raio 1), golpe 0,9 s depois — energia 110-170 + lentidão 50% por 3 s · **Rage:** quantidade 2→3 | 10 s | — | Ritual, Unbound, Overload | Quem é marcado se afasta do grupo. |
| `Mokthar Overload` | disco de raio 7 em volta do boss, com um quadrado seguro 5x5 colado no boss, golpe 2 s depois — energia 120-190 | 15 s | — | Overload | Ficar no quadrado seguro ou sair do disco. |

### Hierarch Ssurrak — Lizard Legion

- **Vida / Exp / Velocidade:** 22.000 / 3.200 / 250 (monsterId 752)
- **Fases:** **Ambush** ─(vida < 68%)→ **Shed Skin** (escudo) ─(guardas mortos ou 40 s)→ **Venom** (+30 de velocidade) ─(vida < 35%)→ **Sunscale** (+40 de velocidade, final)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Ssurrak Shed Skin` | escudo (sem dano) + guardas: Lizard Sentinel×3, Lizard Legionnaire×2 | 1 s | — | Shed Skin (ao entrar) | Matar os guardas para quebrar o escudo. |
| `Ssurrak Marked Prey` | a marca segue 2 jogador(es) por 2,2 s e trava (raio 2), golpe 0,9 s depois — terra 110-170 + dano contínuo terra 25×5 · **Rage:** quantidade 2→3 | 12 s | — | Ambush, Venom, Sunscale | Quem é marcado se afasta do grupo. |
| `Ssurrak Snake Charm` | invoca Lizard Snakecharmer×2, Lizard Sentinel×1 (máx. 5 summons) | 15 s | — | Ambush, Venom | Matar os adds. |
| `Ssurrak Spear Volley` | 3 faixas paralelas de 8 sqm na direção do alvo (vãos de 1 sqm), golpe 1,3 s depois — terra 90-150 · **Rage:** faixas 3→5 | 6.5 s | 9 | Ambush, Shed Skin, Venom, Sunscale | Ficar nos vãos entre as faixas (numa 2ª grade os vãos mudam). |
| `Ssurrak Sunfire` | arena de raio 7 inteira marcada, exceto 3 quadrados 3x3 verdes, golpe 2,4 s depois — fogo 160-260 | 20 s | — | Sunscale | Entrar num quadrado verde antes do golpe. |
| `Ssurrak Tail Sweep` | cone de 3 sqm na direção do alvo nos 4 lados, golpe 1,1 s depois — físico 100-160 | 6 s | 3 | Ambush, Venom, Sunscale | Sair da direção do cone. |
| `Ssurrak Venom Cloud` | 4 marcas círculo raio 2 em jogadores sorteados (uma a cada 0,45 s), golpe 1,9 s depois — terra 60-100 + dano contínuo terra 25×5 · **Rage:** quantidade 4→6 | 9 s | — | Ambush, Shed Skin, Venom, Sunscale | Sair da marca antes do golpe; com poças, não voltar. |

### Titan Korg — Cyclops Rampage

- **Vida / Exp / Velocidade:** 28.000 / 3.400 / 190 (monsterId 751)
- **Fases:** **Smash** ─(vida < 70%)→ **Stone Skin** (escudo) ─(guardas mortos ou 40 s)→ **Rockfall** ─(vida < 35%)→ **Titanfall** (+50 de velocidade, final)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Korg Stone Skin` | escudo (sem dano) + guardas: Cyclops×3, Cyclops Smith×2 | 1 s | — | Stone Skin (ao entrar) | Matar os guardas para quebrar o escudo. |
| `Korg Boulder Barrage` | 5 marcas 5x5 em jogadores sorteados (uma a cada 0,40 s), golpe 2 s depois — físico 100-170 · **Rage:** quantidade 5→7 | 9 s | — | Smash, Stone Skin, Rockfall, Titanfall | Sair da marca antes do golpe; com poças, não voltar. |
| `Korg Ground Slam` | 3 ondas (anéis de 2 sqm) saindo do boss, uma a cada 0,60 s, golpe 1,2 s depois — físico 90-150 · **Rage:** ondas 3→4 | 8 s | — | Smash, Stone Skin, Rockfall, Titanfall | Passar para o anel que já acertou. |
| `Korg Rock Chain` | raio em cadeia: 4 saltos até 5 sqm, um a cada 0,80 s — físico 100-160 · **Rage:** saltos 4→5 | 10 s | — | Smash, Rockfall, Titanfall | Manter distância entre os jogadores (o raio pula para o mais próximo). |
| `Korg Stomp` | marca 5x5 no alvo, o boss pula ao lado e acerta, golpe 1,5 s depois — físico 110-180 | 9 s | 8 | Smash, Rockfall, Titanfall | Sair da marca; o boss cai ao lado. |
| `Korg Titanfall` | arena de raio 8 inteira marcada, exceto 3 quadrados 3x3 verdes, golpe 2,6 s depois — físico 170-270 | 20 s | — | Titanfall | Entrar num quadrado verde antes do golpe. |

### Vizier Khalzar — Djinn War

- **Vida / Exp / Velocidade:** 26.000 / 3.500 / 240 (monsterId 753)
- **Fases:** **Court** ─(vida < 68%)→ **Lamp Guard** (escudo) ─(guardas mortos ou 40 s)→ **Wrath** (+30 de velocidade) ─(vida < 35%)→ **Wishbreaker** (+40 de velocidade, final)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Khalzar Lamp Guards` | escudo (sem dano) + guardas: Green Djinn×3, Blue Djinn×3 | 1 s | — | Lamp Guard (ao entrar) | Matar os guardas para quebrar o escudo. |
| `Khalzar Flame Waves` | 4 ondas (anéis de 2 sqm) saindo do boss, uma a cada 0,60 s, golpe 1,2 s depois — fogo 80-140 · **Final:** ordem do boss para fora→de fora para dentro | 10 s | — | Court, Lamp Guard, Wrath, Wishbreaker | Passar para o anel que já acertou. |
| `Khalzar Genie Lines` | 3 etapas de linhas de 8 sqm (retas e diagonais alternadas), uma a cada 0,7 s, golpe 1,4 s depois — energia 90-150 | 7.5 s | — | Court, Lamp Guard, Wrath, Wishbreaker | Continuar se movendo: o lugar seguro de uma etapa é atingido na seguinte. |
| `Khalzar Lightning Chain` | raio em cadeia: 5 saltos até 5 sqm, um a cada 0,75 s — energia 90-150 · **Rage:** saltos 5→7 | 9 s | — | Court, Wrath, Wishbreaker | Manter distância entre os jogadores (o raio pula para o mais próximo). |
| `Khalzar Sand Prison` | a marca segue 2 jogador(es) por 2 s e trava (raio 1), golpe 0,9 s depois — energia 100-160 + lentidão 90% por 2,5 s | 12 s | — | Court, Wrath, Wishbreaker | Quem é marcado se afasta do grupo. |
| `Khalzar Wish Storm` | arena de raio 8 inteira marcada, exceto 3 quadrados 3x3 verdes, golpe 2,4 s depois — energia 170-270 | 20 s | — | Wishbreaker | Entrar num quadrado verde antes do golpe. |

## Tier III

Definições em `396-bosses-tier3.lua`.

### Glaciarch Vorthrax — Frost Siege

- **Vida / Exp / Velocidade:** 54.000 / 7.000 / 220 (monsterId 756)
- **Fases:** **Chill** ─(vida < 78%)→ **Carapace** (escudo) ─(guardas mortos ou 45 s)→ **Whiteout** ─(vida < 50%)→ **Deep Freeze** ─(vida < 22%)→ **Absolute Zero** (+40 de velocidade, final)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Vorthrax Crystal Carapace` | escudo (sem dano) + guardas: Ice Golem×3, Yeti×2, Ice Witch×1 · enquanto vivos, cada add cura o boss 0,4% por segundo, por 20 s | 1 s | — | Carapace (ao entrar) | Matar os guardas para quebrar o escudo. Matar os adds depressa: eles curam o boss. |
| `Vorthrax Absolute Zero` | arena de raio 9 inteira marcada, exceto 3 quadrados 3x3 verdes, golpe 2,6 s depois — gelo 330-480 · → 2,9 s depois: cone de 9 sqm na direção do alvo, golpe 1,4 s depois — gelo 220-330 | 24 s | — | Deep Freeze, Absolute Zero | Entrar num quadrado verde antes do golpe. Sair da direção do cone. |
| `Vorthrax Frost Breath` | cone de 9 sqm na direção do alvo, golpe 1,5 s depois — gelo 180-280 · **Rage:** lados 1→2, acrescenta → 2 s depois: cone de 9 sqm na direção do alvo, golpe 1,5 s depois — gelo 180-280 | 7 s | 9 | Chill, Carapace, Whiteout, Deep Freeze, Absolute Zero | Sair da direção do cone. |
| `Vorthrax Hail Grid` | faixas de 2 sqm com corredor de 1 sqm entre elas, vertical ou horizontal, golpe 1,9 s depois — gelo 150-230 · → 1,6 s depois: faixas de 2 sqm com corredor de 1 sqm entre elas, vertical ou horizontal, golpe 1,7 s depois — gelo 150-230 | 12 s | — | Chill, Carapace, Whiteout, Deep Freeze, Absolute Zero | Achar o corredor livre. |
| `Vorthrax Ice Tether` | liga 1 par(es) de jogadores por 5 s: têm de ficar juntos (≤ 3 sqm) — gelo 250-360 · **Rage:** pares 1→2 | 16 s | — | Chill, Whiteout, Deep Freeze, Absolute Zero | Ficar perto do par. |
| `Vorthrax Rime Call` | invoca Winter Wolf×3, Yeti×1 (máx. 8 summons) · enquanto vivos, cada add cura o boss 0,5% por segundo, por 12 s | 20 s | — | Chill, Whiteout | Matar os adds. Matar os adds depressa: eles curam o boss. |
| `Vorthrax Shatter` | 1 marcado(s) (raio 2): 1100 de dano dividido entre quem estiver dentro (máx. 480 cada), golpe 1 s depois [gelo] · **Final:** quantidade 1→2 | 16 s | — | Whiteout, Deep Freeze, Absolute Zero | Todos correm para o marcado e dividem o dano. |
| `Vorthrax Whiteout` | perigo que fica: anel de 3..6 sqm do boss por 7 s — gelo 100-150 · **Rage:** ticks 7→10 | 18 s | — | Chill, Whiteout, Deep Freeze, Absolute Zero | Ficar fora da faixa perigosa. |

### Iron Overseer Kragmor — Golem Foundry

- **Vida / Exp / Velocidade:** 52.000 / 6.800 / 210 (monsterId 757)
- **Fases:** **Assembly** ─(vida < 78%)→ **Armor Plating** (escudo) ─(guardas mortos ou 45 s)→ **Overclock** ─(vida < 50%)→ **Magnetize** ─(vida < 22%)→ **Meltdown** (+40 de velocidade, final)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Kragmor Armor Plating` | escudo (sem dano) + guardas: Stone Golem×3, Worker Golem×2, War Golem×1 · enquanto vivos, cada add cura o boss 0,4% por segundo, por 20 s | 1 s | — | Armor Plating (ao entrar) | Matar os guardas para quebrar o escudo. Matar os adds depressa: eles curam o boss. |
| `Kragmor Gear Beam` | 4 raio(s) de largura 1 e 9 sqm girando 6 passos (um a cada 0,50 s) — físico 160-250 · **Rage:** passos 6→10 | 10 s | — | Assembly, Armor Plating, Overclock, Magnetize, Meltdown | Acompanhar o giro, fora do raio. |
| `Kragmor Magnet Pull` | arrasta todos os jogadores para o anel de raio 2 em volta do boss · → 0,4 s depois: disco de raio 5 em volta do boss, golpe 2 s depois — energia 240-340 | 20 s | — | Overclock, Magnetize, Meltdown | Sair do círculo logo depois de ser puxado. Ficar no quadrado seguro ou sair do disco. |
| `Kragmor Meltdown` | arena de raio 9 inteira marcada, exceto 2 quadrados 3x3 verdes, golpe 2,4 s depois — energia 350-480 · → 3 s depois: 1 marcado(s) (raio 2): 1000 de dano dividido entre quem estiver dentro (máx. 450 cada), golpe 1 s depois [energia] | 24 s | — | Meltdown | Entrar num quadrado verde antes do golpe. Todos correm para o marcado e dividem o dano. |
| `Kragmor Overcharge` | liga 1 par(es) de jogadores por 5 s: têm de ficar separados (≥ 5 sqm) — energia 260-380 · **Rage:** pares 1→2 | 16 s | — | Assembly, Overclock, Magnetize, Meltdown | Manter distância do par. |
| `Kragmor Piston Slam` | 5 faixas paralelas de 10 sqm na direção do alvo (vãos de 1 sqm), golpe 1,5 s depois — físico 170-260 · → 1,7 s depois: 6 faixas paralelas de 10 sqm na direção do alvo (vãos de 1 sqm), golpe 1,4 s depois — físico 170-260 | 8 s | 10 | Assembly, Armor Plating, Overclock, Magnetize, Meltdown | Ficar nos vãos entre as faixas (numa 2ª grade os vãos mudam). |
| `Kragmor Scrap Call` | invoca Worker Golem×3, Stone Golem×1 (máx. 8 summons) · enquanto vivos, cada add cura o boss 0,5% por segundo, por 12 s | 20 s | — | Assembly, Overclock | Matar os adds. Matar os adds depressa: eles curam o boss. |
| `Kragmor Steam Vents` | perigo que fica: anel de 1..4 sqm do boss por 7 s — fogo 90-140 · **Rage:** ticks 7→10 | 18 s | — | Assembly, Overclock, Magnetize, Meltdown | Ficar fora da faixa perigosa. |

### Necrarch Mortheus — Undead Uprising

- **Vida / Exp / Velocidade:** 48.000 / 6.500 / 240 (monsterId 754)
- **Fases:** **Gravecall** ─(vida < 78%)→ **Harvest** (escudo) ─(guardas mortos ou 45 s)→ **Deathbound** ─(vida < 50%)→ **Requiem** ─(vida < 22%)→ **Oblivion** (+40 de velocidade, final)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Mortheus Bone Cage` | escudo (sem dano) + guardas: Crypt Shambler×2, BoneBeast×2, Banshee×2 · enquanto vivos, cada add cura o boss 0,4% por segundo, por 20 s | 1 s | — | Harvest (ao entrar) | Matar os guardas para quebrar o escudo. Matar os adds depressa: eles curam o boss. |
| `Mortheus Bone Beam` | 2 raio(s) de largura 1 e 9 sqm girando 8 passos (um a cada 0,45 s) — morte 170-260 · **Rage:** passos 8→12, largura 1→3 | 10 s | — | Gravecall, Harvest, Deathbound, Requiem, Oblivion | Acompanhar o giro, fora do raio. |
| `Mortheus Death Mark` | marca 2 jogador(es): em 5,5 s têm de estar num dos 3 quadrados verdes — morte 300-420 + dano contínuo morte 40×5 · **Rage:** quantidade 2→3 | 15 s | — | Gravecall, Deathbound, Requiem, Oblivion | Os marcados vão ao quadrado verde. |
| `Mortheus Grave Hands` | 5 marcas 3x3 em jogadores sorteados (uma a cada 0,35 s), golpe 1,6 s depois — morte 140-220 · **Rage:** quantidade 5→7, acrescenta → 2,2 s depois: 3 marcas 3x3 em jogadores sorteados (uma a cada 0,35 s), golpe 1,6 s depois — morte 140-220 | 8 s | — | Gravecall, Harvest, Deathbound, Requiem, Oblivion | Sair da marca antes do golpe; com poças, não voltar. |
| `Mortheus Oblivion` | arena de raio 8 inteira marcada, exceto 3 quadrados 3x3 verdes, golpe 2,6 s depois — morte 330-480 · → 2,9 s depois: arena de raio 8 inteira marcada, exceto 3 quadrados 3x3 verdes, golpe 2,2 s depois — morte 250-380 | 24 s | — | Oblivion | Entrar num quadrado verde antes do golpe. |
| `Mortheus Raise Dead` | invoca Skeleton×3, Ghoul×2 (máx. 8 summons) · enquanto vivos, cada add cura o boss 0,5% por segundo, por 12 s | 20 s | — | Gravecall, Deathbound, Requiem | Matar os adds. Matar os adds depressa: eles curam o boss. |
| `Mortheus Requiem` | 1 marcado(s) (raio 2): 1100 de dano dividido entre quem estiver dentro (máx. 480 cada), golpe 1 s depois [morte] · **Final:** quantidade 1→2 | 17 s | — | Requiem, Oblivion | Todos correm para o marcado e dividem o dano. |
| `Mortheus Soul Tether` | liga 1 par(es) de jogadores por 5 s: têm de ficar juntos (≤ 4 sqm) — morte 260-380 · **Rage:** pares 1→2 | 16 s | — | Gravecall, Deathbound, Requiem, Oblivion | Ficar perto do par. |

### Nightmare Weaver Syrelith — Nightmare Horde

- **Vida / Exp / Velocidade:** 50.000 / 7.000 / 240 (monsterId 758)
- **Fases:** **Twilight** ─(vida < 78%)→ **Dreamveil** (escudo) ─(guardas mortos ou 45 s)→ **Terror** ─(vida < 50%)→ **Lucid Dream** ─(vida < 22%)→ **Nightfall** (+40 de velocidade, final)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Syrelith Dreamveil` | escudo (sem dano) + guardas: Nightmare×3, Nightstalker×2, Gargoyle×1 · enquanto vivos, cada add cura o boss 0,4% por segundo, por 20 s | 1 s | — | Dreamveil (ao entrar) | Matar os guardas para quebrar o escudo. Matar os adds depressa: eles curam o boss. |
| `Syrelith Dread Mark` | marca 2 jogador(es): em 5 s têm de estar num dos 3 quadrados verdes — morte 280-400 + dano contínuo morte 35×5 · **Rage:** quantidade 2→3 | 15 s | — | Twilight, Terror, Lucid Dream, Nightfall | Os marcados vão ao quadrado verde. |
| `Syrelith Dream Eater` | 1 marcado(s) (raio 3): 1200 de dano dividido entre quem estiver dentro (máx. 520 cada), golpe 1,1 s depois [morte] · **Final:** quantidade 1→2 | 17 s | — | Terror, Lucid Dream, Nightfall | Todos correm para o marcado e dividem o dano. |
| `Syrelith Nightfall` | perigo que fica: anel de 5..9 sqm do boss por 9 s — morte 100-150 · → 0,6 s depois: marca 2 jogador(es): em 5 s têm de estar num dos 2 quadrados verdes — morte 320-450 | 26 s | — | Lucid Dream, Nightfall | Ficar fora da faixa perigosa. Os marcados vão ao quadrado verde. |
| `Syrelith Nightmare Beam` | 2 raio(s) de largura 3 e 9 sqm girando 10 passos (um a cada 0,45 s) — morte 170-260 | 10 s | — | Twilight, Dreamveil, Terror, Lucid Dream, Nightfall | Acompanhar o giro, fora do raio. |
| `Syrelith Nightmare Call` | invoca Nightstalker×2, Gargoyle×2 (máx. 8 summons) · enquanto vivos, cada add cura o boss 0,5% por segundo, por 12 s | 20 s | — | Twilight, Terror | Matar os adds. Matar os adds depressa: eles curam o boss. |
| `Syrelith Shadow Step` | marca 5x5 no alvo, o boss pula ao lado e acerta, golpe 1,4 s depois — morte 150-230 | 12 s | 9 | Twilight, Dreamveil, Terror, Lucid Dream, Nightfall | Sair da marca; o boss cai ao lado. |
| `Syrelith Terror Tether` | liga 1 par(es) de jogadores por 5 s: têm de ficar separados (≥ 6 sqm) — morte 260-380 · **Rage:** pares 1→2 | 16 s | — | Twilight, Terror, Lucid Dream, Nightfall | Manter distância do par. |

### Pyrothane the Cinderlord — Elemental Surge

- **Vida / Exp / Velocidade:** 50.000 / 6.800 / 230 (monsterId 755)
- **Fases:** **Smolder** ─(vida < 78%)→ **Inferno Shell** (escudo) ─(guardas mortos ou 45 s)→ **Wildfire** ─(vida < 50%)→ **Supernova** ─(vida < 22%)→ **Cinderstorm** (+40 de velocidade, final)

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Pyrothane Inferno Shell` | escudo (sem dano) + guardas: Fire Elemental×3, Earth Elemental×2, Water Elemental×1 · enquanto vivos, cada add cura o boss 0,4% por segundo, por 20 s | 1 s | — | Inferno Shell (ao entrar) | Matar os guardas para quebrar o escudo. Matar os adds depressa: eles curam o boss. |
| `Pyrothane Elemental Call` | invoca Fire Elemental×2, Energy Elemental×1, Earth Elemental×1 (máx. 8 summons) · enquanto vivos, cada add cura o boss 0,5% por segundo, por 12 s | 20 s | — | Smolder, Wildfire | Matar os adds. Matar os adds depressa: eles curam o boss. |
| `Pyrothane Ember Stack` | 1 marcado(s) (raio 2): 1200 de dano dividido entre quem estiver dentro (máx. 500 cada), golpe 1 s depois [fogo] · **Final:** quantidade 1→2 | 16 s | — | Wildfire, Supernova, Cinderstorm | Todos correm para o marcado e dividem o dano. |
| `Pyrothane Eruption` | 6 marcas círculo raio 2 em jogadores sorteados (uma a cada 0,40 s), golpe 1,8 s depois — fogo 150-230 + dano contínuo fogo 30×4 · **Rage:** acrescenta → 2,6 s depois: 4 marcas círculo raio 2 em jogadores sorteados (uma a cada 0,40 s), golpe 1,8 s depois — fogo 150-230 + dano contínuo fogo 30×4 | 9 s | — | Smolder, Inferno Shell, Wildfire, Supernova, Cinderstorm | Sair da marca antes do golpe; com poças, não voltar. |
| `Pyrothane Flare Beam` | 1 raio(s) de largura 3 e 10 sqm girando 10 passos (um a cada 0,40 s) — fogo 160-240 · **Rage:** raios 1→2 | 10 s | — | Smolder, Inferno Shell, Wildfire, Supernova, Cinderstorm | Acompanhar o giro, fora do raio. |
| `Pyrothane Magma Ring` | perigo que fica: anel de 5..9 sqm do boss por 7 s — fogo 90-140 · **Rage:** ticks 7→10 | 18 s | — | Smolder, Wildfire, Supernova, Cinderstorm | Ficar fora da faixa perigosa. |
| `Pyrothane Repel` | liga 1 par(es) de jogadores por 5 s: têm de ficar separados (≥ 5 sqm) — fogo 250-360 · **Rage:** pares 1→2 | 15 s | — | Smolder, Wildfire, Supernova, Cinderstorm | Manter distância do par. |
| `Pyrothane Supernova` | arrasta todos os jogadores para o anel de raio 2 em volta do boss · → 0,4 s depois: disco de raio 5 em volta do boss, golpe 2,2 s depois — fogo 280-400 · **Final:** 0,4 s depois: raio 5→7 | 22 s | — | Supernova, Cinderstorm | Sair do círculo logo depois de ser puxado. Ficar no quadrado seguro ou sair do disco. |

## Tier IV

Definições em `397-bosses-tier4.lua`.

### Countess Sanguessa — Blood Moon

- **Vida / Exp / Velocidade:** 85.000 / 12.500 / 260 (monsterId 760)
- **Fases:** **Court** ─(vida < 80%)→ **Veil of Blood** (escudo) ─(guardas mortos ou 45 s)→ **Blood Moon** ─(vida < 50%)→ **Eclipse** ─(vida < 22% ou enrage)→ **Bloodbath** (+40 de velocidade, final)
- **Enrage:** depois de 7-8 minutos de vida vai para **Bloodbath** e fica nela.

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Sanguessa Veil of Blood` | escudo (sem dano) + guardas: Vampire Bride×3, Vampire×3, Banshee×1 · enquanto vivos, cada add cura o boss 0,4% por segundo, por 24 s | 1 s | — | Veil of Blood (ao entrar) | Matar os guardas para quebrar o escudo. Matar os adds depressa: eles curam o boss. |
| `Sanguessa Blood Link` | liga 1 par(es) de jogadores por 5,5 s: têm de ficar juntos (≤ 3 sqm) — morte 380-520 · **Rage:** pares 1→2 | 18 s | — | Court, Blood Moon, Eclipse | Ficar perto do par. |
| `Sanguessa Blood Orbs` | 2× Bloodmoon Orb com contagem de 9 s: explodem (raio 4) e curam o boss 4% cada — morte 450-600 · **Rage:** quantidade 2→3 | 24 s | — | Blood Moon, Eclipse, Bloodbath | Matar as bombas antes de zerar a contagem. |
| `Sanguessa Blood Pool` | disco de raio 5 em volta do boss, com um quadrado seguro 3x3 colado no boss, golpe 1,8 s depois — morte 250-380 + poças por 8 s (60-100 por segundo) | 12 s | — | Court, Blood Moon, Eclipse, Bloodbath | Ficar no quadrado seguro ou sair do disco. |
| `Sanguessa Crimson Bats` | 8 marcas 3x3 em jogadores sorteados (uma a cada 0,30 s), golpe 1,6 s depois — morte 180-280 + pilha «Bleeding» (+50 por pilha, máx. 5, 20 s) · **Rage:** quantidade 8→10 | 9 s | — | Court, Veil of Blood, Blood Moon, Eclipse, Bloodbath | Sair da marca antes do golpe; com poças, não voltar. |
| `Sanguessa Crimson Pact` | jogadores vermelhos e azuis e 2 zonas (raio 2): em 6 s cada um tem de estar na zona da sua cor — morte 420-560 + dano contínuo morte 50×5 | 22 s | — | Blood Moon, Eclipse, Bloodbath | Cada um vai para a zona da sua cor. |
| `Sanguessa Eclipse` | arena de raio 9 inteira marcada, exceto 2 quadrados 3x3 verdes, golpe 2,6 s depois — morte 480-680 · → 3 s depois: 2 marcado(s) (raio 2): 1500 de dano dividido entre quem estiver dentro (máx. 600 cada), golpe 1 s depois [morte] | 26 s | — | Bloodbath | Entrar num quadrado verde antes do golpe. Todos correm para o marcado e dividem o dano. |
| `Sanguessa Hemorrhage` | marca 2 jogador(es): em 5,5 s têm de estar num dos 3 quadrados verdes — morte 400-550 + dano contínuo morte 60×6 · **Rage:** quantidade 2→3 | 17 s | — | Court, Blood Moon, Eclipse, Bloodbath | Os marcados vão ao quadrado verde. |
| `Sanguessa Moonlit Sweep` | 4 raio(s) de largura 3 e 10 sqm girando 8 passos (um a cada 0,45 s) — morte 220-320 · **Rage:** passos 8→10 | 11 s | — | Court, Veil of Blood, Blood Moon, Eclipse, Bloodbath | Acompanhar o giro, fora do raio. |
| `Sanguessa Vampire Brood` | invoca Vampire×3, Vampire Bride×2 (máx. 8 summons) · enquanto vivos, cada add cura o boss 0,5% por segundo, por 14 s | 22 s | — | Court, Blood Moon | Matar os adds. Matar os adds depressa: eles curam o boss. |

### Forgelord Vexmar — Plague Legion

- **Vida / Exp / Velocidade:** 90.000 / 12.500 / 230 (monsterId 763)
- **Fases:** **Forging** ─(vida < 80%)→ **Bile Armor** (escudo) ─(guardas mortos ou 45 s)→ **Contagion** ─(vida < 50%)→ **Epidemic** ─(vida < 22% ou enrage)→ **Pandemic** (+40 de velocidade, final)
- **Enrage:** depois de 7-8 minutos de vida vai para **Pandemic** e fica nela.

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Vexmar Bile Armor` | escudo (sem dano) + guardas: Demon Skeleton×3, Defiler×2, Blightwalker×1 · enquanto vivos, cada add cura o boss 0,4% por segundo, por 24 s | 1 s | — | Bile Armor (ao entrar) | Matar os guardas para quebrar o escudo. Matar os adds depressa: eles curam o boss. |
| `Vexmar Antidote` | jogadores vermelhos e azuis e 2 zonas (raio 2): em 6 s cada um tem de estar na zona da sua cor — terra 420-560 + dano contínuo terra 50×5 | 22 s | — | Contagion, Epidemic, Pandemic | Cada um vai para a zona da sua cor. |
| `Vexmar Blight Beam` | 4 raio(s) de largura 1 e 10 sqm girando 8 passos (um a cada 0,45 s) — terra 220-320 · **Rage:** passos 8→10 | 11 s | — | Forging, Bile Armor, Contagion, Epidemic, Pandemic | Acompanhar o giro, fora do raio. |
| `Vexmar Corrosion Waves` | 5 ondas (anéis de 2 sqm) saindo do boss, uma a cada 0,55 s, golpe 1,2 s depois — terra 230-350 + pilha «Plague» (+80 por pilha, máx. 5, 20 s) · **Final:** ordem do boss para fora→de fora para dentro | 12 s | — | Forging, Contagion, Epidemic, Pandemic | Passar para o anel que já acertou. |
| `Vexmar Pandemic` | arena de raio 10 inteira marcada, exceto 3 quadrados 3x3 verdes, golpe 2,8 s depois — terra 480-680 · → 3,1 s depois: arena de raio 10 inteira marcada, exceto 3 quadrados 3x3 verdes, golpe 2,2 s depois — terra 350-500 · → 5,6 s depois: arrasta todos os jogadores para o anel de raio 2 em volta do boss; → 0,4 s depois: disco de raio 5 em volta do boss, golpe 2 s depois — terra 380-540 | 30 s | — | Pandemic | Entrar num quadrado verde antes do golpe. Sair do círculo logo depois de ser puxado. Ficar no quadrado seguro ou sair do disco. |
| `Vexmar Plague Call` | invoca Defiler×1, Demon Skeleton×3 (máx. 8 summons) · enquanto vivos, cada add cura o boss 0,5% por segundo, por 14 s | 22 s | — | Forging, Contagion | Matar os adds. Matar os adds depressa: eles curam o boss. |
| `Vexmar Plague Pods` | 2× Plague Pod com contagem de 9 s: explodem (raio 4) e curam o boss 5% cada — terra 450-600 · **Rage:** quantidade 2→3 | 24 s | — | Contagion, Epidemic, Pandemic | Matar as bombas antes de zerar a contagem. |
| `Vexmar Purge` | marca 2 jogador(es): em 5,5 s têm de estar num dos 3 quadrados verdes — terra 400-550 + dano contínuo terra 60×6 · **Rage:** quantidade 2→3 | 17 s | — | Forging, Contagion, Epidemic, Pandemic | Os marcados vão ao quadrado verde. |
| `Vexmar Rot Link` | liga 1 par(es) de jogadores por 5,5 s: têm de ficar juntos (≤ 3 sqm) — terra 380-520 · **Rage:** pares 1→2 | 18 s | — | Forging, Contagion, Epidemic | Ficar perto do par. |
| `Vexmar Spore Burst` | 7 marcas círculo raio 2 em jogadores sorteados (uma a cada 0,35 s), golpe 1,8 s depois — terra 190-290 + pilha «Plague» (+80 por pilha, máx. 5, 20 s) + poças por 7 s (60-100 por segundo) · **Rage:** quantidade 7→9 | 10 s | — | Forging, Bile Armor, Contagion, Epidemic, Pandemic | Sair da marca antes do golpe; com poças, não voltar. |
| `Vexmar Toxic Hammer` | cone de 6 sqm na direção do alvo e no lado oposto, golpe 1,4 s depois — terra 280-400 + pilha «Plague» (+80 por pilha, máx. 5, 20 s) | 7 s | 6 | Forging | Sair da direção do cone. |

### Matriarch Ignaria — Asura Onslaught

- **Vida / Exp / Velocidade:** 85.000 / 12.500 / 250 (monsterId 762)
- **Fases:** **Dawn** ─(vida < 80%)→ **Pyre Barrier** (escudo) ─(guardas mortos ou 45 s)→ **Noon** ─(vida < 50%)→ **Dusk** ─(vida < 22% ou enrage)→ **Dawnbreak** (+40 de velocidade, final)
- **Enrage:** depois de 7-8 minutos de vida vai para **Dawnbreak** e fica nela.

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Ignaria Pyre Barrier` | escudo (sem dano) + guardas: Hellfire Fighter×2, Midnight Asura×2, Dawnfire Asura×2 · enquanto vivos, cada add cura o boss 0,4% por segundo, por 24 s | 1 s | — | Pyre Barrier (ao entrar) | Matar os guardas para quebrar o escudo. Matar os adds depressa: eles curam o boss. |
| `Ignaria Asura Call` | invoca Midnight Asura×2, Dawnfire Asura×2 (máx. 8 summons) · enquanto vivos, cada add cura o boss 0,5% por segundo, por 14 s | 22 s | — | Dawn, Noon | Matar os adds. Matar os adds depressa: eles curam o boss. |
| `Ignaria Burning Pact` | 2 marcado(s) (raio 2): 1500 de dano dividido entre quem estiver dentro (máx. 600 cada), golpe 1 s depois [fogo] · **Final:** quantidade 2→3 | 18 s | — | Noon, Dusk, Dawnbreak | Todos correm para o marcado e dividem o dano. |
| `Ignaria Dawn Beam` | 2 raio(s) de largura 3 e 10 sqm girando 10 passos (um a cada 0,45 s) — fogo 230-340 + pilha «Dawnfire» (+55 por pilha, máx. 5, 20 s) | 10 s | — | Dawn, Pyre Barrier, Noon, Dusk, Dawnbreak | Acompanhar o giro, fora do raio. |
| `Ignaria Dawnbreak` | arena de raio 10 inteira marcada, exceto 3 quadrados 3x3 verdes, golpe 2,8 s depois — fogo 500-700 · → 3,1 s depois: 5 ondas (anéis de 2 sqm) de fora para dentro, uma a cada 0,50 s, golpe 1,1 s depois — fogo 300-440 · → 6,4 s depois: 2 marcado(s) (raio 2): 1500 de dano dividido entre quem estiver dentro (máx. 600 cada), golpe 1 s depois [fogo] | 28 s | — | Dawnbreak | Entrar num quadrado verde antes do golpe. Passar para o anel que já acertou. Todos correm para o marcado e dividem o dano. |
| `Ignaria Ember Mark` | marca 2 jogador(es): em 5,5 s têm de estar num dos 3 quadrados verdes — fogo 400-550 + dano contínuo fogo 60×6 · **Rage:** quantidade 2→3 | 17 s | — | Dawn, Noon, Dusk, Dawnbreak | Os marcados vão ao quadrado verde. |
| `Ignaria Flame Shackles` | liga 1 par(es) de jogadores por 5,5 s: têm de ficar separados (≥ 6 sqm) — fogo 380-520 · **Rage:** pares 1→2 | 18 s | — | Dawn, Noon, Dusk | Manter distância do par. |
| `Ignaria Phoenix Pyre` | 2× Dawnfire Ember com contagem de 9 s: explodem (raio 4) e curam o boss 4% cada — fogo 450-600 · **Rage:** quantidade 2→3 | 24 s | — | Noon, Dusk, Dawnbreak | Matar as bombas antes de zerar a contagem. |
| `Ignaria Rite of Dawn` | jogadores vermelhos e azuis e 2 zonas (raio 2): em 6 s cada um tem de estar na zona da sua cor — fogo 420-560 + dano contínuo fogo 50×5 | 22 s | — | Noon, Dusk, Dawnbreak | Cada um vai para a zona da sua cor. |
| `Ignaria Sunburst` | disco de raio 6 em volta do boss, com um quadrado seguro 5x5 colado no boss, golpe 1,9 s depois — fogo 300-440 + poças por 6 s (70-110 por segundo) | 12 s | — | Dawn, Pyre Barrier, Noon, Dusk, Dawnbreak | Ficar no quadrado seguro ou sair do disco. |

### Warlord Zhardakkan — Draken Legion

- **Vida / Exp / Velocidade:** 92.000 / 12.500 / 240 (monsterId 761)
- **Fases:** **Onslaught** ─(vida < 80%)→ **Drakeguard** (escudo) ─(guardas mortos ou 45 s)→ **Drakefire** ─(vida < 50%)→ **Frenzy** ─(vida < 22% ou enrage)→ **Last Dragon** (+40 de velocidade, final)
- **Enrage:** depois de 7-8 minutos de vida vai para **Last Dragon** e fica nela.

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Zhardak Drakeguard` | escudo (sem dano) + guardas: Draken Elite×3, Draken Spellweaver×2, Draken Warmaster×1 · enquanto vivos, cada add cura o boss 0,4% por segundo, por 24 s | 1 s | — | Drakeguard (ao entrar) | Matar os guardas para quebrar o escudo. Matar os adds depressa: eles curam o boss. |
| `Zhardak Banner Bearers` | 2× Drakenfire Totem com contagem de 9 s: explodem (raio 5) e curam o boss 4% cada — fogo 450-600 · **Rage:** quantidade 2→3 | 24 s | — | Drakefire, Frenzy, Last Dragon | Matar as bombas antes de zerar a contagem. |
| `Zhardak Blood Oath` | liga 1 par(es) de jogadores por 5,5 s: têm de ficar separados (≥ 6 sqm) — fogo 380-520 · **Rage:** pares 1→2 | 18 s | — | Onslaught, Drakefire, Frenzy, Last Dragon | Manter distância do par. |
| `Zhardak Dragonfall` | arena de raio 10 inteira marcada, exceto 3 quadrados 3x3 verdes, golpe 2,8 s depois — fogo 500-700 · → 3,2 s depois: arrasta todos os jogadores para o anel de raio 2 em volta do boss; → 0,4 s depois: disco de raio 5 em volta do boss, golpe 2 s depois — fogo 380-540 | 28 s | — | Last Dragon | Entrar num quadrado verde antes do golpe. Sair do círculo logo depois de ser puxado. Ficar no quadrado seguro ou sair do disco. |
| `Zhardak Dragonfire Rain` | 7 marcas círculo raio 2 em jogadores sorteados (uma a cada 0,35 s), golpe 1,8 s depois — fogo 200-300 + poças por 6 s (70-110 por segundo) · **Rage:** quantidade 7→9 | 10 s | — | Onslaught, Drakeguard, Drakefire, Frenzy, Last Dragon | Sair da marca antes do golpe; com poças, não voltar. |
| `Zhardak Fire Volley` | 5 faixas paralelas de 11 sqm na direção do alvo (vãos de 1 sqm), golpe 1,5 s depois — fogo 260-380 + pilha «Burning» (+60 por pilha, máx. 5, 20 s) · → 1,7 s depois: 6 faixas paralelas de 11 sqm na direção do alvo (vãos de 1 sqm), golpe 1,4 s depois — fogo 260-380 + pilha «Burning» (+60 por pilha, máx. 5, 20 s) | 9 s | 11 | Onslaught, Drakeguard, Drakefire, Frenzy, Last Dragon | Ficar nos vãos entre as faixas (numa 2ª grade os vãos mudam). |
| `Zhardak Frenzy Chain` | raio em cadeia: 6 saltos até 5 sqm, um a cada 0,65 s — fogo 250-350 · **Rage:** saltos 6→8 | 12 s | — | Drakefire, Frenzy, Last Dragon | Manter distância entre os jogadores (o raio pula para o mais próximo). |
| `Zhardak Leaping Slam` | marca 5x5 no alvo, o boss pula ao lado e acerta, golpe 1,5 s depois — físico 280-400 | 12 s | 9 | Onslaught, Drakefire, Frenzy, Last Dragon | Sair da marca; o boss cai ao lado. |
| `Zhardak Legion Call` | invoca Draken Warmaster×2, Draken Spellweaver×2 (máx. 8 summons) · enquanto vivos, cada add cura o boss 0,5% por segundo, por 14 s | 22 s | — | Onslaught, Drakefire | Matar os adds. Matar os adds depressa: eles curam o boss. |
| `Zhardak War Drums` | perigo que fica: anel de 6..10 sqm do boss por 8 s — físico 110-170 · **Rage:** ticks 8→10 | 20 s | — | Onslaught, Drakefire, Frenzy | Ficar fora da faixa perigosa. |

### Wyrmlord Azhrakar — Dragon Siege

- **Vida / Exp / Velocidade:** 90.000 / 12.000 / 230 (monsterId 759)
- **Fases:** **Descent** ─(vida < 80%)→ **Bone Aegis** (escudo) ─(guardas mortos ou 45 s)→ **Dragonfire** ─(vida < 50%)→ **Undying Wrath** ─(vida < 22% ou enrage)→ **Calamity** (+40 de velocidade, final)
- **Enrage:** depois de 7-8 minutos de vida vai para **Calamity** e fica nela.

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Azhrakar Bone Aegis` | escudo (sem dano) + guardas: Dragon Lord×2, Dragon×3, Hydra×1 · enquanto vivos, cada add cura o boss 0,4% por segundo, por 24 s | 1 s | — | Bone Aegis (ao entrar) | Matar os guardas para quebrar o escudo. Matar os adds depressa: eles curam o boss. |
| `Azhrakar Calamity` | arena de raio 10 inteira marcada, exceto 3 quadrados 3x3 verdes, golpe 2,8 s depois — morte 480-680 · → 3,1 s depois: cone de 10 sqm na direção do alvo, golpe 1,5 s depois — fogo 320-460 + pilha «Scorched» (+70 por pilha, máx. 5, 20 s) | 26 s | — | Calamity | Entrar num quadrado verde antes do golpe. Sair da direção do cone. |
| `Azhrakar Doom Breath` | cone de 10 sqm na direção do alvo, golpe 1,5 s depois — fogo 280-420 + pilha «Scorched» (+70 por pilha, máx. 5, 20 s) · **Rage:** lados 1→2, acrescenta → 2 s depois: cone de 10 sqm na direção do alvo, golpe 1,5 s depois — fogo 280-420 + pilha «Scorched» (+70 por pilha, máx. 5, 20 s) | 7 s | 10 | Descent, Bone Aegis, Dragonfire, Undying Wrath, Calamity | Sair da direção do cone. |
| `Azhrakar Doom Orbs` | 2× Doomfire Orb com contagem de 9 s: explodem (raio 4) e curam o boss 4% cada — fogo 450-600 · **Rage:** quantidade 2→3 | 24 s | — | Dragonfire, Undying Wrath, Calamity | Matar as bombas antes de zerar a contagem. |
| `Azhrakar Dread Brood` | invoca Dragon Hatchling×4, Dragon Lord×1 (máx. 8 summons) · enquanto vivos, cada add cura o boss 0,5% por segundo, por 14 s | 22 s | — | Descent, Dragonfire | Matar os adds. Matar os adds depressa: eles curam o boss. |
| `Azhrakar Ember Rain` | 7 marcas 3x3 em jogadores sorteados (uma a cada 0,30 s), golpe 1,7 s depois — fogo 200-300 + poças por 6 s (70-110 por segundo) · **Rage:** quantidade 7→9 | 10 s | — | Descent, Bone Aegis, Dragonfire, Undying Wrath, Calamity | Sair da marca antes do golpe; com poças, não voltar. |
| `Azhrakar Soul Rend` | jogadores vermelhos e azuis e 2 zonas (raio 2): em 6 s cada um tem de estar na zona da sua cor — morte 420-560 + dano contínuo morte 50×5 | 20 s | — | Descent, Dragonfire, Undying Wrath, Calamity | Cada um vai para a zona da sua cor. |
| `Azhrakar Tail Lash` | disco de raio 3 em volta do boss, golpe 1,1 s depois — físico 260-380 | 8 s | 3 | Descent, Dragonfire, Undying Wrath, Calamity | Ficar no quadrado seguro ou sair do disco. |
| `Azhrakar Wing Gale` | 5 ondas (anéis de 2 sqm) saindo do boss, uma a cada 0,55 s, golpe 1,2 s depois — morte 230-350 · **Final:** ordem do boss para fora→de fora para dentro | 12 s | — | Descent, Bone Aegis, Dragonfire, Undying Wrath, Calamity | Passar para o anel que já acertou. |

## Tier V

Definições em `398-bosses-tier5.lua`.

### Archfiend Zulkarath — Demonic Rift

- **Vida / Exp / Velocidade:** 200.000 / 30.000 / 250 (monsterId 769)
- **Fases:** **Rift** ─(vida < 85%)→ **Infernal Gate** (escudo) ─(guardas mortos ou 45 s)→ **Hellfire** ─(vida < 62%)→ **Soulstorm** ─(vida < 38%)→ **Abyss** (+30 de velocidade) ─(vida < 16% ou enrage)→ **Armageddon** (+40 de velocidade, final)
- **Enrage:** depois de 7-8 minutos de vida vai para **Armageddon** e fica nela.

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Zulkarath Infernal Gate` | escudo (sem dano) + guardas: Hellspawn×3, Dark Torturer×2, Hellhound×2 · enquanto vivos, cada add cura o boss 0,4% por segundo, por 28 s | 1 s | — | Infernal Gate (ao entrar) | Matar os guardas para quebrar o escudo. Matar os adds depressa: eles curam o boss. |
| `Zulkarath Abyssal Gravity` | arrasta todos os jogadores para o anel de raio 7 em volta do boss · → 1,6 s depois: arrasta todos os jogadores para o anel de raio 2 em volta do boss; → 0,4 s depois: disco de raio 5 em volta do boss, golpe 1,8 s depois — fogo 600-850 | 26 s | — | Soulstorm, Abyss, Armageddon | Sair do círculo logo depois de ser puxado. Ficar no quadrado seguro ou sair do disco. |
| `Zulkarath Annihilation` | checagem de DPS: tirar 4% da vida do boss em 10 s ou todos levam 1500-2000 [fogo] | 50 s | — | Hellfire, Soulstorm, Abyss, Armageddon | Grupo inteiro no boss: tirar a % de vida antes do fim. |
| `Zulkarath Armageddon` | arena de raio 11 inteira marcada, exceto 3 quadrados 3x3 verdes, golpe 2,8 s depois — fogo 800-1100 · → 3,1 s depois: arena de raio 11 em 8 fatias; 4 acertam, golpe 1,6 s depois; depois as 4 fatias seguras acertam 1,4 s depois — fogo 600-850 · → 7,2 s depois: 4 perseguidores andam 8 sqm atrás de jogadores e explodem (raio 1) — fogo 450-650 | 32 s | — | Armageddon | Entrar num quadrado verde antes do golpe. Cruzar a arena entre o 1º e o 2º golpe. Levar a marca para longe do grupo. |
| `Zulkarath Brimstone Rain` | 9 marcas círculo raio 2 em jogadores sorteados (uma a cada 0,30 s), golpe 1,8 s depois — fogo 380-560 + poças por 8 s (120-180 por segundo) · **Rage:** quantidade 9→11 | 10 s | — | Rift, Infernal Gate, Hellfire, Soulstorm, Abyss, Armageddon | Sair da marca antes do golpe; com poças, não voltar. |
| `Zulkarath Chains of Torment` | liga 2 par(es) de jogadores por 5,5 s: têm de ficar separados (≥ 6 sqm) — fogo 600-850 | 20 s | — | Rift, Hellfire, Soulstorm | Manter distância do par. |
| `Zulkarath Damnation` | marca 3 jogador(es): em 5,5 s têm de estar num dos 3 quadrados verdes — fogo 650-900 + dano contínuo fogo 90×6 · **Rage:** quantidade 3→4 | 19 s | — | Rift, Hellfire, Soulstorm, Abyss | Os marcados vão ao quadrado verde. |
| `Zulkarath Demonic Pact` | jogadores vermelhos e azuis e 2 zonas (raio 2): em 6 s cada um tem de estar na zona da sua cor — fogo 700-950 + dano contínuo fogo 80×5 | 24 s | — | Hellfire, Soulstorm, Abyss | Cada um vai para a zona da sua cor. |
| `Zulkarath Flame Seekers` | 3 perseguidores andam 8 sqm atrás de jogadores e explodem (raio 1) — fogo 450-650 + pilha «Hellburn» (+100 por pilha, máx. 5, 20 s) · **Rage:** quantidade 3→4 | 14 s | — | Rift, Hellfire, Soulstorm, Abyss, Armageddon | Levar a marca para longe do grupo. |
| `Zulkarath Hellfire Breath` | cone de 11 sqm na direção do alvo, golpe 1,5 s depois — fogo 450-650 + pilha «Hellburn» (+100 por pilha, máx. 5, 20 s) · **Rage:** lados 1→2, acrescenta → 2 s depois: cone de 11 sqm na direção do alvo, golpe 1,5 s depois — fogo 450-650 + pilha «Hellburn» (+100 por pilha, máx. 5, 20 s) | 7 s | 11 | Rift, Infernal Gate, Hellfire, Abyss | Sair da direção do cone. |
| `Zulkarath Hellfire Idols` | 3× Hellfire Idol com contagem de 10 s: explodem (raio 5) e curam o boss 5% cada — fogo 700-950 · **Rage:** quantidade 3→4 | 28 s | — | Hellfire, Soulstorm, Abyss, Armageddon | Matar as bombas antes de zerar a contagem. |
| `Zulkarath Rift Beams` | 4 raio(s) de largura 3 e 11 sqm girando 12 passos (um a cada 0,42 s) — fogo 400-580 | 12 s | — | Rift, Infernal Gate, Hellfire, Soulstorm, Abyss, Armageddon | Acompanhar o giro, fora do raio. |
| `Zulkarath Rift Sectors` | arena de raio 10 em 8 fatias; 4 acertam, golpe 1,8 s depois; depois as 4 fatias seguras acertam 1,6 s depois — fogo 500-700 | 16 s | — | Rift, Hellfire, Soulstorm, Abyss, Armageddon | Cruzar a arena entre o 1º e o 2º golpe. |

### Deathwyrm Nekhrazul — Wrath of the Dead Dragons

- **Vida / Exp / Velocidade:** 200.000 / 30.000 / 240 (monsterId 770)
- **Fases:** **Awakening** ─(vida < 85%)→ **Bone Citadel** (escudo) ─(guardas mortos ou 45 s)→ **Deathstorm** ─(vida < 62%)→ **Soulfeast** ─(vida < 38%)→ **Tomb of Ages** (+30 de velocidade) ─(vida < 16% ou enrage)→ **Final Requiem** (+40 de velocidade, final)
- **Enrage:** depois de 7-8 minutos de vida vai para **Final Requiem** e fica nela.

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Nekhrazul Bone Citadel` | escudo (sem dano) + guardas: Demon Skeleton×4, Defiler×2, Destroyer×1 · enquanto vivos, cada add cura o boss 0,4% por segundo, por 28 s | 1 s | — | Bone Citadel (ao entrar) | Matar os guardas para quebrar o escudo. Matar os adds depressa: eles curam o boss. |
| `Nekhrazul Bone Rain` | 10 marcas 3x3 em jogadores sorteados (uma a cada 0,28 s), golpe 1,7 s depois — morte 380-560 + poças por 8 s (100-150 por segundo) · **Rage:** quantidade 10→12 | 10 s | — | Awakening, Bone Citadel, Deathstorm, Soulfeast, Tomb of Ages, Final Requiem | Sair da marca antes do golpe; com poças, não voltar. |
| `Nekhrazul Death Knell` | checagem de DPS: tirar 4% da vida do boss em 10 s ou todos levam 1500-2000 [morte] | 50 s | — | Deathstorm, Soulfeast, Tomb of Ages, Final Requiem | Grupo inteiro no boss: tirar a % de vida antes do fim. |
| `Nekhrazul Final Requiem` | arena de raio 11 inteira marcada, exceto 3 quadrados 3x3 verdes, golpe 2,8 s depois — morte 800-1100 · → 3,1 s depois: arena de raio 11 em 6 fatias; 3 acertam, golpe 1,6 s depois; depois as 3 fatias seguras acertam 1,4 s depois — morte 600-850 · → 7,2 s depois: 2 marcado(s) (raio 2): 2600 de dano dividido entre quem estiver dentro (máx. 1000 cada), golpe 1 s depois [morte] | 32 s | — | Final Requiem | Entrar num quadrado verde antes do golpe. Cruzar a arena entre o 1º e o 2º golpe. Todos correm para o marcado e dividem o dano. |
| `Nekhrazul Grave Breath` | cone de 12 sqm na direção do alvo, golpe 1,5 s depois — morte 450-650 + pilha «Withering» (+100 por pilha, máx. 5, 20 s) · **Rage:** lados 1→2, acrescenta → 2 s depois: cone de 12 sqm na direção do alvo, golpe 1,5 s depois — morte 450-650 + pilha «Withering» (+100 por pilha, máx. 5, 20 s) | 7 s | 12 | Awakening, Bone Citadel, Deathstorm, Tomb of Ages | Sair da direção do cone. |
| `Nekhrazul Marked for Death` | marca 3 jogador(es): em 5,5 s têm de estar num dos 3 quadrados verdes — morte 650-900 + dano contínuo morte 90×6 · **Rage:** quantidade 3→4 | 19 s | — | Awakening, Deathstorm, Soulfeast, Tomb of Ages | Os marcados vão ao quadrado verde. |
| `Nekhrazul Soul Chains` | liga 2 par(es) de jogadores por 5,5 s: têm de ficar juntos (≤ 3 sqm) — morte 600-850 | 20 s | — | Awakening, Deathstorm, Soulfeast | Ficar perto do par. |
| `Nekhrazul Soul Phylacteries` | 3× Soulbound Skull com contagem de 10 s: explodem (raio 5) e curam o boss 5% cada — morte 700-950 · **Rage:** quantidade 3→4 | 28 s | — | Deathstorm, Soulfeast, Tomb of Ages, Final Requiem | Matar as bombas antes de zerar a contagem. |
| `Nekhrazul Tomb Gravity` | arrasta todos os jogadores para o anel de raio 7 em volta do boss · → 1,6 s depois: arrasta todos os jogadores para o anel de raio 2 em volta do boss; → 0,4 s depois: disco de raio 5 em volta do boss, golpe 1,8 s depois — morte 600-850 | 26 s | — | Soulfeast, Tomb of Ages, Final Requiem | Sair do círculo logo depois de ser puxado. Ficar no quadrado seguro ou sair do disco. |
| `Nekhrazul Tomb Sectors` | arena de raio 11 em 6 fatias; 3 acertam, golpe 1,8 s depois; depois as 3 fatias seguras acertam 1,6 s depois — morte 520-720 | 16 s | — | Awakening, Deathstorm, Soulfeast, Tomb of Ages, Final Requiem | Cruzar a arena entre o 1º e o 2º golpe. |
| `Nekhrazul Twin Souls` | jogadores vermelhos e azuis e 2 zonas (raio 2): em 6 s cada um tem de estar na zona da sua cor — morte 700-950 + dano contínuo morte 80×5 | 24 s | — | Deathstorm, Soulfeast, Tomb of Ages | Cada um vai para a zona da sua cor. |
| `Nekhrazul Wing Storm` | 6 ondas (anéis de 2 sqm) saindo do boss, uma a cada 0,50 s, golpe 1,2 s depois — morte 400-580 · **Final:** ordem do boss para fora→de fora para dentro | 13 s | — | Awakening, Bone Citadel, Deathstorm, Soulfeast, Tomb of Ages, Final Requiem | Passar para o anel que já acertou. |
| `Nekhrazul Wraith Seekers` | 3 perseguidores andam 8 sqm atrás de jogadores e explodem (raio 1) — morte 450-650 + pilha «Withering» (+100 por pilha, máx. 5, 20 s) · **Rage:** quantidade 3→4 | 14 s | — | Awakening, Deathstorm, Soulfeast, Tomb of Ages, Final Requiem | Levar a marca para longe do grupo. |

### Hellforged Overlord Malgorath — Hell's Legion

- **Vida / Exp / Velocidade:** 220.000 / 32.000 / 250 (monsterId 771)
- **Fases:** **Muster** ─(vida < 85%)→ **Legion Barrier** (escudo) ─(guardas mortos ou 45 s)→ **Siege** ─(vida < 62%)→ **Conquest** ─(vida < 38%)→ **Overrun** (+30 de velocidade) ─(vida < 16% ou enrage)→ **Final Verdict** (+40 de velocidade, final)
- **Enrage:** depois de 7-8 minutos de vida vai para **Final Verdict** e fica nela.

| Magia | O que faz | Cd | Alc. | Fases | Como lidar |
|---|---|---|---|---|---|
| `Malgorath Legion Barrier` | escudo (sem dano) + guardas: Hellfire Fighter×3, Infernalist×2, Grim Reaper×1 · enquanto vivos, cada add cura o boss 0,4% por segundo, por 28 s | 1 s | — | Legion Barrier (ao entrar) | Matar os guardas para quebrar o escudo. Matar os adds depressa: eles curam o boss. |
| `Malgorath Arc Chain` | raio em cadeia: 8 saltos até 5 sqm, um a cada 0,60 s — energia 400-580 · **Rage:** saltos 8→10 | 11 s | — | Legion Barrier, Siege, Overrun | Manter distância entre os jogadores (o raio pula para o mais próximo). |
| `Malgorath Binding Sigils` | liga 2 par(es) de jogadores por 5,5 s: têm de ficar separados (≥ 7 sqm) — energia 600-850 | 20 s | — | Muster, Siege, Conquest | Manter distância do par. |
| `Malgorath Doom Rain` | 9 marcas círculo raio 2 em jogadores sorteados (uma a cada 0,30 s), golpe 1,8 s depois — energia 380-560 + poças por 8 s (120-180 por segundo) · **Rage:** quantidade 9→11 | 10 s | — | Muster, Legion Barrier, Siege, Conquest, Final Verdict | Sair da marca antes do golpe; com poças, não voltar. |
| `Malgorath Dual Allegiance` | jogadores vermelhos e azuis e 2 zonas (raio 2): em 6 s cada um tem de estar na zona da sua cor — energia 700-950 + dano contínuo energia 80×5 | 24 s | — | Siege, Conquest, Overrun | Cada um vai para a zona da sua cor. |
| `Malgorath Final Verdict` | arena de raio 11 inteira marcada, exceto 3 quadrados 3x3 verdes, golpe 2,8 s depois — energia 800-1100 · → 3,1 s depois: raio em cadeia: 8 saltos até 5 sqm, um a cada 0,60 s — energia 450-650 · → 8,2 s depois: arena de raio 12 em 12 fatias; 6 acertam, golpe 1,6 s depois; depois as 6 fatias seguras acertam 1,4 s depois — energia 600-850 | 34 s | — | Final Verdict | Entrar num quadrado verde antes do golpe. Manter distância entre os jogadores (o raio pula para o mais próximo). Cruzar a arena entre o 1º e o 2º golpe. |
| `Malgorath Hellforged Cores` | 3× Hellforged Core com contagem de 10 s: explodem (raio 5) e curam o boss 5% cada — energia 700-950 · **Rage:** quantidade 3→4 | 28 s | — | Siege, Conquest, Overrun, Final Verdict | Matar as bombas antes de zerar a contagem. |
| `Malgorath Hellstorm Volley` | 5 faixas paralelas de 12 sqm na direção do alvo (vãos de 1 sqm), golpe 1,5 s depois — energia 450-650 + pilha «Overcharged» (+100 por pilha, máx. 5, 20 s) · → 1,7 s depois: 6 faixas paralelas de 12 sqm na direção do alvo (vãos de 1 sqm), golpe 1,4 s depois — energia 450-650 + pilha «Overcharged» (+100 por pilha, máx. 5, 20 s) | 9 s | 12 | Muster, Siege, Overrun | Ficar nos vãos entre as faixas (numa 2ª grade os vãos mudam). |
| `Malgorath Hunter Drones` | 3 perseguidores andam 8 sqm atrás de jogadores e explodem (raio 1) — energia 450-650 + pilha «Overcharged» (+100 por pilha, máx. 5, 20 s) · **Rage:** quantidade 3→4 | 14 s | — | Muster, Siege, Conquest, Overrun, Final Verdict | Levar a marca para longe do grupo. |
| `Malgorath Judgement` | checagem de DPS: tirar 4% da vida do boss em 10 s ou todos levam 1500-2000 [energia] | 50 s | — | Siege, Conquest, Overrun, Final Verdict | Grupo inteiro no boss: tirar a % de vida antes do fim. |
| `Malgorath Legion Beams` | 2 raio(s) de largura 3 e 12 sqm girando 12 passos (um a cada 0,42 s) — energia 400-580 | 12 s | — | Muster, Legion Barrier, Conquest, Overrun, Final Verdict | Acompanhar o giro, fora do raio. |
| `Malgorath Mark of the Legion` | marca 3 jogador(es): em 5,5 s têm de estar num dos 3 quadrados verdes — energia 650-900 + dano contínuo energia 90×6 · **Rage:** quantidade 3→4 | 19 s | — | Muster, Siege, Conquest, Overrun | Os marcados vão ao quadrado verde. |
| `Malgorath Phalanx Sectors` | arena de raio 12 em 12 fatias; 6 acertam, golpe 1,8 s depois; depois as 6 fatias seguras acertam 1,6 s depois — energia 500-700 | 16 s | — | Muster, Siege, Conquest, Overrun, Final Verdict | Cruzar a arena entre o 1º e o 2º golpe. |
| `Malgorath Siege Gravity` | arrasta todos os jogadores para o anel de raio 7 em volta do boss · → 1,6 s depois: arrasta todos os jogadores para o anel de raio 2 em volta do boss; → 0,4 s depois: disco de raio 5 em volta do boss, golpe 1,8 s depois — energia 600-850 | 26 s | — | Conquest, Overrun, Final Verdict | Sair do círculo logo depois de ser puxado. Ficar no quadrado seguro ou sair do disco. |

## Mecânicas (referência rápida)

| Mecânica | Resumo |
|---|---|
| `rain` | marcas que caem sobre jogadores |
| `cone / lanes` | cone ou faixas na direção do alvo |
| `nova` | disco em volta do boss (com quadrado seguro opcional) |
| `waves` | anéis que se expandem (ou contraem) |
| `arms` | linhas em etapas |
| `stripes` | faixas com corredor |
| `bait` | marca que segue e trava |
| `chain` | raio que pula entre jogadores |
| `leap` | salto no alvo |
| `safeSpots` | arena marcada exceto quadrados verdes |
| `tether` | pares ligados: juntos ou separados |
| `stack` | dano para ser dividido |
| `cleanse` | marcados vão ao quadrado verde |
| `field` | perigo que fica por segundos |
| `beam` | raios que giram |
| `siphon` | adds curam o boss |
| `pull` | arrasta para perto do boss |
| `polarity` | duas cores, duas zonas |
| `bombs` | bombas com contagem |
| `sectors` | fatias da arena que acertam duas vezes |
| `seeker` | marcas que perseguem |
| `channel` | checagem de DPS |
| `stack / linger / dot / slow (opções)` | pilhas de debuff, poças, dano contínuo e lentidão |

Este catálogo foi gerado a partir do código e não se atualiza sozinho: depois de mudar bosses, danos ou cooldowns, regenere o arquivo ou edite à mão. A fonte da verdade são os arquivos `data/lib/393` a `398`.
