# Vocação Necromancer (e promoção Lich)

## O que é
Vocação de mago invocador: levanta mortos-vivos a partir de **corpos** e **souls**, luta ao lado deles e usa magias de **death** e **poison**. Os summons têm ataques próprios que crescem com o nível e o magic level do necromante.

| Id | Nome | Premium | Promoção de |
|---|---|---|---|
| 11 | Necromancer | não | |
| 12 | Lich | sim | Necromancer (`fromvoc="11"`); também usa todas as magias do Necromancer |

Definidas em `data/XML/vocations.xml` (vida 6, mana 28, cap 10 por nível, mana multiplier 1.1). `soulmax` 60 (Lich 100) e `gainsoulticks` enorme: **não existe regen natural de soul**, ele só vem da passiva. `isNecromancer(cid)` em `data/lib/031-vocations.lua` vale para as duas. O personagem começa no nível 8 e já tem Summon Skeleton e Death Touch. Os níveis das magias vão de 8 a 54, com no máximo 8 níveis entre uma magia e a próxima (o XP do servidor é baixo). O Dragon Skeleton, na prática, só fica disponível com ML 50 (precisa de 4 summons).

## Fórmulas
- **Poder do necromante:** `P = nível/5 + ML*1.4`. Todo dano é `P × fator`. Em nível 100 / ML 60, P = 104; em nível 200 / ML 100, P = 180.
- **Limite de summons:** `2 + 1 a cada 25 de ML`, máximo 6 (`Necro.summonCap`).
- **Veneno (DoT padrão):** 10s, 1 tick por segundo, dano por tick = `nível/15 + ML/3` (`Necro.poisonTick`).
- Os números ficam em `data/lib/373-necromancer.lua` e no topo de cada script.

## Invocar
Cada Summon exige um **corpo** de monstro a até 3 SQM (o corpo é consumido e o summon nasce nele), **6 soul**, mana, e um slot livre. Não dá para invocar enquanto o Dragon Skeleton estiver ativo.

| Magia | Palavras | Lvl | Mana | Cd | Papel |
|---|---|---|---|---|---|
| Summon Skeleton | `exevo res necro` | 8 | 60 | 2s | Guerreiro |
| Summon Ghoul | `exevo res ghoul` | 18 | 100 | 2s | Tank |
| Summon Banshee | `exevo res banshee` | 26 | 160 | 2s | Ranged |
| Summon Phantasm | `exevo res phantasm` | 35 | 250 | 2s | Mago |
| Summon Dragon Skeleton | `exevo gran res necro` | 54 | 600 | 120s | Ultimate |

### Estatísticas dos summons (vida = `base + nível*a + ML*b`)
| Summon | Vida | Velocidade | Resistências | Ataques (`P × fator`, cooldown) |
|---|---|---|---|---|
| Necro Skeleton | 300 + 4L + 10M | 180 + ML (máx 300) | físico 10% | Bone Slash, físico melee 0.8 a 1.6 (2s) |
| Necro Ghoul | 500 + 6L + 15M | 160 + ML*0.7 | físico 30%, fogo -10%, holy -20% | Claw físico 0.3 a 0.6 (2s); Taunt (desafia monstros em 1 SQM, 8s); Mend (cura 8% da vida dele, 6s) |
| Necro Banshee | 200 + 2L + 5M | 200 + ML | físico 10% | Wail, death à distância (range 5) 0.7 a 1.3 (2s) |
| Necro Phantasm | 250 + 3L + 6M | 220 + ML | físico 20% | Haunt, área 3x3 no alvo, death ou poison sorteado 0.6 a 1.1 (3s) |
| Necro Dragon Skeleton | 2500 + 25L + 30M (+20% por summon consumido além de 4) | 200 | físico 25%, imune a death/poison/paralyze | Bone Crush físico 2.0 a 3.5 (2s); Front Sweep físico 1.2 a 2.0 (4s); Death Wave 1.5 a 2.5 (6s); Grave Burst, anel de death 1.0 a 1.8 (10s) |

Os summons não dão XP nem loot próprio. Os monstros estão em `data/monster/Necro Summons/` e os ataques em `data/spells/scripts/necromancer/summon/`.

### Dragon Skeleton
- Precisa de **4 ou mais** summons (sem contar outro Dragon) e **consome todos**; não gasta soul nem corpo. Nasce na frente do necromante.
- **Não cura** e perde **1,5% da vida máxima por segundo** (cerca de 66s se ninguém o ferir). Quando a vida acaba, ele morre.
- Não pode ser consumido pelo Soul Sacrifice e pelo Bone Shell, não é curado pelo Bone Mend e, enquanto ele existir, nenhum summon novo pode ser invocado.

