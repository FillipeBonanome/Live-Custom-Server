# Vocação Cleric

## O que é
Vocação de mago de **holy** voltada para o grupo: dano médio, curas e buffs leves. Quase toda magia dele faz duas coisas ao mesmo tempo (fere o inimigo e ajuda o aliado). Range média (até 4 SQM) e áreas médias (3x3, 5x5 e feixe de 5 SQM).

| Id | Nome | Premium | Promoção de |
|---|---|---|---|
| 9 | Cleric | não | |
| 10 | Hierophant | sim | Cleric (`fromvoc="9"`); também usa todas as magias do Cleric |

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

## Magias exclusivas do Hierophant (vocação 10)
Todas premium. Spell ids 151 a 154.

| Magia | Palavras | Lvl | Mana | Cooldown | Efeito |
|---|---|---|---|---|---|
| Sacred Wave | `exevo san hur` | 70 | 250 | 2s | Wave grande (formato da Energy Wave, precisa de direção) de dano holy. Quem for atingido perde 10% de resistência a holy por 8s |
| Divine Tempest | `exevo gran mas san` | 90 | 600 | 25s | Chuva diagonal de holy em volta do Cleric por 5s (raio 5, 100 gotas `SMALLHOLY` em momentos aleatórios, sem cair todas juntas). O caster fica **paralisado** durante a chuva. Os hits ignoram tiles em PZ, tiles inexistentes e tiles atrás de paredes (sem linha de visão) |
| Divine Vitality | `utamo gran mas lux` | 60 | 300 | 60s | +10% de vida máxima e de mana máxima por 2 min, no Cleric e na party (raio 7) |
| Radiant Strikes | `utito gran mas lux` | 55 | 250 | 60s | Ataques básicos causam +15% do dano como dano holy extra, por 1 min, no Cleric e na party (raio 7) |

- **Resistência a holy (Sacred Wave):** não existe resistência modificável em monstros, então é aplicada pelo evento `statschange` `HolyResistDown` (`data/creaturescripts/scripts/holyresist.lua`): enquanto a marca dura, cada hit de holy no alvo causa 10% de dano holy extra. O alvo recebe o debuff `Holy Vulnerability` (8s) do sistema de buffs, e o evento consulta `hasCreatureBuff`.
- **Radiant Strikes:** usa o atributo *on hit holy* (`CONDITION_PARAM_ONHIT_HOLY`), que já existia: o valor 15 é **15% do dano do ataque básico** somado como dano holy em todo hit, e não uma chance de proc.
- Buffs novos: Divine Vitality e Radiant Strikes, em `Cleric.buffs` (`data/lib/372-cleric.lua`).

## Passiva: Faith (Fé)
Cada magia **holy** lançada pelo Cleric ou Hierophant dá 1 stack de Faith (máximo 5). Os stacks duram 8s e cada nova magia renova o tempo (se o tempo acabar, volta a 0). Cada stack dá **+3% de dano holy** e **+3% de cura** (5 stacks = +15%). Ao chegar em 5 stacks aparece um fogo de artifício amarelo.

- **Magias que dão stack:** todas as de ataque, Soothing Touch, Group Blessing, Purify, Final Prayer e as do Hierophant (Sacred Wave e Divine Tempest). Buffs (Holy Fury, Divine Grace, Wall of Light, Shield of Faith, Divine Vitality, Radiant Strikes) não dão.
- **Quando conta:** o stack entra depois da magia lançada, então ela usa os stacks que existiam antes dela.
- **Como funciona:** Faith é um único buff **stackável** (categoria `Faith`, máx. 5 stacks), visível em `!buffs` com os stacks. O dano usa o atributo de amplificação holy do buff (3% por stack). A cura usa `Cleric.heal` e as fórmulas do Soothing Touch e do Divine Lance. Código em `data/lib/372-cleric.lua` (`Cleric.faith`, `Cleric.faithStacks`, `Cleric.faithMultiplier`), chamado no fim de cada magia.
- Dar stack a uma magia nova: chame `Cleric.faith(cid)` no fim do `onCastSpell`.

## Buffs (`Cleric.buffs` em `data/lib/372-cleric.lua`)
| Categoria | Duração | Sub id da condition |
|---|---|---|
| Holy Fury | 15s | 8310 |
| Divine Grace | 15s | 8311 |
| Wall of Light | 10s | 8312 |
| Shield of Faith | 6s | 8313 |
| Divine Vitality | 2 min | 8314 |
| Radiant Strikes | 1 min | 8315 |
| Faith | 8s, stackável até 5 (renova a cada magia holy) | 8320 |
| Holy Vulnerability | 8s (debuff em monstros, Sacred Wave) | |

Cada um tem categoria própria, então podem ficar ativos juntos. Aparecem em `!buffs`. São dados com `addCreatureBuff` (ver [23-buffs.md](23-buffs.md)); `Cleric.addBuff(cid, chave)` cria a condition e a remove no `onRemove`.

## Arquivos
- `data/lib/372-cleric.lua`: tabela `Cleric` (fórmulas, lista de aliados, cura, pulsos).
- `data/spells/scripts/attack/` (`holy ray`, `divine lance`, `holy nova`, `rain of light`, `celestial hammer`, `judgment`, `pillar of light`), `healing/` (`soothing touch`, `group blessing`, `purify`, `final prayer`) e `support/` (`shield of faith`, `holy fury`, `divine grace`, `wall of light`).
- `data/spells/spells.xml`: spell ids 136 a 150.

## Limitações
- Só a passiva Faith está implementada. As outras passivas (Luz Vinculada, Fervor etc.) e os combos entre magias ficaram de fora.
- Do Pillar of Light não foram feitos o +8% de dano holy do grupo nos inimigos marcados e a resistência extra nos aliados do círculo (exigem hook na source).
- O Shield of Faith não absorve dano: dá armor/defense e cura no fim.
- Para criar um personagem Cleric, mude `vocation` do jogador para 9 no banco ou pelo comando de GM.
