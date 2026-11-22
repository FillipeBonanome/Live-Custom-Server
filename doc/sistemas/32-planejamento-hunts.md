# Planejamento de hunts por nível dos monstros

Proposta (ainda não implementada) de hunts até o nível 400, divididas em Fácil, Médio e Difícil, baseadas nos levels de `data/lib/302-monsterlevels.lua` (ver `31-nivel-dos-monstros.md`).

## Nível efetivo da hunt
O jogador luta contra 2–3 monstros ao mesmo tempo, então o nível da hunt é maior que o do monstro. Na fórmula (`level = (√(vida × ofensa))^0.655 × 0.61`), com **n** monstros iguais a vida e a ofensa somam:

```
nível da hunt = nível do monstro × n^0.655
```

| Monstros juntos | Fator |
|---|---|
| 2 | ×1,57 |
| 2,5 (média) | ×1,82 |
| 3 | ×2,05 |

Para chegar ao nível alvo, o monstro deve ter cerca de **55% do nível da hunt**. Uma hunt de nível 400 usa monstros de nível ~195–255.

## Hunts

| Dificuldade | Hunt | Monstros (nível) | **Nível da hunt** | Exemplos |
|---|---|---|---|---|
| Fácil | F1 | 1–10 | 2–18 | rat, bug, wolf, troll, goblin, orc, rotworm |
| Fácil | F2 | 10–20 | 18–36 | minotaur, elf, amazon, valkyrie, ghoul, cyclops |
| Fácil | F3 | 20–30 | 36–55 | dwarf guard, orc marauder, monk, mummy, zombie, gargoyle |
| Médio | M1 | 30–45 | 55–82 | vampire, bonebeast, efreet, dragon, wyvern |
| Médio | M2 | 45–60 | 82–109 | lizard legionnaire, orc warlord, worker golem, lich, banshee |
| Médio | M3 | 60–80 | 109–146 | dragon lord, frost dragon, hydra, wyrm, werewolf, infernalist |
| Difícil | D1 | 80–100 | 146–182 | warlock, sea serpent, behemoth, defiler, war golem, stonecracker |
| Difícil | D2 | 100–145 | 182–264 | medusa, ghastly dragon, blightwalker, dark torturer, demon |
| Difícil | D3 | 145–220 | 264–400 | demon, hellhound, undead dragon, deathbringer, juggernaut |

Os valores usam a média ×1,82; o intervalo real vai de ×1,57 a ×2,05.

## Cuidados
- **D3 é a faixa mais fina.** Só `hellhound` (169), `undead dragon` (171) e `demon` (143) são monstros comuns. O resto são bosses (`juggernaut` 208, `deathbringer` 176, `bones` 162, `the imperor` 191). Para mais variedade, criar monstros nível ~150–200.
- **Misturar monstros de níveis próximos.** O nível da hunt é a média da mistura; um monstro de 140 com outros de 40 deixa a hunt bem mais fácil que o nível sugere.
- **O fator assume que todos atacam juntos.** Com muitos atiradores/magos o fator real é perto de ×2,05; em melee puro, perto de ×1,57.
- **Fora das hunts:** summons, `target`/`trainer`/`training`, `tha exp carrier`, `trainedr`, `random noob`, `exp bug`, os `necro *` e as linhas `CHECK` sem dano real.
- **Densidade desigual:** os níveis 1–100 têm ~400 monstros e 100+ têm ~70, por isso as faixas altas são mais largas.

## Monstros portados do Canary (Ported Monsters)
Em `data/monster/Ported Monsters/` entraram 285 monstros do Canary/WoL (ver `33-monstros-canary.md`), com level fixo em `302-monsterlevels.lua` (agora 746 monstros). Os que servem como **monstros comuns** de hunt (hostis, com xp e fora de quest/boss), por faixa:

