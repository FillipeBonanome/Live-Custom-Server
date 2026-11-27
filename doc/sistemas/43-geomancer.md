# Vocação Geomancer (e promoção Colossus)

## O que é
Mago tank de armadura pesada, no estilo de um Mordekaiser. Quase todo o dano é **físico** (pedra, impacto); uma **gema no slot da flecha** transforma **metade do dano** de cada magia no elemento da gema, e o buff **Stone Skin** dá resistência a esse mesmo elemento. Controla o campo de batalha levantando **cristais** que bloqueiam o caminho (de jogadores também) e somem depois de um tempo.

| Id | Nome | Premium | Promoção de |
|---|---|---|---|
| 19 | Geomancer | não | |
| 20 | Colossus | sim | Geomancer (`fromvoc="19"`); também usa todas as magias do Geomancer |

Definidas em `data/XML/vocations.xml`. `isGeomancer(cid)` em `data/lib/031-vocations.lua` vale para as duas.

## Atributos
| | Geomancer | Colossus | Knight (comparação) |
|---|---|---|---|
| Vida por level | 13 | 13 | 15 |
| Mana por level | 12 | 12 | 5 |
| Cap por level | 22 | 22 | 25 |
| Regen de vida / mana | 5 / 4 | 8 / 7 | 6 / 2 |
| Mana multiplier | 2.0 | 2.0 | 3.0 |
| Fórmula de armor | 1.2 | 1.2 | 1.0 |
| Soul máximo | 100 | 200 | |
| Perda na morte | normal | -30% | |

Skills (multiplicador, quanto maior mais lento): **club 1.1**, shielding 1.5, fist 1.5, fishing 1.1; sword, axe e distance 4.0.

## Armas
Só **clubs** (maças): o id `19` foi acrescentado em todas as armas da seção `<!-- Clubs -->` de `data/weapons/weapons.xml` (o 20 entra pela promoção, como no Archer). Poder (`P`) = **club skill + ataque do(s) club(s) nas mãos**; todo dano e cura é `nível/5 + P × fator`.

## Gemas (slot da flecha)
Nenhuma mudança no código-fonte: todo item já pode ir para o slot da flecha (`slotPosition` padrão), e a gema não é gasta porque só armas que atiram munição consomem o que está ali. As gemas **não caem mais de nenhum monstro** (removidas de todos os `data/monster/` ativos; `_backup_products` ficou como estava).

| Gema | Id | Elemento do dano | Resistência do Stone Skin |
|---|---|---|---|
| Violet | 2153 | energy | energy |
| Yellow | 2154 | holy | holy |
| Green | 2155 | poison (earth) | earth |
| Red | 2156 | fire | fire |
| Blue | 2158 | ice | ice |

Com gema: 50% do dano de **toda magia de ataque** vira o elemento e 50% fica físico (`Geomancer.gemShare`). Sem gema, 100% físico. Os efeitos visuais das magias também usam a área do elemento.

**Onde comprar:** o NPC **Durnok Runebrand** vende as gemas por **5000 de ouro** cada, pela **janela de trade** (diga `trade`) ou por conversa (`gems`, depois a cor: `violet`, `yellow`, `green`, `red` ou `blue`, e `yes`, 1 por vez). O trade lê o `shop_buyable` de `data/npc/Durnok Runebrand.xml`; a conversa lê `RuneCarving.gems`: **mude os dois juntos** ao mexer nos preços. Os preços ficam em `RuneCarving.gems` (`data/lib/399-runecarving.lua`). A Amara compra yellow e blue gem por menos (1000 e 3000), então não dá para lucrar revendendo.

## Magias (ids 239 a 248)
Todas com `needlearn="0"`, sem premium, para as vocações 19 e 20 (o Colossus tem mais 4, abaixo). Só as de ataque com alvo ou direção usam `needweapon="1"`. Nenhum golpe atinge quem está em **PZ**, party ou summons de amigos, e nada atravessa parede.

