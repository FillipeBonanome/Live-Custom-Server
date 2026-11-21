# Tasks de caça (NPC Task Master)

## Como funciona
- O **Task Master** fica em 431,351,10. O jogador fala o nome da criatura (ex.: `rotworm`, `dragons`) e o NPC oferece a task: **{kill X Criaturas}** pela recompensa **{Y}** (ouro, experiência ou item). Responder `yes` inicia, `no` cancela.
- Tasks disponíveis: rotworm, cyclops, dragon, giant spider, bog raider, demon e mais 19 criaturas da área 425,352,10 a 437,364,8 (dwarf, minotaur, elf scout, tortoise, sibang, lizard templar, pirate cutthroat, blue djinn, quara mantassin, mutated bat, vampire bride, hydra, dragon lord, frost dragon, hellfire fighter, behemoth, warlock, infernalist, medusa). Falar `list` no NPC mostra todas.
- O jogador só tem **1 task por vez**. Se já tiver uma e aceitar outra, o NPC avisa na oferta que a antiga será reiniciada, e ao aceitar o progresso anterior é perdido.
- A cada criatura morta o jogador recebe uma mensagem **azul** com o progresso (`Task: 12/100 Rotworms killed.`). Ao completar, a mensagem avisa para voltar ao NPC. Summons de jogadores não contam.
- No NPC: `status` mostra o progresso; `reward` (ou `task`) entrega a recompensa de uma task concluída. Se o item não couber na mochila, a task continua concluída e dá para tentar de novo.
- O progresso fica em storages do jogador (54000 = task, 54001 = kills, 54002 = concluída), então sobrevive a relog e restart. Ao logar o jogador vê o estado da task.

## Onde mexer
- `data/lib/340-tasks.lua`: lista `Tasks.list` (kills e recompensa de cada task). Para criar uma nova: adicione em `Tasks.list` **e** no final de `Tasks.order` (a posição é o id salvo; nunca reordene).
- `data/npc/scripts/tasks.lua` e `data/npc/Task Master.xml`: diálogo do NPC.
- `data/creaturescripts/scripts/task_kill.lua` / `task_login.lua`: contagem e registro (eventos `TaskKill` e `TaskLogin`).
- Posição do NPC: `data/world/Styller-spawn.xml`.
