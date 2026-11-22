# Contratos / Daily quests

## Como funciona
- Cada jogador tem, por dia, um contrato por categoria: **experience** e **gold**. O contrato é sempre "matar N vezes um monstro", com N sorteado entre `dailyQuestMinKills` e `dailyQuestMaxKills` (50-100 por padrão).
- O monstro é escolhido pelo level do jogador (veja "Level do monstro"). O mesmo monstro nunca está nas duas categorias ao mesmo tempo para o mesmo jogador.
- Ao completar um contrato a recompensa é entregue e nasce outro **mais difícil** (monstro de level maior e recompensa com bônus). Podem ser feitos até `dailyQuestMaxPerCategory` (5) contratos por categoria por dia.
- Os contratos renovam às `dailyQuestResetHour` (5h, horário do servidor). Os jogadores online recebem um aviso azul no reset.
- A cada kill de um monstro do contrato aparece no chat (azul): `[Daily Quest] Dragon: 12/75 killed, 63 remaining.` Summons de jogadores não contam.
- Os contratos aparecem (mensagem azul) a cada login e o `!daily` abre o resumo completo. O `!daily` também está na lista de comandos do login (`logincommands.lua`).

## Persistência
Tabela `player_daily_quests` (uma linha por jogador e categoria: dia, contratos feitos, monstro, level, kills, total e recompensa). Cada kill grava direto no banco, então deslogar, cair ou reiniciar o servidor não perde progresso. O banco é atualizado sozinho para a versão 30 ao abrir o servidor novo (ou use `schemas/`).

## Level do monstro
Os monstros não têm level, então ele é calculado pela **vida e pelo dano dos ataques** (média e burst), ver `doc/sistemas/31-nivel-dos-monstros.md` (Rat ≈ 4, Dragon ≈ 44, Demon ≈ 143). O contrato nº *t* (0 a 4) procura monstros com level perto de `level do jogador * (dailyQuestBaseLevelFactor + t * dailyQuestLevelStep)` (±15%) e sempre maior que o do contrato anterior. Se não houver nenhum nessa faixa, usa os mais próximos.

Só entram monstros hostis, atacáveis e com experiência > 0. Para ajustar, edite o topo de `data/lib/300-dailyquests.lua`:
- `DailyQuest.monsterLevelOverrides["nome em minúsculas"] = level` força o level de um monstro.
- `DailyQuest.blacklist["nome em minúsculas"] = true` tira o monstro dos contratos.

## Recompensa
`kills * level do monstro * dailyQuestExpPerKillLevel` (experience) ou `* dailyQuestGoldPerKillLevel` (gold), multiplicada por `1 + contratos feitos no dia * dailyQuestTierBonus`.

## Configuração (`config.lua`)
| Opção | Padrão | O que faz |
|---|---|---|
| `dailyQuestsEnabled` | `true` | Liga/desliga o sistema |
| `dailyQuestMinKills`, `dailyQuestMaxKills` | 50, 100 | Faixa de kills de cada contrato |
| `dailyQuestMaxPerCategory` | 5 | Contratos por categoria por dia |
| `dailyQuestResetHour` | 5 | Hora do reset |
| `dailyQuestExpPerKillLevel`, `dailyQuestGoldPerKillLevel` | 5, 10 | Recompensa por kill por level do monstro |
| `dailyQuestTierBonus` | 0.25 | Bônus (+25%) por contrato já feito no dia |
| `dailyQuestBaseLevelFactor`, `dailyQuestLevelStep` | 0.5, 0.1 | Level do monstro do 1º contrato e quanto sobe a cada contrato |
| `dailyQuestMonsterLevelExponent`, `dailyQuestMonsterLevelMultiplier` | 0.6, 1.0 | Fórmula antiga (pela experiência), usada só por monstros sem dados de dano |
| `monsterLevelHorizon`, `monsterLevelBurstWeight`, `monsterLevelExponent`, `monsterLevelMultiplier` | 10, 0.4, 0.655, 0.61 | Fórmula do level calculado pela vida e pelo dano (ver `31-nivel-dos-monstros.md`) |

## Comandos
| Comando | Quem | O que faz |
|---|---|---|
| `!daily` | todos | Mostra os contratos, progresso, recompensas e tempo para o reset |
| `/dailymonsters <min>,<max>` ou `<nome>` | access 4 | Lista os monstros dos contratos com seu level |
| `/dailyreset <jogador>` | access 4 | Apaga os contratos do jogador (novos são gerados) |

## Para scripts
- `getMonsterList()` (C++): tabela com `name`, `experience`, `health`, `healthMax`, `race`, `bestiaryId`, `hostile`, `attackable`, `summonable` de todos os monstros.
- `DailyQuest.getMonsters()`: monstros usados nos contratos com `name`, `level` e `experience`, ordenados por level.
- `DailyQuest.getContract(cid, categoria)` (`"experience"` ou `"gold"`): contrato atual do jogador.

## Arquivos
`data/lib/300-dailyquests.lua` (lógica), `creaturescripts/scripts/dailyquest_login.lua` e `dailyquest_kill.lua`, `talkactions/scripts/daily.lua`, `globalevents/scripts/dailyquest.lua`.
