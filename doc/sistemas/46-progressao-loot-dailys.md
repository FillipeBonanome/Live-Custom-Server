# Progressão de força dos itens pelo loot dos monstros dos dailys

Mapa de **que item cada monstro que pode cair num contrato (`!daily`) dropa**, quão forte ele é, e em que ponto do level do jogador ele aparece. Serve para balancear: onde a progressão sobe, onde trava e onde falta item.

Os números foram extraídos dos arquivos reais (`data/monster/*.xml`, `data/items/items.xml`, `data/weapons/weapons.xml`, `data/XML/uniques.xml`, `data/XML/itemsets.xml`) cruzados com `DailyQuest.allowedMonsters` (`data/lib/300-dailyquests.lua`) e os levels de `data/lib/302-monsterlevels.lua`. Se o XML mudar, os números abaixo envelhecem.

## 1. Quais monstros entram nos dailys
Só os 67 monstros de `DailyQuest.allowedMonsters` (os que têm respawn na sala de teleportes, andares 9 e 10). O contrato nº *t* (0 a 4) procura monstros com level perto de `level do jogador × (0,5 + 0,1·t)` (±15%), sempre maior que o do contrato anterior (ver `16-daily-quests.md`).

| Level do jogador | Contrato 1 (t=0) | Contrato 5 (t=4) |
|---|---|---|
| 20 | 8–11 | 15–21 |
| 50 | 21–29 | 38–52 |
| 100 | 43–58 | 77–104 |
| 150 | 64–86 | 115–155 |
| 200 | 85–115 | 153–207 |

O pool é irregular: há lacunas de level (nada entre 21 e 28, entre 56 e 61, entre 89 e 104, e só 10 monstros acima de 130), então nessas faixas o sistema cai no monstro mais próximo. Acima de 130 o pool é: ghastly dragon 130, dark torturer 134, blightwalker 137, demon 143, undead elite gladiator 143, crypt warrior 144, skeleton elite warrior 144, hellhound 169, undead dragon 171 e juggernaut 208.

Cada contrato pede 50–100 kills (média 75). Os contratos renovam às 5h, no máximo 5 por categoria por dia.

## 2. Como o item chega na mão do jogador
1. **Loot do XML.** `chance` é sobre 100000 (`933` = 0,933%). `config.lua` tem `rateLoot = 2.0`, então as chances dos itens comuns valem **o dobro** na prática (as tabelas abaixo mostram a chance do XML, sem o rate).
2. **Unique.** Se o item dropado tem o mesmo `id` de um unique daquele monstro, ele vira o unique com a `chance` do `uniques.xml` (esse % é sobre o item que já dropou, não sobre o kill). Ver `11-uniques.md`.
3. **Raridade.** Armas e armaduras elegíveis rolam raridade: Uncommon 10%, Rare 4%, Epic 1%, Legendary 0,25% (**15,25%** de qualquer arma ou armadura ganha alguma raridade). Ver `09-raridade.md`.
4. **Encantamento.** Item com raridade tem 1 a 4 slots (Uncommon a Legendary), unique ganha +2. Ver `12-encantamentos.md`.

Ou seja, o item base manda no piso de força e a raridade e o unique dão o teto. A raridade **não depende do monstro**: um rotworm pode dropar uma katana Legendary, só que muito raramente.

## 3. Teto do item base: ele não cresce depois do level ~80
Os itens base são os do Tibia 8.x. A força do item base sobe rápido até uns 45–50 de ataque e trava.

### Armas (melhor ataque por faixa de level do monstro)
| Faixa | Melhor arma que dropa | Atq / Def | Level da arma | Chance base | Monstro |
|---|---|---|---|---|---|
| 7–10 | katana / mace | 16 / 12 | — | 1% / 3,3% | rotworm |
| 16–19 | double axe, halberd | 35 / 12–14 | 25 | 4% | valkyrie, cyclops |
| 36 | ice rapier | 50 / 1 | — | 0,6% | vampire |
| 44 | dragon hammer, fire sword | 32–35 / 20 | 25–30 | 0,3–1,3% | dragon, renegade knight |
| 50 | bonebreaker, war hammer | 45–46 / 10–15 | 50–55 | 0,2–0,7% | worker golem |
| 61 | relic sword | 42 / 24 | 50 | 0,3% | werewolf |
| 69 | dragon lance, dragon slayer | 47 / 16 e 44 / 28 | 60 e 45 | 1,3–1,8% | dragon lord |
| 77–89 | giant sword, berserker, jade hammer | 46–48 / 20–22 | 55–70 | 1,1–2,4% | destroyer, war golem |
| 123 | nightmare blade | 46 / 23 | 70 | 1,2% | grim reaper |
| 143 | demonrage sword | 47 / 22 | 60 | 0,3% | demon |
| 144–169 | ruthless axe | 50 / 15 | 75 | 0,15% (1,6% no hellhound) | crypt warrior, skeleton elite warrior, hellhound |
| 208 | heavy mace | 49 / 15 | 70 | 0,65% | juggernaut |

