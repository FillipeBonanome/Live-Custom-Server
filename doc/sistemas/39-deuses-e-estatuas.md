# Os Onze: deuses e estátuas de benção

## O que faz
O mundo tem **onze deuses**. Cada um tem estátuas espalhadas pelo jogo: **usar a estátua** dá ao jogador a **benção** do deus por **2 horas** (tempo real). As bênçãos aparecem no `!buffs` (categoria `Blessing of <Deus>`), com o tempo restante.

Regras:
- **Não acumulam:** a mesma benção não soma nem é renovada enquanto dura (a estátua avisa quanto tempo falta). Bênçãos de deuses diferentes podem ficar ativas ao mesmo tempo.
- **Sobrevivem ao logout:** o horário de fim fica em um storage do jogador e a benção é devolvida no login (evento `GodsLogin`).
- **Perdem-se na morte:** o evento `GodsDeath` zera tudo (`Morvaine`, o fim de todas as estradas, corta o fio).

## As bênçãos
Cada estátua vale um deus. O action id da estátua é `9810 +` a posição do deus na lista.

| Action id | Deus | Domínio | Benção (2h) |
|---|---|---|---|
| 9810 | Pyranor, o Forjador de Brasas | fogo | +15% de resistência a fire |
| 9811 | Skadrin, a Rainha do Inverno | gelo | +15% de resistência a ice |
| 9812 | Voltarion, o Senhor da Tempestade | energia | +15% de resistência a energy |
| 9813 | Verdantha, a Mãe Raiz | terra | +15% de resistência a earth |
| 9814 | Solanis, a Primeira Luz | sagrado | +15% de resistência a holy |
| 9815 | Morvaine, o Último Sono | morte | +15% de resistência a death |
| 9816 | Nerezza, a Voz das Profundezas | afogamento | +15% de resistência a drown |
| 9817 | Haemora, a Colheita Rubra | vida | +4% de life leech |
| 9818 | Orrelith, o Bebedor de Estrelas | mana | +4% de mana leech |
| 9819 | Azuriel, a Primeira Palavra | magia | +3 magic level |
| 9820 | Kharzul, o Mestre das Mil Batalhas | combate | +5 em todos os skills (menos fishing) |

Os valores ficam no topo de `data/lib/400-gods.lua` (`Gods.resistance`, `lifeLeech`, `manaLeech`, `magicLevel`, `skills`, `duration`).

## Como as estátuas são colocadas
- **Em jogo (staff, access 4):** `/godstatue <deus>` cria a estátua no tile à sua frente (ex.: `/godstatue pyranor`); `/godstatue remove` tira a da frente; `/godstatue list` lista os deuses. A estátua é salva na tabela `god_statues` (criada sozinha pelo Lua) e recriada quando o servidor abre.
- **No editor de mapa:** qualquer item de estátua com o action id do deus (tabela acima) funciona. Os itens usados pelo `/godstatue` são 1449 (Pyranor), 7446 (Skadrin), 1444 (Voltarion e Kharzul), 4861 (Verdantha), 1448 (Solanis), 1452 (Morvaine), 5671 (Nerezza), 1478 (Haemora), 1443 (Orrelith) e 1445 (Azuriel); mude em `Gods.list`.
- A estátua colocada por comando ganha a descrição "It is a statue of <Deus>, <título>. Use it to receive a blessing." (estátuas do editor de mapa não têm essa descrição, a menos que o item tenha `description` no mapa).

## Como funciona por dentro
- `data/lib/400-gods.lua`: lista `Gods.list` (deus, domínio, tipo de benção, item da estátua), `Gods.give/restore/clear/use`, e as estátuas salvas.
- A resistência elemental usa as novas conditions **`CONDITION_PARAM_ABSORB_<ELEMENTO>`** (source: `BONUS_ABSORB_*`), somadas ao absorb dos itens, outfit e vocação em `Player::blockHit` (o dano recebido cai 15%) e em `getElementalResistance`. **Precisa recompilar** (`compilar.bat`).
- Toda benção é uma `CONDITION_ATTRIBUTES` com sub id próprio (`8600 +` posição do deus), que acaba junto com a benção: resistência (`CONDITION_PARAM_ABSORB_*`), life leech, mana leech, magic level ou skills.
- Storages: `56100` a `56110` (horário de fim de cada benção, `os.time()`). Tabela do banco: `god_statues`.
- Arquivos: `actions/scripts/gods_statue.lua` (action ids 9810 a 9820 em `actions.xml`), `creaturescripts/scripts/gods.lua` (login e morte), `globalevents/scripts/gods.lua` (estátuas salvas na abertura), `talkactions/scripts/godstatue.lua`.

