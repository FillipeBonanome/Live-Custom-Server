# Daily Login

Recompensa diária: o jogador usa um pilar no templo uma vez por dia. Dias seguidos aumentam a **streak**; pular um dia volta a streak para 1.

## Como funciona
- O item (pilar, id `1514`) fica em `165, 53, 7` com **action id `9800`** (colocado pelo Remere's Map Editor). Qualquer item com esse action id funciona; o id e o action id ficam em `DailyLogin` (`data/lib/380-dailylogin.lua`) e em `data/actions/actions.xml`.
- O dia muda às `dailyLoginResetHour` (padrão 5h, horário do servidor, igual aos contratos).
- As recompensas giram num ciclo de 7 dias (`DailyLogin.rewards`): ouro, experiência (por level do jogador) e itens. O dia 7 é o melhor. A streak continua crescendo depois do dia 7 e cada ciclo completo soma `cycleBonus` (+10%, máximo +100%) ao ouro e à experiência.
- Se o jogador não tem espaço ou capacidade para os itens, nada é consumido e ele pode tentar de novo.
- No login, o jogador recebe um aviso azul no console se ainda não pegou a recompensa do dia.
- O texto animado **Daily Streak** (amarelo) aparece em `165, 53, 7` (`data/globalevents/scripts/texto.lua`).

## Arquivos
| Arquivo | Função |
|---|---|
| `data/lib/380-dailylogin.lua` | Tabela `DailyLogin`: recompensas, cálculo de dia/streak e `DailyLogin.claim(cid)` |
| `data/actions/scripts/dailylogin.lua` | Ação do pilar |
| `data/creaturescripts/scripts/dailylogin_login.lua` | Aviso no login (evento `DailyLoginLogin`) |

## Configuração (`config.lua`)
- `dailyLoginEnabled` (padrão `true`)
- `dailyLoginResetHour` (padrão `5`)

## Storages
`54200` (dia do último resgate) e `54201` (streak atual). Reservados.

## Textos do templo
Todos os textos animados do templo (`texto.lua` e `placa*.lua`) usam `TEXTCOLOR_YELLOW` (210).
