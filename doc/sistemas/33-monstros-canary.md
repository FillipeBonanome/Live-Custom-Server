# Monstros do Canary (WoL) ausentes neste servidor

Comparação entre `E:\Program Files\WoL Canary\WoL Server\data-otservbr-global\monster` (1662 monstros) e os monstros do servidor atual (`data/monster` + `mods`). **1246** monstros do Canary não existem aqui (comparado por nome, sem acento/símbolos).

## Critérios
- **Cliente 8.6** (`Tibia.dat`: 367 outfits, itens até 11802): outfit com `lookType` > 367 ou `lookTypeEx` > 11802 não existe.
- **Ataques**: o parser XML (`src/monsters.cpp`) aceita `melee`, tipos de dano (`physical/fire/energy/earth/ice/holy/death/lifedrain/manadrain/drown/healing`), `speed`, `outfit`, `invisible`, `drunk`, `strength`, `effect`, campos, conditions e magias nomeadas existentes em `spells.xml`. Ataques `ring`, magias customizadas do Canary (`ice chain`, `X skill reducer`, `X wave`...) e tipos novos precisam ser reescritos.
- **Corpse**: os corpses do Canary usam IDs modernos; trocar por um corpse 8.6 é trivial e não conta como modificação.
- Também não é direto: `monster.events` / `mType.on*` (scripts Lua do Canary) e summons que não existem aqui.
- Os números de velocidade, `melee` (dano fixo no Canary, `skill/attack` aqui) e loot (por nome) precisam sempre ser convertidos.

## Resumo
| Grupo | Qtd |
|---|---|
| A. Porte direto (outfit e ataques ok) | 285 (corpse a trocar em 102) |
| B1. Só trocar o outfit | 395 |
| B2. Reescrever magias/ataques/summons | 242 |
| B3. Depende de script Lua (events) | 324 |

## A. Porte direto
| Monstro | Pasta | XP | HP | Outfit | Observações |
|---|---|---|---|---|---|
| Deathspawn | amphibics | 0 | 225 | 226 |  |
| Filth Toad | amphibics | 90 | 185 | 222 |  |
| Infernal Frog | amphibics | 190 | 655 | 224 |  |
| Deepsea Blood Crab | aquatics | 180 | 320 | 200 |  |
| Renegade Quara Hydromancer | aquatics | 1800 | 2000 | 47 |  |
| Renegade Quara Mantassin | aquatics | 1000 | 1200 | 72 |  |
| Renegade Quara Pincher | aquatics | 2200 | 2800 | 77 |  |
| Renegade Quara Predator | aquatics | 2700 | 3250 | 20 |  |
| Agressive Chicken | birds | 0 | 15000 | 111 |  |
| Agrestic Chicken | birds | 0 | 15 | 111 |  |
| Berserker Chicken | birds | 220 | 465 | 111 |  |
| Cave Parrot | birds | 0 | 30 | 217 |  |
| Demon Parrot | birds | 225 | 360 | 217 |  |
| Tame Terror Bird | birds | 0 | 300 | 218 |  |
| Antenna | bosses | 0 | 5000 | ex 850 | trocar corpse |
| Armenius (Creature) | bosses | 500 | 550 | 68 | bosstiary |
| Bibby Bloodbath | bosses | 1500 | 1200 | 2 | bosstiary |
| Brain Parasite | bosses | 0 | 7500 | 82 |  |
| Chikhaton | bosses | 20000 | 20000 | 361 | bosstiary |
| Clubarc The Plunderer | bosses | 400 | 400 | 342 | bosstiary |
| Ekatrix | bosses | 200 | 500 | 54 | trocar corpse; bosstiary |
| Elvira Hammerthrust | bosses | 165 | 245 | 70 | bosstiary |
| Freegoiz | bosses | 350000 | 80000 | 12 | bosstiary |
| Glitterscale | bosses | 700 | 1000 | 34 | trocar corpse; bosstiary |
| Heoni | bosses | 515 | 900 | 239 | trocar corpse; bosstiary |
| Incredibly Old Witch | bosses | 0 | 620 | 54 |  |
| Jesse the Wicked | bosses | 180 | 280 | 134 | trocar corpse; bosstiary |
| Kraknaknork's Demon | bosses | 0 | 120 | 12 | bosstiary |
| Morik the Gladiator | bosses | 160 | 1235 | 131 | trocar corpse; bosstiary |
| Mornenion | bosses | 115 | 190 | 64 | bosstiary |
| Robby the Reckless | bosses | 110 | 155 | 129 | trocar corpse; bosstiary |
| Teleskor | bosses | 70 | 80 | 298 | bosstiary |
| The Blightfather | bosses | 400 | 400 | 348 | trocar corpse; bosstiary |
| The Collector | bosses | 100 | 340 | 261 | bosstiary |
| The Frog Prince | bosses | 1 | 55 | 224 | bosstiary |
| Verminor | bosses | 35000 | 80000 | 12 | bosstiary |
| Weakened Demon | bosses | 0 | 5 | 12 | trocar corpse; bosstiary |
| Willi Wasp | bosses | 250 | 250 | 44 | bosstiary |
| Yaga the Crone | bosses | 375 | 620 | 54 | trocar corpse; bosstiary |
| Zavarash | bosses | 21000 | 35000 | 12 | bosstiary |
| Zushuka | bosses | 9000 | 15000 | 149 | trocar corpse; bosstiary |
| Clay Guardian | constructs | 400 | 625 | 333 | trocar corpse |
| Brittle Skeleton | dawnport | 35 | 50 | 33 |  |
| Crazed Dwarf | dawnport | 50 | 105 | 69 |  |
| Dawn Bat | dawnport | 10 | 30 | 122 |  |
| Dawn Scorpion | dawnport | 45 | 65 | 43 |  |
| Juvenile Cyclops | dawnport | 130 | 260 | 22 |  |
| Lesser Fire Devil | dawnport | 110 | 175 | 40 |  |
| Muglex Clan Assassin | dawnport | 48 | 75 | 296 |  |
| Muglex Clan Scavenger | dawnport | 37 | 60 | 297 |  |
| Sacred Snake | dawnport | 0 | 10 | 28 | trocar corpse |
| Scar Tribe Shaman | dawnport | 85 | 115 | 6 |  |
| Scar Tribe Warrior | dawnport | 85 | 125 | 7 |  |
| Troll Marauder | dawnport | 40 | 70 | 281 | trocar corpse |
| Dawnfire Asura | demons | 4100 | 2900 | 150 | trocar corpse |
| Duskbringer | demons | 2600 | 3550 | 300 |  |
| Frost Flower Asura | demons | 4200 | 3500 | 150 | trocar corpse |
| Herald of Gloom | demons | 450 | 340 | 320 |  |
| Midnight Asura | demons | 4100 | 3100 | 150 | trocar corpse |
| Shadow Hound | demons | 600 | 555 | 322 |  |
| High Voltage Elemental | elementals | 1500 | 1500 | 293 |  |
| Essence of Darkness | event_creatures | 30 | 1000 | 315 |  |
| Memory of a Banshee | event_creatures | 1430 | 3600 | 78 |  |
| Memory of a Dwarf | event_creatures | 1460 | 3730 | 70 |  |
| Memory of a Hero | event_creatures | 1750 | 3850 | 73 | trocar corpse |
| Memory of a Hydra | event_creatures | 1800 | 3550 | 121 |  |
| Memory of a Lizard | event_creatures | 1450 | 3520 | 337 |  |
| Memory of a Mammoth | event_creatures | 1830 | 3850 | 199 |  |
| Memory of a Pirate | event_creatures | 1500 | 3750 | 97 | trocar corpse |
| Memory of a Scarab | event_creatures | 1590 | 3620 | 79 |  |
| Memory of a Vampire | event_creatures | 1550 | 3650 | 68 |  |
| Memory of a Yalahari | event_creatures | 1640 | 3540 | 309 | trocar corpse |
| Memory of an Amazon | event_creatures | 1480 | 3600 | 137 | trocar corpse |
| Memory of an Elf | event_creatures | 1440 | 3440 | 63 |  |
| Party Skeleton | event_creatures | 0 | 40 | 33 |  |
| Spectral Scum | event_creatures | 0 | 1 | 195 |  |
| Dryad | fey | 190 | 310 | 137 | trocar corpse |
| Swan Maiden | fey | 700 | 800 | 138 | trocar corpse |
| Dwarf Henchman | humanoids | 15 | 350 | 160 |  |
| Dwarf Miner | humanoids | 60 | 120 | 160 |  |
| Elf Overseer | humanoids | 200 | 220 | 159 |  |
| Firestarter | humanoids | 80 | 180 | 159 | trocar corpse |
| Furious Orc Berserker | humanoids | 0 | 210 | 8 |  |
| Minotaur Invader | humanoids | 1600 | 1850 | 29 |  |
| Minotaur Occultist | humanoids | 100 | 125 | 23 |  |
| Minotaur Poacher | humanoids | 55 | 160 | 24 |  |
| Minotaur Totem | humanoids | 500 | 6000 | ex 2299 | trocar corpse |
| Running Elite Orc Guard | humanoids | 0 | 950 | 2 |  |
| Troll Guard | humanoids | 25 | 60 | 281 | trocar corpse |
| Troll Legionnaire | humanoids | 140 | 210 | 53 |  |
| Young Troll | humanoids | 12 | 30 | 15 |  |
| Acolyte of Darkness | humans | 200 | 325 | 9 | trocar corpse |
| Adventurer | humans | 0 | 65 | 129 | trocar corpse |
| Angry Adventurer | humans | 50 | 65 | 129 | trocar corpse |
| Crypt Defiler | humans | 70 | 185 | 146 | trocar corpse |
| Glooth Bandit | humans | 2000 | 2600 | 129 | trocar corpse |
| Glooth Brigand | humans | 1900 | 2400 | 137 | trocar corpse |
| Grave Robber | humans | 65 | 165 | 146 | trocar corpse |
| Monk of the Order | humans | 200 | 240 | 57 | trocar corpse |
| Renegade Knight | humans | 1200 | 1450 | 268 | trocar corpse |
| Vicious Squire | humans | 900 | 1000 | 131 | trocar corpse |
| Vile Grandmaster | humans | 1500 | 1700 | 268 | trocar corpse |
| Bonelord | magicals | 170 | 260 | 17 |  |
| Elder Bonelord | magicals | 280 | 500 | 108 |  |
| Merikh the Slaughterer | magicals | 1500 | 2000 | 103 | bosstiary |
| Doom Deer | mammals | 200 | 405 | 31 |  |
| Enraged Squirrel | mammals | 15 | 35 | 274 | trocar corpse |
| Evil Sheep | mammals | 240 | 350 | 14 |  |
| Mushroom Sniffer | mammals | 0 | 250 | 60 |  |
| Starving Wolf | mammals | 65 | 85 | 27 |  |
| Terrified Elephant | mammals | 160 | 320 | 211 |  |
| Thieving Squirrel | mammals | 15 | 55 | 274 | trocar corpse |
| Vampire Pig | mammals | 165 | 305 | 60 |  |
| Wild Dog | mammals | 0 | 20 | 32 |  |
| Bane Bringer | plants | 400 | 2500 | 310 |  |
| a carved stone tile | quests | 0 | 100 | ex 516 | trocar corpse |
| Angry Demon | quests | 6000 | 8200 | 35 |  |
| Animated Cyclops | quests | 150 | 260 | 22 |  |
| Animated Mummy | quests | 150 | 240 | 65 |  |
| Animated Rotworm | quests | 40 | 65 | 26 |  |
| Animated Skunk | quests | 3 | 20 | 106 |  |
| Animated Stone Golem | quests | 160 | 270 | 67 |  |
| Baby Dragon | quests | 185 | 380 | 271 | trocar corpse |
| Baron Brute | quests | 3000 | 5025 | 2 |  |
| Biting Cold | quests | 0 | 10000 | 53 | bosstiary |
| Black Cobra | quests | 0 | 10000 | 81 | trocar corpse |
| Boogey | quests | 475 | 930 | 300 | bosstiary |
| Bretzecutioner | quests | 3700 | 5600 | 236 | bosstiary |
| Brother Chill | quests | 0 | 10000 | 261 | bosstiary |
| Brother Freeze | quests | 0 | 10000 | 261 | bosstiary |
| Cave Spider | quests | 2000 | 1800 | 38 | trocar corpse; bosstiary |
| Coldheart | quests | 3500 | 7000 | 261 |  |
| Condensed Sin | quests | 0 | 12000 | 315 | trocar corpse |
| Containment Crystal | quests | 0 | 20000 | ex 7805 | trocar corpse |
| Containment Machine | quests | 0 | 6500 | ex 8988 | trocar corpse |
| Cosmic Energy Prism A Invu | quests | 840 | 1000 | ex 2187 | trocar corpse |
| Cosmic Energy Prism B Invu | quests | 840 | 1000 | ex 2187 | trocar corpse |
| Cosmic Energy Prism C Invu | quests | 840 | 1000 | ex 2187 | trocar corpse |
| Cosmic Energy Prism D Invu | quests | 840 | 1000 | ex 2187 | trocar corpse |
| Damned Soul | quests | 300 | 800 | 232 | trocar corpse |
| Dark Druid | quests | 0 | 1800 | 144 | trocar corpse |
| Dark Knight | quests | 0 | 1800 | 131 | trocar corpse |
| Dark Paladin | quests | 0 | 1800 | 129 | trocar corpse |
| Dark Sorcerer | quests | 0 | 1800 | 130 | trocar corpse |
| Deathbine | quests | 340 | 525 | 120 | bosstiary |
| Demon Goblin | quests | 25 | 50 | 35 |  |
| Demon Slave | quests | 0 | 10000 | 35 |  |
| Depowered Minotaur | quests | 1100 | 1500 | 25 |  |
| Desperate Soul | quests | 0 | 15 | 262 |  |
| Destroyed Pillar | quests | 0 | 20000 | ex 7811 | trocar corpse |
| Doctor Perhaps | quests | 325 | 475 | 133 | trocar corpse; bosstiary |
| Doomhowl | quests | 3750 | 8500 | 308 | trocar corpse |
| Dorokoll The Mystic Stop | quests | 0 | 15000 | 154 | trocar corpse |
| Dragon Servant | quests | 2100 | 1900 | 39 |  |
| Dreadful Harvester | quests | 25500 | 25500 | 300 | trocar corpse |
| Earworm | quests | 2000 | 4000 | 26 | trocar corpse |
| Electric Sparks | quests | 320 | 2000 | ex 470 | trocar corpse |
| Enraged Sand Brood | quests | 0 | 2600 | 82 |  |
| Esmeralda | quests | 600 | 800 | 305 | bosstiary |
| Evil Mastermind | quests | 675 | 1295 | 256 | bosstiary |
| Fatality | quests | 3250 | 6000 | 113 |  |
| Fazzrah | quests | 2600 | 2955 | 343 | bosstiary |
| Flame of Omrafir | quests | 550 | 800 | 49 |  |
| Fleshcrawler | quests | 1000 | 1450 | 79 | bosstiary |
| Force Field | quests | 0 | 10000 | ex 2128 | trocar corpse |
| Frozen Man | quests | 0 | 100 | ex 7311 | trocar corpse |
| Goldhanded Cultist | quests | 2000 | 3000 | 132 |  |
| Gorgo | quests | 7000 | 4500 | 330 | trocar corpse; bosstiary |
| Greater Death Minion | quests | 0 | 1500 | 65 |  |
| Haunter | quests | 4000 | 8500 | 320 |  |
| Hide | quests | 240 | 500 | 219 | bosstiary |
| Horadron | quests | 18000 | 30000 | 12 | bosstiary |
| Imp Intruder | quests | 100 | 1000 | 237 |  |
| Incineron | quests | 3500 | 7000 | 243 |  |
| Invading Demon | quests | 0 | 1000 | 35 |  |
| Jailer | quests | 45 | 65 | 298 | bosstiary |
| Kerberos | quests | 10000 | 11000 | 240 | bosstiary |
| Lesser Death Minion | quests | 0 | 550 | 33 |  |
| Lovely Deer | quests | 0 | 25 | 31 |  |
| Lovely Polar Bear | quests | 28 | 85 | 42 |  |
| Lovely Rotworm | quests | 40 | 65 | 26 |  |
| Lovely Scorpion | quests | 45 | 45 | 43 |  |
| Lovely Snake | quests | 10 | 15 | 28 |  |
| Lucifuga Aranea | quests | 10000 | 12000 | 263 |  |
| Malicious Minion | quests | 0 | 4000 | 40 |  |
| Malkhar Deathbringer Stop | quests | 0 | 15000 | 134 | trocar corpse |
| Mean Minion | quests | 0 | 10000 | 237 |  |
| Menace | quests | 3250 | 6000 | 113 |  |
| Mephiles | quests | 415 | 415 | 237 | bosstiary |
| Monstor | quests | 575 | 960 | 244 | bosstiary |
| Neferi the Spy | quests | 19650 | 28000 | 149 | trocar corpse; bosstiary |
| Oberon's Bile | quests | 20000 | 10000 | ex 10980 | trocar corpse |
| Oberon's Hate | quests | 20000 | 10000 | ex 10980 | trocar corpse |
| Oberon's Ire | quests | 20000 | 10000 | ex 11211 | trocar corpse |
| Oberon's Spite | quests | 20000 | 10000 | ex 11212 | trocar corpse |
| Orc Cult Fanatic | quests | 1100 | 1300 | 59 |  |
| Orc Cult Inquisitor | quests | 1150 | 1500 | 8 |  |
| Orc Cult Minion | quests | 850 | 1000 | 50 |  |
| Orc Cultist | quests | 950 | 1350 | 7 |  |
| Percht Minion | quests | 0 | 55 | 53 |  |
| Prince Drazzak | quests | 210000 | 330000 | 12 | bosstiary |
| Purple Butterfly | quests | 0 | 2 | 213 |  |
| Regenerating Mass | quests | 0 | 100000 | 238 | trocar corpse |
| Retainer of Baeloc | quests | 0 | 10000 | 100 | trocar corpse |
| Ribstride | quests | 1100 | 1000 | 101 |  |
| Rift Fragment | quests | 0 | 7200 | ex 2122 | trocar corpse |
| Rift Lord | quests | 0 | 5 | 12 | trocar corpse |
| Rift Phantom | quests | 0 | 150 | 48 |  |
| Rift Spawn | quests | 0 | 10000 | 12 |  |
| Risen Soldier | quests | 0 | 6000 | 306 | trocar corpse |
| Rocko | quests | 3400 | 10000 | 67 |  |
| Sand Brood | quests | 0 | 2100 | 82 |  |
| Security Golem | quests | 0 | 6500 | 326 | trocar corpse |
| Shardhead | quests | 650 | 800 | 261 | bosstiary |
| Soul Scourge | quests | 0 | 10000 | 300 | trocar corpse |
| Soulless Minion | quests | 0 | 2000 | 68 |  |
| Spawn of Havoc | quests | 0 | 10000 | 49 |  |
| Spirit of Fertility | quests | 1100 | 1250 | 11 | trocar corpse |
| Squire of Nictros | quests | 0 | 10000 | 306 | trocar corpse |
| Stolen Soul | quests | 0 | 5000 | 294 | trocar corpse |
| Strange Slime | quests | 0 | 15 | 19 | trocar corpse |
| Sulphur Scuttler | quests | 900 | 1300 | 352 | trocar corpse; bosstiary |
| Superior Death Minion | quests | 0 | 2500 | 84 | trocar corpse |
| Terofar | quests | 24000 | 40000 | 12 | bosstiary |
| The Axeorcist | quests | 3000 | 5100 | 8 |  |
| The Bloodtusk | quests | 300 | 600 | 199 |  |
| The Bloodweb | quests | 1450 | 1750 | 263 | bosstiary |
| The Cold of Winter | quests | 0 | 40 | 53 |  |
| The Devourer of Secrets | quests | 0 | 10000 | 309 | trocar corpse; bosstiary |
| The Dreadorian | quests | 4000 | 9000 | 234 |  |
| The Heat of Summer | quests | 0 | 280 | 49 |  |
| The Many | quests | 4000 | 5000 | 121 | bosstiary |
| The Noxious Spawn | quests | 6000 | 9500 | 220 | trocar corpse |
| The Snapper | quests | 150 | 300 | 119 | bosstiary |
| The Spellstealer | quests | 0 | 10000 | 12 | bosstiary |
| The Weakened Count | quests | 450 | 740 | 68 | bosstiary |
| Tormented Ghost | quests | 5 | 210 | 48 |  |
| Tormentor | quests | 3200 | 4100 | 245 | bosstiary |
| Travelling Merchant | quests | 0 | 110 | 132 | trocar corpse |
| Tremor Worm | quests | 80000 | 125000 | 295 | trocar corpse |
| Tremorak | quests | 1300 | 10000 | 285 | trocar corpse |
| Unbeatable Dragon | quests | 0 | 1900 | 39 | trocar corpse |
| Unbound Defiler | quests | 3700 | 3650 | 238 |  |
| Unbound Demon | quests | 5000 | 8200 | 35 |  |
| Vermin Swarm | quests | 0 | 5000 | 349 | trocar corpse |
| War Servant | quests | 0 | 10000 | 326 | trocar corpse |
| Warm Fire | quests | 220 | 200 | 49 |  |
| Weeping Soul | quests | 0 | 7000 | 48 | trocar corpse |
| Whirling Blades | quests | 0 | 1 | 102 |  |
| Wild Knowledge | quests | 0 | 2000 | 293 | trocar corpse |
| Yalahari Despoiler | quests | 0 | 10000 | 309 | trocar corpse |
| Zarcorix Of Yalahar | quests | 0 | 99999999 | 309 | trocar corpse |
| Battlemaster Zunzu | raids | 2500 | 4000 | 343 | trocar corpse; bosstiary |
| Captain Jones | raids | 620 | 555 | 196 | bosstiary |
| Chayenne | raids | 40000 | 100000 | 155 | bosstiary |
| Chizzoron the Distorter | raids | 4000 | 16000 | 340 | bosstiary |
| Fleabringer | raids | 100 | 265 | 341 | bosstiary |
| Ocyakao | raids | 490 | 700 | 259 | bosstiary |
| Orc Armor | raids | 670 | 950 | 2 |  |
| Orc Helmet | raids | 670 | 950 | 2 |  |
| Orc Sambackpack | raids | 25 | 70 | 5 |  |
| Orc Shield | raids | 670 | 950 | 2 |  |
| Rottie the Rotworm | raids | 40 | 65 | 26 | bosstiary |
| The Voice of Ruin | raids | 3500 | 5500 | 344 | bosstiary |
| Zulazza the Corruptor | raids | 10000 | 46500 | 334 | bosstiary |
| Dreadmaw | reptiles | 1500 | 2000 | 358 | bosstiary |
| Midnight Spawn | slimes | 900 | 2000 | 315 |  |
| Demon Summoner | traps | 0 | 100 | ex 470 | trocar corpse |
| Magic Pillar | traps | 0 | 1 | ex 2190 | trocar corpse |
| Mechanical Fighter | traps | 255 | 420 | 102 |  |
| Pillar | traps | 0 | 100 | ex 2190 | trocar corpse |
| Bane of Light | undeads | 750 | 1100 | 68 |  |
| Crypt Warrior | undeads | 6050 | 7800 | 298 |  |
| Death Priest | undeads | 750 | 800 | 99 | trocar corpse |
| Elder Mummy | undeads | 560 | 850 | 65 |  |
| Grave Guard | undeads | 485 | 720 | 234 | trocar corpse |
| Honour Guard | undeads | 55 | 85 | 298 |  |
| Skeleton Elite Warrior | undeads | 4800 | 7800 | 298 |  |
| Tomb Servant | undeads | 215 | 475 | 100 |  |
| Undead Elite Gladiator | undeads | 5090 | 8000 | 306 |  |
| Undead Mine Worker | undeads | 45 | 65 | 33 |  |
| Undead Prospector | undeads | 85 | 100 | 18 |  |
| Burrowing Beetle | vermins | 165 | 450 | 83 |  |
| Enpa Yolo | vermins | 0 | 65 | 26 |  |
| Sacred Spider | vermins | 330 | 550 | 219 |  |

