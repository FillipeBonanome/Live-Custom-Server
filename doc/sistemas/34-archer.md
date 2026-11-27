# Vocação Archer (e promoção Ranger)

## O que é
Arqueiro elemental. Por padrão atira flechas **físicas**; pode escolher um **encantamento** (fogo, veneno, gelo ou raio) e **todas as magias mudam de elemento e de efeito** conforme ele: queimadura, stacks de veneno, geada que congela, choque que salta entre inimigos e **reações elementais** quando se troca de elemento no meio da luta. Frágil de perto, ganha pelo posicionamento (recuar, prender, controlar).

| Id | Nome | Premium | Promoção de |
|---|---|---|---|
| 17 | Archer | não | |
| 18 | Ranger | sim | Archer (`fromvoc="17"`); também usa todas as magias do Archer |

Definidas em `data/XML/vocations.xml`. `isArcher(cid)` em `data/lib/031-vocations.lua` vale para as duas.

## Atributos
| | Archer | Ranger | Paladin (comparação) |
|---|---|---|---|
| Vida por level | 8 | 8 | 10 |
| Mana por level | 20 | 20 | 15 |
| Cap por level | 18 | 18 | 20 |
| Regen de vida / mana | 4 / 6 | 7 / 10 | 4 / 5 |
| Mana multiplier | 1.4 | 1.4 | 1.4 |
| Fórmula de defesa e armor | 0.8 | 0.8 | 1.0 |
| Soul máximo | 100 | 200 | |
| Perda na morte | normal | -30% | |

Skills (multiplicador, quanto maior mais lento treinar): **distance 1.1**, fist 1.5, fishing 1.1; club, sword, axe e shielding 4.0.

## Restrições
- **Arma equipada:** as magias de ataque têm `needweapon="1"` no `spells.xml` (precisam de uma arma equipada). O poder (`P`) soma o ataque da arma de distância na mão e da flecha na munição. Os arcos premium registrados em `data/weapons/weapons.xml` (Silkweaver, Composite Hornbow, Yol's, Elethriel's e Warsinger) ganharam `<vocation id="17"/>` (o 18 entra pela promoção); as bestas continuam só para Paladin e Royal Paladin. Armas corpo a corpo com lista de vocações não incluem o Archer.
- **Potions:** como o Assassin, **não pode** strong, great nem ultimate health potion, nem strong/great mana. Pode usar small health, health, mana e a **great spirit potion** (`data/actions/scripts/liquids/potions.lua`).

## Fórmulas
- **Poder:** `P = distance skill + ataque do arco + ataque da flecha na munição`. Todo dano é `nível/5 + P × fator` (valor aleatório entre mínimo e máximo).
- **Queimadura** (fire): `nível/25 + P × 0.10` por segundo, 4s, renovada a cada acerto de fogo.
- **Veneno** (poison): `(nível/30 + P × 0.05) × stacks` por segundo, 6s; até 5 stacks; os stacks somem quando acaba o tempo.
- **Geada** (ice): -15% de velocidade por stack, até 3, 4s; no 3º stack o alvo **congela por 1,5s** e os stacks zeram.
- **Choque** (energy): 20% de chance (×1 por stack extra) de **saltar** para outro inimigo em até 3 SQM, em linha de visão, com 50% do dano.
- Os números ficam em `data/lib/376-archer.lua` e no topo de cada script em `data/spells/scripts/archer/`.

## Encantamento (passiva principal)
Sem encantamento, **todas as magias causam dano físico** (sem status e sem marca de reação) e usam a animação da flecha comum (`ARROW`). Quatro magias ligam um encantamento (sem custo de mana, 1s de cooldown); **lançar o mesmo encantamento de novo o desliga** e volta para o físico. O ativo fica salvo no storage `54300` e dá o buff permanente **Enchant** (aparece em `!buffs`): **+30% do dano dos ataques básicos** como o elemento. O globalevent `archer` (1 vez por segundo) recoloca o buff depois de login, morte ou reinício.

| Encantamento | Palavras | Elemento | Animação | Status que as magias aplicam |
|---|---|---|---|---|
| Nenhum (padrão) | | physical | `ARROW` | Nenhum |
| Fogo | `utito ignis` | fire | `FLAMMINGARROW` | **Queimadura** |
| Veneno | `utito toxi` | earth | `POISONARROW` | **Veneno** (stacks) |
| Gelo | `utito glacies` | ice | `SHIVERARROW` | **Geada** (congela no 3º stack) |
| Raio | `utito fulmen` | energy | `FLASHARROW` | **Choque** (salta para outro inimigo) |

Só as **magias** aplicam status; o ataque básico ganha o dano elemental, mas não aplica status.

## Reações elementais
Todo acerto de uma magia deixa uma **marca** do elemento no alvo por 6s. Acertar a marca com o elemento que reage a ela consome a marca, dá **+25% de dano** no acerto e dispara um efeito. As reações seguem um ciclo; trocas fora do ciclo só substituem a marca.

