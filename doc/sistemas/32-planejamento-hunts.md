# Planejamento de hunts por nível dos monstros

Proposta (ainda não implementada) de hunts até o nível 400, divididas em Fácil, Médio e Difícil, baseadas nos levels de `data/lib/302-monsterlevels.lua` (ver `31-nivel-dos-monstros.md`).

## Nível efetivo da hunt
O jogador luta contra vários monstros ao mesmo tempo, então o nível da hunt é maior que o do monstro. Na fórmula (`level = (√(vida × ofensa))^0.655 × 0.61`), com **n** monstros iguais a vida e a ofensa somam:

```
nível da hunt = nível do monstro × n^0.655
```

O número de monstros juntos **cresce com a dificuldade**, porque as hunts altas são de pull em massa:

| Tier | Hunts | Monstros juntos (n) | Fator |
|---|---|---|---|
| Fácil | F1–F3 | 2,5 | ×1,82 |
| Médio | M1 | 3 | ×2,05 |
| Médio | M2 | 3,5 | ×2,27 |
| Médio | M3 | 4 | ×2,48 |
| Difícil | D1–D3 | 5 | ×2,87 |

### Calibração: Asura Palace
O Asura Palace (Hellspawn e Asuras juntos, em grande quantidade) é caçado no Tibia por volta do **nível 200–300** (TibiaVault 150–250, MMOKB 200, TibiaRoute 250+, TibiaStats e TibiaPal 300+). Os monstros dele têm nível médio ~85 aqui (Hellspawn 79, Dawnfire Asura 81, Midnight Asura 88, Frost Flower Asura 92). Para a hunt dar ~250 o jogador precisa de uns 5 monstros juntos (×2,87), que é o fator das hunts Difíceis. O fator antigo (×1,82) dava só ~155 para o mesmo spawn.

Para chegar ao nível alvo, o monstro deve ter cerca de 35% do nível da hunt nas hunts Difíceis e cerca de 55% nas Fáceis.

## Hunts

| Dificuldade | Hunt | Monstros (nível) | Juntos | Fator | **Nível da hunt** | Exemplos |
|---|---|---|---|---|---|---|
| Fácil | F1 | 1–10 | 2,5 | ×1,82 | 2–18 | rat, bug, wolf, troll, goblin, orc, rotworm, **Enraged Squirrel**, **Dawn Bat**, **Young Troll**, **Troll Marauder**, **Brittle Skeleton**, **Crazed Dwarf**, **Scar Tribe Warrior**, **Troll Guard**, **Dawn Scorpion**, **Muglex Clan Assassin**, **Muglex Clan Scavenger**, **Juvenile Cyclops**, **Minotaur Occultist**, **Orc Sambackpack**, **Scar Tribe Shaman**, **Starving Wolf**, **Undead Mine Worker** |
| Fácil | F2 | 10–20 | 2,5 | ×1,82 | 18–36 | minotaur, elf, amazon, valkyrie, ghoul, cyclops, **Dwarf Miner**, **Firestarter**, **Honour Guard**, **Lesser Fire Devil**, **Minotaur Poacher**, **Renegade Quara Mantassin**, **Undead Prospector**, **Renegade Quara Hydromancer**, **Renegade Quara Pincher**, **Filth Toad**, **Renegade Quara Predator**, **Crypt Defiler**, **Dwarf Henchman**, **Troll Legionnaire** |
| Fácil | F3 | 20–30 | 2,5 | ×1,82 | 36–55 | dwarf guard, orc marauder, monk, mummy, zombie, gargoyle, **Bonelord**, **Grave Robber**, **Infernal Frog**, **Monk of the Order**, **Terrified Elephant**, **Deepsea Blood Crab**, **Evil Sheep**, **Vampire Pig**, **Burrowing Beetle**, **Doom Deer**, **Elf Overseer**, **Dryad**, **Herald of Gloom**, **Acolyte of Darkness**, **Tomb Servant** |
| Médio | M1 | 30–45 | 3 | ×2,05 | 61–92 | vampire, bonebeast, efreet, dragon, wyvern, **Demon Parrot**, **Elder Bonelord**, **Essence of Darkness**, **Grave Guard**, **Sacred Spider**, **Clay Guardian**, **Elder Mummy**, **Death Priest**, **Berserker Chicken**, **Midnight Spawn**, **Memory of an Amazon**, **Shadow Hound**, **Vicious Squire**, **Renegade Knight**, **Swan Maiden** |
| Médio | M2 | 45–60 | 3,5 | ×2,27 | 102–136 | lizard legionnaire, orc warlord, worker golem, lich, banshee, **Glooth Brigand**, **Memory of an Elf**, **Bane Bringer**, **Glooth Bandit**, **Memory of a Lizard**, **High Voltage Elemental**, **Memory of a Mammoth**, **Vile Grandmaster**, **Bane of Light**, **Memory of a Dwarf**, **Memory of a Yalahari** |
| Médio | M3 | 60–80 | 4 | ×2,48 | 149–198 | dragon lord, frost dragon, hydra, wyrm, werewolf, infernalist, **Minotaur Invader**, **Memory of a Banshee**, **Memory of a Pirate**, **Memory of a Vampire**, **Memory of a Hero**, **Memory of a Scarab**, **Memory of a Hydra** |
| Difícil | D1 | 80–100 | 5 | ×2,87 | 230–287 (Asura Palace ≈ 244) | warlock, sea serpent, behemoth, defiler, war golem, stonecracker, **Dawnfire Asura**, **Midnight Asura**, **Frost Flower Asura**, **Duskbringer** |
| Difícil | D2 | 100–140 | 5 | ×2,87 | 287–400 | medusa, ghastly dragon, blightwalker, dark torturer, demon, **Undead Elite Gladiator**, **Crypt Warrior**, **Skeleton Elite Warrior** |
| Difícil | D3 | 145–220 | 5 | ×2,87 | 416–631 (acima do teto de 400) | demon, hellhound, undead dragon, deathbringer, juggernaut |