## B1. Modificar só o outfit (ataques ok)
| Monstro | Pasta | XP | HP | Outfit | Observações |
|---|---|---|---|---|---|
| Usurper Knight | WOL | 6900 | 8200 | 1316 | outfit 1316 não existe no cliente 8.6; trocar corpse |
| Bog Frog | amphibics | 0 | 25 | 412 | outfit 412 não existe no cliente 8.6 |
| Salamander | amphibics | 25 | 70 | 529 | outfit 529 não existe no cliente 8.6; trocar corpse |
| Abyssal Calamary | aquatics | 200 | 300 | 451 | outfit 451 não existe no cliente 8.6; trocar corpse |
| Calamary | aquatics | 0 | 75 | 451 | outfit 451 não existe no cliente 8.6; trocar corpse |
| Crustacea Gigantica | aquatics | 1800 | 1600 | 383 | outfit 383 não existe no cliente 8.6; trocar corpse |
| Deathling Scout | aquatics | 6300 | 7200 | 1073 | outfit 1073 não existe no cliente 8.6; trocar corpse |
| Deathling Spellsinger | aquatics | 6400 | 7200 | 1088 | outfit 1088 não existe no cliente 8.6; trocar corpse |
| Deepling Brawler | aquatics | 260 | 380 | 470 | outfit 470 não existe no cliente 8.6; trocar corpse |
| Deepling Elite | aquatics | 3000 | 3200 | 441 | outfit 441 não existe no cliente 8.6; trocar corpse |
| Deepling Guard | aquatics | 2100 | 1900 | 442 | outfit 442 não existe no cliente 8.6; trocar corpse |
| Deepling Scout | aquatics | 160 | 240 | 413 | outfit 413 não existe no cliente 8.6; trocar corpse |
| Deepling Tyrant | aquatics | 4200 | 4500 | 442 | outfit 442 não existe no cliente 8.6; trocar corpse |
| Deepling Warrior | aquatics | 1500 | 1600 | 441 | outfit 441 não existe no cliente 8.6; trocar corpse |
| Deepling Worker | aquatics | 130 | 190 | 470 | outfit 470 não existe no cliente 8.6; trocar corpse |
| Fish | aquatics | 0 | 25 | 455 | outfit 455 não existe no cliente 8.6; trocar corpse |
| Jellyfish | aquatics | 0 | 55 | 452 | outfit 452 não existe no cliente 8.6; trocar corpse |
| Manta Ray | aquatics | 125 | 680 | 449 | outfit 449 não existe no cliente 8.6; trocar corpse |
| Northern Pike | aquatics | 0 | 95 | 454 | outfit 454 não existe no cliente 8.6; trocar corpse |
| Shark | aquatics | 700 | 1200 | 453 | outfit 453 não existe no cliente 8.6; trocar corpse |
| Jungle Moa | birds | 1200 | 1300 | 1534 | outfit 1534 não existe no cliente 8.6; trocar corpse |
| Marsh Stalker | birds | 50 | 100 | 530 | outfit 530 não existe no cliente 8.6; trocar corpse |
| Pigeon | birds | 0 | 30 | 531 | outfit 531 não existe no cliente 8.6; trocar corpse |
| Alchemist Container | bosses | 0 | 1200 | ex 39952 | outfit item 39952 fora do cliente; trocar corpse |
| Brain Head | bosses | 0 | 75000 | ex 32418 | outfit item 32418 fora do cliente; trocar corpse; bosstiary |
| Fleshslicer | bosses | 5500 | 5700 | 457 | outfit 457 não existe no cliente 8.6; trocar corpse; bosstiary |
| Groam | bosses | 180 | 400 | 413 | outfit 413 não existe no cliente 8.6; trocar corpse; bosstiary |
| Morshabaal | bosses | 3000000 | 1000000 | 1468 | outfit 1468 não existe no cliente 8.6; trocar corpse; bosstiary |
| Mutated Visco | bosses | 9800 | 28000 | 554 | outfit 554 não existe no cliente 8.6; trocar corpse; bosstiary |
| Raxias | bosses | 900 | 1100 | 980 | outfit 980 não existe no cliente 8.6; trocar corpse; bosstiary |
| Sugar Daddy | bosses | 15550 | 9500 | 1764 | outfit 1764 não existe no cliente 8.6; trocar corpse; bosstiary |
| Sugar Mommy | bosses | 6800 | 6000 | 1764 | outfit 1764 não existe no cliente 8.6; trocar corpse; bosstiary |
| The Rootkraken | bosses | 600000 | 360000 | 1765 | outfit 1765 não existe no cliente 8.6; trocar corpse; bosstiary |
| Animated Snowman | constructs | 400 | 450 | 1159 | outfit 1159 não existe no cliente 8.6; trocar corpse |
| Biting Book | constructs | 9350 | 6500 | 1066 | outfit 1066 não existe no cliente 8.6; trocar corpse |
| Damaged Crystal Golem | constructs | 0 | 500 | 508 | outfit 508 não existe no cliente 8.6; trocar corpse |
| Diamond Servant | constructs | 700 | 1000 | 397 | outfit 397 não existe no cliente 8.6; trocar corpse |
| Enraged Crystal Golem | constructs | 550 | 700 | 508 | outfit 508 não existe no cliente 8.6; trocar corpse |
| Gingerbread Man | constructs | 22 | 85 | 1738 | outfit 1738 não existe no cliente 8.6; trocar corpse |
| Goggle Cake | constructs | 2700 | 2700 | 1740 | outfit 1740 não existe no cliente 8.6; trocar corpse |
| Golden Servant | constructs | 450 | 550 | 396 | outfit 396 não existe no cliente 8.6; trocar corpse |
| Iron Servant | constructs | 210 | 350 | 395 | outfit 395 não existe no cliente 8.6; trocar corpse |
| Sandstone Scorpion | constructs | 680 | 900 | 398 | outfit 398 não existe no cliente 8.6; trocar corpse |
| Stone Devourer | constructs | 2900 | 4200 | 486 | outfit 486 não existe no cliente 8.6; trocar corpse |
| Weeper | constructs | 5800 | 6800 | 489 | outfit 489 não existe no cliente 8.6; trocar corpse |
| Dawnfly | dawnport | 35 | 90 | 528 | outfit 528 não existe no cliente 8.6; trocar corpse |
| Meadow Strider | dawnport | 50 | 100 | 530 | outfit 530 não existe no cliente 8.6; trocar corpse |
| Spidris Elite Summon | dawnport | 4000 | 5000 | 457 | outfit 457 não existe no cliente 8.6; trocar corpse |
| Troll-Trained Salamander | dawnport | 23 | 70 | 529 | outfit 529 não existe no cliente 8.6; trocar corpse |
| Brinebrute Inferniarch | demons | 20300 | 32000 | 1794 | outfit 1794 não existe no cliente 8.6; trocar corpse |
| Broodrider Inferniarch | demons | 7400 | 9600 | 1796 | outfit 1796 não existe no cliente 8.6; trocar corpse |
| Grimeleech | demons | 7216 | 9500 | 855 | outfit 855 não existe no cliente 8.6; trocar corpse |
| Hellhunter Inferniarch | demons | 8100 | 11300 | 1793 | outfit 1793 não existe no cliente 8.6; trocar corpse |
| Nightfiend | demons | 2100 | 2700 | 556 | outfit 556 não existe no cliente 8.6; trocar corpse |
| Spellreaper Inferniarch | demons | 8350 | 11800 | 1792 | outfit 1792 não existe no cliente 8.6; trocar corpse |
| True Dawnfire Asura | demons | 7475 | 8500 | 1068 | outfit 1068 não existe no cliente 8.6; trocar corpse |
| True Frost Flower Asura | demons | 7069 | 4000 | 1068 | outfit 1068 não existe no cliente 8.6; trocar corpse |
| True Midnight Asura | demons | 7313 | 9000 | 1068 | outfit 1068 não existe no cliente 8.6; trocar corpse |
| Wardragon | dragons | 5810 | 6960 | 1708 | outfit 1708 não existe no cliente 8.6; trocar corpse |
| Candy Floss Elemental | elementals | 3850 | 3700 | 1749 | outfit 1749 não existe no cliente 8.6; trocar corpse |
| Honey Elemental | elementals | 2400 | 2560 | 1733 | outfit 1733 não existe no cliente 8.6; trocar corpse |
| Ironblight | elementals | 5400 | 6600 | 498 | outfit 498 não existe no cliente 8.6; trocar corpse |
| Knowledge Elemental | elementals | 10603 | 10500 | 1065 | outfit 1065 não existe no cliente 8.6; trocar corpse |
| Lava Lurker | elementals | 4000 | 5900 | 1041 | outfit 1041 não existe no cliente 8.6; trocar corpse |
| Memory of a Book | event_creatures | 1770 | 3670 | 1060 | outfit 1060 não existe no cliente 8.6; trocar corpse |
| Memory of a Carnisylvan | event_creatures | 1850 | 3800 | 1418 | outfit 1418 não existe no cliente 8.6; trocar corpse |
| Memory of a Faun | event_creatures | 1600 | 3500 | 980 | outfit 980 não existe no cliente 8.6; trocar corpse |
| Memory of a Frazzlemaw | event_creatures | 1810 | 3770 | 594 | outfit 594 não existe no cliente 8.6; trocar corpse |
| Memory of a Fungus | event_creatures | 1660 | 3580 | 488 | outfit 488 não existe no cliente 8.6; trocar corpse |
| Memory of a Manticore | event_creatures | 1590 | 3730 | 1189 | outfit 1189 não existe no cliente 8.6; trocar corpse |
| Memory of a Shaper | event_creatures | 1750 | 3710 | 932 | outfit 932 não existe no cliente 8.6; trocar corpse |
| Memory of a Wolf | event_creatures | 1640 | 3640 | 918 | outfit 918 não existe no cliente 8.6 |
| Memory of an Insectoid | event_creatures | 1610 | 3630 | 403 | outfit 403 não existe no cliente 8.6; trocar corpse |
| Memory of an Ogre | event_creatures | 1680 | 3570 | 857 | outfit 857 não existe no cliente 8.6; trocar corpse |
| Pinata Dragon | event_creatures | 50 | 10000 | ex 25062 | outfit item 25062 fora do cliente; trocar corpse |
| Instable Sparkion | extra_dimensional | 1350 | 1900 | 877 | outfit 877 não existe no cliente 8.6; trocar corpse |
| Mitmah Scout | extra_dimensional | 3230 | 3940 | 1709 | outfit 1709 não existe no cliente 8.6; trocar corpse |
| Sparkion | extra_dimensional | 1520 | 2700 | 877 | outfit 877 não existe no cliente 8.6; trocar corpse |
| Monk familiar | familiars | 0 | 15000 | 1818 | outfit 1818 não existe no cliente 8.6; trocar corpse |
| Paladin familiar | familiars | 0 | 15000 | 992 | outfit 992 não existe no cliente 8.6; trocar corpse |
| Angry Sugar Fairy | fey | 3100 | 3000 | 1747 | outfit 1747 não existe no cliente 8.6; trocar corpse |
| Arctic Faun | fey | 300 | 300 | 980 | outfit 980 não existe no cliente 8.6; trocar corpse |
| Boogy | fey | 950 | 1300 | 981 | outfit 981 não existe no cliente 8.6; trocar corpse |
| Cream Blob | fey | 21 | 76 | 1757 | outfit 1757 não existe no cliente 8.6; trocar corpse |
| Dark Faun | fey | 900 | 1100 | 980 | outfit 980 não existe no cliente 8.6; trocar corpse |
| Faun | fey | 800 | 900 | 980 | outfit 980 não existe no cliente 8.6; trocar corpse |
| Fruit Drop | fey | 18 | 63 | 1754 | outfit 1754 não existe no cliente 8.6; trocar corpse |
| Nymph | fey | 850 | 900 | 989 | outfit 989 não existe no cliente 8.6; trocar corpse |
| Pooka | fey | 500 | 500 | 977 | outfit 977 não existe no cliente 8.6; trocar corpse |
| Sugar Cube | fey | 19 | 28 | 1753 | outfit 1753 não existe no cliente 8.6; trocar corpse |
| Sugar Cube Worker | fey | 20 | 65 | 1756 | outfit 1756 não existe no cliente 8.6; trocar corpse |
| Tainted Soul | fey | 0 | 250 | 712 | outfit 712 não existe no cliente 8.6; trocar corpse |
| Truffle | fey | 15 | 70 | 1750 | outfit 1750 não existe no cliente 8.6; trocar corpse |
| Truffle Cook | fey | 13 | 54 | 1751 | outfit 1751 não existe no cliente 8.6; trocar corpse |
| Twisted Pooka | fey | 600 | 700 | 978 | outfit 978 não existe no cliente 8.6; trocar corpse |
| Beast Hulking Prehemoth | giants | 0 | 20700 | 1553 | outfit 1553 não existe no cliente 8.6; trocar corpse |
| Hulking Prehemoth | giants | 12690 | 20700 | 1553 | outfit 1553 não existe no cliente 8.6; trocar corpse |
| Ogre Brute | giants | 800 | 1000 | 857 | outfit 857 não existe no cliente 8.6; trocar corpse |
| Ogre Rowdy | giants | 4200 | 4500 | 1213 | outfit 1213 não existe no cliente 8.6; trocar corpse |
| Ogre Ruffian | giants | 5000 | 5500 | 1212 | outfit 1212 não existe no cliente 8.6; trocar corpse |
| Ogre Savage | giants | 950 | 1400 | 858 | outfit 858 não existe no cliente 8.6; trocar corpse |
| Ogre Shaman | giants | 625 | 800 | 859 | outfit 859 não existe no cliente 8.6; trocar corpse |
| Orclops Doomhauler | giants | 1450 | 1700 | 934 | outfit 934 não existe no cliente 8.6; trocar corpse |
| Orclops Ravager | giants | 1100 | 1200 | 935 | outfit 935 não existe no cliente 8.6; trocar corpse |
| Broken Shaper | humanoids | 1800 | 2200 | 932 | outfit 932 não existe no cliente 8.6; trocar corpse |
| Bulltaur Brute | humanoids | 4700 | 6560 | 1717 | outfit 1717 não existe no cliente 8.6; trocar corpse |
| Cheese Thief | humanoids | 0 | 1100 | 534 | outfit 534 não existe no cliente 8.6; trocar corpse |
| Corym Charlatan | humanoids | 150 | 250 | 532 | outfit 532 não existe no cliente 8.6; trocar corpse |
| Corym Skirmisher | humanoids | 260 | 450 | 533 | outfit 533 não existe no cliente 8.6; trocar corpse |
| Crazed Summer Rearguard | humanoids | 4700 | 5300 | 1136 | outfit 1136 não existe no cliente 8.6; trocar corpse |
| Crazed Winter Rearguard | humanoids | 4700 | 5200 | 1136 | outfit 1136 não existe no cliente 8.6; trocar corpse |
| Crazed Winter Vanguard | humanoids | 5400 | 5800 | 1137 | outfit 1137 não existe no cliente 8.6; trocar corpse |
| Elite Pirat | humanoids | 18000 | 20000 | 534 | outfit 534 não existe no cliente 8.6; trocar corpse |
| Execowtioner | humanoids | 2400 | 3500 | 609 | outfit 609 não existe no cliente 8.6; trocar corpse |
| Glooth Powered Minotaur | humanoids | 2600 | 3200 | 607 | outfit 607 não existe no cliente 8.6; trocar corpse |
| Little Corym Charlatan | humanoids | 40 | 90 | 532 | outfit 532 não existe no cliente 8.6; trocar corpse |
| Lost Basher | humanoids | 2300 | 2600 | 538 | outfit 538 não existe no cliente 8.6; trocar corpse |
| Lost Berserker | humanoids | 4800 | 5900 | 496 | outfit 496 não existe no cliente 8.6; trocar corpse |
| Lost Husher | humanoids | 1100 | 1600 | 537 | outfit 537 não existe no cliente 8.6; trocar corpse |
| Lost Thrower | humanoids | 1500 | 1700 | 539 | outfit 539 não existe no cliente 8.6; trocar corpse |
| Minotaur Hunter | humanoids | 1700 | 1400 | 612 | outfit 612 não existe no cliente 8.6; trocar corpse |
| Moohtant | humanoids | 2600 | 3200 | 607 | outfit 607 não existe no cliente 8.6; trocar corpse |
| Pirat Bombardier | humanoids | 1700 | 2300 | 1346 | outfit 1346 não existe no cliente 8.6; trocar corpse |
| Pirat Cutthroat | humanoids | 1800 | 2600 | 1346 | outfit 1346 não existe no cliente 8.6; trocar corpse |
| Pirat Mate | humanoids | 2400 | 3200 | 1346 | outfit 1346 não existe no cliente 8.6; trocar corpse |
| Pirat Scoundrel | humanoids | 1600 | 2200 | 1346 | outfit 1346 não existe no cliente 8.6; trocar corpse |
| Shaper Matriarch | humanoids | 1650 | 2000 | 933 | outfit 933 não existe no cliente 8.6; trocar corpse |
| Soul-Broken Harbinger | humanoids | 5800 | 6300 | 1137 | outfit 1137 não existe no cliente 8.6; trocar corpse |
| Twisted Shaper | humanoids | 2050 | 2500 | 932 | outfit 932 não existe no cliente 8.6; trocar corpse |
| Blood Hand | humans | 750 | 700 | 552 | outfit 552 não existe no cliente 8.6; trocar corpse |
| Blood Priest | humans | 900 | 820 | 553 | outfit 553 não existe no cliente 8.6; trocar corpse |
| Dark Carnisylvan | humans | 4400 | 7500 | 1418 | outfit 1418 não existe no cliente 8.6; trocar corpse |
| Feverish Citizen | humans | 30 | 125 | 425 | outfit 425 não existe no cliente 8.6; trocar corpse |
| Hardened Usurper Archer | humans | 0 | 7300 | 1316 | outfit 1316 não existe no cliente 8.6; trocar corpse |
| Hulking Carnisylvan | humans | 4700 | 8600 | 1418 | outfit 1418 não existe no cliente 8.6; trocar corpse |
| Lion Archer | humans | 0 | 7300 | 1316 | outfit 1316 não existe no cliente 8.6; trocar corpse |
| Lion Warlock | humans | 0 | 7500 | 1316 | outfit 1316 não existe no cliente 8.6; trocar corpse |
| Shadow Pupil | humans | 410 | 450 | 551 | outfit 551 não existe no cliente 8.6; trocar corpse |
| Usurper Archer | humans | 6800 | 7300 | 1316 | outfit 1316 não existe no cliente 8.6; trocar corpse |
| Cunning Werepanther | lycanthropes | 3620 | 4300 | 1648 | outfit 1648 não existe no cliente 8.6; trocar corpse |
| Werebadger | lycanthropes | 1600 | 1700 | 729 | outfit 729 não existe no cliente 8.6; trocar corpse |
| Werebear | lycanthropes | 2100 | 2400 | 720 | outfit 720 não existe no cliente 8.6; trocar corpse |
| Wereboar | lycanthropes | 2000 | 2200 | 721 | outfit 721 não existe no cliente 8.6; trocar corpse |
| Werecrocodile | lycanthropes | 4140 | 5280 | 1647 | outfit 1647 não existe no cliente 8.6; trocar corpse |
| Werehyaena | lycanthropes | 2200 | 2700 | 1300 | outfit 1300 não existe no cliente 8.6; trocar corpse |
| Werehyaena Shaman | lycanthropes | 2200 | 2500 | 1300 | outfit 1300 não existe no cliente 8.6; trocar corpse |
| Werelioness | lycanthropes | 2300 | 3000 | 1301 | outfit 1301 não existe no cliente 8.6; trocar corpse |
| Werepanther | lycanthropes | 3550 | 4200 | 1648 | outfit 1648 não existe no cliente 8.6; trocar corpse |
| Animated Feather | magicals | 9860 | 13000 | 1058 | outfit 1058 não existe no cliente 8.6; trocar corpse |
| Armadile | magicals | 3200 | 3800 | 487 | outfit 487 não existe no cliente 8.6; trocar corpse |
| Bashmu | magicals | 5000 | 8200 | 1408 | outfit 1408 não existe no cliente 8.6; trocar corpse |
| Brain Squid | magicals | 17672 | 18000 | 1059 | outfit 1059 não existe no cliente 8.6; trocar corpse |
| Burning Book | magicals | 13200 | 18000 | 1061 | outfit 1061 não existe no cliente 8.6; trocar corpse |
| Cursed Book | magicals | 13345 | 20000 | 1061 | outfit 1061 não existe no cliente 8.6; trocar corpse |
| Energetic Book | magicals | 12034 | 18500 | 1061 | outfit 1061 não existe no cliente 8.6; trocar corpse |
| Energuardian of Tales | magicals | 11361 | 14000 | 1063 | outfit 1063 não existe no cliente 8.6; trocar corpse |
| Feral Sphinx | magicals | 8800 | 9800 | 1188 | outfit 1188 não existe no cliente 8.6; trocar corpse |
| Flying Book | magicals | 200 | 500 | 1060 | outfit 1060 não existe no cliente 8.6; trocar corpse |
| Girtablilu Warrior | magicals | 5800 | 8500 | 1407 | outfit 1407 não existe no cliente 8.6; trocar corpse |
| Gryphon | magicals | 1000 | 3200 | 1220 | outfit 1220 não existe no cliente 8.6; trocar corpse |
| Guardian of Tales | magicals | 10600 | 15000 | 1063 | outfit 1063 não existe no cliente 8.6; trocar corpse |
| Guzzlemaw | magicals | 6050 | 6400 | 584 | outfit 584 não existe no cliente 8.6; trocar corpse |
| Icecold Book | magicals | 12750 | 21000 | 1061 | outfit 1061 não existe no cliente 8.6; trocar corpse |
| Juvenile Bashmu | magicals | 4500 | 7500 | 1408 | outfit 1408 não existe no cliente 8.6; trocar corpse |
| Lamassu | magicals | 9000 | 8700 | 1190 | outfit 1190 não existe no cliente 8.6; trocar corpse |
| Lumbering Carnivor | magicals | 1452 | 2600 | 1133 | outfit 1133 não existe no cliente 8.6; trocar corpse |
| Manticore | magicals | 5100 | 6700 | 1189 | outfit 1189 não existe no cliente 8.6; trocar corpse |
| Menacing Carnivor | magicals | 2112 | 3500 | 1138 | outfit 1138 não existe no cliente 8.6; trocar corpse |
| Midnight Panther | magicals | 900 | 1200 | 385 | outfit 385 não existe no cliente 8.6; trocar corpse |
| Rage Squid | magicals | 16300 | 17000 | 1059 | outfit 1059 não existe no cliente 8.6; trocar corpse |
| Retching Horror | magicals | 4100 | 5300 | 588 | outfit 588 não existe no cliente 8.6; trocar corpse |
| Rorc | magicals | 105 | 260 | 550 | outfit 550 não existe no cliente 8.6; trocar corpse |
| Shiversleep | magicals | 1900 | 4600 | 592 | outfit 592 não existe no cliente 8.6; trocar corpse |
| Sight of Surrender | magicals | 17000 | 28000 | 583 | outfit 583 não existe no cliente 8.6; trocar corpse |
| Sphinx | magicals | 7500 | 8500 | 1188 | outfit 1188 não existe no cliente 8.6; trocar corpse |
| Spiky Carnivor | magicals | 1650 | 2800 | 1139 | outfit 1139 não existe no cliente 8.6; trocar corpse |
| Squid Warden | magicals | 15300 | 16500 | 1059 | outfit 1059 não existe no cliente 8.6; trocar corpse |
| Thanatursus | magicals | 6300 | 7200 | 1134 | outfit 1134 não existe no cliente 8.6; trocar corpse |
| Boar | mammals | 60 | 198 | 380 | outfit 380 não existe no cliente 8.6; trocar corpse |
| Brown Horse | mammals | 0 | 75 | 436 | outfit 436 não existe no cliente 8.6; trocar corpse |
| Clomp | mammals | 475 | 900 | 860 | outfit 860 não existe no cliente 8.6; trocar corpse |
| Desperate White Deer | mammals | 35 | 55 | 400 | outfit 400 não existe no cliente 8.6; trocar corpse |
| Donkey | mammals | 0 | 45 | 387 | outfit 387 não existe no cliente 8.6; trocar corpse |
| Dromedary | mammals | 0 | 45 | 404 | outfit 404 não existe no cliente 8.6; trocar corpse |
| Exotic Bat | mammals | 1200 | 1500 | 1373 | outfit 1373 não existe no cliente 8.6; trocar corpse |
| Fox | mammals | 15 | 22 | 1029 | outfit 1029 não existe no cliente 8.6; trocar corpse |
| Ghost Wolf | mammals | 65 | 160 | 730 | outfit 730 não existe no cliente 8.6; trocar corpse |
| Giant Beaver | mammals | 0 | 5290 | 1536 | outfit 1536 não existe no cliente 8.6; trocar corpse |
| Gloom Wolf | mammals | 70 | 200 | 716 | outfit 716 não existe no cliente 8.6; trocar corpse |
| Grey Horse | mammals | 0 | 75 | 434 | outfit 434 não existe no cliente 8.6; trocar corpse |
| Horse | mammals | 0 | 75 | 435 | outfit 435 não existe no cliente 8.6; trocar corpse |
| Modified Gnarlhound | mammals | 0 | 1500 | 515 | outfit 515 não existe no cliente 8.6 |
| Mole | mammals | 100 | 200 | 1048 | outfit 1048 não existe no cliente 8.6; trocar corpse |
| Noble Lion | mammals | 400 | 1000 | 570 | outfit 570 não existe no cliente 8.6; trocar corpse |
| Parder | mammals | 1100 | 1200 | 1533 | outfit 1533 não existe no cliente 8.6; trocar corpse |
| Poodle | mammals | 0 | 20 | 473 | outfit 473 não existe no cliente 8.6 |
| Roaring Lion | mammals | 800 | 1000 | 570 | outfit 570 não existe no cliente 8.6; trocar corpse |
| Stone Rhino | mammals | 1800 | 3000 | 936 | outfit 936 não existe no cliente 8.6; trocar corpse |
| Thornfire Wolf | mammals | 200 | 600 | 414 | outfit 414 não existe no cliente 8.6; trocar corpse |
| Water Buffalo | mammals | 20 | 390 | 523 | outfit 523 não existe no cliente 8.6; trocar corpse |
| White Lion | mammals | 2300 | 2700 | 1290 | outfit 1290 não existe no cliente 8.6; trocar corpse |
| White Tiger | mammals | 40 | 75 | 1649 | outfit 1649 não existe no cliente 8.6; trocar corpse |
| Wild Horse | mammals | 0 | 75 | 393 | outfit 393 não existe no cliente 8.6; trocar corpse |
| Old Bear | nostalgia | 23 | 80 | 919 | outfit 919 não existe no cliente 8.6 |
| Old Beholder | nostalgia | 170 | 260 | 924 | outfit 924 não existe no cliente 8.6 |
| Old Bug | nostalgia | 18 | 29 | 920 | outfit 920 não existe no cliente 8.6 |
| Old Giant Spider | nostalgia | 900 | 1300 | 910 | outfit 910 não existe no cliente 8.6 |
| Old Pig | nostalgia | 0 | 25 | 921 | outfit 921 não existe no cliente 8.6 |
| Old Spider | nostalgia | 12 | 20 | 922 | outfit 922 não existe no cliente 8.6 |
| Old Wasp | nostalgia | 24 | 35 | 923 | outfit 923 não existe no cliente 8.6 |
| Old Wolf | nostalgia | 18 | 25 | 918 | outfit 918 não existe no cliente 8.6 |
| Humongous Fungus | plants | 2900 | 3400 | 488 | outfit 488 não existe no cliente 8.6; trocar corpse |
| Leaf Golem | plants | 45 | 90 | 567 | outfit 567 não existe no cliente 8.6; trocar corpse |
| Omnivora | plants | 750 | 1200 | 717 | outfit 717 não existe no cliente 8.6; trocar corpse |
| Stalking Stalk | plants | 11569 | 17100 | 1554 | outfit 1554 não existe no cliente 8.6; trocar corpse |
| Swampling | plants | 45 | 80 | 535 | outfit 535 não existe no cliente 8.6; trocar corpse |
| Wilting Leaf Golem | plants | 225 | 380 | 573 | outfit 573 não existe no cliente 8.6; trocar corpse |
| A Shielded Astral Glyph | quests | 0 | 50000 | ex 24226 | outfit item 24226 fora do cliente; trocar corpse; bosstiary |
| An Observer Eye | quests | 0 | 30000 | 925 | outfit 925 não existe no cliente 8.6; bosstiary |
| An Observer Eye (imune) | quests | 0 | 30000 | 925 | outfit 925 não existe no cliente 8.6; trocar corpse |
| Ancient Lion Archer | quests | 0 | 9000 | 1316 | outfit 1316 não existe no cliente 8.6; trocar corpse |
| Ancient Lion Knight | quests | 8100 | 9100 | 1071 | outfit 1071 não existe no cliente 8.6; trocar corpse; bosstiary |
| Ancient Lion Warlock | quests | 0 | 8500 | 1316 | outfit 1316 não existe no cliente 8.6; trocar corpse |
| Ancient Spawn of Morgathla | quests | 70000 | 900000 | 1055 | outfit 1055 não existe no cliente 8.6; trocar corpse; bosstiary |
| Animated Clomp | quests | 475 | 900 | 860 | outfit 860 não existe no cliente 8.6; trocar corpse |
| Animated Guzzlemaw | quests | 5500 | 6400 | 584 | outfit 584 não existe no cliente 8.6; trocar corpse |
| Animated Moohtant | quests | 2600 | 3200 | 607 | outfit 607 não existe no cliente 8.6; trocar corpse |
| Animated Ogre Brute | quests | 800 | 1000 | 857 | outfit 857 não existe no cliente 8.6; trocar corpse |
| Animated Ogre Savage | quests | 950 | 1400 | 858 | outfit 858 não existe no cliente 8.6; trocar corpse |
| Animated Ogre Shaman | quests | 625 | 800 | 859 | outfit 859 não existe no cliente 8.6; trocar corpse |
| Animated Stone Rhino | quests | 1800 | 3000 | 936 | outfit 936 não existe no cliente 8.6; trocar corpse |
| Animated Sword | quests | 0 | 2000 | ex 24227 | outfit item 24227 fora do cliente; trocar corpse |
| Ascending Ferumbras | quests | 12000 | 150000 | 844 | outfit 844 não existe no cliente 8.6; bosstiary |
| Bad Dream | quests | 0 | 7200 | ex 20110 | outfit item 20110 fora do cliente; trocar corpse |
| Baleful Bunny | quests | 450 | 500 | 1157 | outfit 1157 não existe no cliente 8.6; trocar corpse |
| Barkless Devotee | quests | 2200 | 2800 | 990 | outfit 990 não existe no cliente 8.6 |
| Barkless Fanatic | quests | 2500 | 3200 | 990 | outfit 990 não existe no cliente 8.6 |
| Bone Jaw | quests | 0 | 10000 | 384 | outfit 384 não existe no cliente 8.6; trocar corpse |
| Bonny Bunny | quests | 0 | 200 | 1158 | outfit 1158 não existe no cliente 8.6; trocar corpse |
| Bright Percht Sleigh | quests | 500 | 2300 | 1164 | outfit 1164 não existe no cliente 8.6; trocar corpse |
| Canopic Jar | quests | 0 | 1000 | 598 | outfit 598 não existe no cliente 8.6; trocar corpse |
| Captured Dwarf | quests | 0 | 100 | 538 | outfit 538 não existe no cliente 8.6; trocar corpse |
| Cart Packed with Gold | quests | 0 | 10000 | 1175 | outfit 1175 não existe no cliente 8.6; trocar corpse |
| Cold Percht Sleigh | quests | 500 | 2300 | 1163 | outfit 1163 não existe no cliente 8.6; trocar corpse |
| Dark Knowledge | quests | 0 | 10000 | 1061 | outfit 1061 não existe no cliente 8.6; trocar corpse; bosstiary |
| Dark Percht Sleigh | quests | 500 | 2300 | 1165 | outfit 1165 não existe no cliente 8.6; trocar corpse |
| Dark Soul | quests | 0 | 5000 | 714 | outfit 714 não existe no cliente 8.6; trocar corpse |
| Darklight Source | quests | 22465 | 31550 | 1660 | outfit 1660 não existe no cliente 8.6; trocar corpse |
| Demon Blood | quests | 0 | 10000 | 1041 | outfit 1041 não existe no cliente 8.6; trocar corpse |
| Despair | quests | 0 | 10000 | ex 20052 | outfit item 20052 fora do cliente; trocar corpse |
| Dragon Warden | quests | 4600 | 2800 | 947 | outfit 947 não existe no cliente 8.6; trocar corpse |
| Dragonking Zyrtarch | quests | 1600 | 150000 | 938 | outfit 938 não existe no cliente 8.6; trocar corpse; bosstiary |
| Dread Minion | quests | 0 | 4500 | 882 | outfit 882 não existe no cliente 8.6; trocar corpse |
| Echo Of Chagorz | quests | 0 | 90000 | 1670 | outfit 1670 não existe no cliente 8.6; trocar corpse |
| Echo Of Ichgahal | quests | 0 | 90000 | 1669 | outfit 1669 não existe no cliente 8.6; trocar corpse |
| Echo Of Murcion | quests | 0 | 90000 | 1669 | outfit 1669 não existe no cliente 8.6; trocar corpse |
| Echo Of Vemiath | quests | 0 | 90000 | 1670 | outfit 1670 não existe no cliente 8.6; trocar corpse |
| Enraged Soul | quests | 120 | 150 | 568 | outfit 568 não existe no cliente 8.6; trocar corpse |
| Flickering Spirit Elemental | quests | 450 | 600 | 1840 | outfit 1840 não existe no cliente 8.6 |
| Frozen Soul | quests | 0 | 2000 | 560 | outfit 560 não existe no cliente 8.6; trocar corpse |
| Furious Scorpion | quests | 12000 | 15000 | 398 | outfit 398 não existe no cliente 8.6; trocar corpse |
| Gelidrazah the Frozen | quests | 9000 | 10000 | 947 | outfit 947 não existe no cliente 8.6; trocar corpse; bosstiary |
| Generator | quests | 3000 | 8000 | ex 20710 | outfit item 20710 fora do cliente; trocar corpse |
| Ghulosh' Deathgaze | quests | 0 | 300000 | 1063 | outfit 1063 não existe no cliente 8.6; trocar corpse |
| Gnome Pack Crawler | quests | 0 | 5000 | 492 | outfit 492 não existe no cliente 8.6; trocar corpse |
| Guilt | quests | 320 | 2000 | 583 | outfit 583 não existe no cliente 8.6; trocar corpse |
| Hateful Soul | quests | 5580 | 25000 | 1268 | outfit 1268 não existe no cliente 8.6; trocar corpse |
| Humorless Fungus | quests | 0 | 1600 | 517 | outfit 517 não existe no cliente 8.6; trocar corpse |
| Irgix The Flimsy | quests | 18000 | 24000 | 1268 | outfit 1268 não existe no cliente 8.6; trocar corpse; bosstiary |
| Kalyassa | quests | 9000 | 10000 | 947 | outfit 947 não existe no cliente 8.6; bosstiary |
| Knowledge Raider | quests | 0 | 10000 | 878 | outfit 878 não existe no cliente 8.6; trocar corpse |
| Last Planegazer | quests | 10000 | 50000 | 1044 | outfit 1044 não existe no cliente 8.6; trocar corpse; bosstiary |
| Lava Creature | quests | 0 | 9000 | 1414 | outfit 1414 não existe no cliente 8.6; trocar corpse |
| Lava Lurker Attendant | quests | 0 | 3000 | 1041 | outfit 1041 não existe no cliente 8.6; trocar corpse |
| Librarian | quests | 0 | 11000 | 1067 | outfit 1067 não existe no cliente 8.6; trocar corpse |
| Lokathmor Stuck | quests | 0 | 300000 | 1062 | outfit 1062 não existe no cliente 8.6; trocar corpse |
| Lost Gnome | quests | 0 | 10000 | 493 | outfit 493 não existe no cliente 8.6; trocar corpse |
| Lovely Yielothax | quests | 1250 | 1500 | 408 | outfit 408 não existe no cliente 8.6; trocar corpse |
| Magma Crystal | quests | 0 | 40000 | ex 21572 | outfit item 21572 fora do cliente; trocar corpse |
| Malicious Soul | quests | 25000 | 25000 | 1268 | outfit 1268 não existe no cliente 8.6; trocar corpse |
| Mean Maw | quests | 32500 | 24000 | 1294 | outfit 1294 não existe no cliente 8.6; trocar corpse |
| Minotaur Idol | quests | 0 | 5200 | 1011 | outfit 1011 não existe no cliente 8.6; trocar corpse |
| Mooh'Tah Master | quests | 0 | 185 | 611 | outfit 611 não existe no cliente 8.6; trocar corpse |
| Mushroom | quests | 0 | 10000 | 1773 | outfit 1773 não existe no cliente 8.6; trocar corpse |
| Neutral Deepling Warrior | quests | 1500 | 1600 | 441 | outfit 441 não existe no cliente 8.6; trocar corpse |
| Nightmare of Gaz'haragoth | quests | 0 | 5500 | 587 | outfit 587 não existe no cliente 8.6; trocar corpse |
| Nightmare Tendril | quests | 0 | 2100 | 681 | outfit 681 não existe no cliente 8.6; trocar corpse |
| Percht | quests | 600 | 620 | 1161 | outfit 1161 não existe no cliente 8.6; trocar corpse |
| Plant Attendant | quests | 0 | 90 | 567 | outfit 567 não existe no cliente 8.6; trocar corpse |
| Plunder Patriarch | quests | 0 | 20000 | 1567 | outfit 1567 não existe no cliente 8.6; trocar corpse; bosstiary |
| Poor Soul | quests | 0 | 500 | 1296 | outfit 1296 não existe no cliente 8.6; trocar corpse |
| Psychic Spirit Elemental | quests | 1300 | 1400 | 1840 | outfit 1840 não existe no cliente 8.6 |
| Ravenous Beyondling | quests | 0 | 10000 | 876 | outfit 876 não existe no cliente 8.6; trocar corpse |
| Redeemed Soul | quests | 0 | 250 | 714 | outfit 714 não existe no cliente 8.6; trocar corpse |
| Reflection of Mawhawk | quests | 14000 | 45000 | 595 | outfit 595 não existe no cliente 8.6; trocar corpse |
| Reflection of Obujos | quests | 20000 | 35000 | 445 | outfit 445 não existe no cliente 8.6; trocar corpse; bosstiary |
| Rift Breacher | quests | 0 | 10000 | 875 | outfit 875 não existe no cliente 8.6; trocar corpse |
| Rift Minion | quests | 0 | 10000 | 882 | outfit 882 não existe no cliente 8.6; trocar corpse |
| Sand Vortex | quests | 0 | 20000 | ex 23482 | outfit item 23482 fora do cliente; trocar corpse |
| Schiach | quests | 580 | 600 | 1162 | outfit 1162 não existe no cliente 8.6; trocar corpse |
| Sphere of Wrath | quests | 0 | 20000 | 979 | outfit 979 não existe no cliente 8.6; trocar corpse |
| Supercharged Mazzinor | quests | 0 | 300000 | 979 | outfit 979 não existe no cliente 8.6; trocar corpse; bosstiary |
| Sword of Vengeance | quests | 0 | 2000 | ex 24227 | outfit item 24227 fora do cliente; trocar corpse |
| Tainted Soul Splinter | quests | 0 | 10000 | 1219 | outfit 1219 não existe no cliente 8.6; trocar corpse |
| Tazhadur | quests | 9000 | 10000 | 947 | outfit 947 não existe no cliente 8.6; trocar corpse; bosstiary |
| The Armored Voidborn | quests | 0 | 60000 | 987 | outfit 987 não existe no cliente 8.6; trocar corpse; bosstiary |
| The Book of Secrets | quests | 0 | 8000 | ex 22755 | outfit item 22755 fora do cliente; trocar corpse |
| The End of Days | quests | 0 | 90000 | 1570 | outfit 1570 não existe no cliente 8.6; trocar corpse |
| The Fire Empowered Duke | quests | 40000 | 350000 | 1047 | outfit 1047 não existe no cliente 8.6; trocar corpse |
| The Hungry Baron from Below | quests | 40000 | 350000 | 1045 | outfit 1045 não existe no cliente 8.6; trocar corpse; bosstiary |
| The Percht Queen | quests | 500 | 2300 | ex 30340 | outfit item 30340 fora do cliente; trocar corpse; bosstiary |
| The Sandking Fake | quests | 0 | 50000 | 1013 | outfit 1013 não existe no cliente 8.6; trocar corpse |
| The Scion of Havoc | quests | 0 | 10000 | 875 | outfit 875 não existe no cliente 8.6; trocar corpse; bosstiary |
| Thorn Minion | quests | 1600 | 3500 | 717 | outfit 717 não existe no cliente 8.6; trocar corpse |
| Thorn Steed | quests | 0 | 20000 | 626 | outfit 626 não existe no cliente 8.6; trocar corpse; bosstiary |
| Unaz the Mean | quests | 22000 | 28000 | 1268 | outfit 1268 não existe no cliente 8.6; trocar corpse; bosstiary |
| Utua Stone Sting | quests | 5100 | 6400 | 398 | outfit 398 não existe no cliente 8.6; trocar corpse; bosstiary |
| Vampiric Blood | quests | 0 | 3500 | 1041 | outfit 1041 não existe no cliente 8.6; trocar corpse |
| Voidshard | quests | 0 | 3500 | 878 | outfit 878 não existe no cliente 8.6; trocar corpse |
| Vok the Freakish | quests | 27000 | 32000 | 1268 | outfit 1268 não existe no cliente 8.6; trocar corpse; bosstiary |
| Yirkas Blue Scales | quests | 4900 | 6300 | 1196 | outfit 1196 não existe no cliente 8.6; trocar corpse; bosstiary |
| Zamulosh2 | quests | 55000 | 300000 | 862 | outfit 862 não existe no cliente 8.6; trocar corpse |
| Control Tower | raids | 3000 | 7500 | ex 20894 | outfit item 20894 fora do cliente; trocar corpse |
| Draptor | raids | 2400 | 3000 | 382 | outfit 382 não existe no cliente 8.6; trocar corpse |
| Glooth Battery | raids | 3000 | 8000 | ex 20710 | outfit item 20710 fora do cliente; trocar corpse |
| Glooth Bomb | raids | 2600 | 250000 | 680 | outfit 680 não existe no cliente 8.6; trocar corpse; bosstiary |
| Mawhawk | raids | 14000 | 45000 | 595 | outfit 595 não existe no cliente 8.6; trocar corpse; bosstiary |
| Spyrat East | raids | 3750 | 3000 | ex 30375 | outfit item 30375 fora do cliente; trocar corpse |
| Spyrat North | raids | 3750 | 3000 | ex 30376 | outfit item 30376 fora do cliente; trocar corpse |
| Spyrat South | raids | 3750 | 3000 | ex 30377 | outfit item 30377 fora do cliente; trocar corpse |
| Spyrat West | raids | 3750 | 3000 | ex 30378 | outfit item 30378 fora do cliente; trocar corpse |
| Zomba | raids | 300 | 300 | 570 | outfit 570 não existe no cliente 8.6; trocar corpse; bosstiary |
| Adult Goanna | reptiles | 6650 | 8300 | 1195 | outfit 1195 não existe no cliente 8.6; trocar corpse |
| Boar Man | reptiles | 7720 | 9200 | 1603 | outfit 1603 não existe no cliente 8.6; trocar corpse |
| Crape Man | reptiles | 5040 | 9150 | 1601 | outfit 1601 não existe no cliente 8.6; trocar corpse |
| Liodile | reptiles | 6860 | 8600 | 1602 | outfit 1602 não existe no cliente 8.6; trocar corpse |
| Rhindeer | reptiles | 5600 | 8650 | 1606 | outfit 1606 não existe no cliente 8.6; trocar corpse |
| Two-Headed Turtle | reptiles | 2930 | 5010 | 1535 | outfit 1535 não existe no cliente 8.6; trocar corpse |
| Young Goanna | reptiles | 6100 | 6200 | 1196 | outfit 1196 não existe no cliente 8.6; trocar corpse |
| Chocolate Blob | slimes | 17 | 70 | 1732 | outfit 1732 não existe no cliente 8.6; trocar corpse |
| Ink Blob | slimes | 14450 | 9500 | 1064 | outfit 1064 não existe no cliente 8.6; trocar corpse |
| Training Machine | trainers | 0 | 1000000 | 1142 | outfit 1142 não existe no cliente 8.6; trocar corpse |
| Floor Blob | traps | 0 | 1 | 459 | outfit 459 não existe no cliente 8.6; trocar corpse |
| Blood Beast | undeads | 1000 | 1600 | 602 | outfit 602 não existe no cliente 8.6; trocar corpse |
| Burster Spectre | undeads | 6000 | 6500 | 1122 | outfit 1122 não existe no cliente 8.6; trocar corpse |
| Cursed Ape | undeads | 1860 | 1700 | 1592 | outfit 1592 não existe no cliente 8.6; trocar corpse |
| Cursed Prospector | undeads | 5250 | 3900 | 1268 | outfit 1268 não existe no cliente 8.6; trocar corpse |
| Evil Prospector | undeads | 9000 | 8500 | 1268 | outfit 1268 não existe no cliente 8.6; trocar corpse |
| Falcon Knight | undeads | 6300 | 9000 | 1071 | outfit 1071 não existe no cliente 8.6; trocar corpse |
| Falcon Paladin | undeads | 6900 | 8500 | 1071 | outfit 1071 não existe no cliente 8.6; trocar corpse |
| Flimsy Lost Soul | undeads | 4500 | 4000 | 1268 | outfit 1268 não existe no cliente 8.6; trocar corpse |
| Freakish Lost Soul | undeads | 7020 | 7000 | 1268 | outfit 1268 não existe no cliente 8.6; trocar corpse |
| Gazer Spectre | undeads | 4200 | 4500 | 1122 | outfit 1122 não existe no cliente 8.6; trocar corpse |
| Gravedigger | undeads | 950 | 1500 | 558 | outfit 558 não existe no cliente 8.6; trocar corpse |
| Iks Ahpututu | undeads | 1700 | 1630 | 1590 | outfit 1590 não existe no cliente 8.6; trocar corpse |
| Iks Aucar | undeads | 1150 | 1520 | 1587 | outfit 1587 não existe no cliente 8.6; trocar corpse |
| Iks Chuka | undeads | 1050 | 1240 | 1588 | outfit 1588 não existe no cliente 8.6; trocar corpse |
| Iks Churrascan | undeads | 0 | 1520 | 1587 | outfit 1587 não existe no cliente 8.6; trocar corpse |
| Iks Pututu | undeads | 980 | 1310 | 1589 | outfit 1589 não existe no cliente 8.6; trocar corpse |
| Mean Lost Soul | undeads | 5580 | 5000 | 1268 | outfit 1268 não existe no cliente 8.6; trocar corpse |
| Putrid Mummy | undeads | 900 | 1500 | 976 | outfit 976 não existe no cliente 8.6 |
| Ripper Spectre | undeads | 3500 | 3800 | 1122 | outfit 1122 não existe no cliente 8.6; trocar corpse |
| Tarnished Spirit | undeads | 120 | 150 | 566 | outfit 566 não existe no cliente 8.6; trocar corpse |
| Undead Cavebear | undeads | 600 | 450 | 384 | outfit 384 não existe no cliente 8.6; trocar corpse |
| Vampire Viscount | undeads | 800 | 1200 | 555 | outfit 555 não existe no cliente 8.6; trocar corpse |
| Vicious Manbat | undeads | 1200 | 1700 | 554 | outfit 554 não existe no cliente 8.6; trocar corpse |
| White Shade | undeads | 120 | 260 | 560 | outfit 560 não existe no cliente 8.6; trocar corpse |
| Afflicted Strider | vermins | 5700 | 10000 | 1403 | outfit 1403 não existe no cliente 8.6; trocar corpse |
| Blemished Spawn | vermins | 5300 | 9000 | 1401 | outfit 1401 não existe no cliente 8.6; trocar corpse |
| Cave Chimera | vermins | 6800 | 8000 | 1406 | outfit 1406 não existe no cliente 8.6; trocar corpse |
| Crawler | vermins | 1000 | 1450 | 456 | outfit 456 não existe no cliente 8.6; trocar corpse |
| Emerald Damselfly | vermins | 35 | 90 | 528 | outfit 528 não existe no cliente 8.6; trocar corpse |
| Exotic Cave Spider | vermins | 1400 | 1900 | 1344 | outfit 1344 não existe no cliente 8.6; trocar corpse |
| Eyeless Devourer | vermins | 6000 | 10000 | 1399 | outfit 1399 não existe no cliente 8.6; trocar corpse |
| Hibernal Moth | vermins | 700 | 850 | 1149 | outfit 1149 não existe no cliente 8.6; trocar corpse |
| Insectoid Scout | vermins | 150 | 230 | 403 | outfit 403 não existe no cliente 8.6; trocar corpse |
| Insectoid Worker | vermins | 650 | 950 | 403 | outfit 403 não existe no cliente 8.6; trocar corpse |
| Kollos | vermins | 2400 | 3800 | 458 | outfit 458 não existe no cliente 8.6; trocar corpse |
| Lacewing Moth | vermins | 800 | 900 | 1148 | outfit 1148 não existe no cliente 8.6; trocar corpse |
| Ladybug | vermins | 70 | 255 | 448 | outfit 448 não existe no cliente 8.6; trocar corpse |
| Lavaworm | vermins | 6500 | 7500 | 1394 | outfit 1394 não existe no cliente 8.6; trocar corpse |
| Lesser Swarmer | vermins | 0 | 230 | 460 | outfit 460 não existe no cliente 8.6; trocar corpse |
| Slug | vermins | 70 | 255 | 407 | outfit 407 não existe no cliente 8.6; trocar corpse |
| Spidris | vermins | 2600 | 3700 | 457 | outfit 457 não existe no cliente 8.6; trocar corpse |
| Spidris Elite | vermins | 4000 | 5000 | 457 | outfit 457 não existe no cliente 8.6; trocar corpse |
| Spitter | vermins | 1100 | 1500 | 461 | outfit 461 não existe no cliente 8.6; trocar corpse |
| Swarmer | vermins | 350 | 460 | 460 | outfit 460 não existe no cliente 8.6; trocar corpse |
| Swarmer Hatchling | vermins | 0 | 5 | 460 | outfit 460 não existe no cliente 8.6; trocar corpse |
| Tremendous Tyrant | vermins | 6100 | 11500 | 1396 | outfit 1396 não existe no cliente 8.6; trocar corpse |
| Varnished Diremaw | vermins | 5900 | 9000 | 1397 | outfit 1397 não existe no cliente 8.6; trocar corpse |
| Waspoid | vermins | 830 | 1100 | 462 | outfit 462 não existe no cliente 8.6; trocar corpse |
| Wild Fire Magic | wild_magics | 0 | 1 | ex None | sem outfit; trocar corpse |
| Wild Fury Magic | wild_magics | 0 | 1 | ex None | sem outfit; trocar corpse |
| Wild Nature Magic | wild_magics | 0 | 1 | ex None | sem outfit; trocar corpse |
| Wild Water Magic | wild_magics | 0 | 1 | ex None | sem outfit; trocar corpse |

