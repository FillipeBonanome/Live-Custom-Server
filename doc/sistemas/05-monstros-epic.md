# Monstros Epic

## O que faz
Spawns naturais têm uma chance de nascer **epic**: recebem um vínculo elemental aleatório, caveira vermelha e o nome `[Vínculo] Nome` (ex.: `[Blazing] Dragon`).

| Vínculo | Elemento |
|---|---|
| Blazing | fogo |
| Frozen | gelo |
| Venomous | terra |
| Storm | energia |
| Radiant | sagrado |
| Cursed | morte |
| Tidal | água |

Benefícios do epic: mais vida, mais xp, dano elemental extra nos ataques físicos, resistência ao seu elemento e rolagens extras de loot no corpo.

## Configuração (`config.lua`)
```lua
epicMonsterChance = 3              -- % de nascer epic (0 desativa)
epicMonsterHealthMultiplier = 2.0
epicMonsterExperienceBonus = 100   -- % de xp extra
epicMonsterElementalDamage = 50    -- % do dano físico somado como elemental
epicMonsterElementalResistance = 50
epicMonsterExtraLootRolls = 1
epicMonsterGemChance = 100        -- % do corpo ter a gema do elemento
epicMonsterGemMax = 3             -- quantidade sorteada de 1 até este valor
```

## Gemas do runecarving
As gemas das runas (small ruby/sapphire/emerald/amethyst/diamond, black pearl, white pearl) **não estão mais no loot de nenhum monstro**. Elas só caem de monstros epic, pela gema do vínculo: Blazing = small ruby, Frozen = small sapphire, Venomous = small emerald, Storm = small amethyst, Radiant = small diamond, Cursed = black pearl, Tidal = white pearl. Código: `Monster::dropEpicGems` em `src/monster.cpp`. Não coloque essas gemas no XML dos monstros.

## Exemplo
Um Dragon (xp 700) epic com os padrões: vida x2, 1400 xp, loot rolado 2 vezes. Se for Blazing, cada ataque físico causa +50% de dano de fogo e ele tem +50% de resistência a fogo.