| Marca → novo elemento | Reação | Efeito |
|---|---|---|
| Veneno → Fogo | Ignite | Explosão de fire 3x3 (P × 0.5 a 0.8) |
| Fogo → Gelo | Shatter | Burst de ice 3x3 (P × 0.5 a 0.8) e apaga a queimadura |
| Gelo → Raio | Conduct | O alvo recebe +15% de dano do Archer por 5s |
| Raio → Veneno | Corrode | 3 stacks de veneno de uma vez |

Com o **Elemental Avatar** ativo as reações não disparam.

## Magias do Archer (ids 210 a 223)
Todas com `needlearn="0"`, sem premium. As de ataque têm `needweapon="1"`; as de alvo têm `needtarget` e `blockwalls`. Todo dano de magia passa por `Archer.hit`, que **não acerta ninguém em PZ**, nem membros da party, nem summons de amigos.

| Magia | Palavras | Lvl | Mana | Cd | Efeito base |
|---|---|---|---|---|---|
| Enchant Fire / Poison / Ice / Energy | `utito ignis` / `toxi` / `glacies` / `fulmen` | 8 | 0 | 1s | Liga o encantamento (de novo = desliga, volta ao físico) |
| Elemental Shot | `exori sagitta` | 8 | 10 | 1s | 1 alvo (alcance 7), P × 0.7 a 1.1 |
| Piercing Arrow | `exori penetra` | 14 | 35 | 4s | Linha do jogador **através do alvo** (alcance 6) até completar 6 SQM, mesmo que o alvo esteja colado: **atravessa todos** na linha, P × 0.5 a 0.9. O efeito vai no último tile; para em paredes e ignora quem está em PZ |
| Twin Shot | `exori gemina` | 18 | 40 | 2s | 2 flechas em 0,3s, P × 0.5 a 0.8 cada |
| Elemental Trap | `exevo laqueus` | 22 | 55 | 10s | Armadilha 3x3 no alvo (alcance 6) por 6s, P × 0.2 a 0.3 por segundo |
| Disengage | `exani retro` | 26 | 50 | 12s | Salta até 3 SQM para trás e deixa um efeito onde estava, P × 0.4 a 0.6 em 3x3 |
| Verdant Mend | `exura herba` | 20 | 60 | 8s | Cura em você level/5 + P × 1.0 a 1.5 (não precisa de arco). Com o encantamento: fogo = cura 25% maior, veneno = remove condições nocivas, gelo = 10% menos dano de todos os elementos por 4s (buff Frost Mantle, subId 8720), energia = +30% de velocidade por 3s |
| Arrow Fan | `exori mas sagitta` | 30 | 70 | 6s | Cone de 3 de largura e 5 de alcance, P × 0.6 a 1.0 |
| **Rain of Arrows** | `exevo mas sagitta` | 36 | 110 | 9s | **Chuva em área** (5x5) no alvo (alcance 6): 6 acertos em 1,5s, P × 0.3 a 0.45 por acerto. As flechas (40) sempre caem de cima; só o lado de onde vêm muda: esquerda, centro ou direita, conforme a posição do jogador em relação ao alvo (centro se estiver na mesma coluna, com 1 SQM de folga) |
| Elemental Surge | `utito mas elementum` | 40 | 150 | 40s | Buff de 10s: +40% elemental nos ataques básicos, +15 fist (velocidade de ataque), +1 stack em todo status |
| Overcharge Shot | `exori concentra` | 46 | 130 | 10s | Carrega 1,2s e dispara 1 flecha, P × 2.2 a 3.2; se o alvo sumir/morrer/sair da vista, o tiro se perde |
| Convergence | `exori prisma` | 52 | 200 | 20s | Dispara poison, fire, ice e energy em sequência (0,3s), P × 0.7 a 1.1 cada; a ordem dispara as reações em cadeia |

### O que cada elemento muda

| Magia | Fogo | Veneno | Gelo | Raio |
|---|---|---|---|---|
| **Elemental Shot** | Queima | +1 stack | +1 de geada | 20% de saltar |
| **Piercing Arrow** | Rastro de fogo na linha por 3s (P × 0.15 a 0.25 por segundo) | +1 stack em cada | +1 geada em cada | +10% de dano por criatura já atravessada |
| **Twin Shot** | A 2ª flecha explode em 3x3 | A 2ª dá 2 stacks | A 2ª dá 2 de geada | A 2ª vai para outro inimigo perto do alvo |
| **Elemental Trap** | Chão em chamas | Nuvem tóxica (1 stack por segundo) | Prende 2s a quem pisa pela 1ª vez | Atordoa 1s a quem pisa pela 1ª vez |
| **Disengage** | Explosão de fogo onde estava | Nuvem de veneno | Geada nos inimigos em volta | +30% de velocidade por 3s |
| **Arrow Fan** | Queima | 2 stacks | +1 geada | Salto garantido em cada acerto |
| **Rain of Arrows** | Queima a cada acerto | +1 stack a cada 2º acerto | +1 geada a cada 2º acerto | O último acerto causa +40% |
| **Overcharge Shot** | Explode em 5x5 (60% nos outros) | 5 stacks de uma vez | Congela 2s | Atravessa e acerta o de trás com 70% |

