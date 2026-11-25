# Glifos de magia

## O que faz
**Todas as vocações têm glifos.** Hoje já têm: as 13 magias de ataque do **sorcerer**, as 5 do **paladin**, 10 do **druid**, 12 do **knight**, 19 do **cleric** (ataque, cura e suporte, nas três últimas), as 23 do **necromancer** (invocações, ataques, buffs e as 4 do Lich), as 16 do **assassin** (as 12 do Assassin e as 4 premium do Nightblade), as 14 do **berserker** (as 10 do Berserker e as 4 premium do Warlord) e as 14 do **archer** (as 10 do Archer e as 4 premium do Ranger; os 4 Enchants não têm glifos). Cada vocação tem o seu NPC mestre. Cada magia tem dois glifos (**A** e **B**) e o jogador escolhe **um** para alterar a magia. O primeiro glifo de cada magia é comprado com **pontos de bestiário**; trocar para o outro custa **só ouro** (caro).

Cada magia pertence a uma vocação (`vocation` em `Glyphs.spells`: 1 sorcerer, que é o padrão; 3 paladin; 2 druid; 4 knight; 9 cleric, 11 necromancer, 13 assassin, 15 berserker, 17 archer). O orçamento `glyphBudgetPercent` é calculado por vocação (as 13 magias do sorcerer, as 5 do paladin, as 10 do druid, as 12 do knight, as 19 do cleric, as 23 do necromancer, as 16 do assassin, as 14 do berserker, as 14 do archer). As promoções (Hierophant, Lich, Nightblade, Warlord, Ranger etc.) usam os glifos da vocação base.

## Pontos de bestiário
Cada **nível de conhecimento** concluído num monstro (ver [04-bestiary.md](04-bestiary.md)) dá pontos. Eles são **calculados a partir das kills**, não ficam salvos: jogadores antigos já têm os pontos e não há risco de perdê-los. Só os pontos **gastos** ficam em storage.

- Base por nível: `bestiaryPointsPerLevel = "1, 2, 3, 5"`.
- Multiplicador pela experiência do monstro: `bestiaryPointsByExperience = "0:1, 100:2, 500:3, 2000:5, 10000:8, 50000:12"` (vale a faixa mais alta alcançada). Um Rotworm dá 1, 2, 3, 5; um monstro de 2000+ de exp dá 5, 10, 15, 25.
- Exceção por monstro, no XML: `<monster ... bestiaryPoints="3, 5, 8, 12">` (pontos exatos de cada nível; o último valor vale para os níveis seguintes).
- Ao subir de nível o jogador vê `(+N bestiary point(s))`; `!bestiary <monstro>` mostra os pontos do monstro.

## Comando
- `!glyphs`: pontos livres, nível e preço de cada magia e o glifo escolhido.
- `!glyphs <magia>`: os dois glifos, preço e nível necessário.
- `!glyphs <magia> a|b`: mostra o preço e pede confirmação.
- `!glyphs <magia> a|b yes`: escolhe o glifo (pontos na primeira vez, ouro na troca).

## Preços e regras (tudo em `config.lua`)
| Chave | Efeito |
|---|---|
| `glyphsEnabled` | liga/desliga o sistema (os glifos param de valer, nada se perde) |
| `glyphBudgetPercent` | 20: comprar **um glifo em todas as 13 magias** custa 20% de todos os pontos do bestiário. O orçamento é dividido entre as magias proporcionalmente ao nível da magia |
| `glyphCostOverrides` | preço fixo em pontos para magias específicas: `"Flame Strike=300, Hells Core=2500"` |
| `glyphLevelMultiplier` | nível do jogador exigido = nível da magia × este valor (4: Flame Strike 48, Hells Core 240) |
| `glyphSwapGoldPerSpellLevel` | ouro da troca = nível da magia × este valor (50.000: Flame Strike 600k, Hells Core 3M); a troca não gasta pontos |
| `glyphStorageBase` | primeiro storage (56200 = pontos gastos; 56201+ = escolha de cada magia) |

O preço automático se ajusta sozinho se monstros forem adicionados ao bestiário. Os dois glifos de uma magia custam o mesmo.

## Como desenhar um glifo
Em `data/lib/403-glyphs.lua`, dentro de `Glyphs.spells`, preencha `glyphs` da magia:
```lua
glyphs = {
	A = {name = "Nome", description = "o que faz, em inglês", descriptionPt = "o mesmo em português, sem acentos (opcional)", damage = 1.15},
	B = {name = "Nome", description = "...", burn = 5}
}
```
- `damage` / `healing`: multiplicador aplicado automaticamente pelo `SpellBalance` (`data/lib/402-spell-balance.lua`), sem editar o script da magia.
- Qualquer outro campo (queimadura, área, elemento convertido...) é lido pelo script da magia: `local glyph = Glyphs.get(cid, "attack/flame strike")` e depois `glyph.burn`.
- **Nunca reordene** `Glyphs.spells` (a posição define o storage); acrescente no fim. As posições de 1 a 126 estão em uso (59 das outras vocações, 60 a 82 do necromancer, 83 a 98 do assassin, 99 a 112 do berserker e 113 a 126 do archer) e o storage `glyphStorageBase + 200` é o dos pontos de teste (antes era `+ 99`, que o berserker passou a usar, e antes `+ 60`, do necromancer): uma vocação futura pode usar as posições de 127 a 199. Um GM que tinha pontos de teste no `+ 99` os perde (basta dar `/glyph points <n>` de novo).

## Arquivos
- `src/bestiary.cpp/.h`, `src/monsters.cpp/.h`, `src/configmanager.cpp/.h`, `src/luascript.cpp/.h`: pontos do bestiário. **Precisa recompilar** (`compilar.bat`).
- Lua: `getPlayerBestiaryPoints(cid)` e `getBestiaryTotalPoints()`.
- `data/lib/403-glyphs.lua`: magias, preços, compra/troca (`Glyphs.choose`), textos.
- `data/talkactions/scripts/glyphs.lua`: o comando `!glyphs`.
- `data/lib/402-spell-balance.lua`: aplica o multiplicador do glifo.

## Testes (staff, access 4)
`/glyph points <n>` soma pontos de bestiário para gastar (negativo tira), `/glyph give <magia> a|b` coloca o glifo de graça (ignora nível e pontos), `/glyph remove <magia>`, `/glyph reset` (zera glifos, pontos gastos e bônus). Só afeta quem digita. Os pontos de teste ficam no storage `glyphStorageBase + 200`. Depois de editar `403-glyphs.lua` (lib) reinicie o servidor ou use `/reload libs`; para os scripts de talkaction, `/reload talkactions`.