| Hunt | Novos monstros (nível) |
|---|---|
| F1 (1–10) | Enraged Squirrel 3, Dawn Bat 4, Young Troll 4, Troll Marauder 4, Brittle Skeleton 5, Crazed Dwarf 5, Scar Tribe Warrior 5, Troll Guard 5, Dawn Scorpion 6, Muglex Clan Assassin 7, Muglex Clan Scavenger 7, Juvenile Cyclops 9, Minotaur Occultist 9, Orc Sambackpack 9, Scar Tribe Shaman 9, Starving Wolf 9, Undead Mine Worker 9 |
| F2 (10–20) | Dwarf Miner 11, Firestarter 11, Honour Guard 11, Lesser Fire Devil 11, Minotaur Poacher 11, Renegade Quara Mantassin 12, Undead Prospector 12, Renegade Quara Hydromancer 14, Renegade Quara Pincher 15, Filth Toad 16, Renegade Quara Predator 16, Crypt Defiler 18, Dwarf Henchman 18, Troll Legionnaire 18 |
| F3 (20–30) | Bonelord 20, Grave Robber 20, Infernal Frog 20, Monk of the Order 22, Terrified Elephant 22, Deepsea Blood Crab 23, Evil Sheep 23, Vampire Pig 24, Burrowing Beetle 25, Doom Deer 25, Elf Overseer 25, Dryad 26, Herald of Gloom 27, Acolyte of Darkness 29, Tomb Servant 29 |
| M1 (30–45) | Demon Parrot 30, Elder Bonelord 30, Essence of Darkness 32, Grave Guard 33, Sacred Spider 33, Clay Guardian 35, Elder Mummy 36, Death Priest 37, Berserker Chicken 39, Midnight Spawn 40, Memory of an Amazon 41, Shadow Hound 43, Vicious Squire 43, Renegade Knight 44, Swan Maiden 44 |
| M2 (45–60) | Glooth Brigand 48, Memory of an Elf 49, Bane Bringer 50, Glooth Bandit 50, Memory of a Lizard 51, High Voltage Elemental 52, Memory of a Mammoth 52, Vile Grandmaster 53, Bane of Light 55, Memory of a Dwarf 56, Memory of a Yalahari 57 |
| M3 (60–80) | Minotaur Invader 60, Memory of a Banshee 62, Memory of a Pirate 62, Memory of a Vampire 62, Memory of a Hero 64, Memory of a Scarab 68, Memory of a Hydra 69 |
| D1 (80–100) | Dawnfire Asura 81, Midnight Asura 88, Frost Flower Asura 92, Duskbringer 99 |
| D2 (100–145) | Undead Elite Gladiator 143, Crypt Warrior 144, Skeleton Elite Warrior 144 |
| D3 (145–220) | nenhum monstro comum novo |

Observações:
- **D1 e D2 continuam finas** (3–4 monstros novos cada) e **D3 não ganhou nenhum monstro comum**: o port só trouxe bosses (Kerberos 171, Zushuka 161, Chizzoron the Distorter 157, Chikhaton 201) e criaturas de quest (Dreadful Harvester 187, Oberon's Bile/Hate/Ire/Spite 150). Para D3 ainda é preciso criar monstros nível ~150–200.
- Os `Memory of ...` (Dawnport/Memories), `Orc Armor/Helmet/Shield`, `Mechanical Fighter`, `Electric Sparks`, `Minotaur Totem` e os `Cosmic Energy Prism` são ligados a evento, quest ou summon; conferir antes de usar numa hunt.
- **Fora das hunts (quest/boss):** Freegoiz 371, Verminor 371, Zavarash 303, Chayenne 303, Neferi the Spy 252, Zulazza the Corruptor 250, Horadron 244, Terofar 240, Prince Drazzak 492 e os demais bosses ficam como alvo de boss/raid. **Zarcorix Of Yalahar** tem vida 99999999 no Canary (level 2232 na tabela); ajustar antes de qualquer uso.
- Os `Lovely *`, `Animated *`, `Unbound *` e demais monstros de quest (pasta `quests` do Canary, sem categoria própria) dependem do mapa da quest e não entram nas hunts.

## Próximo passo
Gerar um script que cruze os levels com o `spawn.xml` do mapa, para ver quais hunts já existem e quais faltam.
