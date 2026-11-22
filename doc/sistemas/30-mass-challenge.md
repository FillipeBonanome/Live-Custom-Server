# Mass Challenge e Great Mass Challenge

Duas magias de taunt em área para o **Elite Knight** (vocação 8, como o Challenge `exeta res`). Além de forçar os monstros a atacar o conjurador (`doChallengeCreature`), elas deixam os monstros com **range 1** por um tempo, usando `doMonsterChangeRange(monstro, 1, duração)`: monstros à distância precisam vir para o corpo a corpo e o alcance dos ataques deles fica limitado a 1 SQM. Summons de jogadores não são afetados.

| Magia | Palavras | Id | Lvl | Mana | Cd | Área | Range 1 por |
|---|---|---|---|---|---|---|---|
| Challenge (já existia) | `exeta res` | 75 | 20 | 30 | 1 s | 3x3 | |
| Mass Challenge | `exeta mas res` | 208 | 40 | 150 | 20 s | `AREA_CIRCLE3X3` (raio 3) | 12 s |
| Great Mass Challenge | `exeta gran mas res` | 209 | 65 | 400 | 40 s | disco de raio 5 | 20 s |

Premium, sem `needlearn`. Scripts em `data/spells/scripts/support/mass challenge.lua` e `great mass challenge.lua`; o alcance, a duração e a mana ficam no topo de cada script e em `data/spells/spells.xml`. A função `doMonsterChangeRange` vem do commit "monster range" (`src/luascript.cpp`, `Monster::setRangeOverride`); nada aqui precisa de recompilação.
