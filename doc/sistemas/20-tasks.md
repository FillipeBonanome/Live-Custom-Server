# Tasks de caça (NPC Task Master)

## Como funciona
- O **Task Master** fica em 431,351,10. O jogador fala o nome da criatura (ex.: `rotworm`, `dragons`) e o NPC oferece a task: **{kill X Criaturas}** pela recompensa **{Y}** (ouro, experiência ou item). Responder `yes` inicia, `no` cancela.
- **Task points e tiers:** cada task pertence a um tier (1 a 7) e cada tier exige um total de task points para ser liberado. Concluir uma task dá pontos conforme o tier dela e o jogador recebe um rank. Os pontos nunca são gastos e as tasks são **repetíveis**, então dá para farmar pontos.

| Tier | Rank | Pontos para liberar | Pontos por task | Tasks |
|---|---|---|---|---|
| 1 | Rookie Hunter | 0 | 5 | rotworm, dwarf, minotaur, elf scout |
| 2 | Apprentice Hunter | 20 | 8 | tortoise, sibang, lizard templar, cyclops |
| 3 | Adept Hunter | 60 | 12 | pirate cutthroat, blue djinn, giant spider, bog raider |
| 4 | Veteran Hunter | 120 | 16 | quara mantassin, mutated bat, vampire bride |
| 5 | Elite Hunter | 220 | 22 | dragon, hydra, dragon lord, frost dragon |
| 6 | Master Hunter | 380 | 30 | hellfire fighter, behemoth, warlock, infernalist, medusa |
| 7 | Legendary Hunter | 600 | 40 | demon |

- **`!tasks`**: mostra a task ativa e o progresso, a recompensa, os task points, o rank, quanto falta para o próximo rank e quantas tasks estão liberadas.
- No NPC: `list` mostra as tasks liberadas e as bloqueadas (com os pontos necessários), `points`/`rank` mostra os pontos e quanto falta para o próximo rank. Pedir uma task bloqueada é recusado.
- O jogador só tem **1 task por vez**. Se já tiver uma e aceitar outra, o NPC avisa na oferta que a antiga será reiniciada, e ao aceitar o progresso anterior é perdido.
- A cada criatura morta o jogador recebe uma mensagem **azul** com o progresso (`Task: 12/100 Rotworms killed.`). Ao completar, a mensagem avisa para voltar ao NPC. Summons de jogadores não contam.
- No NPC: `status` mostra o progresso; `reward` (ou `task`) entrega a recompensa de uma task concluída. Se o item não couber na mochila, a task continua concluída e dá para tentar de novo.
- O progresso fica em storages do jogador (54000 = task, 54001 = kills, 54002 = concluída, 54003 = task points), então sobrevive a relog e restart. Ao logar o jogador vê o estado da task.

## Onde mexer
- `data/lib/340-tasks.lua`: `Tasks.tiers` (pontos para liberar, pontos por task e rank) e `Tasks.list` (tier, kills e recompensa de cada task). Para criar uma nova: adicione em `Tasks.list` (com o `tier`) **e** no final de `Tasks.order` (a posição é o id salvo; nunca reordene).
- `data/npc/scripts/tasks.lua` e `data/npc/Task Master.xml`: diálogo do NPC.
- `data/creaturescripts/scripts/task_kill.lua` / `task_login.lua`: contagem e registro (eventos `TaskKill` e `TaskLogin`).
- Posição do NPC: `data/world/Styller-spawn.xml`.
