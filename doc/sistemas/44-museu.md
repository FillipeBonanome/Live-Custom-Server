# Salão de exposição dos uniques (museu)

## O que faz
Cria do zero, só com o chão (o resto fica no void), um salão onde cada unique de `data/XML/uniques.xml` fica exposto no chão. O jogador dá *look* no item e vê nome, descrição e atributos reais. A lista é lida do XML a cada build, então o salão acompanha a quantidade de uniques.

## Como entrar
Coloque no templo um teleporte para `1412, 505, 7` (`Museum.origin`). Ao pisar no teleporte de saída (logo atrás da origem) o jogador volta ao templo da própria cidade.

## Layout
- Fileiras de `Museum.columns` (9) itens, com 1 sqm livre entre eles (`Museum.spacing`).
- Grupos na ordem: capacetes, colares, armaduras, calças, botas, anéis, escudos, espadas, machados, clavas, distância, wands/rods, munição, outros. Uma fileira vazia separa os grupos.
- O chão (`Museum.ground`, 406 = white marble tile) cobre toda a área e cresce sozinho com o número de uniques. Tiles inexistentes são criados e tiles com o chão void (id 100, `Museum.voidGround`) têm o chão trocado pelo mármore; tiles com qualquer outro chão não são alterados.

## Quando é criado
- Ao ligar o servidor (`globalevents/scripts/museum.lua`).
- `/museum` (access 5) recria o salão sem reiniciar: use depois de mudar o `uniques.xml` e dar `/reload`.

## Bloqueio de movimento
O evento global `onMoveItem` (`creaturescripts/scripts/museum_moveitem.lua`) recusa qualquer movimento de item de ou para a área do salão (inclusive soltar itens lá).

## Configuração (`data/lib/405-museum.lua`, tabela `Museum`)
`origin`, `ground`, `voidGround`, `columns`, `spacing`, `firstRowOffset`, `pedestal` (altar 1642 embaixo de cada unique; 0 desliga), `cover` (item 8047 colocado por cima de cada unique para não ser pego; 0 desliga), `exclude` (nomes de uniques que não entram, ex.: segredos de lore), `itemActionId`, `exitActionId`, `exitItem`.