## B2. Ataques/summons a adaptar
| Monstro | Pasta | XP | HP | Outfit | Observações |
|---|---|---|---|---|---|
| Makara | amphibics | 5720 | 5050 | 1565 | outfit 1565 não existe no cliente 8.6; trocar corpse; magia Canary: makarawatersplash |
| Deepling Master Librarian | aquatics | 1900 | 1700 | 443 | outfit 443 não existe no cliente 8.6; trocar corpse; magia Canary: deepling spellsinger skill reducer |
| Deepling Spellsinger | aquatics | 1000 | 850 | 443 | outfit 443 não existe no cliente 8.6; trocar corpse; magia Canary: deepling spellsinger skill reducer |
| Quara Looter | aquatics | 8650 | 11500 | 1741 | outfit 1741 não existe no cliente 8.6; trocar corpse; magia Canary: podzillaphyschain; magia Canary: quarasmallicering |
| Quara Plunderer | aquatics | 10800 | 13500 | 1758 | outfit 1758 não existe no cliente 8.6; trocar corpse; magia Canary: quaracrossdeath; magia Canary: quarasmokedeath |
| Quara Raider | aquatics | 8150 | 12500 | 1759 | outfit 1759 não existe no cliente 8.6; trocar corpse; magia Canary: quaralargeicering; magia Canary: quararaidershoot; magia Canary: quaraseamonster; magia Canary: quarawatersplash |
| Renegade Quara Constrictor | aquatics | 1250 | 1500 | 46 | magia Canary: quara constrictor electrify; magia Canary: quara constrictor freeze |
| Headpecker | birds | 12026 | 16300 | 1557 | outfit 1557 não existe no cliente 8.6; trocar corpse; magia Canary: headpecker explosion |
| Bullwark | bosses | 22000 | 72000 | 607 | outfit 607 não existe no cliente 8.6; trocar corpse; magia Canary: bullwark paralyze; magia Canary: bullwark summon; bosstiary |
| Cerebellum | bosses | 0 | 20000 | ex 32572 | outfit item 32572 fora do cliente; trocar corpse; magia Canary: heal brain head |
| Doctor Marrow | bosses | 0 | 120000 | 1611 | outfit 1611 não existe no cliente 8.6; trocar corpse; magia Canary: doctor marrow explosion; magia Canary: fear; magia Canary: root; bosstiary |
| Kraknaknork | bosses | 300 | 80 | 6 | magia Canary: kraknaknork explosion wave; magia Canary: kraknaknork ice wave; magia Canary: kraknaknork poison wave; summon ausente: Weakened Demon |
| Lisa | bosses | 18000 | 55000 | 604 | outfit 604 não existe no cliente 8.6; trocar corpse; magia Canary: lisa heal; magia Canary: lisa paralyze; magia Canary: lisa skill reducer; magia Canary: lisa summon; magia Canary: lisa wave; bosstiary |
| Mad Mage | bosses | 1800 | 2500 | 394 | outfit 394 não existe no cliente 8.6; trocar corpse; summon ausente: Golden Servant; bosstiary |
| Spider Queen | bosses | 120 | 10000 | 219 | magia Canary: spider queen wrap |
| The Brainstealer | bosses | 72000 | 300000 | 1412 | outfit 1412 não existe no cliente 8.6; trocar corpse; summon ausente: brain parasite; bosstiary |
| The Monster | bosses | 30000 | 450000 | 1600 | outfit 1600 não existe no cliente 8.6; trocar corpse; magia Canary: destroy magic walls; bosstiary |
| Weakened Shlorg | bosses | 6500 | 10000 | 565 | outfit 565 não existe no cliente 8.6; trocar corpse; magia Canary: shlorg paralyze; bosstiary |
| Glooth Golem | constructs | 1606 | 2700 | 600 | outfit 600 não existe no cliente 8.6; trocar corpse; magia Canary: war golem electrify; magia Canary: war golem skill reducer |
| Infected Weeper | constructs | 1200 | 3000 | 489 | outfit 489 não existe no cliente 8.6; trocar corpse; summon ausente: Parasite |
| Lava Golem | constructs | 7900 | 9000 | 491 | outfit 491 não existe no cliente 8.6; trocar corpse; magia Canary: lava golem soulfire |
| Magma Crawler | constructs | 3900 | 4800 | 492 | outfit 492 não existe no cliente 8.6; trocar corpse; magia Canary: magma crawler soulfire; magia Canary: magma crawler wave; magia Canary: soulfire rune |
| Metal Gargoyle | constructs | 1278 | 2100 | 601 | outfit 601 não existe no cliente 8.6; trocar corpse; magia Canary: metal gargoyle curse |
| Orewalker | constructs | 5900 | 7200 | 490 | outfit 490 não existe no cliente 8.6; trocar corpse; magia Canary: orewalker wave |
| Rustheap Golem | constructs | 2100 | 2800 | 603 | outfit 603 não existe no cliente 8.6; trocar corpse; magia Canary: frazzlemaw paralyze; magia Canary: rustheap golem electrify; magia Canary: rustheap golem wave |
| Shrieking Cry-Stal | constructs | 13560 | 20650 | 1560 | outfit 1560 não existe no cliente 8.6; trocar corpse; magia Canary: energy chain; magia Canary: fear |
| Walker | constructs | 2200 | 3000 | 605 | outfit 605 não existe no cliente 8.6; trocar corpse; magia Canary: walker skill reducer |
| Salamander Trainer | dawnport | 70 | 220 | 15 | magia Canary: salamander trainer summon |
| Woodling | dawnport | 40 | 80 | 535 | outfit 535 não existe no cliente 8.6; trocar corpse; magia Canary: woodling paralyze |
| Askarak Demon | demons | 900 | 1500 | 420 | outfit 420 não existe no cliente 8.6; trocar corpse; magia Canary: askarak wave |
| Askarak Lord | demons | 1200 | 2100 | 410 | outfit 410 não existe no cliente 8.6; trocar corpse; magia Canary: askarak wave |
| Askarak Prince | demons | 1700 | 2600 | 419 | outfit 419 não existe no cliente 8.6; trocar corpse; magia Canary: askarak wave |
| Demon Outcast | demons | 6200 | 6900 | 590 | outfit 590 não existe no cliente 8.6; trocar corpse; magia Canary: demon outcast skill reducer |
| Floating Savant | demons | 8000 | 8000 | 1063 | outfit 1063 não existe no cliente 8.6; trocar corpse; summon ausente: Lava Lurker Attendant |
| Gorger Inferniarch | demons | 7180 | 9450 | 1797 | outfit 1797 não existe no cliente 8.6; trocar corpse; magia Canary: extended fire chain |
| Hellflayer | demons | 11720 | 14000 | 856 | outfit 856 não existe no cliente 8.6; trocar corpse; magia Canary: choking fear drown; magia Canary: warlock skill reducer |
| Shaburak Demon | demons | 900 | 1500 | 417 | outfit 417 não existe no cliente 8.6; trocar corpse; magia Canary: shaburak wave |
| Shaburak Lord | demons | 1200 | 2100 | 409 | outfit 409 não existe no cliente 8.6; trocar corpse; magia Canary: shaburak wave |
| Shaburak Prince | demons | 1700 | 2600 | 418 | outfit 418 não existe no cliente 8.6; trocar corpse; magia Canary: shaburak wave |
| Sineater Inferniarch | demons | 6750 | 9150 | 1795 | outfit 1795 não existe no cliente 8.6; trocar corpse; magia Canary: big death wave |
| Vexclaw | demons | 6248 | 8500 | 854 | outfit 854 não existe no cliente 8.6; trocar corpse; magia Canary: choking fear drown |
| Dragolisk | dragons | 5050 | 6180 | 1707 | outfit 1707 não existe no cliente 8.6; trocar corpse; magia Canary: death chain |
| Elder Wyrm | dragons | 2500 | 2700 | 561 | outfit 561 não existe no cliente 8.6; trocar corpse; magia Canary: elder wyrm wave |
| Mega Dragon | dragons | 7810 | 7920 | 1712 | outfit 1712 não existe no cliente 8.6; trocar corpse; magia Canary: death chain |
| Cliff Strider | elementals | 7100 | 9400 | 497 | outfit 497 não existe no cliente 8.6; trocar corpse; magia Canary: cliff strider electrify; magia Canary: cliff strider skill reducer |
| Foam Stalker | elementals | 3120 | 4500 | 1562 | outfit 1562 não existe no cliente 8.6; trocar corpse; magia Canary: foamsplash |
| Raging Fire | elementals | 1500 | 1800 | 242 | trocar corpse; magia Canary: massive fire elemental soulfire |
| Ravenous Lava Lurker | elementals | 4000 | 5000 | 1041 | outfit 1041 não existe no cliente 8.6; magia Canary: ravennouslavalurkertarget; magia Canary: ravennouslavalurkerwave |
| Sulphur Spouter | elementals | 11517 | 19000 | 1547 | outfit 1547 não existe no cliente 8.6; trocar corpse; magia Canary: sulphur spouter wave |
| Eclipse Knight | event_creatures | 4650 | 45000 | 234 | magia Canary: dark torturer skill reducer |
| Memory of a Golem | event_creatures | 1620 | 3660 | 600 | outfit 600 não existe no cliente 8.6; trocar corpse; magia Canary: war golem skill reducer |
| Memory of a Werelion | event_creatures | 1800 | 3880 | 1301 | outfit 1301 não existe no cliente 8.6; trocar corpse; magia Canary: werelion wave |
| Breach Brood | extra_dimensional | 1760 | 3500 | 878 | outfit 878 não existe no cliente 8.6; trocar corpse; magia Canary: breach brood reducer |
| Dread Intruder | extra_dimensional | 2400 | 4500 | 882 | outfit 882 não existe no cliente 8.6; trocar corpse; magia Canary: dread intruder wave |
| Instable Breach Brood | extra_dimensional | 1100 | 2200 | 878 | outfit 878 não existe no cliente 8.6; trocar corpse; magia Canary: breach brood reducer |
| Mitmah Seer | extra_dimensional | 4580 | 4620 | 1710 | outfit 1710 não existe no cliente 8.6; trocar corpse; magia Canary: mitmahseekwave |
| Reality Reaver | extra_dimensional | 2480 | 3900 | 879 | outfit 879 não existe no cliente 8.6; trocar corpse; magia Canary: reality reaver wave |
| Stabilizing Dread Intruder | extra_dimensional | 1900 | 2800 | 882 | outfit 882 não existe no cliente 8.6; trocar corpse; magia Canary: dread intruder wave |
| Stabilizing Reality Reaver | extra_dimensional | 1950 | 2500 | 879 | outfit 879 não existe no cliente 8.6; trocar corpse; magia Canary: reality reaver wave |
| Druid familiar | familiars | 0 | 20000 | 993 | outfit 993 não existe no cliente 8.6; trocar corpse; magia Canary: summon challenge |
| Knight familiar | familiars | 0 | 10000 | 991 | outfit 991 não existe no cliente 8.6; trocar corpse; magia Canary: sudden death rune |
| Sorcerer familiar | familiars | 0 | 20000 | 994 | outfit 994 não existe no cliente 8.6; trocar corpse; magia Canary: summon challenge |
| Pixie | fey | 700 | 770 | 982 | outfit 982 não existe no cliente 8.6; trocar corpse; magia Canary: pixie skill reducer |
| Ogre Sage | giants | 5500 | 4800 | 1214 | outfit 1214 não existe no cliente 8.6; trocar corpse; summon ausente: Young Goanna |
| Bulltaur Alchemist | humanoids | 4500 | 5690 | 1718 | outfit 1718 não existe no cliente 8.6; trocar corpse; magia Canary: bulltaur avalanche |
| Bulltaur Forgepriest | humanoids | 6400 | 6840 | 1719 | outfit 1719 não existe no cliente 8.6; trocar corpse; magia Canary: bulltaur explosion; magia Canary: bulltaurewave |
| Corym Vanguard | humanoids | 490 | 700 | 534 | outfit 534 não existe no cliente 8.6; trocar corpse; magia Canary: corym vanguard wave |
| Crazed Summer Vanguard | humanoids | 5000 | 5500 | 1137 | outfit 1137 não existe no cliente 8.6; trocar corpse; magia Canary: sparks chain |
| Enslaved Dwarf | humanoids | 2700 | 3800 | 494 | outfit 494 não existe no cliente 8.6; trocar corpse; magia Canary: enslaved dwarf skill reducer 1; magia Canary: enslaved dwarf skill reducer 2 |
| Furious Troll | humanoids | 185 | 245 | 281 | summon ausente: Mechanical Fighter |
| Insane Siren | humanoids | 6000 | 6500 | 1136 | outfit 1136 não existe no cliente 8.6; trocar corpse; magia Canary: sparks chain |
| Minotaur Amazon | humanoids | 2200 | 2600 | 608 | outfit 608 não existe no cliente 8.6; trocar corpse; magia Canary: minotaur amazon paralyze |
| Mooh'Tah Warrior | humanoids | 900 | 1200 | 611 | outfit 611 não existe no cliente 8.6; trocar corpse; magia Canary: mooh'tah master skill reducer |
| Pirat Artillerist | humanoids | 2800 | 2700 | 1346 | outfit 1346 não existe no cliente 8.6; trocar corpse; magia Canary: corym vanguard wave |
| Worm Priestess | humanoids | 1500 | 1100 | 613 | outfit 613 não existe no cliente 8.6; trocar corpse; magia Canary: worm priestess paralyze |
| Black Sphinx Acolyte | humans | 7200 | 8100 | 1200 | outfit 1200 não existe no cliente 8.6; trocar corpse; summon ausente: Skeleton Elite Warrior |
| Carnisylvan Sapling | humans | 0 | 750 | 1419 | outfit 1419 não existe no cliente 8.6; trocar corpse; magia Canary: sapling explode |
| Hardened Usurper Knight | humans | 0 | 8200 | 1317 | outfit 1317 não existe no cliente 8.6; trocar corpse; magia Canary: singlecloudchain |
| Hardened Usurper Warlock | humans | 0 | 7500 | 1316 | outfit 1316 não existe no cliente 8.6; trocar corpse; magia Canary: singledeathchain; magia Canary: singleicechain |
| Poisonous Carnisylvan | humans | 4400 | 8000 | 1418 | outfit 1418 não existe no cliente 8.6; trocar corpse; summon ausente: Carnisylvan Sapling |
| Usurper Knight | humans | 6900 | 8200 | 1316 | outfit 1316 não existe no cliente 8.6; trocar corpse; magia Canary: singlecloudchain |
| Usurper Warlock | humans | 7000 | 7500 | 1316 | outfit 1316 não existe no cliente 8.6; trocar corpse; magia Canary: singledeathchain; magia Canary: singleicechain |
| Feral Werecrocodile | lycanthropes | 5430 | 6400 | 1647 | outfit 1647 não existe no cliente 8.6; trocar corpse; magia Canary: werecrocodile fire ring |
| Werefox | lycanthropes | 1600 | 1500 | 1030 | outfit 1030 não existe no cliente 8.6; trocar corpse; summon ausente: fox |
| Werelion | lycanthropes | 2200 | 2800 | 1301 | outfit 1301 não existe no cliente 8.6; trocar corpse; magia Canary: werelion wave |
| Weretiger | lycanthropes | 3920 | 5000 | 1646 | outfit 1646 não existe no cliente 8.6; trocar corpse; magia Canary: energy chain |
| White Weretiger | lycanthropes | 5200 | 6100 | 1646 | outfit 1646 não existe no cliente 8.6; trocar corpse; magia Canary: energy ring; magia Canary: white weretiger ice ring |
| Arachnophobica | magicals | 4700 | 5000 | 1135 | outfit 1135 não existe no cliente 8.6; trocar corpse; magia Canary: arachnophobicawavedice; magia Canary: arachnophobicawaveenergy |
| Choking Fear | magicals | 4700 | 5800 | 586 | outfit 586 não existe no cliente 8.6; trocar corpse; magia Canary: choking fear drown |
| Crypt Warden | magicals | 8400 | 8300 | 1190 | outfit 1190 não existe no cliente 8.6; trocar corpse; magia Canary: warden ring; magia Canary: warden x |
| Dragonling | magicals | 2200 | 2600 | 505 | outfit 505 não existe no cliente 8.6; trocar corpse; magia Canary: dragonling wave |
| Fahim the Wise | magicals | 1500 | 2000 | 104 | magia Canary: djinn electrify; bosstiary |
| Feversleep | magicals | 5060 | 5900 | 593 | outfit 593 não existe no cliente 8.6; trocar corpse; magia Canary: feversleep skill reducer |
| Forest Fury | magicals | 330 | 480 | 569 | outfit 569 não existe no cliente 8.6; trocar corpse; magia Canary: forest fury skill reducer |
| Shock Head | magicals | 2300 | 4200 | 579 | outfit 579 não existe no cliente 8.6; trocar corpse; magia Canary: shock head skill reducer 1; magia Canary: shock head skill reducer 2 |
| Terrorsleep | magicals | 6900 | 7200 | 587 | outfit 587 não existe no cliente 8.6; trocar corpse; magia Canary: feversleep skill reducer |
| Venerable Girtablilu | magicals | 5300 | 8500 | 1407 | outfit 1407 não existe no cliente 8.6; trocar corpse; magia Canary: girtablilu poison wave |
| Crystal Wolf | mammals | 275 | 750 | 391 | outfit 391 não existe no cliente 8.6; trocar corpse; magia Canary: crystal wolf wave |
| Evil Sheep Lord | mammals | 340 | 400 | 13 | summon ausente: Evil Sheep |
| Ghoulish Hyaena | mammals | 195 | 400 | 94 | magia Canary: ghoulish hyaena wave |
| Gore Horn | mammals | 12595 | 20620 | 1548 | outfit 1548 não existe no cliente 8.6; trocar corpse; magia Canary: root |
| Gorerilla | mammals | 13172 | 16850 | 1559 | outfit 1559 não existe no cliente 8.6; trocar corpse; magia Canary: gorerilla large ring; magia Canary: gorerilla small ring |
| Hot Dog | mammals | 190 | 505 | 32 | magia Canary: hot dog wave |
| Killer Rabbit | mammals | 160 | 205 | 74 | summon ausente: killer rabbit |
| Nighthunter | mammals | 12647 | 19200 | 1552 | outfit 1552 não existe no cliente 8.6; trocar corpse; magia Canary: nighthunter wave |
| Sabretooth | mammals | 11931 | 17300 | 1549 | outfit 1549 não existe no cliente 8.6; trocar corpse; magia Canary: sabretooth wave |
| Vulcongra | mammals | 1100 | 1600 | 509 | outfit 509 não existe no cliente 8.6; trocar corpse; magia Canary: vulcongra soulfire |
| Glooth Anemone | plants | 1755 | 2400 | 604 | outfit 604 não existe no cliente 8.6; trocar corpse; magia Canary: glooth anemone summon |
| Hideous Fungus | plants | 3700 | 4600 | 499 | outfit 499 não existe no cliente 8.6; trocar corpse; summon ausente: humorless fungus |
| Rootthing Amber Shaper | plants | 12400 | 15000 | 1762 | outfit 1762 não existe no cliente 8.6; trocar corpse; magia Canary: poison chain; magia Canary: rotthingshaper |
| Rootthing Bug Tracker | plants | 9650 | 12500 | 1763 | outfit 1763 não existe no cliente 8.6; trocar corpse; magia Canary: podzillaphyschain; magia Canary: rotthligexplo; magia Canary: rotthligholyulus |
| Rootthing Nutshell | plants | 9200 | 13500 | 1760 | outfit 1760 não existe no cliente 8.6; trocar corpse; magia Canary: rotthingwave; magia Canary: rotthligulus |
| A Greedy Eye | quests | 0 | 30000 | 925 | outfit 925 não existe no cliente 8.6; magia Canary: greedy eye beam |
| Aggressive Lava | quests | 0 | 5000 | 1041 | outfit 1041 não existe no cliente 8.6; magia Canary: aggressivelavawave |
| Aggressive Matter | quests | 0 | 5000 | 615 | outfit 615 não existe no cliente 8.6; trocar corpse; magia Canary: rot elemental paralyze |
| Amenef the Burning | quests | 21500 | 26000 | 541 | outfit 541 não existe no cliente 8.6; trocar corpse; magia Canary: firering; magia Canary: firex; bosstiary |
| Black Vixen | quests | 3200 | 3200 | 1038 | outfit 1038 não existe no cliente 8.6; trocar corpse; summon ausente: werefox; bosstiary |
| Bloated Man-Maggot | quests | 21570 | 31700 | 1654 | outfit 1654 não existe no cliente 8.6; trocar corpse; magia Canary: largefirering |
| Bloodback | quests | 4000 | 5200 | 1039 | outfit 1039 não existe no cliente 8.6; trocar corpse; summon ausente: Wereboar; bosstiary |
| Bruise Payne | quests | 1000 | 1600 | 307 | magia Canary: mutated bat curse; bosstiary |
| Condensed Sins | quests | 0 | 1500 | 315 | magia Canary: death blob curse |
| Converter | quests | 21425 | 29600 | 1623 | outfit 1623 não existe no cliente 8.6; trocar corpse; magia Canary: energy chain; magia Canary: largeholyring |
| Darkfang | quests | 4000 | 4800 | 308 | trocar corpse; magia Canary: werewolf skill reducer; summon ausente: Gloom Wolf; bosstiary |
| Darklight Construct | quests | 22050 | 32200 | 1622 | outfit 1622 não existe no cliente 8.6; trocar corpse; magia Canary: extended fire chain; magia Canary: largefirering |
| Darklight Emitter | quests | 20600 | 27500 | 1627 | outfit 1627 não existe no cliente 8.6; trocar corpse; magia Canary: largefirering |
| Darklight Matter | quests | 22250 | 30150 | 1624 | outfit 1624 não existe no cliente 8.6; trocar corpse; magia Canary: largeredring |
| Darklight Striker | quests | 22200 | 29700 | 1661 | outfit 1661 não existe no cliente 8.6; trocar corpse; magia Canary: extended holy chain; magia Canary: largepinkring |
| Dirtbeard | quests | 375 | 630 | 98 | trocar corpse; magia Canary: pirate corsair skill reducer; bosstiary |
| Dragon Wrath | quests | 4600 | 7800 | 351 | magia Canary: ghastly dragon curse; magia Canary: ghastly dragon paralyze; magia Canary: ghastly dragon wave |
| Dreadwing | quests | 3750 | 8500 | 307 | magia Canary: mutated bat curse |
| Drume | quests | 25000 | 80000 | 1317 | outfit 1317 não existe no cliente 8.6; trocar corpse; magia Canary: singlecloudchain; summon ausente: preceptor lazare,grand commander soeren,grand chaplain gaunder; bosstiary |
| Elder Bloodjaw | quests | 0 | 86000 | 1628 | outfit 1628 não existe no cliente 8.6; trocar corpse; magia Canary: blightwalker curse |
| Eliz The Unyielding Stop | quests | 0 | 15000 | 632 | outfit 632 não existe no cliente 8.6; trocar corpse; magia Canary: cults of tibia armor buff |
| Ember Beast | quests | 0 | 4000 | 498 | outfit 498 não existe no cliente 8.6; trocar corpse; magia Canary: emberbeastarea; magia Canary: emberbeasthur |
| Energy Pulse | quests | 0 | 5000 | 294 | magia Canary: energy pulse explosion |
| Enthralled Demon | quests | 100 | 8200 | 35 | trocar corpse; magia Canary: demon paralyze |
| Eruption of Destruction | quests | 0 | 8500 | ex 391 | trocar corpse; magia Canary: eruption of destruction explosion |
| Eshtaba The Conjurer Stop | quests | 0 | 15000 | 149 | trocar corpse; summon ausente: Dread Minion,Dread Minion,Dread Minion,Dread Minion,Dread Minion |
| Ethershreck | quests | 5600 | 9500 | 351 | magia Canary: ghastly dragon curse; bosstiary |
| Feroxa5 | quests | 0 | 150000 | 731 | outfit 731 não existe no cliente 8.6; trocar corpse; magia Canary: feroxa summon; bosstiary |
| Fiery Blood | quests | 0 | 25000 | 49 | magia Canary: aggressivelavawave |
| Fiery Heart | quests | 0 | 7500 | ex 391 | trocar corpse; magia Canary: aggressivelavawave |
| Flameborn | quests | 2550 | 3500 | 322 | magia Canary: fireball rune; magia Canary: hellspawn soulfire; bosstiary |
| Freed Soul | quests | 0 | 50000 | 294 | trocar corpse; magia Canary: freed soul spell |
| Frozen Minion | quests | 230 | 2200 | 53 | magia Canary: frozen minion beam; magia Canary: frozen minion heal; magia Canary: frozen minion wave |
| Glooth Masher | quests | 2200 | 2700 | 600 | outfit 600 não existe no cliente 8.6; trocar corpse; magia Canary: war golem electrify; magia Canary: war golem skill reducer |
| Glooth Slasher | quests | 2200 | 2700 | 600 | outfit 600 não existe no cliente 8.6; trocar corpse; magia Canary: war golem electrify; magia Canary: war golem skill reducer |
| Glooth Trasher | quests | 2200 | 2700 | 600 | outfit 600 não existe no cliente 8.6; trocar corpse; magia Canary: war golem electrify; magia Canary: war golem skill reducer |
| Glooth-Generator | quests | 0 | 12000 | ex 20710 | outfit item 20710 fora do cliente; trocar corpse; magia Canary: glooth-generator summon |
| Greater Canopic Jar | quests | 0 | 7000 | 599 | outfit 599 não existe no cliente 8.6; trocar corpse; summon ausente: Elder Mummy |
| Greed | quests | 0 | 1000 | 293 | trocar corpse; magia Canary: anomaly break; bosstiary |
| Haunted Dragon | quests | 6500 | 6500 | 231 | magia Canary: undead dragon curse |
| Hemming | quests | 2850 | 3000 | 308 | trocar corpse; magia Canary: werewolf skill reducer; bosstiary |
| Horestis | quests | 3500 | 6000 | 91 | summon ausente: Sandstone Scorpion; bosstiary |
| Icicle | quests | 0 | 8200 | 904 | outfit 904 não existe no cliente 8.6; magia Canary: icicle heal |
| Katex Blood Tongue | quests | 5000 | 6300 | 1300 | outfit 1300 não existe no cliente 8.6; trocar corpse; magia Canary: katex deathT; summon ausente: werehyaena; bosstiary |
| Lost Time | quests | 0 | 2000 | ex 24963 | outfit item 24963 fora do cliente; trocar corpse; magia Canary: white shade paralyze |
| Lovely Frazzlemaw | quests | 3400 | 4100 | 594 | outfit 594 não existe no cliente 8.6; trocar corpse; magia Canary: frazzlemaw paralyze |
| Lovely Souleater | quests | 1300 | 1100 | 355 | trocar corpse; magia Canary: souleater drown; magia Canary: souleater wave |
| Meandering Mushroom | quests | 21980 | 29100 | 1621 | outfit 1621 não existe no cliente 8.6; trocar corpse; magia Canary: largeblackring |
| Megasylvan Yselda | quests | 19900 | 32000 | ex 36928 | outfit item 36928 fora do cliente; trocar corpse; magia Canary: earth beamMY; magia Canary: mana leechMY; summon ausente: Carnisylvan Sapling; bosstiary |
| Mezlon The Defiler Stop | quests | 0 | 15000 | 144 | trocar corpse; magia Canary: heal monster 9x9 |
| Minion of Versperoth | quests | 0 | 9000 | 491 | outfit 491 não existe no cliente 8.6; trocar corpse; magia Canary: lava golem soulfire |
| Mycobiontic Beetle | quests | 21175 | 30200 | 1620 | outfit 1620 não existe no cliente 8.6; trocar corpse; magia Canary: largepoisonring |
| Omrafir | quests | 50000 | 322000 | 12 | magia Canary: omrafir beam; magia Canary: omrafir healing 2; magia Canary: omrafir summon; magia Canary: omrafir wave; bosstiary |
| Oozing Carcass | quests | 20980 | 27500 | 1626 | outfit 1626 não existe no cliente 8.6; trocar corpse; magia Canary: energy chain; magia Canary: largedeathring |
| Oozing Corpus | quests | 20600 | 28700 | 1625 | outfit 1625 não existe no cliente 8.6; trocar corpse; magia Canary: death chain |
| Orc Cult Priest | quests | 1000 | 1300 | 6 | magia Canary: heal monster |
| Overcharged Demon | quests | 0 | 21500 | 35 | trocar corpse; magia Canary: demon paralyze |
| Paiz the Pauperizer | quests | 6300 | 8500 | 362 | trocar corpse; magia Canary: soulfire rune; bosstiary |
| Rage of Mazoran | quests | 0 | 4500 | 243 | magia Canary: hellfire fighter soulfire |
| Rotten Man-Maggot | quests | 22625 | 31100 | 1655 | outfit 1655 não existe no cliente 8.6; trocar corpse; magia Canary: largeicering |
| Shadow Fiend | quests | 500 | 3200 | 320 | trocar corpse; magia Canary: nightstalker paralyze |
| Shadow Tentacle | quests | 0 | 22500 | 681 | outfit 681 não existe no cliente 8.6; trocar corpse; magia Canary: blightwalker curse |
| Shadowpelt | quests | 4600 | 6000 | 1040 | outfit 1040 não existe no cliente 8.6; trocar corpse; summon ausente: Werebear; bosstiary |
| Sharpclaw | quests | 3000 | 3300 | 1031 | outfit 1031 não existe no cliente 8.6; trocar corpse; magia Canary: ghastly dragon curse; summon ausente: Werebadger; bosstiary |
| Sin Devourer | quests | 500 | 2700 | 320 | trocar corpse; magia Canary: nightstalker paralyze; magia Canary: silencer skill reducer |
| Sister Hetai | quests | 20500 | 25000 | 1199 | outfit 1199 não existe no cliente 8.6; trocar corpse; magia Canary: targetfirering; bosstiary |
| Solid Frozen Horror | quests | 0 | 70000 | 261 | magia Canary: hirintror freeze; magia Canary: hirintror skill reducer; magia Canary: ice golem paralyze; bosstiary |
| Sopping Carcass | quests | 23425 | 32700 | 1658 | outfit 1658 não existe no cliente 8.6; trocar corpse; magia Canary: ice chain |
| Sopping Corpus | quests | 22465 | 33400 | 1659 | outfit 1659 não existe no cliente 8.6; trocar corpse; magia Canary: largepoisonring |
| Soul Reaper | quests | 2200 | 3500 | 878 | outfit 878 não existe no cliente 8.6; trocar corpse; magia Canary: breach brood reducer |
| Spark of Destruction | quests | 0 | 3900 | 879 | outfit 879 não existe no cliente 8.6; trocar corpse; magia Canary: reality reaver wave |
| Srezz Yellow Eyes | quests | 4800 | 6200 | 220 | magia Canary: lleech waveT; bosstiary |
| Sun-Marked Goanna | quests | 7600 | 7800 | 1195 | outfit 1195 não existe no cliente 8.6; trocar corpse; magia Canary: wave t |
| Thawing Dragon Lord | quests | 2100 | 25000 | 1077 | outfit 1077 não existe no cliente 8.6; trocar corpse; magia Canary: ice crystal bomb; bosstiary |
| The Remorseless Corruptor | quests | 0 | 290000 | 875 | outfit 875 não existe no cliente 8.6; trocar corpse; magia Canary: remorseless wave; bosstiary |
| The Sinister Hermit | quests | 0 | 30000 | 153 | trocar corpse; magia Canary: shock head skill reducer 2; summon ausente: Vermin Swarm |
| The Sinister Hermit Dirty | quests | 0 | 30000 | 153 | trocar corpse; magia Canary: shock head skill reducer 2; summon ausente: Vermin Swarm |
| Time Keeper | quests | 0 | 1000 | 560 | outfit 560 não existe no cliente 8.6; trocar corpse; magia Canary: white shade paralyze |
| Time Waster | quests | 0 | 1000 | ex 23729 | outfit item 23729 fora do cliente; trocar corpse; magia Canary: white shade paralyze |
| Tromphonyte | quests | 1300 | 3000 | 381 | outfit 381 não existe no cliente 8.6; trocar corpse; magia Canary: stampor skill reducer; bosstiary |
| Unbound Blightwalker | quests | 5850 | 8900 | 246 | magia Canary: blightwalker curse |
| Unbound Demon Outcast | quests | 6200 | 6900 | 590 | outfit 590 não existe no cliente 8.6; trocar corpse; magia Canary: demon outcast skill reducer |
| Unchained Fire | quests | 0 | 30000 | 242 | trocar corpse; magia Canary: unchained fire beam; magia Canary: unchained fire explosion |
| Urmahlullu the Weakened | quests | 55000 | 100000 | 1197 | outfit 1197 não existe no cliente 8.6; trocar corpse; magia Canary: urmahlulluring; bosstiary |
| Void | quests | 320 | 2000 | ex 470 | trocar corpse; summon ausente: Enthralled Demon |
| Walking Pillar | quests | 24300 | 38000 | 1656 | outfit 1656 não existe no cliente 8.6; trocar corpse; magia Canary: extended energy chain; magia Canary: largepinkring |
| Wandering Pillar | quests | 23200 | 37000 | 1657 | outfit 1657 não existe no cliente 8.6; trocar corpse; magia Canary: largeholyring |
| Zanakeph | quests | 9900 | 13000 | 231 | magia Canary: undead dragon curse; bosstiary |
| Zorvorax | quests | 9000 | 10000 | 928 | outfit 928 não existe no cliente 8.6; magia Canary: undead dragon curse; bosstiary |
| Frost Servant | raids | 0 | 385 | 261 | magia Canary: hirintror summon |
| Furyosa | raids | 11500 | 25000 | 149 | trocar corpse; magia Canary: fury skill reducer; bosstiary |
| Glooth Fairy | raids | 19000 | 59000 | 600 | outfit 600 não existe no cliente 8.6; trocar corpse; magia Canary: glooth fairy skill reducer; magia Canary: war golem skill reducer; bosstiary |
| Grand Mother Foulscale | raids | 1400 | 1850 | 34 | summon ausente: dragon hatchlings; bosstiary |
| Hirintror | raids | 800 | 1500 | 261 | magia Canary: hirintror freeze; magia Canary: hirintror skill reducer; magia Canary: hirintror summon; magia Canary: ice golem paralyze; bosstiary |
| Spawn of the Welter | raids | 0 | 1850 | 121 | magia Canary: spawn of the welter heal |
| The Pale Count | raids | 28000 | 50000 | 557 | outfit 557 não existe no cliente 8.6; trocar corpse; summon ausente: Nightfiend; bosstiary |
| The Welter | raids | 11000 | 25000 | 563 | outfit 563 não existe no cliente 8.6; trocar corpse; magia Canary: the welter heal; magia Canary: the welter paralyze; magia Canary: the welter summon2; summon ausente: spawn of the welter; bosstiary |
| Tyrn | raids | 6900 | 12000 | 562 | outfit 562 não existe no cliente 8.6; trocar corpse; magia Canary: tyrn electrify; magia Canary: tyrn heal; magia Canary: tyrn skill reducer; bosstiary |
| White Pale | raids | 390 | 500 | 564 | outfit 564 não existe no cliente 8.6; trocar corpse; magia Canary: white pale paralyze; magia Canary: white pale summon; bosstiary |
| Carnivostrich | reptiles | 7290 | 8250 | 1605 | outfit 1605 não existe no cliente 8.6; trocar corpse; magia Canary: energy chain; magia Canary: thunderstorm ring |
| Corrupt Naga | reptiles | 4380 | 5990 | 1538 | outfit 1538 não existe no cliente 8.6; trocar corpse; magia Canary: nagadeathattack |
| Emerald Tortoise | reptiles | 12129 | 22300 | 1550 | outfit 1550 não existe no cliente 8.6; trocar corpse; magia Canary: emerald tortoise large ring; magia Canary: emerald tortoise small explosion; magia Canary: emerald tortoise small ring; magia Canary: energy chain |
| Fungosaurus | reptiles | 0 | 30000 | 1555 | outfit 1555 não existe no cliente 8.6; trocar corpse; magia Canary: fear; magia Canary: root |
| Harpy | reptiles | 5720 | 7700 | 1604 | outfit 1604 não existe no cliente 8.6; trocar corpse; magia Canary: energy chain; magia Canary: energy ring |
| Mantosaurus | reptiles | 11569 | 19400 | 1556 | outfit 1556 não existe no cliente 8.6; trocar corpse; magia Canary: mantosaurus ring |
| Mercurial Menace | reptiles | 12095 | 18500 | 1561 | outfit 1561 não existe no cliente 8.6; trocar corpse; magia Canary: mercurial menace ring |
| Naga Archer | reptiles | 5150 | 4640 | 1537 | outfit 1537 não existe no cliente 8.6; trocar corpse; magia Canary: death chain; magia Canary: nagadeath; magia Canary: nagadeathattack |
| Naga Warrior | reptiles | 5890 | 5530 | 1539 | outfit 1539 não existe no cliente 8.6; trocar corpse; magia Canary: nagadeathattack |
| Noxious Ripptor | reptiles | 13190 | 22700 | 1558 | outfit 1558 não existe no cliente 8.6; trocar corpse; magia Canary: noxious ripptor wave |
| Rogue Naga | reptiles | 4510 | 6200 | 1543 | outfit 1543 não existe no cliente 8.6; trocar corpse; magia Canary: death chain; magia Canary: nagadeath; magia Canary: nagadeathattack |
| Seacrest Serpent | reptiles | 2900 | 3000 | 675 | outfit 675 não existe no cliente 8.6; trocar corpse; magia Canary: seacrest serpent wave |
| Stampor | reptiles | 780 | 1200 | 381 | outfit 381 não existe no cliente 8.6; trocar corpse; magia Canary: stampor skill reducer |
| Stonerefiner | reptiles | 500 | 800 | 1032 | outfit 1032 não existe no cliente 8.6; trocar corpse; magia Canary: stone shower rune |
| Devourer | slimes | 1755 | 1900 | 617 | outfit 617 não existe no cliente 8.6; trocar corpse; magia Canary: devourer paralyze; magia Canary: devourer wave |
| Glooth Blob | slimes | 700 | 750 | 614 | outfit 614 não existe no cliente 8.6; trocar corpse; summon ausente: Glooth Blob |
| Squidgy Slime | slimes | 55 | 150 | 19 | summon ausente: Squidgy Slime |
| Deaththrower | traps | 0 | 100 | ex 2190 | trocar corpse; magia Canary: dark torturer skill reducer |
| Hell Hole | traps | 0 | 100 | ex 391 | trocar corpse; summon ausente: Deathspawn |
| Hive Pore | traps | 0 | 1 | ex 14064 | outfit item 14064 fora do cliente; trocar corpse; summon ausente: Lesser Swarmer |
| Ahau | undeads | 17500 | 9000 | 1591 | outfit 1591 não existe no cliente 8.6; trocar corpse; magia Canary: boulder ring; bosstiary |
| Iks Yapunac | undeads | 3125 | 3125 | 1702 | outfit 1702 não existe no cliente 8.6; trocar corpse; magia Canary: iksyapunacwave |
| Rot Elemental | undeads | 750 | 850 | 615 | outfit 615 não existe no cliente 8.6; trocar corpse; magia Canary: rot elemental paralyze |
| Cave Devourer | vermins | 3380 | 4500 | 1036 | outfit 1036 não existe no cliente 8.6; trocar corpse; magia Canary: stalagmite rune; magia Canary: stone shower rune |
| Chasm Spawn | vermins | 3600 | 4500 | 1037 | outfit 1037 não existe no cliente 8.6; trocar corpse; magia Canary: explosion rune; magia Canary: stone shower rune |
| Hive Overseer | vermins | 5500 | 7500 | 458 | outfit 458 não existe no cliente 8.6; trocar corpse; summon ausente: Spidris Elite Summon |
| Lavafungus | vermins | 6200 | 7200 | 1405 | outfit 1405 não existe no cliente 8.6; trocar corpse; magia Canary: lavafungus ring; magia Canary: lavafungus x wave |
| Streaked Devourer | vermins | 6300 | 7000 | 1398 | outfit 1398 não existe no cliente 8.6; trocar corpse; magia Canary: devourer death wave |
| Sulphider | vermins | 13328 | 21000 | 1546 | outfit 1546 não existe no cliente 8.6; trocar corpse; magia Canary: blast ring |
| Tunnel Tyrant | vermins | 4420 | 5200 | 1035 | outfit 1035 não existe no cliente 8.6; trocar corpse; magia Canary: stalagmite rune; magia Canary: stone shower rune |
| Undertaker | vermins | 13543 | 20100 | 1551 | outfit 1551 não existe no cliente 8.6; trocar corpse; magia Canary: root wave; magia Canary: undertaker square explosion |

