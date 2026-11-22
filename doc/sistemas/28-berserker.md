# Vocação Berserker (e promoção Warlord)

## O que é
Guerreiro de machado focado em armas de **duas mãos** (e pode usar **escudo junto**). As magias **gastam vida em vez de mana**, ele tem **life leech passivo**, ganha **Fúria** (+axe skill) a cada magia e causa **mais dano físico quanto menos vida tem**.

| Id | Nome | Premium | Promoção de |
|---|---|---|---|
| 15 | Berserker | não | |
| 16 | Warlord | sim | Berserker (`fromvoc="15"`); também usa todas as magias do Berserker |

Definidas em `data/XML/vocations.xml`. `isBerserker(cid)` em `data/lib/031-vocations.lua` vale para as duas.

## Atributos
| | Berserker | Warlord | Knight (comparação) |
|---|---|---|---|
| Vida por level | 15 | 15 | 15 |
| Mana por level | 3 | 3 | 5 |
| Cap por level | 25 | 25 | 25 |
| Regen de vida / mana | 6 / 1 | 10 / 2 | 6 / 2 |
| Soul máximo | 100 | 200 | |
| Perda na morte | normal | -30% | |

Skills (multiplicador): **axe 1.1**, fist 1.5, shielding 2.0, club 3.0, sword 3.0, distance 4.0. A velocidade de ataque vem do fist skill, como nas outras vocações.

## Armas e escudo
- **Só machados** (de uma e de duas mãos): em `data/weapons/weapons.xml` os machados que já tinham lista de vocações ganharam `<vocation id="15"/>`, os que estavam livres ou bloqueados para o Assassin passaram a incluir o 15, e as espadas livres agora têm uma lista que exclui o Berserker. Clavas e armas de distância já o excluíam. O Berserker equipa as outras armas, mas elas não causam dano.
- **Duas mãos com escudo:** atributo novo `canTwoHandShield="1"` em `vocations.xml` (só Berserker e Warlord). Mudança na source: `Player::canTwoHandShield` e as quatro verificações de `Player::__queryAdd` (`src/player.cpp`) que antes devolviam "both hands need to be free" / "drop the two-handed item". Os outros jogadores continuam sem poder.
- **Potions:** pode usar todas as health potions (strong, great e ultimate), como o Knight.

## Passivas
- **Life leech:** 8% (Warlord 10%). É uma condition renovada a cada segundo pelo globalevent `berserker`.
- **Rage:** `+0,4%` de dano físico para cada 1% de vida que falta, no máximo **+30%** (com 25% de vida ou menos). Usa a condition `ELEMENTAL_AMP_PHYSICAL`, na mesma condition do leech, atualizada a cada segundo. Passa de 0 a 30 conforme a vida cai.
- **Fúria:** cada magia dá 1 stack (máx. 10, 12 s, renovada a cada magia); cada stack dá **+2 de axe skill** (até +20). Aparece em `!buffs`.

## Custo em vida
As magias usam o atributo novo **`healthpercent`** (% da vida máxima, coluna "Custo") no `spells.xml`, no lugar de `mana`. A source também aceita **`health`** (valor fixo) em qualquer magia, e as duas podem ser combinadas com `mana`. A vida só é descontada depois de a magia ser lançada, nunca deixa o jogador abaixo de 1 de vida e, se a vida atual não passa do custo, a magia dá erro ("You do not have enough health.") e **não entra em cooldown**. Gastar vida baixa o seu HP, o que aumenta o Rage; o leech devolve a vida. Jogadores com `PlayerFlag_HasInfiniteMana` (GMs) não pagam.

## Fórmulas
- **Poder:** `P = axe skill (com Fúria) + ataque do machado`, multiplicado por **1,15** com arma de duas mãos. Todo dano é `nível/5 + P × fator`.
- **Sangramento** (Rending Blow): `P × 0,08 + nível/20` por segundo, 6 s (timer em Lua).
- Os números ficam em `data/lib/375-berserker.lua` e no topo de cada script em `data/spells/scripts/berserker/`.

## Magias do Berserker (ids 194 a 203)
Todas sem premium, com `needlearn="0"`.

