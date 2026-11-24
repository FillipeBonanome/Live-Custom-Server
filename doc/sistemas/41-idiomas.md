# Idiomas

## O que faz
Cada personagem escolhe o idioma (English ou Português). O idioma muda as **falas dos NPCs traduzidos** e as **mensagens de combate** do servidor ("Você perdeu X de vida...", "Você causou X de dano em..."). O que ainda não foi traduzido continua em inglês.

A primeira coisa que o Guardian of Origins pergunta, no tutorial do primeiro login, é o idioma (nas duas línguas). Depois disso ele fala só no idioma escolhido.

## Como usar
- Tutorial: dizer `English` ou `Portugues` ao Guardian of Origins.
- Mudar depois: `!language english` ou `!language portugues` (sem argumento mostra o idioma atual). Dizer o nome do idioma ao Guardian também troca.
- `!resettutorial` apaga o idioma, e o Guardian pergunta de novo.

## Estados (storage 52220)
`-1` = nunca escolheu (conta como inglês), `1` = English, `2` = Portuguese. O mesmo número é lido pelo C++ (`Player::LANGUAGE_STORAGE`, `Player::isPortuguese()` em `src/player.h`).

## Traduzir um NPC
Os textos viram tabelas com uma entrada por idioma, lidas por `Language.text(cid, texto)`. Idioma que falta na tabela cai em inglês:

```lua
npcHandler:say(Language.text(cid, {en = "Hello, adventurer.", pt = "Ola, aventureiro."}), cid)
Language.send(cid, MESSAGE_STATUS_CONSOLE_BLUE, {en = "Done.", pt = "Pronto."})
```
O exemplo completo é `data/npc/scripts/tutorial.lua`. Nunca use a palavra "jogador"/"player" nas falas. Textos sem acento (encoding dos arquivos). Dentro do NPC, o nome de quem fala é `getCreatureName(cid)`.

## Novo idioma
1. Acrescentar o id e as palavras que o escolhem em `Language.list` (`data/lib/202-language.lua`).
2. Acrescentar a chave nos textos já traduzidos.
3. Para as mensagens de combate, estender `Player::isPortuguese()` (C++) para um `getLanguage()` e as frases em `player.cpp`/`game.cpp`.

## Ainda em inglês (para ir traduzindo)
Brannoc, Durnok Runebrand, Magister Cassian Vael e os demais NPCs; o popup com o texto das raças (`getRaceDescription`); o texto do Quest Log (`data/XML/quests.xml`, fixo em português); as demais mensagens do servidor.

## Arquivos
- `data/lib/202-language.lua`: `Language.getChosen/get/set/clear/find/text/send`.
- `data/talkactions/scripts/language.lua`: `!language`.
- `src/player.cpp`, `src/player.h`, `src/game.cpp`: mensagens de combate. Precisa recompilar.
- `data/npc/scripts/tutorial.lua`: o Guardian, bilíngue.
- `data/npc/scripts/trainer_tasks.lua`: o Brannoc, bilíngue. Aceita palavras-chave nos dois idiomas (tabela `ALIASES`) e nunca traduz nomes de criaturas.

## NPCs traduzidos sem reescrever (camada de tradução)

Para NPCs antigos em inglês, `Language.install()` no fim do script envolve o `selfSay` e o `onCreatureSay` (`data/lib/202-language.lua`). Cada fala em inglês é trocada pela versão em português (quando o jogador escolheu português) e as palavras em português que o jogador diz viram a palavra-chave em inglês que o script entende. Os textos ficam em `data/lib/203-npc-texts.lua`: `Language.add("english @", "portugues %1")` (o `@` é qualquer trecho) e `Language.alias({"sim"}, "yes")`. Fala sem entrada continua em inglês.

NPCs com essa camada: Riona, Yasir, Rashid, Dufi, John Wayne (NPC Montaria), Obi, Raphael, Mad, King Johnny, Dark Rodo, Priest, Bursar Halvard (antigo Guild Treasurer) e Huntmaster Kael (antigo Prey Master). O Sweaty Cyclops foi reescrito (`itens.lua`) com textos `{en, pt}`.

Limites: mensagens vindas das libs (lista de bônus da guild, `Prey.describe`, mensagens da janela de trade) continuam parcialmente em inglês.