| Magia | Palavras | Lvl | Mana | Cd | Efeito |
|---|---|---|---|---|---|
| Stone Strike | `exori petra` | 8 | 15 | 1,5s | 1 alvo (alcance 3), P × 0.9 a 1.3 |
| Stone Skin | `utamo petra` | 12 | 60 | 30s | Buff de 20s: +8 armor, +6 defense, 10% menos dano físico; com gema, 25% menos dano do elemento da gema |
| Earthen Mend | `exura terra` | 14 | 40 | 1s | Cura nível/5 + P × 1.2 a 1.8 |
| Crystal Wall | `exevo lapis lata` | 20 | 50 | 10s | **Parede** de 5 large crystals **atravessada** na direção em que olha (perpendicular), centrada 2 SQM à frente, por 8s. Onde um cristal nasce sob um inimigo, causa P × 0.5 a 0.8 nele (e o tile fica vazio) |
| Crystal Pillar | `exevo lapis alta` | 20 | 50 | 10s | **Corredor** de 5 large crystals **na direção** em que olha, começando 2 SQM à frente, por 8s. Mesmo dano sob inimigos |
| Stone Roar | `exeta petra` | 22 | 50 | 15s | Raio 4: dano pequeno (P × 0.3 a 0.5) e **provoca** (challenge) todos os monstros |
| Tremor Wave | `exevo mas terra` | 26 | 70 | 6s | Wave à frente (5 de comprimento, até 5 de largura), P × 0.8 a 1.2; **a linha do centro leva +35%** |
| Fissure | `exori fissura` | 30 | 70 | 8s | **4 ou 5 random walks** a partir do alvo (alcance 5), em leque ao redor da direção jogador→alvo (reto e ±45° e ±90°): 7 tiles cada, P × 0.25 a 0.4 em cada tile; o alvo leva o golpe inicial uma vez |
| Gem Resonance | `exura res gemma` | 34 | 120 | 20s | 5 curas de nível/5 + P × 0.5 a 0.7 (1 por segundo) e **+25% de dano do elemento da gema** por 12s |
| Crystal Storm | `exevo lapis grando` | 40 | 120 | 14s | 6 large crystals surgem aleatoriamente a 1-2 SQM do alvo (alcance 6). Cada um causa P × 0.3 a 0.45 em quem estiver a até 2 SQM **e** lança **3 random walks** (3 direções aleatórias diferentes, 4 tiles, P × 0.2 a 0.3) a partir do tile onde nasceu |

### Tremor Wave
A animação começa na linha do **centro** e se espalha para as **bordas**: cada linha é atingida 150ms depois da anterior (`laneDelay`) e cada fileira 70ms depois da anterior (`forwardDelay`). O dano é aplicado no momento em que o efeito aparece em cada tile, e cada criatura leva um único golpe.

### Cristais
Usam os itens **large crystal** (ids 8633 a 8636, sorteados): bloqueiam jogadores e monstros e não podem ser movidos. Pelo `items.xml` (`duration 20`, `decayTo 0`) somem sozinhos em 20s, o que serve de rede de segurança se o evento de remoção falhar; as magias os removem antes (6 a 8s). Para trocar o visual, mude `Geomancer.crystalItems` em `data/lib/378-geomancer.lua` (o item precisa bloquear, ser fixo e ter o decay). Cristais só nascem em tile **livre** (sem criatura, sem item sólido, fora de PZ e em linha de visão); onde há um inimigo, o Crystal Wall e o Crystal Pillar causam dano nele em vez de erguer o cristal. A **direção** vem para onde o jogador está olhando (`Geomancer.crystalLine`). Todo cristal recebe o **actionId 54900** (`Geomancer.crystalActionId`): um jogador que **usa** (clica) um cristal o faz sumir (`data/actions/scripts/geomancer_crystal.lua`, registrado em `actions.xml`); isso vale para qualquer jogador e a explosão do Crystal Bulwark só acontece quando o tempo acaba.