### Adicionar um deus
Acrescente uma linha no **fim** de `Gods.list` (a posição define o action id, o sub id e o storage: nunca reordene). Se passar de `9820`, amplie o `fromaid`/`toaid` em `actions.xml`.

---

# Lore dos Onze

## Antes de tudo: o Silêncio
No começo havia apenas o **Silêncio**, sem luz, sem chão, sem nome. Ele não era vazio: era um fôlego preso. Quando o fôlego enfim se soltou, saiu dele a **Primeira Palavra**, e a Palavra foi **Azuriel**. Tudo que Azuriel nomeou passou a existir. Nomeou a luz, e ela foi **Solanis**. Nomeou o fim da luz, e ele foi **Morvaine**, irmão gêmeo dela, porque nada que brilha existe sem a sombra que lhe dá forma.

Os outros vieram do que a Palavra tocou: o calor que sobrou da primeira sílaba, o frio que ficou no intervalo entre duas, o trovão do eco, o sussurro da raiz e a imensidão salgada de onde tudo ouviu. Assim nasceram os **Onze**.

Os deuses não criaram os mortais por bondade; criaram-nos por **curiosidade**. Queriam saber o que fariam criaturas que podem morrer. A resposta foi a história inteira do mundo, e os deuses nunca se cansaram dela.

## A Hora da Graça
Um deus não consegue ficar muito tempo entre os mortais sem se desfazer: a atenção divina queima quem a recebe e quem a dá. Na **Concordata do Primeiro Inverno**, os Onze fizeram um pacto com os povos do mundo: cada deus pode **pousar o olhar** sobre um mortal por **duas horas**, nem mais, nem menos. Para isso, os mortais erguem **estátuas** nas cidades, nas estradas e nas ruínas; é pela estátua que o deus enxerga, e por isso ela só responde a quem a toca e fala com o deus de olhos abertos.

A benção dura duas horas porque é o que o mundo suporta. Dois deuses podem olhar o mesmo mortal ao mesmo tempo, mas **o mesmo deus não olha duas vezes** enquanto o primeiro olhar ainda arde. A **morte** quebra tudo: o fio entre o deus e o mortal passa pela mão de Morvaine, e ele o corta quando alguém chega ao seu portão.

## Os Onze

### Os elementais

**Pyranor, o Forjador de Brasas** (fogo)
O mais antigo dos deuses depois de Azuriel. Nasceu do calor que a Primeira Palavra deixou ao ser dita e foi o primeiro a **trabalhar**: forjou as montanhas, as ilhas e o aço da primeira lâmina. É paciente e orgulhoso, e fala pouco, como quem ouve o metal. Os anões o veneram, e dizem que cada forja bem acesa tem uma brasa dele dentro. Seu lema: *"A forja nunca morre."*

**Skadrin, a Rainha do Inverno** (gelo)
Nasceu do silêncio entre duas sílabas. Não odeia ninguém: o inverno não é crueldade, é **resistência**. Foi companheira de Pyranor antes da primeira Guerra das Estações, e a rivalidade dos dois ainda explica por que o fogo derrete o gelo e o gelo apaga o fogo. Ensina a quem a segue a esperar, e a esperar bem. Seu lema: *"O inverno apenas suporta. Suporte comigo."*

**Voltarion, o Senhor da Tempestade** (energia)
O eco do trovão da Palavra tomou forma. Irmão de Nerezza (as nuvens e o mar são a mesma família), impetuoso, barulhento, o único dos Onze que ri alto. Gosta de quem se joga no perigo antes de pensar, e já destruiu uma torre inteira por ter achado a ordem das coisas "entediante". Seu lema: *"Deixe o trovão falar pelos seus ossos!"*

**Verdantha, a Mãe Raiz** (terra e veneno)
A voz baixa que vive sob a terra, nos pântanos, nas raízes e nas sementes. Mãe de tudo que cresce e de tudo que apodrece, porque, para ela, são o mesmo ciclo. Ensinou aos mortais que **todo veneno é remédio** e que a dose faz a diferença. Os povos dos pântanos, dos lagartos e dos elfos a invocam. Seu lema: *"Todo veneno é um remédio. Aprenda qual é qual."*