## Glifos definidos
| Magia | Glifo | Efeito |
|---|---|---|
| Flame Strike | A (Kinetic Flame, nome provisório) | +15% de dano e 30% de chance de empurrar o alvo 1 sqm para longe do caster |
| Flame Strike | B (Cross Flame, nome provisório) | o golpe atinge também os 4 sqm ao redor do alvo (cruz de 5 sqm) |
| Energy Strike | A (Triple Thunder, provisório) | 3 golpes (1 a cada 0,2s) no mesmo alvo, cada um com 1/3 de 130%: 130% do dano original no total |
| Energy Strike | B (Chain Lightning, provisório) | o raio salta para até 2 criaturas a mais (até 3 sqm da última, em linha de visão, sem repetir), cada ricochete com 70% do dano original; não pega NPC, party, summons próprios nem PZ |
| Terra Strike | A (Toxic Earth, provisório) | envenena o alvo por 50% do dano do golpe, em 6 ticks de 1s (usa o dano realmente rolado, já com o SpellBalance) |
| Terra Strike | B (Withering Earth, provisório) | tira 10 pontos de resistência a earth do monstro por 10s (aplicado antes do golpe; vale para todo dano earth que ele receber; só monstros) |
| Ice Strike | A (Glacial Grip, provisório) | paraliza o alvo (lentidão de 95%) por 1,5s, sempre; monstros imunes a paralisia não são afetados |
| Ice Strike | B (Frost Lance, provisório) | o gelo atravessa o alvo e acerta todas as criaturas da linha, até 6 sqm do caster; paredes (linha de visão bloqueada) interrompem |
| Death Strike | A (Withering Death, provisório) | tira 10 pontos de resistência a death do monstro por 10s (antes do golpe; só monstros) |
| Death Strike | B (Dark Curse, provisório) | amaldiçoa o alvo (curse): 50% do dano do golpe de novo, em dano de trevas, 5 ticks de 2s (10s) |
| Fire Wave | A (Great Wave, provisório) | onda maior: 5 linhas de alcance (antes 4) e 7 sqm de largura na ponta (antes 5); o dano não muda. Áreas definidas no próprio script |
| Fire Wave | B (Scorching Wave, provisório) | toda criatura atingida queima (CONDITION_FIRE): 50% do dano médio da magia, 5 ticks de 2s (10s). O dano médio é calculado pela fórmula (com SpellBalance), não pelo dano que cada alvo recebeu |
| Energy Beam | A (Overcharged Beam, provisório) | +15% de dano |
| Energy Beam | B (Static Rush, provisório) | 25% de chance, a cada cast, de ganhar haste (+30%, a mesma do Haste) por 5s; se já existe um haste ativo (Haste, Strong Haste ou o próprio glifo) ele não é substituído |
| Great Fireball | A (Compact Fireball, provisório) | área 1 sqm menor (AREA_CIRCLE2X2, 5x5, em vez de 7x7) e +15% de dano |
| Great Fireball | B (Kindling, provisório) | criaturas que estão queimando (CONDITION_FIRE) levam um golpe extra de fogo de 15% do dano da magia. O dano de cada alvo é rolado pelo servidor, então o extra é 15% da faixa de dano da fórmula (min a max, com SpellBalance), não 15% do golpe exato |
| Thunderstorm | A (Storm Web, provisório) | área 1 sqm menor e cada inimigo atingido solta um chain lightning (até 2 saltos, 50% do dano cada) para criaturas que ainda não foram atingidas; todas as correntes compartilham a mesma lista de atingidos |
| Thunderstorm | B (Lingering Storm, provisório) | cada tile atingido tem 20% de chance de continuar dando dano de energia: 10 ticks em 5s, 150% do dano da magia no total (15% por tick) |
| Hells Core | A (Infernal Legion, provisório) | cada inimigo atingido ganha uma criatura infernal ao lado, que luta pelo caster por 6s (até 10 por cast); o tipo depende do nível: Fire Devil (0), Fire Elemental (80), Massive Fire Elemental (120), Hellfire Fighter (160), Hellhound (220), Demon (300). A explosão continua acontecendo |
| Hells Core | B (Meteor Storm, provisório) | no lugar da explosão, 48 meteoros caem em tiles aleatórios em volta do sorcerer (raio 5) ao longo de 4s; cada um atinge uma cruz de 5 sqm com 37,5% do dano da fórmula |
| Rage of the Skies | A (Skyfall, provisório) | no lugar da explosão, 60 raios caem em tiles aleatórios em volta do sorcerer (raio 6) ao longo de 5s; cada um atinge uma cruz de 5 sqm com 40% do dano da fórmula |
| Rage of the Skies | B (Storm Rage, provisório) | depois da explosão, por 10s: +15% de chance de crítico, +15% de dodge, +25% de amplificação de energia e velocidade do Strong Haste; aparece em `!buffs` |
| Great Energy Beam | A (Longshot Beam, provisório; desenhado pelo Claude) | o feixe alcança 10 sqm (antes 7) e causa +10% de dano |
| Great Energy Beam | B (Conductive Beam, provisório; desenhado pelo Claude) | monstros atingidos perdem 15 pontos de resistência a energia por 8s (condition) |
| Energy Wave | A (Shockwave, provisório; desenhado pelo Claude) | toda criatura atingida é empurrada 1 sqm para longe do caster (as mais distantes primeiro; mesmas regras do empurrão) |
| Energy Wave | B (Mana Siphon, provisório; desenhado pelo Claude) | o caster recupera mana por inimigo atingido (até 5): 5% do dano médio da onda para cada um |
| Ethereal Spear (paladin) | A (Piercing Lance, provisório; desenhado pelo Claude) | a lança atravessa o alvo e acerta toda a linha, até 5 sqm do caster (paredes interrompem) |
| Ethereal Spear | B (Executioner, provisório) | +50% de dano em alvo com 30% de vida ou menos |
| Divine Missile (paladin) | A (Twin Missile, provisório) | 2 mísseis, 0,25s de intervalo, 130% do dano original no total |
| Divine Missile | B (Sanctified Mark, provisório) | tira 10 pontos de resistência a sagrado do monstro por 10s (antes do golpe; só monstros) |
| Divine Caldera (paladin) | A (Hallowed Ground, provisório) | a área fica sagrada por 5s: 5 pulsos de 1s, 80% do dano da magia no total |
| Divine Caldera | B (Repelling Light, provisório) | toda criatura atingida é empurrada 1 sqm para longe do caster |
| Divine Grenade (paladin, magia nova) | A (Twin Grenade, provisório) | uma segunda explosão 1,5s depois da primeira, no mesmo local, com 60% do dano |
| Divine Grenade | B (Blinding Flash, provisório) | toda criatura atingida fica paralisada por 2s |
| Strong Ethereal Spear (paladin, magia nova) | A (Impaling Lance, provisório) | como o Piercing Lance, até 7 sqm, +10% de dano |
| Strong Ethereal Spear | B (Hunter's Mark, provisório) | tira 10 pontos de resistência física do monstro por 10s (só monstros) |
| Ice Wave (druid) | A (Frostbite, provisório) | toda criatura atingida fica 40% mais lenta por 4s (usa `Glyphs.paralyze` com 0,4) |
| Ice Wave | B (Glacial Slide, provisório) | se a onda atingir pelo menos 1 inimigo, o caster ganha haste (+30%) por 3s (não substitui um haste já ativo) |
| Stone Shower (druid) | A (Stunning Stones, provisório) | cada inimigo atingido tem 25% de chance de ficar paralisado por 1,5s |
| Stone Shower | B (Gravel Armor, provisório) | por 8s o caster recebe 15% menos dano físico e de terra (buff `Gravel Armor` em `!buffs`, subId 8810) |
| Avalanche (druid) | A (Rolling Avalanche, provisório) | 0,8s depois, um segundo impacto 2 sqm mais longe, na direção caster → primeiro impacto, com 70% do dano |
| Avalanche | B (Shatterfrost, provisório) | tira 15 pontos de resistência a gelo do monstro por 8s (só monstros) |
| Terra Wave (druid) | A (Thorn Field, provisório) | cada tile atingido tem 30% de chance de virar espinhos: 5 pulsos de 1s, 120% do dano da magia no total |
| Terra Wave | B (Regrowth, provisório) | por inimigo atingido (até 5), o caster e a party num raio de 3 sqm recuperam 4% do dano médio da onda em vida |
| Wrath of Nature (druid) | A (Living Forest, provisório) | cada inimigo atingido ganha uma criatura da floresta por 8s (até 10); tipo por nível: Spit Nettle (0), Carniphila (70), Haunted Treeling (110), Earth Elemental (150), Massive Earth Elemental (220), Defiler (300) |
| Wrath of Nature | B (Primal Fury, provisório) | depois da explosão, por 10s: +25% de dano de terra e 1% da vida máxima por segundo (buff `Primal Fury`, subId 8812) |
| Eternal Winter (druid) | A (Hailstorm, provisório) | no lugar da explosão, 60 estilhaços de gelo caem em tiles aleatórios em volta do druid (raio 5) ao longo de 5s; cada um atinge uma cruz de 5 sqm com 40% do dano da fórmula |
| Eternal Winter | B (Glacial Cyclone, provisório) | no lugar da explosão, um disco cheio de gelo (sem buraco no meio, 5 sqm de raio) varre ao redor do druid tile a tile em 1,3s, **2 giros seguidos** (o segundo começa onde o druid estiver), 1 golpe por tile por giro com 70% do dano cada: 140% no total (`RingAttack`, `data/lib/069-ringattack.lua`); não segura nem puxa ninguém |
| Heal Friend (druid) | A (Rejuvenation, provisório) | o alvo cura mais 40% da cura média da magia, em 6 curas de 1s |
| Heal Friend | B (Swift Remedy, provisório) | remove toda condição ruim do alvo (veneno, fogo, energia, paralisia, afogamento, congelamento, ofuscação, maldição, embriaguez) e dá haste por 4s |
| Mass Healing (druid) | A (Verdant Ward, provisório) | todo jogador curado recebe 10% menos dano de qualquer elemento por 6s (buff `Verdant Ward`, subId 8811) |
| Mass Healing | B (Blooming Circle, provisório) | área com raio 4 (antes 3) e +15% de cura |
| Undead Legion (druid) | A (Dread Legion, provisório) | a criatura levantada depende do nível: Skeleton (0), Skeleton Warrior (60), BoneBeast (100), Lich (160), Blightwalker (240), Undead Dragon (300) |
| Undead Legion | B (Soul Harvest, provisório) | cada esqueleto levantado (até 5) devolve 3% da vida e da mana máximas do caster |
| Wild Growth (druid, rune) | A (Thornwall, provisório) | a vegetação fere as criaturas ao redor (3x3) com dano de terra, 1 pulso por segundo por 10s (dano de `level / 5 + magic * 1` a `level / 5 + magic * 2` por pulso, a rune não tem dano próprio) |
| Wild Growth | B (Lasting Growth, provisório) | aos 40s a vegetação é recriada, então dura cerca de 85s em vez de 45s |
| Whirlwind Throw (knight) | A (Ricochet Throw, provisório) | a arma ricocheteia para até 2 inimigos a mais (até 3 sqm do último atingido), cada ricochete com 70% do dano |
| Whirlwind Throw | B (Hamstring, provisório) | o alvo fica 40% mais lento por 4s e perde 10 pontos de resistência física por 6s (antes do golpe; só monstros perdem resistência) |
| Brutal Strike (knight) | A (Crushing Blow, provisório) | +50% de dano em alvo com 30% de vida ou menos |
| Brutal Strike | B (Sundering Strike, provisório) | tira 15 pontos de resistência física do monstro por 8s e faz o alvo sangrar: 50% do dano rolado do golpe, 5 ticks de 2s |
| Groundshaker (knight) | A (Tremor, provisório) | cada inimigo atingido tem 25% de chance de ficar paralisado por 1,5s |
| Groundshaker | B (Quake Wave, provisório) | área de raio 4 (antes 3) e toda criatura atingida é empurrada 1 sqm |
| Berserk (knight) | A (Bloodlust, provisório) | o knight recupera 3% da vida máxima por inimigo atingido (até 5) |
| Berserk | B (Rampage, provisório) | 2 golpes na mesma área, 0,3s de intervalo, 130% do dano original no total |
| Fierce Berserk (knight) | A (Savage Fury, provisório) | depois do golpe, por 8s: +15% de dano físico (amplificação) e +15% de crítico (buff em `!buffs`, subId 8820) |
| Fierce Berserk | B (Warlord's Roar, provisório) | depois do golpe, por 6s: 15% menos dano de todo elemento (subId 8821) e todo monstro atingido perde 10 pontos de resistência física por 6s |
| Bruise Bane (knight) | A (Second Wind, provisório) | cura mais 40% da cura média, em 4 curas de 1s |
| Bruise Bane | B (Hardened Skin, provisório) | 10% menos dano físico por 5s (subId 8822) |
| Wound Cleansing (knight) | A (Purifying Blood, provisório) | remove toda condição ruim e dá haste por 3s |
| Wound Cleansing | B (Iron Will, provisório) | não pode ser paralisado por 6s (a paralisia é removida a cada 0,4s) |
| Fair Wound Cleansing (knight) | A (Soothing Rest, provisório) | +15% de cura |
| Fair Wound Cleansing | B (Battle Recovery, provisório) | além de curar, remove toda condição ruim |
| Intense Wound Cleansing (knight) | A (Last Stand, provisório) | a cura é até 50% maior quanto menor a vida do knight (proporcional à vida que falta) |
| Intense Wound Cleansing | B (Unyielding, provisório) | depois da cura, 20% menos dano de todo elemento por 8s (subId 8823) |
| Charge (knight) | A (Shoulder Charge, provisório) | todo inimigo ao lado do knight é empurrado 1 sqm antes da investida |
| Charge | B (Long Rush, provisório) | a velocidade dura 8s em vez de 5s |
| Protector (knight) | A (Iron Wall, provisório) | enquanto o protetor dura, 20% menos dano de todo elemento (subId 8824) |
| Protector | B (Healing Aegis, provisório) | recupera 1% da vida máxima por segundo durante os 10s |
| Blood Rage (knight) | A (Berserker's Heart, provisório) | o bônus corpo a corpo sobe de +35% para +50% e recupera 1% da vida máxima por segundo |
| Blood Rage | B (Frenzy, provisório) | life leech de 5% enquanto a fúria dura |

**Magias novas do paladin** (`data/spells/spells.xml`, spellid 237 e 238): **Divine Grenade** (`exevo tempo mas san`, nível 82, 160 mana, 20s, alcance 7: a granada explode 2s depois no local do alvo, área 3x3 sagrada) e **Strong Ethereal Spear** (`exori gran con`, nível 90, 55 mana, 8s, alcance 7, cerca do dobro do dano da Ethereal Spear). As fórmulas de dano são nossas; ajuste no script de cada uma.

**Glifos do knight** (vocação 4, nomes provisórios, desenhados pelo Claude; o execute do Brutal Strike A foi pedido pelo dono): tabela abaixo. **Não precisa recompilar.** Funções novas da lib: `Glyphs.bleed(cid, alvo, total, ticks, intervalo)` (sangramento físico), `Glyphs.paralysisImmunity(cid, ms)` (remove a paralisia a cada 0,4s), `Glyphs.pushAll(cid, lista, chance)` (empurra uma lista de criaturas, as mais distantes primeiro) e `Glyphs.absorbAll(percent)` (parâmetros de `statBuff` com X% menos dano de todo elemento). SubIds de condition novos: 8820 Savage Fury, 8821 Warlord's Roar, 8822 Hardened Skin, 8823 Unyielding, 8824 Iron Wall.

**Glifos do cleric** (vocação 9; nomes provisórios, desenhados pelo Claude). **Não precisa recompilar.** Mudanças de lib: `Cleric.zone` aceita `extra = function(cid, allies, pos)` (chamado a cada pulso) e `Cleric.buffs` ganhou versões mais fortes dos buffs (`divine_grace_radiant`, `divine_grace_flow`, `wall_of_light_reinforced`, `divine_vitality_greater`, `radiant_strikes_piercing`, `radiant_strikes_lasting`) usadas pelos glifos. SubIds novos: 8830 Pillar of Mercy, 8831 Absolving Touch, 8832 Righteous Fury, 8833 Shared Fury, 8834 Wall of Reflection. As magias de Hierophant (Sacred Wave, Divine Tempest, Divine Vitality, Radiant Strikes) têm glifos de vocação 9, que o Hierophant usa pela vocação base.

| Magia | Glifo | Efeito |
|---|---|---|
| Holy Ray | A (Mending Ray) | cura o aliado (caster ou party, até 7 sqm) com menos vida em 25% do dano médio da magia |
| Holy Ray | B (Zealous Ray) | cada cast dá 2 stacks de Faith em vez de 1 |
| Divine Lance | A (Long Lance) | o feixe alcança 7 sqm (antes 5) e dano e cura +10% |
| Divine Lance | B (Guiding Light) | cura +25% e todo jogador curado pelo feixe ganha haste por 3s |
| Holy Nova | A (Wide Nova) | raio 3 (antes 2) e +15% de cura |
| Holy Nova | B (Echoing Nova) | segundo pulso 1s depois com 50% do dano e da cura (150% no total) |
| Rain of Light | A (Downpour) | 6 pulsos em vez de 3, cada um com 65% (130% no total) |
| Rain of Light | B (Rain of Mana) | quem está dentro (caster e party) recupera 1% da mana máxima por pulso |
| Celestial Hammer | A (Cleaving Hammer) | atinge também os 4 sqm ao redor do alvo com 50% do dano |
| Celestial Hammer | B (Heavy Hand) | +20% de dano e stun de 3s (antes 2s) |
| Judgment | A (Swift Verdict) | a sentença cai em 0,75s (antes 1,5s) |
| Judgment | B (Mass Verdict) | a sentença cai também nos outros inimigos a até 2 sqm do alvo, com 60% do dano |
| Pillar of Light | A (Enduring Pillar) | o círculo dura 7 pulsos (antes 4) |
| Pillar of Light | B (Pillar of Mercy) | cura do círculo x2 e quem está dentro recebe 10% menos dano de todo elemento (buff, subId 8830) |
| Sacred Wave | A (Shattering Wave) | monstros perdem 20% de resistência sagrada por 12s (condition real, no lugar do -10% por 8s) |
| Sacred Wave | B (Slowing Light) | todo inimigo atingido fica 40% mais lento por 4s |
| Divine Tempest | A (Steady Footing) | o caster fica só 50% mais lento (em vez de paralisado) |
| Divine Tempest | B (Tempest of Grace) | a cada segundo (5x) o caster e a party a até 5 sqm recuperam 4% do dano médio total da magia |
| Soothing Touch | A (Twin Souls) | ao curar outro jogador, o caster recupera 50% da cura média |
| Soothing Touch | B (Absolving Touch) | remove toda condição ruim do alvo e dá 15% menos dano por 4s (subId 8831) |
| Group Blessing | A (Wide Blessing) | raio 4 (antes 2) e +15% de cura |
| Group Blessing | B (Blessing of Renewal) | cada abençoado recupera 1% da vida máxima por segundo por 8s |
| Purify | A (Wide Purification) | raio 3, limpa toda condição ruim (`Glyphs.cleanse`) e +30% de dano |
| Purify | B (Warding Purification) | os jogadores limpos ficam imunes a veneno, fogo, energia, maldição e paralisia por 6s |
| Final Prayer | A (Endless Prayer) | 5 pulsos (10s) em vez de 3 |
| Final Prayer | B (Prayer of Salvation) | a cada pulso, quem está abaixo de 35% de vida é curado 100% a mais |
| Shield of Faith | A (Reinforced Faith) | dura 10s e dá +12 de armadura e +9 de defesa |
| Shield of Faith | B (Burst of Faith) | ao acabar, explode: outros aliados a até 2 sqm são curados e inimigos recebem dano sagrado, 50% da cura |
| Holy Fury | A (Righteous Fury) | +10% de chance de crítico pelos 15s (subId 8832) |
| Holy Fury | B (Shared Fury) | a party a até 3 sqm ganha +10% de dano sagrado (metade) por 15s (subId 8833) |
| Divine Grace | A (Radiant Grace) | +20% de magic level em vez de +10% |
| Divine Grace | B (Graceful Flow) | dura 25s e devolve 5% da mana máxima na hora |
| Wall of Light | A (Reinforced Wall) | armadura e defesa dobram (+10 e +8) |
| Wall of Light | B (Wall of Reflection) | 15% menos dano de todo elemento por 10s (subId 8834) |
| Divine Vitality | A (Greater Vitality) | +15% de vida e mana máximas em vez de +10% |
| Divine Vitality | B (Instant Reprieve) | todo afetado recupera 15% da vida máxima na hora |
| Radiant Strikes | A (Piercing Radiance) | 25% do dano como sagrado em vez de 15% |
| Radiant Strikes | B (Lasting Radiance) | dura 2 min e alcança a party a até 10 sqm (antes 7) |

**Glifos do necromancer** (vocação 11, as 23 magias; nomes provisórios, desenhados pelo Claude). **Não precisa recompilar.** Cada magia tem dois glifos com focos diferentes (dano, controle, sustain, economia de soul, defesa...). Os campos de cada glifo são lidos pelos scripts de `data/spells/scripts/necromancer/` (e `summon/`) e por `data/lib/373-necromancer.lua`; o glifo de uma invocação vale para o summon que ela levanta (os ataques do summon consultam o glifo do dono). Funções novas da lib do necromancer: `Necro.glyph(cid, "nome")`, `Necro.ownerGlyph(summon)`, `Necro.guard(summon, %, ms)` (resistência a todo elemento num summon), `Necro.enemiesAround(pos, raio)`, `Necro.poisonTarget(cid, alvo, glifo)`, `Necro.applyGlyph`, `Necro.graveBurst`, `Necro.armorPercent`. Buffs novos em `Necro.buffs`: `unholy_frenzy_dire`, `soul_sacrifice_pact`, `bone_shell_reinforced`, `bone_shell_burst`, `venom_corrosion_strong`. SubId novo de condition: 8335 (Bone Barrier, resistência dos summons). Novo evento de creaturescript: `NecroSpikes` (`necrospikes.lua`, statschange, registrado nos summons pelo Bone Armor).

| Magia | Glifo | Efeito |
|---|---|---|
| Summon Skeleton | A (Bone Fencer) | o esqueleto nasce com +30% de vida e causa +20% de dano |
| Summon Skeleton | B (Frugal Soul) | 25% de chance de não gastar o soul |
| Summon Ghoul | A (Rotten Flesh) | +30% de vida e regenera 1% por segundo |
| Summon Ghoul | B (Stench of the Grave) | o Taunt alcança 2 sqm e os desafiados ficam 25% mais lentos por 4s |
| Summon Banshee | A (Piercing Wail) | o grito atravessa o alvo e acerta os monstros da linha, até 5 sqm dela |
| Summon Banshee | B (Keening) | o grito deixa o alvo 30% mais lento por 3s |
| Summon Phantasm | A (Twin Haunt) | 2 golpes, 0,5s de intervalo, 130% do dano no total |
| Summon Phantasm | B (Withering Haunt) | monstros atingidos perdem 10% de resistência a death e poison por 6s |
| Summon Dragon Skeleton | A (Ancient Bones) | perde 0,75% de vida por segundo em vez de 1,5% (dura o dobro) |
| Summon Dragon Skeleton | B (Dragon's Fury) | Grave Burst com +20% de dano e uma rajada extra entre as normais (uma a cada 5s) |
| Death Touch | A (Soul Tap) | recupera mana igual a 10% do dano médio da magia |
| Death Touch | B (Marked for Death) | -10% de resistência a death por 8s (antes do golpe, só monstros) |
| Venom Touch | A (Festering Wound) | o veneno dura 15s em vez de 10 (150%) |
| Venom Touch | B (Crippling Venom) | o alvo fica 30% mais lento por 4s |
| Dark Orb | A (Grim Burst) | +20% de dano |
| Dark Orb | B (Feeding Orb) | os summons recuperam 3% da vida por inimigo atingido (até 5) |
| Venom Orb | A (Toxic Cloud) | a área continua envenenada por 5s: 120% do dano da magia no total (5 pulsos) |
| Venom Orb | B (Plague Spores) | monstros atingidos perdem 15% de resistência a poison por 8s |
| Death Wave | A (Wide Wave) | onda com 5 sqm de largura e 1 sqm a mais de alcance |
| Death Wave | B (Soul Reaper) | se atingir 3 ou mais inimigos, 25% de chance de +1 soul |
| Venom Wave | A (Virulent Wave) | o veneno causa o dobro de dano por tick |
| Venom Wave | B (Retching Gust) | toda criatura atingida é empurrada 1 sqm |
| Rain of Poison | A (Acid Rain) | a chuva dura 8 pulsos (8s) em vez de 5 |
| Rain of Poison | B (Corrosive Rain) | Venom Corrosion de +40% de penetração por 20s, para o necromante e a party a até 7 sqm |
| Death Tornado | A (Twin Gale) | 2 giros seguidos, 70% do dano cada (140% no total) |
| Death Tornado | B (Dead Calm) | todo monstro que o disco atravessa fica 35% mais lento por 4s |
| Bone Armor | A (Ossified Armor) | +40% de resistência física (em vez de 25%), também nos summons invocados durante o buff |
| Bone Armor | B (Spiked Bones) | durante o buff, o monstro que acerta um summon leva 10% do dano de volta (físico) |
| Unholy Frenzy | A (Dire Frenzy) | +45% de dano nos summons, mas só por 12s |
| Unholy Frenzy | B (Bloodthirsty Dead) | os summons recuperam 5% do dano de cada ataque (do dano da fórmula, não do realmente causado) em vida |
| Soul Sacrifice | A (Mercy of the Fallen) | devolve 5 soul em vez de 3 |
| Soul Sacrifice | B (Dark Pact) | o bônus vai a +60% e o necromante recupera 10% da vida |
| Bone Shell | A (Reinforced Shell) | +24 de armor e +18 de defense |
| Bone Shell | B (Shell Burst) | quando acaba (também se for renovada), explode em death raio 2, P x 1.5 a 2.5 |
| Bone Mend | A (Greater Mend) | +30% de cura e 9 sqm de alcance |
| Bone Mend | B (Marrow Link) | o necromante recupera 25% da cura média da magia |
| Recall | A (Swift Recall) | o necromante e os summons ganham haste por 3s |
| Recall | B (Bone Barrier) | os summons chegam com 15% menos dano de todo elemento por 6s |
| Soul Siphon (Lich) | A (Greater Siphon) | cura 55% do dano no necromante e 15% nos summons |
| Soul Siphon | B (Reaping Siphon) | +50% de dano em alvo com 30% de vida ou menos, e a morte dá 2 soul |
| Summon Bone Abomination (Lich) | A (Colossal Bones) | +40% de vida e o Taunt alcança 5 sqm |
| Summon Bone Abomination | B (Volatile Marrow) | a explosão ao morrer é 7x7 e causa +50% de dano |
| Corpse Explosion (Lich) | A (Chain Detonation) | até 2 outros corpos a até 2 sqm da explosão explodem também (consomem o corpo), 50% do dano cada |
| Corpse Explosion | B (Shattering Blast) | todo inimigo a até 2 sqm fica 50% mais lento por 3s |
| Army of the Dead (Lich) | A (Legion) | 5 bone soldiers por 15s |
| Army of the Dead | B (Undying Vanguard) | 3 soldiers por 30s, que desafiam os monstros a 3 sqm a cada 6s e a cada golpe deixam o alvo 20% mais lento por 2s |

**Glifos do assassin** (vocação 13, as 16 magias: 12 do Assassin e 4 premium do Nightblade; nomes provisórios, desenhados pelo Claude). **Não precisa recompilar.** Cada magia tem dois glifos de **tipos diferentes** (dano em alvo único, dano em área, controle, dano ao longo do tempo, mobilidade, defesa, sustain, utilidade ou buff), nunca dois do mesmo tipo. As magias do assassin **não passam pelo `SpellBalance`**: todo campo do glifo é lido pelo script em `data/spells/scripts/assassin/` (por isso o `damage` do glifo não é usado). O Nightblade usa os glifos pela vocação base, como o Hierophant e o Lich.

Lib nova (`data/lib/374-assassin.lua`): `Assassin.glyph(cid, "nome")`, `Assassin.enemiesAround(cid, pos, raio [, exceto])`, `Assassin.average(cid, fmin, fmax)`, `Assassin.lethal` (Lethal Shadow), `Assassin.isBehind(cid, alvo, ladoOk)`, `Assassin.poison(cid, ticks, multiplicador)` e `Assassin.clones(cid, quantidade, duração, desafio)`. Buffs novos em `Assassin.buffs`: `shadow_dodge_long`, `bloodthirst_crimson`, `bloodthirst_predator`, `night_veil_swift` (mesmo nome e subId do original, então **substituem** o buff normal em vez de empilhar) e `assassins_prey` (subId 8406). SubId novo fora da lib: 8407 Veil of Reflection.

| Magia | Glifo | Tipo | Efeito |
|---|---|---|---|
| Quick Slash | A (Rapid Flurry) | dano alvo único | 20% de chance de cortar de novo na hora, com 60% do dano |
| Quick Slash | B (Opening Cut) | utilidade | 25% de chance de dar 2 stacks de Momentum em vez de 1 |
| Shadow Step | A (Fleeting Shade) | defesa | a esquiva depois do passo é +40% (em vez de +25%) e dura 3s |
| Shadow Step | B (Lingering Fear) | controle | o alvo fica 40% mais lento por 3s depois do passo |
| Twin Fang | A (Serrated Fangs) | dano ao longo do tempo | cada corte faz o alvo sangrar por 40% do dano dele, em 4 ticks de 1s |
| Twin Fang | B (Hungry Fangs) | sustain | recupera 3% da vida máxima por corte que acertar |
| Venom Edge | A (Lethal Dose) | dano alvo único | o veneno causa o dobro de dano por tick e dura 10s (em vez de 8) |
| Venom Edge | B (Creeping Toxin) | controle | o alvo fica 30% mais lento por 4s e perde 10% de resistência a terra por 8s (antes do golpe, só monstros) |
| Bleeding Cut | A (Open Wound) | dano alvo único | +30% de dano no corte e o sangramento dura 8s (em vez de 6) |
| Bleeding Cut | B (Hemorrhage) | dano em área | o sangramento também começa nos inimigos a até 2 sqm do alvo, com 50% do dano por tick |
| Backstab | A (Assassin's Prey) | buff | depois do golpe, +15% de crítico por 6s (subId 8406) |
| Backstab | B (Shadowed Strike) | mobilidade/posição | funciona também pelos lados do alvo; só a frente é recusada |
| Smoke Bomb | A (Choking Smoke) | controle | todo inimigo atingido fica 40% mais lento por 4s |
| Smoke Bomb | B (Lingering Haze) | dano em área | a fumaça fica mais 4s: 4 pulsos a mais de 25% do dano (100% a mais no total) |
| Blade Dance | A (Whirling Blades) | dano em área | a área passa de 3x3 para raio 2 (`AREA_CIRCLE2X2`) |
| Blade Dance | B (Dance of Steel) | sustain | recupera 2% da vida máxima por inimigo atingido (até 5) |
| Bloodthirst | A (Crimson Thirst) | sustain | o life leech sobe de 12% para 20% |
| Bloodthirst | B (Predator's Edge) | buff | +15% de crítico (em vez de 5%) e +10% de dano físico; dura 15s |
| Execute | A (Merciless) | dano alvo único | o bônus de vida baixa vale abaixo de 40% (em vez de 30%) e é x2,0 (em vez de x1,75) |
| Execute | B (Bounty) | utilidade | se a faca matar o alvo, devolve os stacks de Momentum gastos e 10% da mana máxima |
| Deathblow | A (Final Mercy) | utilidade | o alvo pode ter até 35% de vida (em vez de 25%) |
| Deathblow | B (Reaper's Rush) | mobilidade | se o golpe matar o alvo: haste (+30%) por 5s e invisibilidade por 2s |
| Vanish | A (Ghost Walk) | mobilidade | também dá haste (+30%) por 5s |
| Vanish | B (Lethal Shadow) | dano alvo único | o primeiro golpe de magia em até 5s causa +40% de dano |
| Thousand Cuts | A (Rending Flurry) | dano ao longo do tempo | cada corte faz o alvo sangrar por 25% do dano dele, em 5 ticks de 1s |
| Thousand Cuts | B (Whirling Cuts) | dano em área | cada corte também atinge os outros inimigos a até 1 sqm do alvo, com 40% do dano |
| Death Mark | A (Marked for Ruin) | controle | o marcado perde 15% de resistência a death por 6s (só monstros) |
| Death Mark | B (Spreading Doom) | dano em área | a detonação passa de 3x3 para raio 2 |
| Phantom Clones | A (Legion of Shadows) | dano em área | 3 clones em vez de 2 |
| Phantom Clones | B (Enduring Illusion) | defesa | os clones duram 18s (em vez de 12) e desafiam os monstros a até 3 sqm quando aparecem |
| Night Veil | A (Veil of Swiftness) | mobilidade | o véu dura 15s (em vez de 12) e dá haste (+30%) enquanto durar |
| Night Veil | B (Veil of Reflection) | defesa | além do véu, 15% menos dano de todo elemento por 10s (subId 8407) |

Observações do assassin: o Execute não tem como reduzir o cooldown pela API de Lua, então o Bounty devolve **Momentum e mana** (não cooldown). O Clone Slash (ataque dos clones) não tem glifo próprio: os glifos do Phantom Clones já cobrem os clones. O Lethal Shadow só vale para o dano das magias do assassin (e não dos ataques básicos), e some se o Vanish passar de 5s sem golpe.

**Glifos do berserker** (vocação 15, as 14 magias: 10 do Berserker e 4 premium do Warlord; nomes provisórios, desenhados pelo Claude). **Não precisa recompilar.** Cada magia tem dois glifos de **tipos diferentes** (dano em área, dano alvo único, controle, dano ao longo do tempo, debuff, sustain, defesa, mobilidade, utilidade ou buff), nunca dois do mesmo tipo. As magias do berserker **não passam pelo `SpellBalance`**: todo campo do glifo é lido pelo script em `data/spells/scripts/berserker/` (o `damage` só é usado pelo Cleave). O Warlord usa os glifos pela vocação base. As magias gastam vida, então os glifos de sustain compensam o custo sem tirar o risco do estilo.

Lib nova (`data/lib/375-berserker.lua`): `Berserker.glyph(cid, "nome")` (o nome é o do script, ex. `"savage leap"`), `Berserker.enemiesAround(cid, pos, raio [, exceto])`, `Berserker.slowAll(cid, lista, percentual, ms)`, `Berserker.guard(cid, nome, subId, %, ms)` (X% menos dano de todo elemento) e `Berserker.vengeance(cid, nome, subId, amp, crítico, ms)` (+% de dano físico e de crítico). Buff novo em `Berserker.buffs`: `blood_pact_flesh` (mesmo nome e subId do Blood Pact, então **substitui** o buff normal). SubIds novos: 8451 Stonehide, 8452 Iron Cry, 8453 Unbroken Frenzy, 8454 Pact of Vengeance, 8455 Vengeful Rage. O `range` do Savage Leap em `spells.xml` passou de 4 para 6 (o script mantém 4 sem o glifo Long Leap).

| Magia | Glifo | Tipo | Efeito |
|---|---|---|---|
| Cleave | A (Wide Cleave) | dano em área | o golpe também atinge os 3 tiles à frente e causa +10% de dano |
| Cleave | B (Fury Surge) | buff | 30% de chance de ganhar +1 stack de Fúria |
| Savage Leap | A (Quaking Landing) | controle | todo inimigo atingido pela aterrissagem fica paralisado por 1,5s |
| Savage Leap | B (Long Leap) | mobilidade | alcance 6 sqm (antes 4) e haste (+30%) por 3s depois do pulo |
| Rending Blow | A (Deep Wound) | dano ao longo do tempo | o sangramento dura 10s (antes 6) e cada tick causa +40% |
| Rending Blow | B (Sundering Blow) | debuff | o alvo perde 15% de resistência física por 8s (antes do golpe, só monstros) |
| Warcry | A (Iron Cry) | defesa | 10% menos dano de todo elemento por 8s (subId 8452) |
| Warcry | B (Rallying Cry) | utilidade de grupo | a party a até 5 sqm ganha o armor e a defense do Warcry e haste por 4s |
| Whirlwind | A (Hurricane) | dano em área | a área passa de 3x3 para raio 2 (`AREA_CIRCLE2X2`) |
| Whirlwind | B (Bloodspin) | sustain | recupera 2% da vida máxima por inimigo atingido (até 5) |
| Ground Slam | A (Seismic Reach) | dano em área | onda com 1 sqm a mais de alcance e 2 sqm a mais de largura na ponta (a mesma do Fire Wave A) |
| Ground Slam | B (Tectonic Shock) | controle | 30% de chance de paralisar por 2s e a lentidão de 60% dura 5s (antes 3s) |
| Blood Pact | A (Pact of Flesh) | sustain | o leech sobe de +8% para +14% |
| Blood Pact | B (Pact of Vengeance) | buff | +15% de dano físico e +10% de crítico por 12s (subId 8454) |
| Rampage | A (Relentless Rampage) | dano alvo único | 6 golpes em vez de 4, no mesmo 1,2s, 130% do dano original no total |
| Rampage | B (Hamstring) | controle | o alvo fica 40% mais lento por 4s |
| Skullsplitter | A (Cranium Crusher) | dano alvo único | +50% de dano em alvo com 30% de vida ou menos |
| Skullsplitter | B (Bounty of Blood) | utilidade | se o golpe matar o alvo, devolve a vida que a magia custou (15%) e dá +3 de Fúria |
| Roar of Fury | A (Berserk Roar) | buff | dá 7 stacks de Fúria em vez de 5 |
| Roar of Fury | B (Dreadful Roar) | controle | inimigos a até 3 sqm ficam 40% mais lentos por 4s |
| Earthshatter | A (Aftershock) | dano em área | segunda onda 1,2s depois, na mesma área, com 60% do dano |
| Earthshatter | B (Stonehide) | defesa | 20% menos dano de todo elemento por 8s (subId 8451) |
| Blood Frenzy | A (Hunting Frenzy) | mobilidade | haste (+30%) enquanto o frenzy durar (10s) |
| Blood Frenzy | B (Unbroken Frenzy) | defesa | 15% menos dano de todo elemento (subId 8453) e imunidade a paralisia durante os 10s |
| Titan's Wrath | A (Cataclysm) | dano em área | o último golpe atinge raio 2 (`AREA_CIRCLE2X2`) e causa +20% de dano |
| Titan's Wrath | B (Titan's Grip) | controle | cada golpe deixa os atingidos 40% mais lentos por 4s e o último os paralisa por 2s |
| Undying Rage | A (Second Life) | sustain | quando a fúria acaba, recupera 30% da vida máxima |
| Undying Rage | B (Vengeful Rage) | buff | +30% de dano físico e +15% de crítico enquanto durar (subId 8455) |

Observações do berserker: o Bounty of Blood devolve a vida 0,4s depois do golpe, porque o custo em vida é descontado depois do script; o valor devolvido é 15% da vida máxima, o custo do Skullsplitter (`config.cost` no script, ajuste se o custo mudar em `spells.xml`). O Rallying Cry só tem efeito em quem está na party. No Ground Slam, o Tectonic Shock usa um combate sem a condição de lentidão do spell (a lentidão longa e o stun são aplicados pelo glifo, para uma não sobrescrever a outra). O Cleave tem a área `{1, 3, 1}, {1, 0, 1}` do script, em que a segunda linha fica atrás de quem lança; o Wide Cleave soma uma linha à frente.

**Glifos do archer** (vocação 17, as 14 magias: 10 do Archer e 4 premium do Ranger; nomes provisórios, desenhados pelo Claude). **Não precisa recompilar.** As 4 magias de Enchant (Fire, Poison, Ice e Energy) **não têm glifos**: custam 0 de mana e só ligam o elemento. Cada magia tem dois glifos de **tipos diferentes** (dano alvo único, dano em área, controle, dano ao longo do tempo, debuff, sustain, defesa, mobilidade, utilidade ou buff), nunca dois do mesmo tipo, e funcionam com **qualquer encantamento** (não repetem o que o elemento já faz). As magias do archer **não passam pelo `SpellBalance`**: todo campo do glifo é lido pelo script em `data/spells/scripts/archer/`. O Ranger usa os glifos pela vocação base.

Lib nova (`data/lib/376-archer.lua`): `Archer.glyph(cid, "nome")` (o nome é o do script, ex. `"twin shot"`), `Archer.guard(cid, nome, subId, %, ms)` (X% menos dano de todo elemento), `Archer.empower(cid, nome, subId, amp, crítico, ms)` (+% de dano em todos os elementos do archer e de crítico), `Archer.weaken(alvo, %, ms)` (monstros perdem resistência a físico, fogo, terra, gelo e energia) e `Archer.refundMana(cid, quantidade)` (devolve a mana 0,3s depois, porque o custo é cobrado depois do script). SubIds novos: 8710 Hunter's Tempo, 8711 Smoke Veil, 8712 Warding Surge, 8713 Steady Charge, 8714 Rising Gale, 8715 Radiant Avatar, 8716 Falcon's Focus. O `range` do Piercing Arrow em `spells.xml` passou de 6 para 9 (o script mantém 6 sem o glifo Longbow Pierce).

| Magia | Glifo | Tipo | Efeito |
|---|---|---|---|
| Elemental Shot | A (Frugal Quiver) | utilidade | 25% de chance de devolver a mana do tiro |
| Elemental Shot | B (Sharpshot) | dano alvo único | +25% de dano em alvo a 5 sqm ou mais |
| Piercing Arrow | A (Longbow Pierce) | dano em área | a flecha alcança 9 sqm (antes 6) e causa +10% de dano |
| Piercing Arrow | B (Hunter's Tempo) | buff | depois do tiro, +10% de dano e +15% de crítico por 6s (subId 8710) |
| Twin Shot | A (Triple Shot) | dano alvo único | 3 flechas em vez de 2, 130% do dano original no total |
| Twin Shot | B (Leeching Arrow) | sustain | recupera 2% da vida máxima por flecha que acertar |
| Elemental Trap | A (Lasting Trap) | dano ao longo do tempo | dura 10s (antes 6) e causa +30% de dano por segundo |
| Elemental Trap | B (Sticky Net) | controle | quem pisa fica 50% mais lento por 4s (depois da prisão ou do stun de gelo e raio) |
| Disengage | A (Rolling Retreat) | mobilidade | salta até 5 tiles (antes 3) e ganha haste por 3s |
| Disengage | B (Smoke Veil) | defesa | 20% menos dano de todo elemento por 5s (subId 8711) |
| Arrow Fan | A (Wide Fan) | dano em área | cone de 6 de alcance e 5 de largura (antes 5 e 3) |
| Arrow Fan | B (Scatter Shot) | controle | toda criatura atingida é empurrada 1 sqm |
| Rain of Arrows | A (Storm of Arrows) | dano em área | 9 acertos em vez de 6 no mesmo 1,5s, 130% do dano original no total |
| Rain of Arrows | B (Armor-Piercing Rain) | debuff | monstros na área perdem 10% de resistência a físico, fogo, terra, gelo e energia por 6s |
| Elemental Surge | A (Swift Surge) | mobilidade | haste (+30%) enquanto o surge durar (10s) |
| Elemental Surge | B (Warding Surge) | defesa | 15% menos dano de todo elemento durante o surge (subId 8712) |
| Overcharge Shot | A (Unflinching Charge) | defesa | durante a carga, 25% menos dano de todo elemento e imune a paralisia (subId 8713) |
| Overcharge Shot | B (Quick Charge) | utilidade | a carga leva 0,6s (antes 1,2s) |
| Convergence | A (Prismatic Burst) | dano em área | cada flecha explode em 3x3 ao redor do alvo, 30% do dano nos outros |
| Convergence | B (Harmonic Mark) | debuff | o alvo perde 10% de resistência a físico, fogo, terra, gelo e energia por 8s (só monstros) |
| Arrow Tempest | A (Relentless Tempest) | dano em área | 7 ricochetes (antes 5) e só -7% de dano por ricochete (antes -10%) |
| Arrow Tempest | B (Rising Gale) | buff | depois do tiro, +15% de dano e +15% de crítico por 8s (subId 8714) |
| Elemental Avatar | A (Radiant Avatar) | buff | +15% de dano e +15% de crítico durante os 12s (subId 8715) |
| Elemental Avatar | B (Living Element) | sustain | recupera 1% da vida máxima por segundo durante os 12s |
| Spirit Falcon | A (Twin Falcons) | dano alvo único | o falcão ataca a cada 1s (antes 1,5s) |
| Spirit Falcon | B (Falcon's Focus) | buff | +10% de dano e +10% de crítico enquanto o falcão durar (subId 8716) |
| Perfect Shot | A (Deadeye) | dano alvo único | +50% de dano em alvo com 30% de vida ou menos |
| Perfect Shot | B (Hunter's Rush) | utilidade | se matar o alvo, devolve 50% da mana da magia e dá haste por 3s |

Observações do archer: os glifos de buff (`Archer.empower`) usam `CONDITION_PARAM_ELEMENTAL_AMP_*` de todos os elementos do archer mais `CONDITION_PARAM_CRITICALCHANCE`; como o dano das magias sai de `Archer.hit` (`doTargetCombatHealth`), o bônus entra pelo mesmo caminho dos outros buffs de amplificação, mas vale testar com cada encantamento. O Sticky Net, com gelo ou raio, espera a prisão ou o stun acabar para aplicar a lentidão (para uma não sobrescrever a outra). O Hunter's Rush e o Frugal Quiver devolvem a mana 0,3s depois do tiro (`Archer.refundMana`); o custo usado está em `config.cost` nos scripts do Elemental Shot e do Perfect Shot (ajuste se o custo mudar em `spells.xml`).

Observações: os orbs do necromante usam `AREA_CIRCLE3X3` (círculo de raio 3, 7x7), apesar de o doc do necromancer dizer "3x3". As invocações não passam pelo `SpellBalance` (o dano delas é `P x fator`), por isso os multiplicadores de summon (`summonDamage`, `frenzy`, `blast`, `burst`) são aplicados pelos próprios scripts.

**Fist Fury foi removida do jogo** (`utito punho`, spellid 135): saiu do `spells.xml` e o script `support/fist fury.lua` foi apagado.

**Chuvas** (Skyfall, Meteor Storm e Hailstorm): a cadência é de 12 projéteis por segundo (o dobro da primeira versão, que tinha 6). Para o dano total não mudar, cada projétil causa metade do que causava (`share` em `Glyphs.spells`). Para mudar a cadência é só ajustar `drops` e `duration`.

**Funções novas da lib** (`403-glyphs.lua`): `Glyphs.allies(cid, raio)` (caster e party por perto), `Glyphs.haste(cid, ms)`, `Glyphs.statBuff(cid, {...})` (buff de atributos em `!buffs`), `Glyphs.healOverTime(cid, total, ticks, intervalo)`, `Glyphs.regen(cid, percent, ticks, intervalo)` e `Glyphs.cleanse(cid)`. SubIds de condition usados: 8801 Storm Rage, 8810 Gravel Armor, 8811 Verdant Ward, 8812 Primal Fury.

**As strikes do druid** (Flame, Energy, Terra, Ice e Death Strike) são as mesmas do sorcerer, mas os glifos delas são de vocação 1: o druid ainda não os usa.

## Sistema de empurrão
`Push.away(caster, alvo[, chance])`, `Push.creature(cid, direcao)` e `Push.direction(de, para)` em `data/lib/404-push.lua`, sobre a função nova `doCreaturePush(cid, direcao)` (`src/luascript.cpp`, **precisa recompilar**). O servidor recusa o empurrão (o alvo fica parado) quando o tile de destino:
- não existe ou não tem chão;
- é protection zone ou casa;
- muda de andar (escada, buraco, rampa) ou é teleporte;
- tem campo mágico (fogo, veneno...);
- está bloqueado (parede, item, outra criatura);

ou quando a criatura não pode se mover ou é um jogador com a flag `CannotBePushed`. Monstros com `pushable="0"` (bosses) são empurrados mesmo assim. A direção é a do caster para o alvo; se o alvo está bem mais longe em um eixo que no outro (ex.: 3 sqm a leste e 1 ao norte), o empurrão é só naquele eixo.

## Redução de resistência dos monstros
`Glyphs.reduceResistance(alvo, tipo_de_dano, pontos, ms)` e `Glyphs.restoreResistance(alvo, tipo_de_dano)` (`403-glyphs.lua`). É uma **condition de verdade**: um `CONDITION_ATTRIBUTES` com `CONDITION_PARAM_ABSORB_<ELEMENTO>` negativo, o mesmo parâmetro que as bênçãos dos deuses usam em jogadores ([39-deuses-e-estatuas.md](39-deuses-e-estatuas.md)).
- Cada elemento tem a sua condition (subId `8700 +` o parâmetro `CONDITION_PARAM_ABSORB_*`, ou seja, 8785 a 8792), então earth e death não se atrapalham. Aplicar de novo renova o tempo.
- Para monstros, o `ConditionAttributes` (`src/condition.cpp`, `updateMonsterBonus`) soma o valor no `bonusAbsorb` do monstro ao iniciar e subtrai ao terminar (expirou, foi removida ou o monstro morreu); `Monster::blockHit` lê esse valor junto da resistência do XML. Valor negativo = o monstro recebe mais dano (-10 em 0% de resistência = +10% de dano).
- Vale para todo dano daquele elemento recebido pelo monstro, de qualquer fonte. Só monstros: em jogadores um bônus negativo é ignorado (`Player::getBonusAbsorb` não passa de 0).
- O tempo é da própria condition, então pode ser removida com `doRemoveCondition(alvo, CONDITION_ATTRIBUTES, subId)`, e não existe mais `addEvent`.
- **Precisa recompilar** (`compilar.bat`).

Outras coisas do mesmo tipo (resistência, e futuramente outros bônus) entram no mesmo caminho: é só ampliar `ConditionAttributes::updateMonsterBonus` e o que o `Monster` lê. O `doMonsterSetElementMod` antigo continua existindo (usado pelo Bone Armor), é um valor separado que se soma ao da condition.

## NPCs dos glifos
- **Lysander Lightbinder** (`data/npc/Lysander Lightbinder.xml`, `data/npc/scripts/glyphmaster_paladin.lua`): o mestre do paladin, igual ao Thalion mas só com as magias de vocação 3. **Ainda não tem posição no mapa**: coloque-o no Remere's e em `data/world/Styller-spawn.xml`. O script é uma cópia do `glyphweaver.lua` com `MASTER_VOCATION = 3`; para outra vocação, copie de novo e mude esse número e os textos.

- **Sylvara Rootbinder** (`data/npc/Sylvara Rootbinder.xml`, `data/npc/scripts/glyphmaster_druid.lua`): a mestra do druid, cópia do Lysander com `MASTER_VOCATION = 2`. **Também ainda não tem posição no mapa**: coloque-a no Remere's e em `data/world/Styller-spawn.xml`.

- **Dorian Ironbinder** (`data/npc/Dorian Ironbinder.xml`, `data/npc/scripts/glyphmaster_knight.lua`): o mestre do knight, cópia da Sylvara com `MASTER_VOCATION = 4`. **Também ainda não tem posição no mapa**: coloque-o no Remere's e em `data/world/Styller-spawn.xml`.

- **Seraphine Dawnbinder** (`data/npc/Seraphine Dawnbinder.xml`, `data/npc/scripts/glyphmaster_cleric.lua`): a mestra do cleric, cópia do Dorian com `MASTER_VOCATION = 9`. **Também ainda não tem posição no mapa**: coloque-a no Remere's e em `data/world/Styller-spawn.xml`.

- **Morwen Gravebinder** (`data/npc/Morwen Gravebinder.xml`, `data/npc/scripts/glyphmaster_necromancer.lua`): a mestra do necromancer (e do Lich), cópia da Seraphine com `MASTER_VOCATION = 11` e textos próprios. **Também ainda não tem posição no mapa**: coloque-a no Remere's e em `data/world/Styller-spawn.xml`.

- **Vesper Shadowbinder** (`data/npc/Vesper Shadowbinder.xml`, `data/npc/scripts/glyphmaster_assassin.lua`): o mestre do assassin (e do Nightblade), cópia da Morwen com `MASTER_VOCATION = 13` e textos próprios. **Também ainda não tem posição no mapa**: coloque-o no Remere's e em `data/world/Styller-spawn.xml`.

- **Korgan Bloodbinder** (`data/npc/Korgan Bloodbinder.xml`, `data/npc/scripts/glyphmaster_berserker.lua`): o mestre do berserker (e do Warlord), cópia do Vesper com `MASTER_VOCATION = 15` e textos próprios. **Também ainda não tem posição no mapa**: coloque-o no Remere's e em `data/world/Styller-spawn.xml`.

- **Lyra Windbinder** (`data/npc/Lyra Windbinder.xml`, `data/npc/scripts/glyphmaster_archer.lua`): a mestra do archer (e do Ranger), cópia do Korgan com `MASTER_VOCATION = 17` e textos próprios. **Também ainda não tem posição no mapa**: coloque-a no Remere's e em `data/world/Styller-spawn.xml`.

## NPC: Thalion Glyphweaver
Mago que escreve os glifos de quem fala com ele (`data/npc/Thalion Glyphweaver.xml`, `data/npc/scripts/glyphweaver.lua`), na posição **84, 55, 6** (`data/world/Styller-spawn.xml`). Cadastrado também no Remere's (`E:\rme-build\data\860\creatures.xml` e `854\creatures.xml`, com backup `creatures.xml.bak_pre_glyphweaver`).
- Só ensina as magias de sorcerer (e atende a staff, para teste). Cada vocação tem o seu mestre (ver acima).
- Falas: `glyphs`/`basics` (explica o sistema), `points` (pontos livres, ganhos e gastos), `list` (magias, nível exigido e preço em pontos, com `[A]`/`[B]` na que já tem glifo), o nome de uma magia (descreve os dois glifos, preços e o que você tem), depois `A` ou `B` e `yes`/`no`. Também aceita `flame strike a` direto.
- Compra pelo `Glyphs.choose`: primeira vez em pontos, troca em ouro. As mensagens de erro e as falas estão em inglês e português (`!language`); os nomes dos glifos ficam em inglês e as descrições têm versão em português (`descriptionPt`), escolhida pelo idioma do jogador.
- O comando `!glyphs` continua existindo para consulta; a compra e a troca podem ser feitas por ele ou pelo NPC.