O maior ataque base que dropa em todo o pool é **50** (`ruthless axe`, `ice rapier`). Do dragon lord (69) em diante o ataque base sobe de 44–47 para 50 no máximo. A diferença entre `dragon lord` e `demon` em arma base é quase nula: quem sobe a força é raridade/unique (seção 4).

Varinhas e rods: `wand of inferno` 24 (dragon, level 33), `springsprout rod` 25 (bog raider), `underworld rod` 26 (midnight asura, grim reaper, undead dragon, level 42). Arcos e bestas não têm ataque no item (a munição define), e os melhores arcos são 0,2% (`silkweaver bow`, `yol's bow`, `warsinger bow`, `devileye`, `royal crossbow`).

### Armaduras e escudos (melhor por slot)
| Slot | Itens que dropam, em ordem de força | Onde começa |
|---|---|---|
| Elmo | legion helmet 4 → steel helmet 6 → royal helmet 9 / skull helmet 9 → zaoan helmet 9 | royal helmet no dragon lord (69); devil helmet 7 no demon |
| Armadura | studded 5 → plate 10 → knight armor 12 → crown armor 13 → dragon scale mail 15 → golden armor 14 → **magic plate armor 17** | magic plate no demon (143), 0,2% |
| Pernas | leather 1 → brass 5 → plate 7 → knight/zaoan/terra 8 → golden legs 9 | golden legs no dark torturer (134) e juggernaut (208) |
| Botas | leather boots 1 → steel boots 3 | steel boots no destroyer (77); `boots of haste` 0,8% no hydra |
| Escudo | copper 19 → battle 23 → dragon 31 → crown/tower 32 → medusa 33 → **mastermind 37** | mastermind no demon (143) e juggernaut (208) |

O pico de armadura é 17 (magic plate) e de escudo 37 (mastermind), ambos só no **demon** com 0,2% e 1,9%. A armadura de melhor custo-benefício que aparece cedo é a `dragon scale mail` 15 (dragon lord, 0,933%).

## 4. Onde a progressão realmente acontece: uniques
Quase todo monstro do pool tem um unique, e os uniques sobem de força com o level do monstro. Bônus (`attribute`) por faixa:

| Faixa do monstro | Exemplos | Bônus típicos | Chance de virar unique |
|---|---|---|---|
| 7–21 | Slimebound Bulwark (rotworm), Tuskbound Mail (orc), Leafwoven Bow (elf) | skill +1, crit +1, on-hit 2, +30 vida/mana | 25–100% |
| 28–37 | Rune-forged Cleaver (dwarf guard), Rib-forged Mail (bonebeast) | skill +1, crit +1–2, on-hit 2–3, +50 vida | 31–100% |
| 43–56 | Gilded Mail, Ember-scaled Maul, Renegade Cleaver, Valorous Crown | skill +1–2, crit +2–3, on-hit 3–4, +50 a +80 vida/mana | 100% |
| 61–78 | Emberscale Mail, Emerald Garb, Ruinous Maul, Ashen Band | skill +2, crit +3, on-hit 4–6, penetração 4–8, +60 a +150 vida/mana | 25–100% |
| 79–104 | Brimstone Maul, Tidal Maul, Moonlit Rod, Dawnfire Helm, Corroded Greaves | skill +2, crit +3, on-hit 4–5, penetração 5–7, +120 vida/mana, magic level +1 a +2 | 40–100% |
| 123–171 | Scythe-touched Blade, Demonbound Blade, Sealed Blade, Cinderfang Blade, Wraithvenom Scale Mail | skill +2 a +3, crit +4 a +5, on-hit 5–7, penetração 7–8, +120 vida, leech 2 | 25–100% |
| 208 | Ironheart Mail | on-hit físico 7, penetração 9, +200 vida | 56% |

Pontos de força relevantes:
- **Uniques que mudam o valor base:** só os 4 `scale mail` (armor 17 a 18, base 15) e os elmos `Helm of Cinders` e `Rimecrest Helmet` (armor 11, base 9). Os demais só somam bônus.
- **Maior bônus de vida/mana:** `Emberscale Mail` e as irmãs, +150; `Ironheart Mail`, +200.
- **Únicos com leech:** `Duskscale Mail` (lifeleech 2, undead dragon) e `Wraithvenom Scale Mail` (manaleech 2 e dodge 4, ghastly dragon).
- **Único com magic level:** `Tuskhide Wand` (+1, behemoth) e `Moonlit Rod` (+2, midnight asura). Não existe unique de ML para o resto do pool.