## B3. Requerem script (events)
| Monstro | Pasta | XP | HP | Outfit | Observações |
|---|---|---|---|---|---|
| Aldorias | WOL | 1 | 99200 | 37 | script Lua |
| Lion Knight | WOL | 0 | 8200 | 1317 | outfit 1317 não existe no cliente 8.6; trocar corpse; magia Canary: aiattack; magia Canary: aithinkattacks; magia Canary: aithinkitems; script Lua |
| NPC Test 2 | WOL | 1 | 99200 | 37 | script Lua |
| Rogue | WOL | 0 | 8200 | 1317 | outfit 1317 não existe no cliente 8.6; trocar corpse; magia Canary: aiattack; magia Canary: aithinkattacks; magia Canary: aithinkitems; script Lua |
| Skeleton AI | WOL | 35 | 50 | 33 | magia Canary: aiattack; magia Canary: aithinkattacks; script Lua |
| Sword Merchant | WOL | 1 | 99200 | 37 | script Lua |
| Bakragore | bosses | 15000000 | 660000 | 1671 | outfit 1671 não existe no cliente 8.6; trocar corpse; summon ausente: Elder Bloodjaw; events Lua; script Lua; bosstiary |
| Chagorz | bosses | 3250000 | 350000 | 1666 | outfit 1666 não existe no cliente 8.6; trocar corpse; events Lua; script Lua; bosstiary |
| Custodian | bosses | 27500 | 47000 | 1217 | outfit 1217 não existe no cliente 8.6; trocar corpse; magia Canary: explosion wave; events Lua; bosstiary |
| Energized Raging Mage | bosses | 0 | 3500 | 423 | outfit 423 não existe no cliente 8.6; trocar corpse; magia Canary: energized raging mage skill reducer; magia Canary: thunderstorm rune; summon ausente: Golden Servant; events Lua; bosstiary |
| Gaffir | bosses | 25000 | 48500 | 1217 | outfit 1217 não existe no cliente 8.6; trocar corpse; summon ausente: Black Cobra; events Lua; bosstiary |
| Guard Captain Quaid | bosses | 28000 | 55000 | 1217 | outfit 1217 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Ichgahal | bosses | 3250000 | 350000 | 1665 | outfit 1665 não existe no cliente 8.6; trocar corpse; summon ausente: Mushroom; events Lua; script Lua; bosstiary |
| Izcandar Champion of Summer | bosses | 6900 | 130000 | 1137 | outfit 1137 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Izcandar Champion of Winter | bosses | 6900 | 130000 | 1137 | outfit 1137 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Kroazur | bosses | 2700 | 3000 | 842 | outfit 842 não existe no cliente 8.6; events Lua; bosstiary |
| Mitmah Vanguard | bosses | 300000 | 200000 | 1716 | outfit 1716 não existe no cliente 8.6; trocar corpse; magia Canary: boulder ring; magia Canary: root; events Lua; script Lua; bosstiary |
| Murcion | bosses | 3250000 | 350000 | 1664 | outfit 1664 não existe no cliente 8.6; trocar corpse; summon ausente: Mushroom; events Lua; script Lua; bosstiary |
| Raging mage | bosses | 3250 | 3500 | 416 | outfit 416 não existe no cliente 8.6; trocar corpse; magia Canary: thunderstorm rune; summon ausente: Golden Servant; events Lua; bosstiary |
| Renegade Orc | bosses | 270 | 450 | 59 | events Lua; bosstiary |
| Splasher | bosses | 1500 | 1700 | 47 | events Lua; bosstiary |
| The Astral Source | bosses | 3000 | 150000 | ex 24228 | outfit item 24228 fora do cliente; trocar corpse; events Lua; bosstiary |
| The Book of Death | bosses | 0 | 7800 | 1061 | outfit 1061 não existe no cliente 8.6; trocar corpse; events Lua |
| The First Dragon | bosses | 9000 | 50000 | 947 | outfit 947 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| The Flaming Orchid | bosses | 8500 | 4000 | 150 | trocar corpse; magia Canary: Ignite; magia Canary: aggressivelavawave; magia Canary: big death wave; events Lua |
| Vemiath | bosses | 3250000 | 350000 | 1668 | outfit 1668 não existe no cliente 8.6; trocar corpse; events Lua; script Lua; bosstiary |
| Diamond Servant Replica | constructs | 1400 | 2000 | 397 | outfit 397 não existe no cliente 8.6; trocar corpse; magia Canary: wyrm wave; events Lua |
| Golden Servant Replica | constructs | 1250 | 2000 | 396 | outfit 396 não existe no cliente 8.6; trocar corpse; events Lua |
| Iron Servant Replica | constructs | 600 | 1000 | 395 | outfit 395 não existe no cliente 8.6; trocar corpse; script Lua |
| Mountain Troll | dawnport | 12 | 30 | 15 | events Lua |
| Muglex Clan Footman | dawnport | 25 | 50 | 61 | events Lua |
| Yielothax | extra_dimensional | 1250 | 1500 | 408 | outfit 408 não existe no cliente 8.6; trocar corpse; events Lua |
| Lost Exile | humanoids | 1800 | 1600 | 537 | outfit 537 não existe no cliente 8.6; trocar corpse; magia Canary: sudden death rune; events Lua |
| Minotaur Bruiser | humanoids | 50 | 100 | 25 | events Lua |
| Minotaur Cult Follower | humanoids | 950 | 1600 | 25 | events Lua |
| Minotaur Cult Prophet | humanoids | 1100 | 1700 | 23 | magia Canary: Minotaur Cult Prophet Mass Healing; events Lua |
| Minotaur Cult Zealot | humanoids | 1350 | 1800 | 29 | events Lua |
| Burning Gladiator | humans | 7350 | 10000 | 541 | outfit 541 não existe no cliente 8.6; trocar corpse; magia Canary: firering; magia Canary: firex; events Lua |
| Cobra Assassin | humans | 6980 | 8200 | 1217 | outfit 1217 não existe no cliente 8.6; trocar corpse; magia Canary: wave t; script Lua |
| Cobra Scout | humans | 7310 | 8500 | 1217 | outfit 1217 não existe no cliente 8.6; trocar corpse; script Lua |
| Cobra Vizier | humans | 7650 | 8500 | 1217 | outfit 1217 não existe no cliente 8.6; trocar corpse; magia Canary: death chain; magia Canary: explosion wave; script Lua |
| Lion Knight | humans | 0 | 8200 | 1317 | outfit 1317 não existe no cliente 8.6; trocar corpse; magia Canary: aiattack; magia Canary: aithinkattacks; magia Canary: aithinkitems; script Lua |
| Necromancer Servant | humans | 590 | 600 | 9 | trocar corpse; events Lua |
| Nomad Blue | humans | 60 | 160 | 146 | trocar corpse; events Lua |
| Nomad Female | humans | 60 | 160 | 150 | trocar corpse; events Lua |
| Priestess of the Wild Sun | humans | 6400 | 8500 | 1199 | outfit 1199 não existe no cliente 8.6; trocar corpse; magia Canary: targetfirering; events Lua |
| Candy Horror | magicals | 3000 | 3100 | 1739 | outfit 1739 não existe no cliente 8.6; trocar corpse; events Lua |
| Crystalcrusher | magicals | 500 | 570 | 511 | outfit 511 não existe no cliente 8.6; trocar corpse; events Lua |
| Enfeebled Silencer | magicals | 1100 | 1100 | 585 | outfit 585 não existe no cliente 8.6; trocar corpse; magia Canary: silencer skill reducer; events Lua |
| Frazzlemaw | magicals | 3740 | 4100 | 594 | outfit 594 não existe no cliente 8.6; trocar corpse; events Lua |
| Nibblemaw | magicals | 2700 | 2900 | 1737 | outfit 1737 não existe no cliente 8.6; trocar corpse; events Lua |
| Silencer | magicals | 5100 | 5400 | 585 | outfit 585 não existe no cliente 8.6; trocar corpse; magia Canary: silencer skill reducer; events Lua |
| Weakened Frazzlemaw | magicals | 1000 | 1200 | 594 | outfit 594 não existe no cliente 8.6; trocar corpse; events Lua |
| Enraged White Deer | mammals | 165 | 255 | 400 | outfit 400 não existe no cliente 8.6; trocar corpse; events Lua |
| White Deer | mammals | 0 | 195 | 400 | outfit 400 não existe no cliente 8.6; trocar corpse; events Lua |
| Abyssador | quests | 400000 | 340000 | 495 | outfit 495 não existe no cliente 8.6; trocar corpse; magia Canary: abyssador poison wave; events Lua; bosstiary |
| Aftershock | quests | 20000 | 105000 | 875 | outfit 875 não existe no cliente 8.6; trocar corpse; magia Canary: aftershock wave; magia Canary: anomaly break; events Lua; bosstiary |
| Alptramun | quests | 55000 | 320000 | 1143 | outfit 1143 não existe no cliente 8.6; trocar corpse; magia Canary: stone shower rune; events Lua; bosstiary |
| An Astral Glyph | quests | 0 | 300000 | ex 24225 | outfit item 24225 fora do cliente; trocar corpse; events Lua; bosstiary |
| Angry Plant | quests | 0 | 10000 | 120 | events Lua |
| Anomaly | quests | 50000 | 290000 | 876 | outfit 876 não existe no cliente 8.6; trocar corpse; magia Canary: anomaly break; magia Canary: anomaly wave; events Lua; bosstiary |
| Arbaziloth | quests | 500000 | 360000 | 1802 | outfit 1802 não existe no cliente 8.6; trocar corpse; summon ausente: Overcharged Demon; script Lua; bosstiary |
| Ashes of Burning Hatred | quests | 0 | 15000 | ex 34009 | outfit item 34009 fora do cliente; events Lua |
| Aspect of Power | quests | 0 | 25000 | 1306 | outfit 1306 não existe no cliente 8.6; trocar corpse; events Lua |
| Azaram's Soul | quests | 0 | 1 | 1219 | outfit 1219 não existe no cliente 8.6; trocar corpse; events Lua |
| Azerus2 | quests | 6000 | 26000 | 309 | trocar corpse; events Lua |
| Blaze of Burning Hatred | quests | 0 | 15000 | ex 34013 | outfit item 34013 fora do cliente; events Lua |
| Bone Capsule | quests | 0 | 70000 | 863 | outfit 863 não existe no cliente 8.6; trocar corpse; events Lua |
| Bony Sea Devil | quests | 19470 | 24000 | 1294 | outfit 1294 não existe no cliente 8.6; trocar corpse; magia Canary: destroy magic walls; magia Canary: ice chain; magia Canary: soulwars fear; events Lua; script Lua |
| Bound Astral Power | quests | 0 | 70000 | 879 | outfit 879 não existe no cliente 8.6; trocar corpse; events Lua |
| Brachiodemon | quests | 15770 | 25000 | 1299 | outfit 1299 não existe no cliente 8.6; trocar corpse; magia Canary: destroy magic walls; events Lua; script Lua |
| Bragrumol | quests | 18000 | 38000 | 856 | outfit 856 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Branchy Crawler | quests | 17860 | 27000 | 1297 | outfit 1297 não existe no cliente 8.6; trocar corpse; magia Canary: root; events Lua; script Lua |
| Brokul | quests | 23000 | 50000 | 1076 | outfit 1076 não existe no cliente 8.6; trocar corpse; summon ausente: neutral deepling warrior; events Lua; bosstiary |
| Brother Worm | quests | 30000 | 300000 | 295 | events Lua; bosstiary |
| Capricious Phantom | quests | 19360 | 30000 | 1298 | outfit 1298 não existe no cliente 8.6; trocar corpse; magia Canary: ice chain; events Lua |
| Charged Anomaly | quests | 0 | 18000 | 876 | outfit 876 não existe no cliente 8.6; trocar corpse; magia Canary: anomaly break; magia Canary: charge vortex; events Lua; bosstiary |
| Charged Disruption | quests | 400 | 128000 | ex 1949 | trocar corpse; events Lua; bosstiary |
| Charger | quests | 85 | 1600 | 293 | trocar corpse; events Lua |
| Charging Outburst | quests | 50000 | 12000 | 876 | outfit 876 não existe no cliente 8.6; trocar corpse; magia Canary: anomaly break; magia Canary: outburst explode; events Lua; bosstiary |
| Cloak of Terror | quests | 19700 | 28000 | 1295 | outfit 1295 não existe no cliente 8.6; trocar corpse; magia Canary: destroy magic walls; events Lua; script Lua |
| Concentrated Death | quests | 0 | 10000 | 315 | trocar corpse; events Lua; bosstiary |
| Corrupted Soul | quests | 1300 | 1100 | 355 | trocar corpse; magia Canary: souleater drown; magia Canary: souleater wave; events Lua |
| Cosmic Energy Prism A | quests | 840 | 1000 | ex 2187 | trocar corpse; events Lua |
| Cosmic Energy Prism B | quests | 840 | 1000 | ex 2187 | trocar corpse; events Lua |
| Cosmic Energy Prism C | quests | 840 | 1000 | ex 2187 | trocar corpse; events Lua |
| Cosmic Energy Prism D | quests | 840 | 1000 | ex 2187 | trocar corpse; events Lua |
| Count Vlarkorth | quests | 55000 | 75000 | 1221 | outfit 1221 não existe no cliente 8.6; trocar corpse; summon ausente: Soulless Minion; events Lua; bosstiary |
| Courage Leech | quests | 18900 | 27000 | 1315 | outfit 1315 não existe no cliente 8.6; trocar corpse; magia Canary: energy chain; events Lua |
| Crackler | quests | 0 | 15000 | 293 | trocar corpse; events Lua |
| Cult Believer | quests | 850 | 975 | 132 | trocar corpse; events Lua |
| Cult Enforcer | quests | 1000 | 1150 | 134 | trocar corpse; events Lua |
| Cult Scholar | quests | 1100 | 1650 | 145 | trocar corpse; events Lua |
| Damage Resonance | quests | 560 | 11000 | ex 22761 | outfit item 22761 fora do cliente; trocar corpse; events Lua; bosstiary |
| Dazed Leaf Golem | quests | 8000 | 10000 | 573 | outfit 573 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Death Dragon | quests | 350 | 8350 | 231 | trocar corpse; magia Canary: undead dragon curse; events Lua |
| Death Priest Shargon | quests | 20000 | 65000 | 278 | trocar corpse; summon ausente: Lesser Death Minion,Superior Death Minion,Greater Death Minion; events Lua; bosstiary |
| Deathstrike | quests | 40000 | 200000 | 500 | outfit 500 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Deep Terror | quests | 35000 | 100000 | 676 | outfit 676 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Depolarized Crackler | quests | 30000 | 15000 | 290 | trocar corpse; events Lua |
| Destabilized Ferumbras | quests | 35000 | 62000 | 844 | outfit 844 não existe no cliente 8.6; trocar corpse; magia Canary: ferumbras electrify; magia Canary: ferumbras soulfire; events Lua; bosstiary |
| Disgusting Ooze | quests | 3700 | 3650 | 238 | magia Canary: defiler paralyze 1; magia Canary: defiler paralyze 2; magia Canary: defiler paralyze 3; events Lua |
| Disruption | quests | 398 | 12000 | ex 22761 | outfit item 22761 fora do cliente; trocar corpse; events Lua |
| Distorted Phantom | quests | 18870 | 26000 | 1298 | outfit 1298 não existe no cliente 8.6; trocar corpse; magia Canary: extended holy chain; magia Canary: ice chain; events Lua |
| Dorokoll the Mystic | quests | 50000 | 30000 | 154 | trocar corpse; events Lua |
| Dragon Egg | quests | 0 | 5000 | ex 25077 | outfit item 25077 fora do cliente; trocar corpse; events Lua |
| Dragon Essence | quests | 0 | 30000 | 248 | trocar corpse; events Lua |
| Dragon Hoard | quests | 0 | 999999 | ex 5674 | trocar corpse; events Lua; script Lua; bosstiary |
| Dreadful Disruptor | quests | 14000 | 14000 | 879 | outfit 879 não existe no cliente 8.6; trocar corpse; magia Canary: dread intruder wave; script Lua; bosstiary |
| Druid's Apparition | quests | 28600 | 25000 | 148 | magia Canary: ice chain; events Lua |
| Duke Krule | quests | 55000 | 75000 | 1221 | outfit 1221 não existe no cliente 8.6; trocar corpse; summon ausente: Soul Scourge; events Lua; bosstiary |
| Earl Osam | quests | 55000 | 75000 | 1223 | outfit 1223 não existe no cliente 8.6; trocar corpse; magia Canary: ice chain; summon ausente: Frozen Soul; events Lua; bosstiary |
| Eliz the Unyielding | quests | 50000 | 30000 | 632 | outfit 632 não existe no cliente 8.6; trocar corpse; magia Canary: cults of tibia armor buff; events Lua |
| Empowered Glooth Horror | quests | 2150 | 25000 | 677 | outfit 677 não existe no cliente 8.6; trocar corpse; events Lua |
| Eradicator | quests | 50000 | 290000 | 875 | outfit 875 não existe no cliente 8.6; trocar corpse; magia Canary: anomaly break; magia Canary: big energy wave; events Lua; bosstiary |
| Eradicator2 | quests | 50000 | 290000 | 875 | outfit 875 não existe no cliente 8.6; trocar corpse; magia Canary: anomaly break; magia Canary: big lifedrain wave; events Lua; bosstiary |
| Eshtaba the Conjurer | quests | 50000 | 30000 | 149 | trocar corpse; summon ausente: Dread Minion,Dread Minion,Dread Minion,Dread Minion,Dread Minion; events Lua |
| Essence of Malice | quests | 150000 | 250000 | 351 | magia Canary: ghastly dragon curse; events Lua; bosstiary |
| Faceless Bane | quests | 20000 | 35000 | 1119 | outfit 1119 não existe no cliente 8.6; trocar corpse; events Lua; script Lua; bosstiary |
| Fallen Challenger | quests | 0 | 9000 | 231 | trocar corpse; events Lua |
| Feeble Glooth Horror | quests | 245 | 5000 | 677 | outfit 677 não existe no cliente 8.6; trocar corpse; events Lua |
| Feroxa | quests | 0 | 100000 | 158 | trocar corpse; magia Canary: feroxa summon; events Lua; bosstiary |
| Feroxa2 | quests | 0 | 50000 | 731 | outfit 731 não existe no cliente 8.6; trocar corpse; magia Canary: feroxa summon; events Lua |
| Feroxa3 | quests | 0 | 130000 | 158 | trocar corpse; magia Canary: feroxa summon; events Lua |
| Feroxa4 | quests | 0 | 130000 | 716 | outfit 716 não existe no cliente 8.6; trocar corpse; magia Canary: feroxa summon; events Lua |
| Ferumbras Essence | quests | 0 | 35000 | 294 | events Lua |
| Ferumbras Mortal Shell | quests | 2000000 | 300000 | 229 | magia Canary: ferumbras electrify; magia Canary: ferumbras soulfire; events Lua; bosstiary |
| Ferumbras Soul Splinter | quests | 35000 | 90000 | 843 | outfit 843 não existe no cliente 8.6; trocar corpse; magia Canary: ferumbras electrify; magia Canary: ferumbras soulfire; events Lua |
| Fetter | quests | 0 | 13500 | 235 | trocar corpse; magia Canary: spectre drown; events Lua |
| Flame of Burning Hatred | quests | 0 | 15000 | ex 34011 | outfit item 34011 fora do cliente; events Lua |
| Foreshock | quests | 20000 | 105000 | 875 | outfit 875 não existe no cliente 8.6; trocar corpse; magia Canary: anomaly break; events Lua; bosstiary |
| Frenzy | quests | 1313 | 8210 | 290 | trocar corpse; magia Canary: big energy purple wave2; events Lua; bosstiary |
| Fury of the Emperor | quests | 550 | 51000 | 351 | events Lua; bosstiary |
| Gaz'Haragoth | quests | 1000000 | 350000 | 591 | outfit 591 não existe no cliente 8.6; trocar corpse; magia Canary: gaz'haragoth death; magia Canary: gaz'haragoth iceball; magia Canary: gaz'haragoth paralyze; magia Canary: gaz'haragoth summon; events Lua; bosstiary |
| Ghulosh | quests | 45000 | 300000 | 1062 | outfit 1062 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Glooth Horror | quests | 900 | 15000 | 677 | outfit 677 não existe no cliente 8.6; trocar corpse; events Lua |
| Gnomevil | quests | 400000 | 250000 | 504 | outfit 504 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Gorzindel | quests | 100000 | 300000 | 1062 | outfit 1062 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Goshnar's Cruelty | quests | 75000 | 300000 | 1303 | outfit 1303 não existe no cliente 8.6; trocar corpse; magia Canary: cruelty transform elemental; magia Canary: singlecloudchain; events Lua; script Lua; bosstiary |
| Goshnar's Greed | quests | 150000 | 300000 | 1304 | outfit 1304 não existe no cliente 8.6; trocar corpse; magia Canary: singlecloudchain; events Lua; script Lua; bosstiary |
| Goshnar's Hatred | quests | 75000 | 300000 | 1307 | outfit 1307 não existe no cliente 8.6; trocar corpse; magia Canary: singlecloudchain; events Lua; script Lua; bosstiary |
| Goshnar's Malice | quests | 75000 | 300000 | 1306 | outfit 1306 não existe no cliente 8.6; trocar corpse; events Lua; script Lua; bosstiary |
| Goshnar's Megalomania Blue | quests | 3000000 | 620000 | 1337 | outfit 1337 não existe no cliente 8.6; trocar corpse; magia Canary: megalomania blue; events Lua; script Lua; bosstiary |
| Goshnar's Megalomania Green | quests | 3000000 | 620000 | 99 | trocar corpse; magia Canary: megalomania transform elemental; magia Canary: soulwars fear; events Lua; script Lua; bosstiary |
| Goshnar's Megalomania Purple | quests | 0 | 620000 | 1308 | outfit 1308 não existe no cliente 8.6; magia Canary: megalomania transform elemental; magia Canary: soulwars fear; events Lua; script Lua; bosstiary |
| Goshnar's Spite | quests | 75000 | 300000 | 1305 | outfit 1305 não existe no cliente 8.6; trocar corpse; magia Canary: singlecloudchain; magia Canary: soulwars fear; events Lua; bosstiary |
| Grand Canon Dominus | quests | 11000 | 15000 | 1071 | outfit 1071 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Grand Chaplain Gaunder | quests | 14000 | 18000 | 1071 | outfit 1071 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Grand Commander Soeren | quests | 12000 | 17000 | 1071 | outfit 1071 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Grand Master Oberon | quests | 20000 | 60000 | 1072 | outfit 1072 não existe no cliente 8.6; trocar corpse; events Lua; script Lua; bosstiary |
| Greater Splinter of Madness | quests | 0 | 4000 | 1268 | outfit 1268 não existe no cliente 8.6; trocar corpse; script Lua |
| Greedbeast | quests | 0 | 10000 | 101 | trocar corpse; events Lua |
| Horrible Dream | quests | 0 | 320 | 315 | magia Canary: death blob curse; events Lua |
| Infernal Demon | quests | 17430 | 32000 | 1313 | outfit 1313 não existe no cliente 8.6; trocar corpse; magia Canary: death chain; events Lua |
| Infernal Phantom | quests | 15770 | 26000 | 1298 | outfit 1298 não existe no cliente 8.6; trocar corpse; magia Canary: extended fire chain; events Lua |
| Inky | quests | 700 | 750 | 46 | magia Canary: quara constrictor electrify; events Lua; bosstiary |
| Izcandar the Banished | quests | 55000 | 320000 | 1137 | outfit 1137 não existe no cliente 8.6; events Lua; bosstiary |
| Jaul | quests | 30000 | 90000 | 444 | outfit 444 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Kesar | quests | 0 | 35000 | 1317 | outfit 1317 não existe no cliente 8.6; trocar corpse; magia Canary: singlecloudchain; magia Canary: singledeathchain; magia Canary: singleicechain; events Lua |
| King Zelos | quests | 75000 | 480000 | 1224 | outfit 1224 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Knight's Apparition | quests | 28600 | 25000 | 131 | trocar corpse; magia Canary: ice chain; events Lua |
| Lady Tenebris | quests | 50000 | 150000 | 433 | outfit 433 não existe no cliente 8.6; magia Canary: tenebris summon; magia Canary: tenebris ultimate; events Lua; bosstiary |
| Leiden | quests | 0 | 30000 | 988 | outfit 988 não existe no cliente 8.6; trocar corpse; summon ausente: Barkless Fanatic,Barkless Fanatic; events Lua |
| Lesser Splinter of Madness | quests | 0 | 4000 | 1268 | outfit 1268 não existe no cliente 8.6; trocar corpse; script Lua |
| Lion Commander | quests | 0 | 8500 | 1317 | outfit 1317 não existe no cliente 8.6; trocar corpse; magia Canary: singlecloudchain; magia Canary: singledeathchain; summon ausente: lion archer,lion knight,lion warlock; events Lua; script Lua |
| Liquor Spirit | quests | 0 | 7000 | 986 | outfit 986 não existe no cliente 8.6; trocar corpse; events Lua |
| Lloyd | quests | 50000 | 64000 | 940 | outfit 940 não existe no cliente 8.6; trocar corpse; magia Canary: lloyd wave; magia Canary: lloyd wave2; magia Canary: lloyd wave3; events Lua; bosstiary |
| Lokathmor | quests | 100000 | 300000 | 1062 | outfit 1062 não existe no cliente 8.6; summon ausente: demon blood; events Lua; bosstiary |
| Lord Azaram | quests | 55000 | 300000 | 1223 | outfit 1223 não existe no cliente 8.6; trocar corpse; magia Canary: lord azaram wave; summon ausente: Condensed Sins; events Lua; bosstiary |
| Magical Sphere | quests | 0 | 20000 | 979 | outfit 979 não existe no cliente 8.6; trocar corpse; events Lua |
| Magma Bubble | quests | 80000 | 450000 | 1413 | outfit 1413 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Magnor Mournbringer | quests | 0 | 250000 | 1221 | outfit 1221 não existe no cliente 8.6; trocar corpse; events Lua; script Lua |
| Makeshift Home | quests | 1800 | 6900 | ex 27366 | outfit item 27366 fora do cliente; trocar corpse; events Lua |
| Malkhar Deathbringer | quests | 50000 | 30000 | 134 | trocar corpse; events Lua |
| Malofur Mangrinder | quests | 55000 | 320000 | 1120 | outfit 1120 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Many Faces | quests | 18870 | 30000 | 1296 | outfit 1296 não existe no cliente 8.6; trocar corpse; magia Canary: destroy magic walls; magia Canary: extended holy chain; events Lua; script Lua |
| Maxxenius | quests | 55000 | 320000 | 1142 | outfit 1142 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Mazoran | quests | 500000 | 290000 | 842 | outfit 842 não existe no cliente 8.6; trocar corpse; magia Canary: mazoran fire; events Lua; bosstiary |
| Mazzinor | quests | 100000 | 300000 | 1062 | outfit 1062 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Melting Frozen Horror | quests | 65000 | 70000 | 261 | magia Canary: hirintror freeze; magia Canary: hirintror skill reducer; magia Canary: ice golem paralyze; events Lua; bosstiary |
| Mezlon the Defiler | quests | 50000 | 30000 | 144 | trocar corpse; magia Canary: heal monster 9x9; events Lua |
| Mighty Splinter of Madness | quests | 0 | 4000 | 1268 | outfit 1268 não existe no cliente 8.6; trocar corpse; script Lua |
| Mind-Wrecking Dream | quests | 0 | 3900 | 300 | events Lua |
| Minion of Gaz'haragoth | quests | 0 | 5500 | 590 | outfit 590 não existe no cliente 8.6; trocar corpse; events Lua |
| Mirror Image | quests | 27000 | 35000 | 136 | trocar corpse; magia Canary: ice chain; events Lua; script Lua |
| Misguided Bully | quests | 1200 | 2000 | 159 | trocar corpse; magia Canary: heal monster; events Lua |
| Misguided Shadow | quests | 1500 | 3000 | 985 | outfit 985 não existe no cliente 8.6; trocar corpse; events Lua |
| Misguided Thief | quests | 1200 | 1800 | 684 | outfit 684 não existe no cliente 8.6; trocar corpse; events Lua |
| Monk's Apparition | quests | 28600 | 25000 | 1824 | outfit 1824 não existe no cliente 8.6; magia Canary: ice chain; events Lua |
| Mould Phantom | quests | 18330 | 28000 | 1298 | outfit 1298 não existe no cliente 8.6; trocar corpse; magia Canary: extended holy chain; magia Canary: poison chain; events Lua |
| Mounted Thorn Knight | quests | 15000 | 100000 | 512 | outfit 512 não existe no cliente 8.6; trocar corpse; magia Canary: thorn summon; events Lua |
| Mozradek | quests | 21000 | 28000 | 240 | trocar corpse; events Lua; bosstiary |
| Mutated Zalamon | quests | 10980 | 155000 | 357 | trocar corpse; events Lua; bosstiary |
| Nargol The Impaler | quests | 0 | 250000 | 1222 | outfit 1222 não existe no cliente 8.6; trocar corpse; events Lua; script Lua; bosstiary |
| Necromantic Focus | quests | 0 | 12000 | ex 7059 | trocar corpse; events Lua |
| Nightmarish Dream | quests | 0 | 1000 | 78 | trocar corpse; events Lua |
| Obujos | quests | 20000 | 35000 | 445 | outfit 445 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Organic Matter | quests | 0 | 10000 | 617 | outfit 617 não existe no cliente 8.6; trocar corpse; events Lua |
| Outburst | quests | 50000 | 290000 | 876 | outfit 876 não existe no cliente 8.6; trocar corpse; magia Canary: anomaly break; magia Canary: big energy purple wave; magia Canary: big skill reducer; events Lua; bosstiary |
| Overcharge | quests | 0 | 8000 | 290 | trocar corpse; events Lua |
| Overcharged Disruption | quests | 400 | 128000 | ex 1959 | trocar corpse; events Lua; bosstiary |
| Paladin's Apparition | quests | 28600 | 25000 | 129 | trocar corpse; magia Canary: ice chain; events Lua |
| Pillar of Death | quests | 0 | 20000 | ex 11427 | trocar corpse; events Lua |
| Pillar of Draining | quests | 0 | 20000 | ex 11427 | trocar corpse; events Lua |
| Pillar of Healing | quests | 0 | 7300 | ex 11427 | trocar corpse; events Lua |
| Pillar of Protection | quests | 0 | 20000 | ex 11427 | trocar corpse; events Lua |
| Pillar of Summoning | quests | 0 | 20000 | ex 11427 | trocar corpse; events Lua |
| Plagirath | quests | 500000 | 290000 | 862 | outfit 862 não existe no cliente 8.6; trocar corpse; magia Canary: plagirath bog; magia Canary: plagirath heal; magia Canary: plagirath summon; events Lua; bosstiary |
| Plagueroot | quests | 55000 | 320000 | 1121 | outfit 1121 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Plant Abomination | quests | 0 | 3900 | 310 | trocar corpse; events Lua |
| Possessed Tree | quests | 1300 | 2500 | 310 | trocar corpse; magia Canary: haunted treeling paralyze; events Lua |
| Powerful Soul | quests | 0 | 30000 | 568 | outfit 568 não existe no cliente 8.6; trocar corpse; events Lua; script Lua |
| Preceptor Lazare | quests | 10000 | 16000 | 1078 | outfit 1078 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Professor Maxxen | quests | 15500 | 90000 | 679 | outfit 679 não existe no cliente 8.6; trocar corpse; magia Canary: generator; magia Canary: glooth fairy healing; magia Canary: glooth fairy paralyze; magia Canary: glooth fairy skill reducer; magia Canary: maxxenteleport; magia Canary: war golem electrify; magia Canary: war golem skill reducer; summon ausente: walker,glooth trasher,glooth smasher,glooth slasher; events Lua; bosstiary |
| Ragiaz | quests | 500000 | 280000 | 862 | outfit 862 não existe no cliente 8.6; trocar corpse; magia Canary: ragiaz transform; events Lua; bosstiary |
| Ratmiral Blackwhiskers | quests | 50000 | 220000 | 1377 | outfit 1377 não existe no cliente 8.6; trocar corpse; summon ausente: elite pirat; events Lua; bosstiary |
| Ravenous Hunger | quests | 0 | 100000 | 556 | outfit 556 não existe no cliente 8.6; events Lua; bosstiary |
| Razzagorn | quests | 500000 | 290000 | 842 | outfit 842 não existe no cliente 8.6; trocar corpse; magia Canary: razzagorn summon; summon ausente: Eruption of Destruction; events Lua; bosstiary |
| Realityquake | quests | 20000 | 110000 | ex 1949 | trocar corpse; magia Canary: anomaly break; events Lua; bosstiary |
| Rewar The Bloody | quests | 0 | 250000 | 1221 | outfit 1221 não existe no cliente 8.6; trocar corpse; events Lua; script Lua |
| Rewar The Bloody Inv | quests | 0 | 250000 | 633 | outfit 633 não existe no cliente 8.6; trocar corpse; events Lua; script Lua |
| Rift Invader | quests | 100 | 6250 | 290 | trocar corpse; events Lua |
| Rotten Golem | quests | 17860 | 28000 | 1312 | outfit 1312 não existe no cliente 8.6; trocar corpse; magia Canary: poison chain; magia Canary: root; events Lua |
| Rupture | quests | 112000 | 290000 | 875 | outfit 875 não existe no cliente 8.6; trocar corpse; magia Canary: anomaly break; magia Canary: rupture wave; events Lua; bosstiary |
| Scarlett Etzel | quests | 20000 | 30000 | 1201 | outfit 1201 não existe no cliente 8.6; trocar corpse; magia Canary: sudden death rune; events Lua; bosstiary |
| Scorn of the Emperor | quests | 450 | 45000 | 351 | events Lua; bosstiary |
| Shard of Corruption | quests | 5 | 600 | 67 | events Lua; bosstiary |
| Shard of Magnor | quests | 0 | 20000 | 1221 | outfit 1221 não existe no cliente 8.6; trocar corpse; events Lua |
| Sharptooth | quests | 3000 | 3100 | 20 | events Lua; bosstiary |
| Shulgrax | quests | 500000 | 40000 | 842 | outfit 842 não existe no cliente 8.6; trocar corpse; magia Canary: shulgrax summon; events Lua; bosstiary |
| Sir Baeloc | quests | 55000 | 75000 | 1222 | outfit 1222 não existe no cliente 8.6; trocar corpse; summon ausente: Retainer of Baeloc; events Lua; bosstiary |
| Sir Nictros | quests | 55000 | 75000 | 1222 | outfit 1222 não existe no cliente 8.6; trocar corpse; summon ausente: Squire of Nictros; events Lua; bosstiary |
| Snail Slime | quests | 0 | 4500 | 19 | trocar corpse; events Lua |
| Snake Thing | quests | 8400 | 70000 | 220 | trocar corpse; events Lua; bosstiary |
| Somewhat Beatable | quests | 0 | 3000 | 34 | trocar corpse; events Lua |
| Sorcerer's Apparition | quests | 28600 | 25000 | 138 | magia Canary: ice chain; events Lua |
| Soul Cage | quests | 100000 | 100000 | 863 | outfit 863 não existe no cliente 8.6; trocar corpse; magia Canary: Heal Malice; events Lua |
| Soul of Dragonking Zyrtarch | quests | 70000 | 150000 | 938 | outfit 938 não existe no cliente 8.6; trocar corpse; magia Canary: charged energy elemental electrify; events Lua; bosstiary |
| Soul Sphere | quests | 0 | 10000 | 979 | outfit 979 não existe no cliente 8.6; trocar corpse; script Lua |
| Soulcatcher | quests | 320 | 50000 | ex 11053 | trocar corpse; magia Canary: soulcatcher summon; events Lua |
| Soulsnatcher | quests | 0 | 10000 | 1268 | outfit 1268 não existe no cliente 8.6; trocar corpse; magia Canary: soulsnatcher-lifedrain-beam; magia Canary: soulsnatcher-lifedrain-missile; magia Canary: soulsnatcher-manadrain-ball; events Lua; script Lua |
| Spark of Burning Hatred | quests | 0 | 15000 | ex 34010 | outfit item 34010 fora do cliente; events Lua |
| Spirit Overlord | quests | 2800 | 4000 | 1840 | outfit 1840 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Spite of the Emperor | quests | 500 | 48000 | 351 | events Lua; bosstiary |
| Spiteful Spitter | quests | 24960 | 28000 | 1295 | outfit 1295 não existe no cliente 8.6; trocar corpse; script Lua |
| Stolen Knowledge of Armor | quests | 0 | 10000 | 1061 | outfit 1061 não existe no cliente 8.6; trocar corpse; events Lua |
| Stolen Knowledge of Healing | quests | 0 | 10000 | 1061 | outfit 1061 não existe no cliente 8.6; trocar corpse; events Lua |
| Stolen Knowledge of Lifesteal | quests | 0 | 10000 | 1061 | outfit 1061 não existe no cliente 8.6; trocar corpse; events Lua |
| Stolen Knowledge of Spells | quests | 0 | 10000 | 1061 | outfit 1061 não existe no cliente 8.6; trocar corpse; events Lua |
| Stolen Knowledge of Summoning | quests | 0 | 10000 | 1061 | outfit 1061 não existe no cliente 8.6; trocar corpse; events Lua |
| Stolen Tome of Portals | quests | 0 | 10000 | ex 23985 | outfit item 23985 fora do cliente; trocar corpse; events Lua |
| Strong Glooth Horror | quests | 1500 | 20000 | 677 | outfit 677 não existe no cliente 8.6; trocar corpse; events Lua |
| Strong Soul | quests | 0 | 20000 | 566 | outfit 566 não existe no cliente 8.6; trocar corpse; events Lua; script Lua |
| Symbol of Hatred | quests | 0 | 14000 | ex 11427 | trocar corpse; script Lua |
| Tanjis | quests | 15000 | 30000 | 446 | outfit 446 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Tarbaz | quests | 500000 | 290000 | 842 | outfit 842 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| Tentacle of the Deep Terror | quests | 0 | 25500 | 681 | outfit 681 não existe no cliente 8.6; trocar corpse; magia Canary: blightwalker curse; events Lua |
| Tentugly's Head | quests | 40000 | 75000 | ex 35105 | outfit item 35105 fora do cliente; trocar corpse; magia Canary: energy waveT; events Lua; bosstiary |
| The Baron from Below | quests | 50000 | 350000 | 1045 | outfit 1045 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| The Blazing Rose | quests | 10000 | 10000 | 1068 | outfit 1068 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| The Blazing Time Guardian | quests | 50000 | 150000 | 944 | outfit 944 não existe no cliente 8.6; trocar corpse; magia Canary: time guardian lost time; summon ausente: time waster; events Lua; bosstiary |
| The Corruptor of Souls | quests | 112000 | 290000 | 875 | outfit 875 não existe no cliente 8.6; trocar corpse; magia Canary: remorseless wave; events Lua; bosstiary |
| The Count of the Core | quests | 300000 | 350000 | 1046 | outfit 1046 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| The Destruction | quests | 0 | 250000 | 876 | outfit 876 não existe no cliente 8.6; trocar corpse; magia Canary: anomaly break; magia Canary: destruction summon; events Lua; bosstiary |
| The Diamond Blossom | quests | 10000 | 20000 | 1068 | outfit 1068 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| The Distorted Astral Source | quests | 3000 | 10000000 | ex 24229 | outfit item 24229 fora do cliente; trocar corpse; events Lua; bosstiary |
| The Dread Maiden | quests | 72000 | 300000 | 1278 | outfit 1278 não existe no cliente 8.6; trocar corpse; magia Canary: dread rcircle; events Lua; bosstiary |
| The Duke of the Depths | quests | 300000 | 350000 | 1047 | outfit 1047 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| The Enraged Thorn Knight | quests | 30000 | 90000 | 512 | outfit 512 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| The False God | quests | 50000 | 300000 | 984 | outfit 984 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| The Fear Feaster | quests | 30000 | 300000 | 1276 | outfit 1276 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| The Freezing Time Guardian | quests | 50000 | 150000 | 943 | outfit 943 não existe no cliente 8.6; trocar corpse; magia Canary: time guardian lost time; events Lua; bosstiary |
| The Hunger | quests | 0 | 250000 | 876 | outfit 876 não existe no cliente 8.6; trocar corpse; magia Canary: anomaly break; magia Canary: hunger summon; magia Canary: practise fire wave; events Lua; bosstiary |
| The Keeper | quests | 3205 | 40000 | 220 | events Lua; bosstiary |
| The Last Lore Keeper | quests | 45000 | 750000 | 939 | outfit 939 não existe no cliente 8.6; trocar corpse; magia Canary: medusa paralyze; summon ausente: sword of vengeance; events Lua; bosstiary |
| The Lily of Night | quests | 10000 | 19000 | 1068 | outfit 1068 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| The Lord of the Lice | quests | 0 | 80000 | 305 | magia Canary: mutated rat paralyze; events Lua; bosstiary |
| The Nightmare Beast | quests | 75000 | 850000 | 1144 | outfit 1144 não existe no cliente 8.6; trocar corpse; magia Canary: big death wave; magia Canary: death beam; events Lua; bosstiary |
| The Pale Worm | quests | 30000 | 420000 | 1272 | outfit 1272 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| The Primal Menace | quests | 0 | 400000 | 1566 | outfit 1566 não existe no cliente 8.6; trocar corpse; magia Canary: big death wave; events Lua; script Lua; bosstiary |
| The Rage | quests | 0 | 250000 | 876 | outfit 876 não existe no cliente 8.6; trocar corpse; magia Canary: anomaly break; magia Canary: big death wave; magia Canary: big explosion wave; magia Canary: rage summon; events Lua; bosstiary |
| The Ravager | quests | 14980 | 53500 | 91 | summon ausente: Elder Mummy,Canopic Jar,Greater Canopic Jar; events Lua; bosstiary |
| The Red Knight | quests | 0 | 250000 | 1223 | outfit 1223 não existe no cliente 8.6; trocar corpse; script Lua |
| The Sandking | quests | 0 | 50000 | 1013 | outfit 1013 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| The Scourge of Oblivion | quests | 75000 | 800000 | 875 | outfit 875 não existe no cliente 8.6; trocar corpse; magia Canary: choking fear drown; summon ausente: Charger,Spark of Destruction; events Lua; bosstiary |
| The Shatterer | quests | 58000 | 220000 | 842 | outfit 842 não existe no cliente 8.6; events Lua; bosstiary |
| The Shielded Thorn Knight | quests | 0 | 70000 | 512 | outfit 512 não existe no cliente 8.6; trocar corpse; events Lua |
| The Souldespoiler | quests | 50000 | 290000 | 875 | outfit 875 não existe no cliente 8.6; trocar corpse; summon ausente: Freed Soul; events Lua; bosstiary |
| The Source of Corruption | quests | 0 | 500000 | 979 | outfit 979 não existe no cliente 8.6; trocar corpse; magia Canary: source of corruption wave; events Lua; bosstiary |
| The Time Guardian | quests | 50000 | 150000 | 945 | outfit 945 não existe no cliente 8.6; trocar corpse; magia Canary: time guardian; magia Canary: time guardiann; events Lua; bosstiary |
| The Unarmored Voidborn | quests | 15000 | 250000 | 987 | outfit 987 não existe no cliente 8.6; trocar corpse; events Lua; bosstiary |
| The Unwelcome | quests | 30000 | 300000 | 1277 | outfit 1277 não existe no cliente 8.6; trocar corpse; summon ausente: wormling; events Lua; bosstiary |
| Timira the Many-Headed | quests | 45500 | 75000 | 1542 | outfit 1542 não existe no cliente 8.6; trocar corpse; magia Canary: death chain; magia Canary: mana drain chain; magia Canary: timira explosion; magia Canary: timira fire ring; script Lua; bosstiary |
| Tirecz | quests | 6000 | 25000 | 334 | trocar corpse; events Lua |
| Turbulent Elemental | quests | 19360 | 28000 | 1314 | outfit 1314 não existe no cliente 8.6; trocar corpse; magia Canary: soulwars fear; events Lua |
| Ugly Monster | quests | 1000 | 10000 | 1218 | outfit 1218 não existe no cliente 8.6; trocar corpse; events Lua |
| Unpleasant Dream | quests | 0 | 50 | 349 | trocar corpse; events Lua |
| Unstable Spark | quests | 1500 | 10500 | 290 | trocar corpse; events Lua |
| Urmahlullu the Immaculate | quests | 0 | 512000 | 1197 | outfit 1197 não existe no cliente 8.6; trocar corpse; magia Canary: urmahlulluring; events Lua; bosstiary |
| Urmahlullu the Tamed | quests | 0 | 300000 | 1197 | outfit 1197 não existe no cliente 8.6; trocar corpse; magia Canary: urmahlulluring; events Lua; bosstiary |
| Usurper Commander | quests | 7200 | 8500 | 1317 | outfit 1317 não existe no cliente 8.6; trocar corpse; magia Canary: singlecloudchain; magia Canary: singledeathchain; summon ausente: hardened usurper archer,hardened usurper warlock,hardened usurper knight; events Lua; script Lua |
| Versperoth | quests | 30000 | 100000 | 295 | trocar corpse; events Lua; bosstiary |
| Vibrant Phantom | quests | 19700 | 27000 | 1298 | outfit 1298 não existe no cliente 8.6; trocar corpse; magia Canary: extended energy chain; magia Canary: extended holy chain; events Lua |
| Weak Soul | quests | 0 | 10000 | 48 | trocar corpse; events Lua; script Lua |
| Weakened Glooth Horror | quests | 245 | 10000 | 677 | outfit 677 não existe no cliente 8.6; trocar corpse; events Lua |
| Wildness of Urmahlullu | quests | 0 | 400000 | 570 | outfit 570 não existe no cliente 8.6; trocar corpse; magia Canary: urmahlulluring; events Lua; bosstiary |
| Wine Cask | quests | 0 | 30000 | ex 2521 | trocar corpse; events Lua |
| Wisdom of Urmahlullu | quests | 0 | 200000 | 1200 | outfit 1200 não existe no cliente 8.6; trocar corpse; magia Canary: urmahlulluring; events Lua; bosstiary |
| World Devourer | quests | 77700 | 25000 | 875 | outfit 875 não existe no cliente 8.6; trocar corpse; magia Canary: anomaly break; magia Canary: devourer summon; events Lua; bosstiary |
| Wormling | quests | 0 | 5000 | 1275 | outfit 1275 não existe no cliente 8.6; trocar corpse; events Lua |
| Wrath of the Emperor | quests | 600 | 55000 | 351 | events Lua; bosstiary |
| Xogixath | quests | 22000 | 28000 | 842 | outfit 842 não existe no cliente 8.6; trocar corpse; magia Canary: sudden death rune; events Lua; bosstiary |
| Zamulosh | quests | 500000 | 300000 | 862 | outfit 862 não existe no cliente 8.6; trocar corpse; magia Canary: zamulosh invisible; magia Canary: zamulosh tp; summon ausente: Zamulosh2; events Lua; bosstiary |
| Zamulosh3 | quests | 55000 | 1000 | 862 | outfit 862 não existe no cliente 8.6; trocar corpse; events Lua |
| Egg | raids | 0 | 800 | ex 4839 | trocar corpse; events Lua |
| Giant Spider Wyda | raids | 12 | 20 | 38 | events Lua |
| Lizard Magistratus | reptiles | 2000 | 6250 | 115 | magia Canary: lizard magistratus curse; events Lua |
| Lizard Noble | reptiles | 2000 | 7000 | 115 | events Lua |
| Hazardous Phantom | undeads | 66000 | 70000 | 1298 | outfit 1298 não existe no cliente 8.6; trocar corpse; magia Canary: ice chain; magia Canary: soulwars fear; events Lua |
| Deepworm | vermins | 2520 | 3500 | 1033 | outfit 1033 não existe no cliente 8.6; trocar corpse; events Lua |
| Diremaw | vermins | 2770 | 3600 | 1034 | outfit 1034 não existe no cliente 8.6; trocar corpse; events Lua |
| Drillworm | vermins | 1200 | 1500 | 527 | outfit 527 não existe no cliente 8.6; trocar corpse; events Lua |
| Parasite | vermins | 0 | 550 | 82 | events Lua |
| Wiggler | vermins | 900 | 1200 | 510 | outfit 510 não existe no cliente 8.6; trocar corpse; events Lua |