**Solanis, a Primeira Luz** (sagrado)
A primeira coisa que a Palavra nomeou. É a mais bondosa e a mais exigente: a luz não perdoa nada, **revela** tudo, inclusive o que o mortal prefere não ver. Gêmea de Morvaine, ela o ama e jamais o entenderá. Sacerdotes e hierofantes juram em seu nome. Seu lema: *"Onde eu brilho, nenhuma sombra guarda segredo."*

**Morvaine, o Último Sono** (morte)
Gêmeo de Solanis. Não é cruel nem bondoso: é **inevitável**. Guarda o portão ao fim de todas as estradas e jamais apressou ninguém, porque sabe que todos chegam. Os necromantes tentam enganá-lo, e ele acha graça. Respeita os que aceitam o fim sem mentiras. Seu lema: *"Sou o fim de toda estrada. Não vou apressá-lo."*

**Nerezza, a Voz das Profundezas** (afogamento)
Irmã de Voltarion e senhora do mar profundo, onde a luz não chega. O mar guarda tudo que toma, mas pode ser **convencido** a emprestar. Viajantes, piratas e pescadores lhe deixam oferendas antes de zarpar. É a mais misteriosa dos Onze: ninguém sabe o que ela quer. Seu lema: *"O mar guarda o que toma... mas pode ser convencido a emprestar."*

### Os de ofício

**Haemora, a Colheita Rubra** (life leech)
Filha de Verdantha. Aprendeu com a mãe que **a vida nunca se perde, apenas muda de mãos**, e levou a lição ao extremo: a vida de quem cai pertence a quem fica de pé. Caçadores, predadores e vampiros a invocam, cada um com seu sentido. Seu lema: *"A vida é uma dívida que os caídos pagam aos vivos. Cobre."*

**Orrelith, o Bebedor de Estrelas** (mana leech)
Dizem que cada estrela é uma taça e que Orrelith bebe de todas, sem derramar uma gota. Nasceu de um dos sopros de Azuriel. Magos que dominam o fluxo de mana (e os que roubam o dos outros) lhe fazem preces. É sereno, distraído e nunca está onde diz estar. Seu lema: *"Cada estrela é uma taça. Beba, e não derrame."*

**Azuriel, a Primeira Palavra** (magia)
O mais velho. Ele **foi** a Palavra que rompeu o Silêncio, e por isso toda magia é, no fundo, uma tentativa de dizer a mesma frase. Fala por enigmas e raramente ouve preces, mas escuta quem escuta. Estudiosos e magos o consideram patrono, e o Magister Cassian Vael costuma dizer que "ainda não terminamos de entender a primeira sílaba". Seu lema: *"Antes da luz, houve uma palavra. Ouça com atenção."*

**Kharzul, o Mestre das Mil Batalhas** (combate)
O único dos Onze que **nasceu mortal**. Foi um guerreiro que venceu mil batalhas sem nunca matar um inocente, e os deuses, em vez de lhe dar um trono, deram-lhe a eternidade. Ele nunca esqueceu o que era sangrar, e por isso treina todo mundo sem pena e sem desprezo. Guerreiros, arqueiros e duelistas treinam diante de suas estátuas. Seu lema: *"Uma lâmina só aprende com a mão que sangra. Treine, e suba."*

## Relações entre os deuses
- **Solanis e Morvaine**: gêmeos, luz e fim. Ela o ama; ele a respeita; nenhum dos dois entende o outro.
- **Pyranor e Skadrin**: foram companheiros, hoje são a rivalidade mais antiga do mundo.
- **Voltarion e Nerezza**: irmãos. O raio cai no mar e o mar devolve a chuva.
- **Verdantha e Haemora**: mãe e filha. Uma dá vida, a outra cobra de volta.
- **Azuriel e Orrelith**: o verbo e a sede. Tudo que é dito pode ser bebido.
- **Kharzul**: o único que já foi mortal; os outros dez o tratam com um respeito curioso.

## Ligações com o resto do mundo
- Os **anões** (e Durnok Runebrand) honram Pyranor; a **raça Lizard** e os **elfos** invocam Verdantha; os **Undead** devem a Morvaine um respeito mesclado de ressentimento.
- As **runas** são pedaços da Primeira Palavra: cada uma carrega uma sílaba. É por isso que o runesmith pede respeito antes de entalhar as mais fortes (ver [38-runecarving.md](38-runecarving.md)).
