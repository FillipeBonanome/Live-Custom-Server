# Tutorial e `!help`

## Fluxo do primeiro login
Personagem novo (sem `firstitems`) vai ao labirinto, depois ao Guardian of Origins (idioma, lore, raça) e ao templo. A vocação já vem do account manager, então o tutorial só a **explica**.

Questlog "Tutorial" (storage `52211`, definido em `data/XML/quests.xml`):

| Passo | NPC / ação | Palavra |
|---|---|---|
| 1 | Guardian of Origins: escolhe a raça | |
| 2 | Brannoc: treino e tasks | `basics` |
| 3 | Durnok Runebrand: runas | `basics` |
| 4 | Huntmaster Kael: prey, `!daily`, `!bestiary` | `basics` |
| 5 | Brannoc: explica a vocação do jogador | `vocation` |
| 6 | Primeira caçada: pega uma task com Brannoc e diz `reward`. Ele ensina `!autoloot`, a morte e o `!help` | `reward` |
| 7 | Fim | |

Cada NPC só avança a quest a partir do passo anterior (`doPlayerAdvanceTutorialQuest`), mas a explicação pode ser ouvida de novo a qualquer hora. `!resettutorial` (access 5) recomeça tudo.

## Próxima etapa dita pelos NPCs
Quem está na quest ouve o próximo passo: o NPC fala logo depois de cumprimentar (Brannoc, Durnok e Kael) e quando o jogador diz `next` (ou `proximo`, `etapa`, `passo`). Se o próximo passo for com o próprio NPC ele diz "diga X para mim", senão diz com quem falar e o que dizer. Fora da quest ele não fala nada na saudação, e em `next` responde que o jogador não está no tutorial. O Guardian também diz o passo se o jogador falar com ele depois da raça.
Os textos ficam em `TUTORIAL_NEXT` (`data/lib/201-tutorial.lua`), com `getPlayerTutorialHint(cid, npc)` e `doNpcTutorialHintLater(npcHandler, cid, npc)`. Um passo novo precisa de uma entrada ali.

## Falas da vocação
`VOCATIONS` em `data/npc/scripts/trainer_tasks.lua`, indexado pela vocação **base** (as promovidas usam a da base). Duas falas por idioma. Para uma nova vocação, acrescente uma entrada.

## `!help`
`data/talkactions/scripts/help.lua`. `!help` lista os assuntos, `!help <assunto>` explica (aceita o nome em inglês e em português, tabela `WORDS`). Assuntos: tasks, prey, daily, bestiary, autoloot, items, enchant, glyphs, buffs, death, vocation, language. Os textos são bilíngues (`Language.text`). Para um assunto novo: entrada em `TOPICS`, na `ORDER` e em `WORDS`. O `!help` também está na mensagem de boas-vindas (`logincommands.lua`).

## Pendências
- Ainda não testado no jogo.
- Quem já tinha terminado o tutorial antigo (passo 4) volta a ter a quest em andamento.
- Fight mode e glifos por vocação a fundo ainda não têm assunto no `!help`.