## Ataques
| Magia | Palavras | Lvl | Mana | Cd | Efeito |
|---|---|---|---|---|---|
| Death Touch | `exori necro` | 8 | 15 | 2s | Death em 1 alvo (range 4), P × 0.7 a 1.3 |
| Venom Touch | `exori pox` | 12 | 25 | 2s | Poison em 1 alvo, P × 0.4 a 0.8, e envenena (DoT padrão) |
| Dark Orb | `exevo gran necro` | 20 | 90 | 2s | Bola de death 3x3 no alvo, P × 1.0 a 1.8. Animação só com o `VFX.Explosion` (2 anéis de tiros de death) |
| Venom Orb | `exevo gran pox` | 20 | 90 | 2s | Bola de poison 3x3 no alvo, P × 0.8 a 1.4, e envenena. Animação só com o `VFX.Explosion` (2 anéis de tiros de poison) |
| Death Wave | `exevo necro hur` | 28 | 110 | 2s | Wave de death (formato do Vis Hur), P × 1.2 a 2.0 |
| Venom Wave | `exevo pox hur` | 28 | 110 | 2s | Wave de poison, P × 1.0 a 1.7, e envenena |
| Rain of Poison | `exevo gran mas pox` | 40 | 250 | 20s | Chuva de veneno caindo no alvo (animação `VFX.Rain`, sempre caindo na diagonal) sobre uma zona 5x5 fixa por 5s (1 pulso/s), P × 0.5 a 0.9 por pulso; o dano não desenha efeito próprio. Dá o buff **Venom Corrosion** (+25% de penetração de poison por 10s) |
| Death Tornado | `exevo gran mas necro` | 46 | 400 | 25s | Ultimate: disco cheio de death com 5 SQM de raio em volta do necromante (sem buraco), varrido tile a tile em 1,3s via `RingAttack`, com a animação de cada tile sorteada entre 2 efeitos (`MORTAREA` e `YALAHARIGHOST`, o fantasma), P × 1.2 a 2.0 por tile. Não prende |

**Poison é `COMBAT_EARTHDAMAGE`** (o mesmo elemento da condition de veneno).

## Magias exclusivas do Lich (vocação 12)
Todas premium. Spell ids 174 a 177. Níveis de 58 a 70, no máximo 6 níveis entre elas.

| Magia | Palavras | Lvl | Mana | Cd | Efeito |
|---|---|---|---|---|---|
| Soul Siphon | `exori gran necro` | 58 | 220 | 3s | Death em 1 alvo (range 4), P × 2.0 a 3.0. **Cura o necromante em 40% do dano** e os summons (menos o Dragon) em 10%. Se o alvo (monstro) morrer por ela, **+1 soul** |
| Summon Bone Abomination | `exevo gran res abom` | 62 | 400 | 2s | Invoca uma Bone Abomination: summon lento e muito resistente (vida `1000 + 12L + 30M`, velocidade `130 + ML*0.5`, máx 220) que acerta fisicamente tudo em volta (3x3, P × 1.0 a 1.8, 2s), desafia os monstros próximos (taunt, 10s) e **explode em death 5x5 ao morrer** (P × 2.0 a 3.5, vale o Unholy Frenzy). Custa corpo, 6 soul e 1 slot. Não explode se for consumida (Dragon, Soul Sacrifice, Bone Shell) |
| Corpse Explosion | `exevo mas necro` | 66 | 350 | 8s | Consome um corpo a até 4 SQM (com alvo, o mais próximo dele) e explode numa área 5x5 com death e poison, P × 2.5 a 4.0 no total (metade de cada) |
| Army of the Dead | `exevo mas res necro` | 70 | 600 | 60s | Levanta 3 Bone Soldiers por 20s a partir de um corpo (vida `150 + 2L + 5M`, golpe físico P × 0.5 a 1.0 a cada 2s). **Não ocupam slot** e não são consumidos pelos buffs 3 e 4 nem pelo Dragon. Custa 12 soul. Não funciona com o Dragon Skeleton ativo |