## Port do grupo A (feito)
Os 285 monstros do grupo A foram convertidos de Lua para XML em `data/monster/Ported Monsters/<categoria>/<nome>.xml` e registrados no fim de `data/monster/monsters.xml`. Categoria = classe do bestiary do Canary; sem classe, usa a do monstro de mesmo outfit; bosses ficam em `Bosses`.

Conversão aplicada:
- `monsterId` novo, de 459 a 743 (bestiary).
- Velocidade `x2` (escala antiga do servidor); `melee` convertido para `skill 70` + `attack` que reproduz o dano máximo do Canary.
- Ataques/defesas: tipos de dano, `speed`, `invisible`, `drunk`, `outfit`, campos e conditions; efeitos e tiros traduzidos pelo ID para os nomes do servidor. Ficaram de fora ataques `outfit` cujo monstro-alvo não existe aqui (13), `condition` de sangramento (3) e `strength` (2).
- Corpse: mantido quando existe no cliente 8.6, senão trocado pelo item de mesmo nome ou, em 91 casos, pelo corpse mais comum da mesma `race`. Conferir visualmente.
- Loot: itens resolvidos pelo nome (IDs 8.6). 105 itens sem equivalente no servidor foram descartados; resolve-se o loot de cada monstro caso a caso.
- Levels calculados pela fórmula (`301-monsterlevel.lua`) e gravados em `302-monsterlevels.lua`; 28 monstros sem dano (marcados `CHECK`) usam a experiência.
- Requer reiniciar o servidor. Não foi carregado em jogo, apenas validado como XML.
