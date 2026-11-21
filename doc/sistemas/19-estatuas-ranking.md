# Estátuas dos melhores jogadores

## Como funciona
- Existe uma estátua para o **top 1 de cada ranking** (os mesmos do `!rank`): level, magic, fist, club, sword, axe, distance, shielding e fishing. Cada uma usa o **outfit** do jogador (cores e addons) e mostra só o nome do jogador sobre a estátua. Ao dar look: `You see the statue of Nome, the best player in Level (250).` A barra de vida fica cheia (esconder a vida faz o client desenhar o nome quase invisível).
- As estátuas ficam na área 150,48,6 a 155,50,6 (só as 9 posições abaixo são usadas; o resto da área fica livre):

| | x=150 | x=152 | x=154 |
|---|---|---|---|
| y=48 | Level | Magic | Fist |
| y=49 | Club | Sword | Axe |
| y=50 | Distance | Shielding | Fishing |

- Staff (group 2 ou mais) e o Account Manager não entram. O desempate é por experiência (level), mana gasta (magic) ou pontos do skill.
- São atualizadas quando o servidor abre e a cada 10 minutos. Uma estátua só é recriada (com efeito de teleport) quando o jogador, o outfit ou a pontuação mudam.
- A estátua é o monstro `Rank Statue` (`data/monster/rankstatue.xml`): não pode ser atacada, empurrada nem andar, e não aparece no bestiary.

## Ajustes
- **Posições:** `RankStatues.categories` em `data/lib/330-rankstatues.lua` (cada linha tem `pos`). Para tirar um ranking, remova a linha.
- **Intervalo:** `interval` do evento `rankstatues` em `data/globalevents/globalevents.xml` (padrão 600000 ms).
- **Posição bloqueada:** se um jogador ou objeto estiver no tile, a estátua não é criada e o console avisa; ela é tentada de novo na próxima atualização.

## Para scripts
- C++: `doCreateNamedMonster(name, displayName, pos[, description])` cria o monstro já com outro nome (o `doCreateMonster` não permite) e devolve o uid, ou `false`.
- Lua: `RankStatues.update()` e `RankStatues.getTop(category)`.
- A estátua é marcada com o storage de criatura `52300` (usado para limpar estátuas antigas depois de um reload).