## 5. Chance de drop por contrato (média de 75 kills, sem `rateLoot`)
| Monstro (level) | Item | Chance no XML | Esperado em 75 kills | Vira unique |
|---|---|---|---|---|
| Rotworm (7) | Slimebound Bulwark (copper shield) | 2,857% | 2,1 | 100% |
| Dragon (44) | Ember-scaled Maul (dragon hammer) | 1,333% | 1,0 | 100% |
| Dragon Lord (69) | dragon scale mail | 0,933% | 0,70 | 25% → **0,17** Emberscale |
| Dragon Lord (69) | royal helmet | 1,188% | 0,89 | 25% → **0,22** Helm of Cinders |
| Dragon Lord (69) | dragon slayer / dragon lance | 1,833% / 1,309% | 1,4 / 1,0 | — |
| Hellspawn (79) | onyx flail | 0,4% | 0,3 | — |
| Destroyer (77) | giant sword | 1,3% | 1,0 | — |
| Demon (143) | giant sword → Demonbound Blade | 3,8% | 2,85 | 39,5% → **1,1** |
| Demon (143) | magic plate armor | 0,2% | 0,15 | — |
| Demon (143) | demon shield / mastermind shield | 3,1% / 1,9% | 2,3 / 1,4 | — |
| Undead Dragon (171) | dragon scale mail → Duskscale Mail | 1,4% | 1,05 | 25% → **0,26** |
| Juggernaut (208) | heavy mace | 0,65% | 0,49 | — |

Com `rateLoot = 2.0` as colunas de "esperado" dobram para itens comuns. A coluna "vira unique" não é afetada pelo rate. Um jogador que fecha 2 categorias × 5 contratos faz até ~750 kills por dia, então quase todos os itens da tabela aparecem em dias, não semanas, exceto os de 0,2% (magic plate, arcos).

## 6. O que a progressão tem de problemático
1. **Platô de item base a partir do level ~80.** O melhor ataque base é 50 e o level 61 já tem 42–47, então caçar monstros 100+ não melhora o item base. A progressão acima de 80 depende só de uniques e raridade.
2. **Hunts de level 123+ têm poucos itens novos.** `grim reaper`, `dark torturer`, `blightwalker`, `crypt warrior`, `skeleton elite warrior` e `hellhound` dropam armas do mesmo nível de ataque (41–50) do `dragon lord`. Só ganham em unique (crit +4 a +5, on-hit 5–7).
3. **Hellhound e Juggernaut quase não têm armadura.** O primeiro só dropa armas (nenhum elmo, armadura, perna ou bota). O Juggernaut tem golden armor 14 e skullcracker 14, abaixo da `dragon scale mail` do level 69.
4. **Pool pequeno acima de 130 (10 monstros)**, com poucos monstros para formar contratos de level 150–200 (o contrato 5 de um jogador 200 procura 153–207).
5. **Itens com armor 0 ou 1 no pool alto.** `Medusa` (104) dropa `rusty armor` com 0,4% e `werewolf` (61) `rusty armor`. São lixo de crafting do Tibia.
6. **Só um item set.** `Crown Set` (crown helmet/armor/legs/shield) cai de `renegade knight` (44), `vile grandmaster` (53) e `hero` (56), com 0,1–1,2% por peça. Bônus de 2, 3 e 4 peças (dodge, crit, vida, leech). Não existe set para as faixas 61+.
7. **Armaduras clássicas não têm level mínimo.** Armas têm level em `weapons.xml`, mas `dragon scale mail`, `magic plate armor`, `knight armor`, `golden armor`, os elmos e os escudos clássicos não têm `minlevel` no `items.xml`; um jogador de level baixo que dropar uma `dragon scale mail` já a veste. Só os itens mais novos têm: `terra legs` 40, `terra mantle`, `magma coat` e `zaoan armor` 50, `frozen plate` 75, `skullcracker armor` 100.
8. **Anéis e amuletos não foram analisados em força**, só em lista. Há `might ring`, `stealth ring`, `death ring`, `ring of healing`, `boots of haste` (0,8% no hydra) com efeito de item padrão, sem comparação aqui.

## 7. Como ajustar
- **Chance de drop de um item:** `data/monster/<pasta>/<monstro>.xml`, linha `<item id="..." chance="...">` (100000 = 100%).
- **Chance de virar unique / bônus:** `data/XML/uniques.xml` (`chance`, `monsters`, `attribute`).
- **Novo unique para o pool alto:** use `id` de um item que o monstro já dropa e `chance` entre 25 e 100, para não depender só de raridade.
- **Raridade:** `config.lua` (`rarityChance*`) e `data/XML/rarity_archetypes.xml` (quais atributos o tipo de item sorteia).
- **Quais monstros entram nos dailys:** `DailyQuest.allowedMonsters` em `data/lib/300-dailyquests.lua`.
- **Mudar o level de um monstro:** `data/lib/302-monsterlevels.lua`.

## Método
Script em Python (extração em um scratchpad temporário, não versionado) que leu, para cada monstro de `allowedMonsters`, o arquivo XML do monstro (via `data/monster/monsters.xml`), cruzou os `id` do `<loot>` com `items.xml` (ataque, defesa, armadura, slot), `weapons.xml` (level da arma) e `uniques.xml` (por nome do monstro). Itens de backpack e munição foram ignorados. Chances do XML foram divididas por 1000 para virar %.