| Magia | Palavras | Lvl | Custo | Cd | Efeito |
|---|---|---|---|---|---|
| Cleave | `exori fendo` | 8 | 3% | 1s | Golpe direcional (`direction`), P × 0.7 a 1.1, na área `{1, 3, 1}, {1, 0, 1}` (onde `3` é você, virada para onde olha). A magia de spam |
| Savage Leap | `exani saltus` | 12 | 4% | 6s | Salta até um alvo a 4 SQM e bate em 3x3 ao cair, P × 1.0 a 1.6 |
| Rending Blow | `exori rumpo` | 16 | 5% | 4s | Golpe forte em alvo adjacente, P × 1.2 a 1.8, e sangramento por 6 s |
| Warcry | `utito clamor` | 20 | 6% | 20s | Monstros a 3 SQM passam a atacar você (taunt); +5 armor e +3 defense por 8 s |
| Whirlwind | `exori mas turbo` | 25 | 7% | 6s | Gira e acerta em volta (3x3), P × 0.8 a 1.4; o leech cura por alvo atingido |
| Ground Slam | `exori terra` | 30 | 8% | 8s | Onda de choque à frente, P × 1.1 a 1.7, e reduz a velocidade dos monstros em 60% por 3 s |
| Blood Pact | `utito sanguis` | 35 | 10% | 30s | +8% de leech por 12 s (dobra o leech passivo) |
| Rampage | `exori furor` | 40 | 8% | 15s | 4 golpes em 1,2 s num alvo, P × 0.45 a 0.65 cada |
| Skullsplitter | `exori gran cranium` | 46 | 15% | 20s | Golpe enorme em alvo adjacente, P × 3.0 a 4.2, **até ×2 com a vida baixa** |
| Roar of Fury | `utito gran furor` | 54 | 10% | 45s | Dá **5 stacks de Fúria** de uma vez (+10 axe skill por 12 s) |

## Magias do Warlord (ids 204 a 207)
Todas premium e exclusivas da vocação 16.

| Magia | Palavras | Lvl | Custo | Cd | Efeito |
|---|---|---|---|---|---|
| Earthshatter | `exevo gran mas terra` | 58 | 18% | 40s | Onda de choque ao redor na mesma área do Groundshaker (`AREA_CIRCLE3X3`, raio 3), P × 2.5 a 3.5 |
| Blood Frenzy | `utito gran sanguis` | 62 | 15% | 45s | Por 10 s: +10% de leech, +25 de fist (velocidade de ataque) e +1 Fúria por segundo |
| Titan's Wrath | `exori gran mas titan` | 66 | 20% | 60s | 3 golpes pesados em 3 s ao redor (P × 1.5-2.0, depois 2.0-2.6, depois 2.8-3.6) |
| Undying Rage | `utamo furor` | 70 | 12% | 90s | Por 6 s o dano não pode matar você (fica com 1 de vida) e +10% de leech |

Todas dão 1 Fúria, menos o Roar of Fury (5) e o Blood Frenzy (1 + 1 por segundo).

## Buffs
Sub ids `8440` a `8444` (Fury, Blood Pact, Warcry, Blood Frenzy, Undying Rage) e `8450` (a condition passiva de leech e Rage). Todos usam `addCreatureBuff` (menos a passiva) e aparecem em `!buffs`.

## Arquivos
| Arquivo | Função |
|---|---|
| `data/lib/375-berserker.lua` | Tabela `Berserker`: poder, dano, Fúria, leech, Rage, buffs |
| `data/spells/scripts/berserker/` | Uma magia por arquivo |
| `data/globalevents/scripts/berserker.lua` | Renova a passiva (leech e Rage) a cada segundo |
| `data/creaturescripts/scripts/undyingrage.lua` | Evento do Undying Rage (`UndyingRage`, registrado pela magia) |
| `data/XML/vocations.xml`, `data/spells/spells.xml` | Vocações 15 e 16 e as magias 194 a 207 |
| `src/player.cpp`, `src/player.h`, `src/vocation.cpp`, `src/vocation.h` | `canTwoHandShield` |
| `src/spells.cpp`, `src/spells.h` | Custo de vida das magias: `health` e `healthpercent` |

## Observações
- **Duas mãos com escudo e o client:** o client 8.x desenha a arma de duas mãos nos dois slots e pode recusar o movimento do escudo antes de falar com o servidor. A parte do servidor está feita; o comportamento do client precisa ser testado.
- Mudar a vocação do jogador pode deixá-lo com arma de duas mãos e escudo que a nova vocação não permite; o servidor não corrige isso sozinho.
- A promoção para Warlord usa os NPCs de promoção que já existem (`fromvoc="15"`).
- Precisa recompilar (`compilar.bat`) e reiniciar o servidor.
