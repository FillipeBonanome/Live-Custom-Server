# Vocação Cleric

## O que é
Vocação de mago de **holy** voltada para o grupo: dano médio, curas e buffs leves. Quase toda magia dele faz duas coisas ao mesmo tempo (fere o inimigo e ajuda o aliado). Range média (até 4 SQM) e áreas médias (3x3, 5x5 e feixe de 5 SQM).

| Id | Nome | Premium | Promoção de |
|---|---|---|---|
| 9 | Cleric | não | |
| 10 | Hierophant | sim | Cleric (`fromvoc="9"`) |

Definidas em `data/XML/vocations.xml` (vida/mana/cap entre Druid e Paladin, mana multiplier 1.1). `isCleric(cid)` em `data/lib/031-vocations.lua` vale para as duas.
Além das magias abaixo, o Cleric recebeu as magias universais que todas as vocações já tinham (Haste, Light, Magic Shield, Fist Fury etc.).

## Magias
"Aliados" = o próprio Cleric e os membros da party dele (`Cleric.allies`). Fórmulas: `nível/divisor + magic level * multiplicador`; os números ficam no topo de cada script e podem ser ajustados.

### Ataque
| Magia | Palavras | Lvl | Mana | Cooldown | Efeito |
|---|---|---|---|---|---|
| Holy Ray | `exori lux` | 20 | 25 | 2s | Dano holy em 1 alvo (range 4) |
| Divine Lance | `exori gran lux` | 35 | 90 | 2s | Feixe de 5 SQM: dano nos inimigos e cura nos players da linha |
| Holy Nova | `exevo mas lux` | 30 | 120 | 2s | Explosão 5x5 em volta de si: dano nos inimigos e cura nos aliados |
| Rain of Light | `exevo gran lux` | 40 | 130 | 2s | Zona 5x5 no alvo por 3s (1 pulso/s): dano nos inimigos, cura nos aliados |
| Celestial Hammer | `exori vis lux` | 45 | 70 | 2s | Dano alto em 1 alvo + paralisia de 2s (stun) |
| Judgment | `exori judex` | 50 | 140 | 8s | Marca o alvo; após 1,5s cai a sentença: dano alto nele e cura nos aliados em 3 SQM |
| Pillar of Light | `exevo pila lux` | 45 | 200 | 6s (grupo próprio) | Substitui as runas de área: ver abaixo |

**Pillar of Light:** acerta 3x3 em volta do **inimigo** (range 4, precisa de alvo, dano holy médio-alto) e deixa um círculo de luz por 4s (pulso por segundo): inimigos dentro tomam dano e aliados dentro são curados. Se o alvo central morrer com o círculo ativo, o pilar explode uma vez (raio 2, metade do dano máximo inicial).

### Cura e suporte
| Magia | Palavras | Lvl | Mana | Cooldown | Efeito |
|---|---|---|---|---|---|
| Soothing Touch | `exura lux sio "nome"` | 18 | 100 | 1s | Cura média em 1 aliado (range 4) |
| Group Blessing | `exura gran mas lux` | 36 | 160 | 8s | Cura em 2 SQM e dá Divine Grace aos aliados |
| Purify | `exana lux` | 25 | 90 | 4s | Remove veneno, fogo, energia, curse e paralisia dos aliados em 2 SQM; dano holy pequeno nos inimigos |
| Final Prayer | `exura gran mas san` | 60 | 450 | 30s | 3 pulsos (a cada 2s) em 3 SQM em volta do Cleric: cura grande nos aliados e dano nos inimigos |
| Shield of Faith | `utamo lux "nome"` | 22 | 80 | 6s | +8 armor e +6 defense por 6s; ao acabar cura o alvo. Use o nome do aliado, o alvo atual ou o próprio nome |
| Holy Fury | `utito lux` | 30 | 100 | 15s | +20% de dano holy por 15s (só no Cleric) |
| Divine Grace | `utura lux` | 34 | 120 | 15s | +10% de magic level por 15s nos aliados em 3 SQM |
| Wall of Light | `utamo mas lux` | 38 | 140 | 12s | +5 armor e +4 defense por 10s nos aliados em 3 SQM |

## Buffs (`data/lib/371-buffs-list.lua`)
| Id | Categoria | Duração |
|---|---|---|
| `holy_fury` | holy_attack | 15s |
| `divine_grace` | holy_grace | 15s |
| `wall_of_light` | holy_ward | 10s |
| `faith_shield` | shield | 6s |

Cada um tem categoria própria, então os quatro podem ficar ativos juntos. Aparecem em `!buffs`.

## Arquivos
- `data/lib/372-cleric.lua`: tabela `Cleric` (fórmulas, lista de aliados, cura, pulsos).
- `data/spells/scripts/attack/` (`holy ray`, `divine lance`, `holy nova`, `rain of light`, `celestial hammer`, `judgment`, `pillar of light`), `healing/` (`soothing touch`, `group blessing`, `purify`, `final prayer`) e `support/` (`shield of faith`, `holy fury`, `divine grace`, `wall of light`).
- `data/spells/spells.xml`: spell ids 136 a 150.

## Limitações
- Só as magias estão implementadas. Passivas (Fé, Luz Vinculada etc.) e combos entre magias ficaram de fora.
- Do Pillar of Light não foram feitos o +8% de dano holy do grupo nos inimigos marcados e a resistência extra nos aliados do círculo (exigem hook na source).
- O Shield of Faith não absorve dano: dá armor/defense e cura no fim.
- Para criar um personagem Cleric, mude `vocation` do jogador para 9 no banco ou pelo comando de GM.