O intervalo real de cada hunt vai do fator com 1 monstro a menos até o fator com 1 a mais.

## Cuidados
- **D3 fica acima do teto de 400.** Com o fator ×2,87, o demon (143) já dá ~410 e o hellhound (169) ~485; D3 só entra se o nível máximo do plano subir. **D3 é a faixa mais fina.** Só `hellhound` (169), `undead dragon` (171) e `demon` (143) são monstros comuns. O resto são bosses (`juggernaut` 208, `deathbringer` 176, `bones` 162, `the imperor` 191). Para mais variedade, criar monstros nível ~150–200.
- **Misturar monstros de níveis próximos.** O nível da hunt é a média da mistura; um monstro de 140 com outros de 40 deixa a hunt bem mais fácil que o nível sugere.
- **O fator assume que todos atacam juntos.** Com muitos atiradores/magos o fator real é maior; em melee puro, menor.
- **Os fatores são calibrados no Asura Palace** (uma única âncora, com fontes que divergem entre 150 e 300); conferir com outras hunts conhecidas antes de fechar os números.
- **Fora das hunts:** summons, `target`/`trainer`/`training`, `tha exp carrier`, `trainedr`, `random noob`, `exp bug`, os `necro *` e as linhas `CHECK` sem dano real.
- **Densidade desigual:** os níveis 1–100 têm ~400 monstros e 100+ têm ~70, por isso as faixas altas são mais largas.

## Monstros portados do Canary
Os 285 monstros de `data/monster/Ported Monsters/` (ver `33-monstros-canary.md`) já estão na tabela de hunts acima, em **negrito**, com level fixo em `302-monsterlevels.lua` (746 monstros). Entraram só os monstros comuns (hostis, com xp e fora de quest/boss).

Observações:
- **D1 e D2 continuam finas** (3–4 monstros novos cada) e **D3 não ganhou nenhum monstro comum**: o port só trouxe bosses (Kerberos 171, Zushuka 161, Chizzoron the Distorter 157, Chikhaton 201) e criaturas de quest (Dreadful Harvester 187, Oberon's Bile/Hate/Ire/Spite 150). Para D3 ainda é preciso criar monstros nível ~150–200.
- Os `Memory of ...` (Dawnport/Memories), `Orc Armor/Helmet/Shield`, `Mechanical Fighter`, `Electric Sparks`, `Minotaur Totem` e os `Cosmic Energy Prism` são ligados a evento, quest ou summon; conferir antes de usar numa hunt.
- **Fora das hunts (quest/boss):** Freegoiz 371, Verminor 371, Zavarash 303, Chayenne 303, Neferi the Spy 252, Zulazza the Corruptor 250, Horadron 244, Terofar 240, Prince Drazzak 492 e os demais bosses ficam como alvo de boss/raid. **Zarcorix Of Yalahar** tem vida 99999999 no Canary (level 2232 na tabela); ajustar antes de qualquer uso.
- Os `Lovely *`, `Animated *`, `Unbound *` e demais monstros de quest (pasta `quests` do Canary, sem categoria própria) dependem do mapa da quest e não entram nas hunts.

## Próximo passo
Gerar um script que cruze os levels com o `spawn.xml` do mapa, para ver quais hunts já existem e quais faltam.
