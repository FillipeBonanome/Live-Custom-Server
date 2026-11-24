# Loot dos bosses

## O que faz
Os 24 bosses de invasão (ver [36-bosses.md](36-bosses.md) e [35-invasoes.md](35-invasoes.md)) dropam, além do loot normal do XML, itens próprios no corpo:

- **Uniques do boss**: cada boss tem 2 uniques temáticos (uma arma/varinha e uma peça de equipamento), definidos em `data/XML/uniques.xml` sem `chance` (só existem por este drop). Cada unique é sorteado **separadamente**, então um kill pode dropar nenhum, um ou os dois.
- **Runas de encantamento garantidas**: as mesmas runas que o Durnok Runebrand entalha ([38-runecarving.md](38-runecarving.md)). O tier da runa depende do tier do boss e 60% das runas são do elemento do boss, quando existe uma desse tier.

Se o corpo estiver cheio, o item cai no chão aos pés do boss. Quando um unique cai, todo o servidor recebe uma mensagem (`BossLoot.broadcast`).

## Tabela por tier
| Tier do boss | Chance de cada unique | Runas garantidas | Tier das runas (peso) |
|---|---|---|---|
| I | 20% | 1 | Uncommon 70, Rare 30 |
| II | 18% | 2 | Uncommon 30, Rare 60, Epic 10 |
| III | 16% | 2 | Rare 40, Epic 50, Legendary 10 |
| IV | 14% | 3 | Rare 20, Epic 60, Legendary 20 |
| V | 12% | 3 | Epic 40, Legendary 60 |

Os bônus dos uniques crescem com o tier (ex.: dano elemental no hit 4, 6, 9, 12 e 16; vida máxima 80 a 450). Os atributos base de ataque, defesa e armor são os do item original com um bônus pequeno.

## Uniques
| Boss (tier) | Uniques |
|---|---|
| Chief Grumbak (I) | Grumbak's Frostcleaver, Frozen Chieftain's Furs |
| Fenrak Moonfang (I) | Moonfang Blade, Alpha's Pelt Mail |
| Queen Silkara (I) | Silkara's Venom Fang, Brood Mother's Crown |
| Warlord Ruzad (I) | Ruzad's Warbrand, Warlord's Crushing Helm |
| Captain Blackreef (II) | Blackreef Cutlass, Captain's Sea Coat |
| Empress Aethra (II) | Aethra's Spearbow, Empress Circlet |
| Forgemaster Brokk (II) | Brokk's Forgehammer, Forgemaster's Plate |
| Hexlord Mokthar (II) | Mokthar's Hex Staff, Hexlord Horns |
| Hierarch Ssurrak (II) | Ssurrak's Sunblade, Hierarch's Scale Shield |
| Titan Korg (II) | Korg's Boulder Maul, Titan's Greaves |
| Vizier Khalzar (II) | Khalzar's Lamp Wand, Vizier's Slippers |
| Glaciarch Vorthrax (III) | Vorthrax Icebrand, Glaciarch's Plate |
| Iron Overseer Kragmor (III) | Kragmor's Overclock Axe, Overseer's Servo Boots |
| Necrarch Mortheus (III) | Mortheus' Harvest Rod, Harvester's Amulet |
| Nightmare Weaver Syrelith (III) | Syrelith's Dreamthread, Nightmare Greaves |
| Pyrothane the Cinderlord (III) | Pyrothane's Cinderblade, Cinderlord's Shield |
| Countess Sanguessa (IV) | Sanguessa's Bloodthorn, Countess' Crimson Mantle |
| Forgelord Vexmar (IV) | Vexmar's Plaguehammer, Plagueforged Legs |
| Matriarch Ignaria (IV) | Ignaria's Embertongue, Matriarch's Flamecrown |
| Warlord Zhardakkan (IV) | Zhardakkan's Drakebreaker, Draken Warplate |
| Wyrmlord Azhrakar (IV) | Azhrakar's Wyrmfang, Wyrmlord's Aegis |
| Archfiend Zulkarath (V) | Zulkarath's Hellbrand, Archfiend's Demonplate |
| Deathwyrm Nekhrazul (V) | Nekhrazul's Grave Staff, Deathwyrm Crown |
| Hellforged Overlord Malgorath (V) | Malgorath's Hellmaul, Overlord's Hellshield |

## Arquivos
- `data/lib/401-boss-loot.lua`: `BossLoot.bosses` (tier, elemento e uniques de cada boss), `uniqueChance`, `runeCount`, `runeTierWeights`, `elementChance` e `broadcast`.
- `data/creaturescripts/scripts/ai_death.lua`: chama `BossLoot.drop(cid, corpse)` na morte (o boss precisa do ataque `AI Think`, como todos os bosses).
- `data/XML/uniques.xml`: as definições dos uniques (bloco "Boss uniques").

## Boss novo
1. Registre o boss na lib de IA e nas invasões como de costume.
2. Crie 2 uniques no `uniques.xml`, sem `chance`.
3. Acrescente `["Nome do Boss"] = {tier = N, element = "fire", uniques = {"Unique 1", "Unique 2"}}` em `BossLoot.bosses`.

Para testar um unique sem matar o boss: `/unique Nome do Unique` (GM).