## Buffs e suporte
| Magia | Palavras | Lvl | Mana | Cd | Efeito |
|---|---|---|---|---|---|
| Bone Armor | `utamo necro` | 16 | 60 | 20s | +25% de resistência a físico nos summons por 20s |
| Unholy Frenzy | `utito necro` | 23 | 80 | 25s | +30% de dano em todos os summons por 20s |
| Soul Sacrifice | `utito mort necro` | 31 | 60 | 20s | Consome o summon de menor vida: +40% de dano death/poison por 15s e **devolve 3 soul** |
| Bone Shell | `utamo gran necro` | 31 | 60 | 20s | Consome o summon de menor vida: +14 armor e +10 defense por 15s e **devolve 3 soul** |
| Bone Mend | `exura necro` | 14 | 60 | 4s | Cura os summons em 7 SQM (P × 2.0 a 3.5), exceto o Dragon Skeleton |
| Recall | `utevo necro` | 11 | 40 | 6s | Teleporta todos os summons para perto do necromante |

Bone Armor aplica a resistência só nos summons que existem na hora (um summon invocado depois não recebe). Unholy Frenzy vale para todos, porque os ataques consultam o buff no dono a cada golpe.

## Passiva: Soul Harvest
Quando um monstro morre por ação do necromante **ou de um summon dele**, há chance de a alma ser absorvida: `20% + 0,25% por ML` (máximo 50%). Ganha **1 soul** (2 se o monstro dá 1000 de XP ou mais). Não vale para summons, players e nem dentro de PZ. Está no evento `SoulHarvest` (`data/creaturescripts/scripts/soulharvest.lua`) e em `Necro.harvest`.

## Buffs (`Necro.buffs` em `data/lib/373-necromancer.lua`)
| Categoria | Duração | Sub id |
|---|---|---|
| Bone Armor / Unholy Frenzy | 20s | (sem condition) |
| Soul Sacrifice | 15s | 8332 |
| Bone Shell | 15s | 8333 |
| Venom Corrosion | 10s | 8334 |

Aparecem em `!buffs`. Ver [23-buffs.md](23-buffs.md).

## Mudanças na source (valem para todas as vocações)
- **XP:** o dano que o summon de um player causa em **monstros** é creditado ao dono. O summon não tira XP do dono nem recebe XP, mesmo que cause todo o dano (`Monster::onAttackedCreatureDrain`). Os eventos `kill` do dono disparam normalmente.
- **PvP:** summons de players causam só **50%** do dano em players e em summons de players. Configurável em `config.lua`: `summonPvpDamagePercent` (100 = sem redução). Em `Game::combatChangeHealth`.
- **PZ:** summons de players podem entrar em protection zone (`Tile::__queryAdd`). Monstros comuns continuam sem entrar.
- **Penetração:** o summon usa a penetração elemental do dono (`Monster::blockHit`), então o Venom Corrosion do Rain of Poison também vale para o dano dos summons.
- **Dono e summons não se ferem:** `Combat::canDoCombat` bloqueia dano entre o dono e os summons dele, e entre summons do mesmo dono. Antes, em Open PvP, as magias de área do necromante (Death Wave, Tornado...) e os ataques de área dos summons podiam acertar os próprios summons ou o dono.
- **Resistência temporária em monstros:** nova função Lua `doMonsterSetElementMod(cid, combatType, percent)` (usada pelo Bone Armor; 0 remove).

## Arquivos
- `data/lib/373-necromancer.lua`: tabela `Necro` (fórmulas, summons, buffs, passiva). `data/lib/069-ringattack.lua`: `RingAttack` (portado do servidor antigo).
- `data/creaturescripts/scripts/necroabomination.lua` (explosão da Bone Abomination).
- `data/spells/scripts/necromancer/` (magias do jogador) e `necromancer/summon/` (ataques dos summons).
- `data/spells/spells.xml`: spell ids 155 a 173 (Necromancer) e 174 a 177 (Lich). `data/monster/Necro Summons/` e `data/monster/monsters.xml`.

## Glifos
As 23 magias do Necromancer (e do Lich) têm 2 glifos cada (A e B), com focos diferentes: dano, controle, sustain, economia de soul, defesa. A tabela de efeitos está em [42-glifos.md](42-glifos.md). O NPC mestre é **Morwen Gravebinder** (ainda sem posição no mapa). O glifo de uma invocação vale para o summon que ela levanta: os ataques dos summons consultam o glifo do dono (`Necro.ownerGlyph`).

## Limitações
- Não há Command Target (summons atacam sozinhos).
- O limite de 6 summons conta qualquer summon do jogador, não só os do necromante.
- O Dragon Skeleton usa o efeito do `RingAttack` e não efeitos da lib de VFX.
- Para criar um personagem Necromancer, mude `vocation` do jogador para 11 no banco ou pelo comando de GM. Rode `!vocation Necromancer` para ver o resumo.
