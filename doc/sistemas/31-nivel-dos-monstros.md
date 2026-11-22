# Level dos monstros

Os arquivos dos monstros não têm level. Ele é usado pelos contratos (daily quests), pelo prey, pelas criaturas premiadas e pelas listas dos comandos de staff. Antes era estimado só pela experiência (`experiência ^ 0.6`). Agora é calculado pela **vida** e pelo **dano dos ataques**, tanto a média quanto o burst máximo (`data/lib/301-monsterlevel.lua`).

## Dados lidos do monstro
`getMonsterList()` (source, `luaGetMonsterList`) devolve para cada monstro, além do que já devolvia:

| Campo | O que é |
|---|---|
| `damagePerSecond` | Dano médio por segundo: para cada ataque, média de `min`/`max` x `chance` x ataques por segundo (`1000 / interval`) |
| `maxHit` | Maior golpe único |
| `burst` | Soma do maior golpe de todos os ataques (o pior caso, todos disparando juntos) |
| `attackCount`, `unknownAttacks` | Quantidade de ataques e quantos não têm dano no arquivo (scripts ou magias nomeadas), que não entram na conta |

O ataque melee/distance com `attack` e `skill` usa `ceil(skill * attack * 0.05 + attack * 0.5)` como golpe máximo, igual à source. As rates `rateMonsterAttack` e `rateMonsterHealth` do `config.lua` entram na conta. Dano de condições (veneno, fogo) e de campos não é contado, e ataques de área contam como um alvo só.

## Fórmula
```
oferta = dano/s * horizonte * (1 - pesoBurst) + burst * pesoBurst
score  = raiz(vida * oferta)
level  = floor(score ^ expoente * multiplicador)
```
Padrões: horizonte **10 s**, peso do burst **0.4**, expoente **0.655**, multiplicador **0.61**. Foram ajustados por regressão sobre os monstros do servidor para manter os levels na mesma escala da fórmula antiga (R² 0,87), então contratos, prey e tasks continuam equilibrados. Monstros sem dano conhecido (sem ataque, ou só ataques por script sem `min`/`max`) usam a fórmula antiga pela experiência.

Exemplos: Rat 4, Dragon 44, Dragon Lord 69, Demon 143, Orshabaal 258. Monstros com muita experiência e pouco perigo (Magebomb, 480000 de experiência) deixam de ficar com level absurdo (2562 antes, 65 agora).

## Níveis fixos (hardcoded)
Os níveis em uso ficam **escritos** em `data/lib/302-monsterlevels.lua`, na tabela `MonsterLevels` (um monstro por linha, nome em minúsculas, com a vida, a experiência, o dano por segundo e o burst usados no comentário). O arquivo foi gerado pela fórmula acima para os 461 monstros do servidor. Para balancear um monstro, basta trocar o número dele:

```lua
["dragon"] = 44, -- Dragon | hp 1000 | exp 700 | dps 51.2 | burst 435
```

Tudo que precisa do level chama `MonsterLevel.get(nome [, monstro])` (`data/lib/301-monsterlevel.lua`), que devolve o valor da tabela e, para um monstro que ainda não está nela (um monstro novo), o calculado pela fórmula. Por isso contratos, prey e criaturas premiadas (`DailyQuest.getMonsterLevel`, que `getMonsters` usa) já leem a tabela, e um monstro novo continua funcionando sem editar nada. A ordem de prioridade é `DailyQuest.monsterLevelOverrides` (antigo, vazio), depois `MonsterLevels`, depois a fórmula.

As linhas marcadas com `CHECK` são monstros sem dano conhecido (sem ataque, ou só ataques por script sem `min`/`max`): o level veio da experiência e vale a pena revisar.

Os contratos já gerados guardam o level da época em `player_daily_quests` (`monster_level`); os novos usam a tabela.

### Comando de staff
- `/monsterlevels`: lista os monstros que **não** estão em `MonsterLevels`, com o level calculado, em linhas prontas para colar na tabela.
- `/monsterlevels <nome>`: mostra o level em uso, o fixo, o calculado e os dados da fórmula (vida, experiência, dano/s, maior golpe, burst e ataques sem dano).

## Configuração (`config.lua`)
`monsterLevelHorizon`, `monsterLevelBurstWeight`, `monsterLevelExponent` e `monsterLevelMultiplier`. As opções `dailyQuestMonsterLevelExponent` e `dailyQuestMonsterLevelMultiplier` valem só para a fórmula antiga (fallback). Para forçar o level de um monstro, use `DailyQuest.monsterLevelOverrides`.

## Comando de staff
`/dailymonsters [min],[max]` ou `/dailymonsters <nome>` lista os monstros dos contratos com o level, a experiência, a vida, o dano por segundo e o burst.

## Arquivos
`data/lib/302-monsterlevels.lua` (tabela fixa), `data/lib/301-monsterlevel.lua` (fórmula e `MonsterLevel.get`), `data/talkactions/scripts/monsterlevels.lua`, `data/lib/300-dailyquests.lua` (`DailyQuest.getMonsterLevel` e `getMonsters`), `src/luascript.cpp` (`luaGetMonsterList`). Precisa recompilar e reiniciar.