### Gem Resonance e Stone Skin
Os buffs aparecem em `!buffs` (subIds `8900` Stone Skin, `8901` Gem Resonance, `8902` Titan's Resonance, `8903` Crystal Bulwark). Sem gema, o Gem Resonance só cura.

## Magias do Colossus (ids 249 a 252)
Premium e exclusivas da vocação 20. Nenhum golpe atinge quem está em PZ, party ou summons de amigos, e nada atravessa parede.

| Magia | Palavras | Lvl | Mana | Cd | Efeito |
|---|---|---|---|---|---|
| Crystal Bulwark | `utamo lapis` | 58 | 250 | 45s | Anel de large crystals nos 8 tiles em volta (o tile **à frente**, na direção do olhar, fica livre para sair) por 8s; 20% menos dano de todos os elementos (buff `8903`). Cristal que nasce sob um inimigo causa P × 0.6 a 0.9 nele (tile vazio); ao sumir, cada cristal **explode** (P × 0.5 a 0.8 em 1 SQM) |
| Seismic Slam | `exori gran petra` | 62 | 150 | 12s | 1 alvo (alcance 2), P × 2.2 a 3.0, **atordoa 1,5s**; +30% se o alvo estiver **preso** (já lento/atordoado ou com um cristal ao lado). Com gema: fogo queima 3s (P × 0.1 a 0.15 por segundo), veneno 4s (P × 0.08 a 0.12), gelo -40% de velocidade por 4s depois do atordoamento, energia salta para 2 inimigos (P × 0.6 a 0.9) e holy cura 25% do dano |
| Titan's Resonance | `utamo gran terra` | 66 | 350 | 60s | Buff de 15s (`8902`): 15% menos dano de todos os elementos (40% do elemento da gema) e **todo golpe de magia** manda um raio de pedra do alvo a até 2 inimigos próximos (`Attacks.chainLightning`), 35% do dano do golpe cada, caindo 30% por salto; no máximo um raio a cada 0,5s |
| Tectonic Fury | `exevo gran terra` | 70 | 400 | 40s | 4 anéis **circulares** de ondas (um disco de raio 4 em volta dele, como o Hell's Core, 0,15s entre os anéis) do centro para as bordas, P × 1.6 a 2.4 em quem estiver no anel (1 golpe por criatura); cada anel solta **1 random walk** a partir de um tile dele, para longe do jogador (3 tiles, P × 0.3 a 0.45) |

O raio do Titan's Resonance está em `Geomancer.titanChain` e roda dentro de `Geomancer.hit` (opção `noChain` desliga). É a primeira magia que usa o `Attacks.chainLightning`.

## Biblioteca de tipos de ataque (`data/lib/377-attacks.lua`)
Define **onde e quando** acertar; o que o golpe faz fica num callback da magia, então qualquer vocação pode usar.

| Função | O que faz |
|---|---|
| `Attacks.chainLightning(cid, target, o)` | O raio salta de inimigo em inimigo (`bounces`, `jumpRange`, `falloff`, `delay`); exige linha de visão limpa entre os dois e nunca repete criatura |
| `Attacks.randomWalk(cid, o)` | Golpe que anda tile a tile a partir de `o.from`: a cada passo sorteia um tile livre à frente ou numa das 2 diagonais (no máximo `maxTurn` × 45° da direção original), com `interval` ms de atraso; nunca entra em PZ, repete tile ou atravessa parede; termina ao ficar sem saída |
| `Attacks.valid / enemies / around / enemiesOn / tileOpen` | Alvos válidos e tiles livres |
| `Attacks.vector / sign / ring` | Direções |

O `chainLightning` é usado pelo Seismic Slam com gema de energia e pelo Titan's Resonance (o Archer tem a sua própria versão em `Archer.chain`).

## Arquivos
| Arquivo | Função |
|---|---|
| `data/lib/377-attacks.lua` | Tipos de ataque genéricos |
| `data/lib/378-geomancer.lua` | Tabela `Geomancer`: gemas, poder, `hit`, cura, cristais e buffs |
| `data/lib/399-runecarving.lua`, `data/npc/scripts/runesmith.lua` | Venda das gemas pelo Durnok (`RuneCarving.gems`, `RuneCarving.buyGem`) |
| `data/spells/scripts/geomancer/` | Uma magia por arquivo |
| `data/XML/vocations.xml`, `data/spells/spells.xml` | Vocações 19 e 20 e as magias 239 a 248 |
| `data/weapons/weapons.xml` | Clubs liberados para o Geomancer |
| `data/talkactions/scripts/vocation.lua` | Descrição no `!vocation` |
| `data/actions/scripts/geomancer_crystal.lua`, `data/actions/actions.xml` | Usar um cristal o remove (actionId 54900) |
| `data/talkactions/scripts/testarea.lua` | Comando `/testarea` |
| `data/lib/403-glyphs.lua` | Glifos do geomancer (vocação 19, posições 127 a 140) |
| `data/npc/Garrik Stonebinder.xml`, `data/npc/scripts/glyphmaster_geomancer.lua` | NPC mestre dos glifos |
| `data/items/items.xml` | Large crystals (8633-8636) com decay de 20s |
| `data/monster/` | As 5 gemas grandes foram removidas dos drops |

## Glifos
As 14 magias (10 do Geomancer e 4 do Colossus) têm 2 glifos cada, de **tipos diferentes** (nunca dois de dano alvo único, dois de suporte etc. na mesma magia). Comprados com pontos de bestiário no NPC **Garrik Stonebinder** (160, 44, 8) ou por `!glyphs`; a tabela completa está em [42-glifos.md](42-glifos.md). As magias leem o glifo por `Geomancer.glyph(cid, "nome do script")`. Os níveis exigidos seguem a regra geral (nível da magia × 4).

## Comando de teste
`/testarea` (acesso 4, `data/talkactions/scripts/testarea.lua`): teleporta o GM/God para a área de testes (451, 40, 7).

## Ainda não implementado
Restrição de potions e as ideias Boulder Throw e Rock Barrage (ataques à distância para o Geomancer base). Nada disso precisa recompilar: reinicie o servidor (vocações, magias e armas são lidos na inicialização).
