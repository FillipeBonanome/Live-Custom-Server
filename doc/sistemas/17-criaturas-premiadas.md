# Criaturas premiadas

## Como funciona
- Toda vez que o servidor abre, `data/globalevents/scripts/rewardedmonsters.lua` sorteia uma % dos monstros para a categoria **experience** e outra para **loot**. A lista vale até o próximo restart.
- O mesmo monstro não aparece 2x na mesma categoria, mas pode estar nas duas categorias.
- Matar uma criatura premiada de experience dá `rewardedMonstersExperienceBonus`% a mais de experiência; de loot, soma `rewardedMonstersLootBonus`% ao bônus de loot (mesma conta do bônus de loot dos jogadores, em cima do `rateLoot`).
- No login (depois da boas-vindas e das daily quests) o jogador recebe, em azul, por exemplo: `Experience (+20%): Dragon [Lv 50], Demon [Lv 184].` Listas grandes são divididas em várias mensagens.
- `!rewarded` (ou `!premiadas`) abre a lista completa com os levels.

## Quais monstros entram
O mesmo grupo das daily quests (hostis, atacáveis e com experiência > 0, fora da `DailyQuest.blacklist`) e o mesmo level estimado (veja `16-daily-quests.md`). A quantidade sorteada é `floor(total * rewardedMonstersPercent / 100)`, no mínimo 1 se a % for maior que 0.

## Configuração (`config.lua`)
| Opção | Padrão | O que faz |
|---|---|---|
| `rewardedMonstersEnabled` | `true` | Liga/desliga o sistema |
| `rewardedMonstersPercent` | 5 | % dos monstros sorteados em cada categoria |
| `rewardedMonstersExperienceBonus` | 20 | % de experiência extra |
| `rewardedMonstersLootBonus` | 20 | % de bônus no loot |

## Para scripts (C++)
- `setRewardedMonsters(category, bonusPercent, {names})`: define a lista (`"experience"` ou `"loot"`).
- `getRewardedMonsters(category)`: `{bonus = percent, monsters = {nomes em minúsculas}}`.
- `RewardedMonsters.roll()`, `.getList(category)` e `.send(cid)` em `data/lib/310-rewarded.lua`.

A experiência é aplicada em `Creature::onAttackedCreatureKilled` e o loot em `MonsterType::dropLoot` (`src/rewarded.cpp`).