## Magias do Ranger (ids 224 a 227)
Todas premium e exclusivas da vocação 18.

| Magia | Palavras | Lvl | Mana | Cd | Efeito |
|---|---|---|---|---|---|
| Arrow Tempest | `exevo gran sagitta` | 58 | 300 | 30s | **Flecha que ricocheteia** (ver abaixo), P × 1.0 a 1.5 |
| Elemental Avatar | `utamo elementum` | 62 | 350 | 60s | 12s: todo ataque e magia causa os 4 elementos (25% do dano cada) e aplica os 4 status; ataques básicos com +25% de cada elemento; sem reações |
| Spirit Falcon | `exevo res falco` | 66 | 400 | 45s | 15s: um falcão ataca a cada 1,5s (P × 0.5 a 0.8) o seu alvo, ou o inimigo mais próximo em 6 SQM, com o elemento do momento. Não é summon (não ocupa slot e não pode ser ferido) |
| Perfect Shot | `exori perfecta` | 70 | 250 | 20s | Alcance 10, P × 4.0 a 5.5, crítico garantido (+30%); ×1,5 se o alvo tiver 3 ou mais status |

### Arrow Tempest (ricochete)
Acerta o alvo (alcance 7) e **ricocheteia** para o inimigo mais próximo em até 4 SQM, até **5 vezes** (6 acertos no total), com 180ms entre cada salto e **-10% de dano por salto** (mínimo 50%). Regras (em `Archer.chain`):
- **Não atravessa paredes:** o salto só acontece se houver linha de visão limpa entre um inimigo e o próximo (`isSightClear`); a magia também tem `blockwalls`.
- **Não ataca ninguém em PZ:** quem está em protection zone é ignorado como candidato e nunca recebe dano. Party e summons de amigos também são ignorados.
- Nunca acerta a mesma criatura duas vezes.
- Cada acerto tem o elemento do encantamento (queimadura, veneno, geada ou salto de choque).

## VFX
Paleta por elemento (vermelho/laranja, verde, azul-claro e amarelo). Perfis registrados com `VFX.register` em `data/lib/376-archer.lua`: `archer_enchant`, `archer_shot`, `archer_pierce`, `archer_rain`, `archer_trap`, `archer_charge`, `archer_reaction`, `archer_surge`, `archer_avatar`, `archer_falcon` e `archer_tempest`. Dá para testá-los com `/vfx <perfil>`; recebem `element` (`fire`, `poison`, `ice`, `energy`) e `from`. As chamadas passam por `Archer.fx`, que nunca interrompe uma magia se uma opção estiver errada.

## Buffs
Sub ids `8700` a `8706` (Enchant Fire, Poison, Ice, Energy, Elemental Surge, Elemental Avatar, Spirit Falcon). Usam `addCreatureBuff` e aparecem em `!buffs`.

## Arquivos
| Arquivo | Função |
|---|---|
| `data/lib/376-archer.lua` | Tabela `Archer`: elementos, poder, alvos válidos, status, reações, `Archer.hit`, zonas, ricochete (`Archer.chain`), buffs e VFX |
| `data/spells/scripts/archer/` | Uma magia por arquivo |
| `data/globalevents/scripts/archer.lua` | Mantém o buff Enchant (1 vez por segundo) |
| `data/XML/vocations.xml`, `data/spells/spells.xml` | Vocações 17 e 18 e as magias 210 a 227 |
| `data/weapons/weapons.xml` | Arcos premium liberados para o Archer |
| `data/actions/scripts/liquids/potions.lua` | Restrição das potions |
| `data/talkactions/scripts/vocation.lua` | Descrição no `!vocation` |

## Observações
- As magias ficam disponíveis pelo nível (sem `needlearn`), do nível 8 em diante.
- A promoção para Ranger usa os NPCs de promoção que já existem (`fromvoc="17"`).
- Os status (queimadura, veneno, geada) usam timers em Lua, não conditions da source; a geada e o congelamento usam `CONDITION_PARALYZE`, então um monstro imune a paralisia não fica lento.
- Nada deste sistema precisa recompilar: reinicie o servidor (vocações, magias, armas e globalevents são lidos na inicialização).

## Glifos
As 14 magias de ataque e buff (10 do Archer e 4 do Ranger) têm 2 glifos cada, de tipos diferentes e que funcionam com qualquer encantamento; os 4 Enchants não têm glifos. Comprados com pontos de bestiário na NPC **Lyra Windbinder** (ainda sem posição no mapa) ou por `!glyphs`. A tabela está em [42-glifos.md](42-glifos.md). As magias leem o glifo por `Archer.glyph(cid, "nome do script")`. O `range` do Piercing Arrow em `spells.xml` agora é 9 (o script mantém 6 sem o glifo).
