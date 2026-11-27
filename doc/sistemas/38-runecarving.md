# Runecarving

## O que faz
As runas de encantamento (ver [12-encantamentos.md](12-encantamentos.md)) não são mais vendidas por NPC nem dropadas por monstros. A única runa à venda é a **blank rune** (id 2260). Quem transforma a blank rune em runa de encantamento é o NPC **Durnok Runebrand**, um anão runesmith (posição 145, 54, 7).

## Como usar
1. Comprar uma blank rune em um NPC de runas.
2. Falar com Durnok e dizer o nome da runa (`Flaming`). Ele explica o que a runa faz e pede 1 blank rune, ouro e gemas do elemento; `yes` confirma.
3. Usar a runa pronta sobre o equipamento com slot livre.

Palavras do NPC: `list` (runas que ele faz para você), `price`, `respect` (seu rank), `mission`, `deliver`.

## Tiers e preço
O tier é a raridade do encantamento e define o preço:

| Tier | Ouro | Gemas do elemento |
|---|---|---|
| Uncommon | 500 | 2 |
| Rare | 2.000 | 4 |
| Epic | 8.000 | 6 |
| Legendary | 30.000 | 10 |

Gemas: earth = small emerald, fire = small ruby, energy = small amethyst, ice = small sapphire, holy = small diamond, death = black pearl, arcane = white pearl.

As gemas só caem de **monstros epic** (ver [05-monstros-epic.md](05-monstros-epic.md)): o vínculo define a gema (Blazing = ruby, Frozen = sapphire, Venomous = emerald, Storm = amethyst, Radiant = diamond, Cursed = black pearl, Tidal = white pearl, que cobre o elemento arcane). Foram removidas do loot de todos os monstros.

## Respeito e missões
Durnok faz as runas Uncommon para qualquer um. Os tiers seguintes são liberados pelo **respeito** (pontos), ganho entregando itens das missões. As missões são lineares (uma por vez, `mission` mostra a atual, `deliver` entrega tudo de uma vez) e cada uma vale uma vez.

| Rank | Respeito | Libera |
|---|---|---|
| Stranger | 0 | Uncommon |
| Apprentice of the Forge | 30 | Rare |
| Forge Companion | 100 | Epic |
| Heart of the Mountain | 250 | Legendary |

Itens pedidos (todos já existem nas hunts): minotaur leather, lizard scale, wolf paw (rank 2); giant spider silk, beholder eye, red dragon scale, red piece of cloth (rank 3); demon horn, demonic essence, perfect behemoth fang, Morgaroth's heart, soul orb (rank 4). Quantidades e respeito de cada uma em `RuneCarving.missions`.

## Arquivos
- `data/lib/399-runecarving.lua`: preços (`tiers`), gemas (`materials`), receitas (`recipes`), descrições das runas (`descriptions`, mantenha em sincronia com `enchantments.xml`), ranks (`ranks`) e missões (`missions`). O progresso fica nos storages 56000 (respeito) e 56001+ (missão entregue). Nunca reordene as missões; acrescente no fim.
- `data/npc/Durnok Runebrand.xml` e `data/npc/scripts/runesmith.lua`: o NPC.
- `data/world/Styller-spawn.xml`: posição do NPC.

## Lua
`RuneCarving.carve(cid, "Flaming")` (retorna `true` ou `false, motivo`), `RuneCarving.description("Flaming")`, `RuneCarving.getRank(cid)`, `RuneCarving.getRespect(cid)`.

## Venda de gemas (Geomancer)
O Durnok também vende as 5 **gemas grandes** do Geomancer (violet 2153, yellow 2154, green 2155, red 2156, blue 2158), 5000 de ouro cada, pela janela de **trade** (`shop_buyable` e `module_shop` em `data/npc/Durnok Runebrand.xml`) ou por conversa (`gems`, depois a cor e `yes`, 1 por vez). Não têm relação com as gemas pequenas das runas. Preços em `RuneCarving.gems`; a compra é `RuneCarving.buyGem(cid, cor)` (retorna `true, gema` ou `false, motivo`) e só tira o ouro se a gema couber na mochila. Ver [43-geomancer.md](43-geomancer.md).
