# Glifos de magia

## O que faz
Cada magia de ataque do **sorcerer** e do **paladin** tem dois glifos (**A** e **B**). O jogador escolhe **um** para alterar a magia. O primeiro glifo de cada magia é comprado com **pontos de bestiário**; trocar para o outro custa **só ouro** (caro).

Cada magia pertence a uma vocação (`vocation` em `Glyphs.spells`: 1 sorcerer, que é o padrão; 3 paladin). O orçamento `glyphBudgetPercent` é calculado por vocação (as 13 magias do sorcerer, as 5 do paladin).

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
- **Nunca reordene** `Glyphs.spells` (a posição define o storage); acrescente no fim.

## Arquivos
- `src/bestiary.cpp/.h`, `src/monsters.cpp/.h`, `src/configmanager.cpp/.h`, `src/luascript.cpp/.h`: pontos do bestiário. **Precisa recompilar** (`compilar.bat`).
- Lua: `getPlayerBestiaryPoints(cid)` e `getBestiaryTotalPoints()`.
- `data/lib/403-glyphs.lua`: magias, preços, compra/troca (`Glyphs.choose`), textos.
- `data/talkactions/scripts/glyphs.lua`: o comando `!glyphs`.
- `data/lib/402-spell-balance.lua`: aplica o multiplicador do glifo.

## Testes (staff, access 4)
`/glyph points <n>` soma pontos de bestiário para gastar (negativo tira), `/glyph give <magia> a|b` coloca o glifo de graça (ignora nível e pontos), `/glyph remove <magia>`, `/glyph reset` (zera glifos, pontos gastos e bônus). Só afeta quem digita. Os pontos de teste ficam no storage `glyphStorageBase + 60`. Depois de editar `403-glyphs.lua` (lib) reinicie o servidor ou use `/reload libs`; para os scripts de talkaction, `/reload talkactions`.

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
| Hells Core | B (Meteor Storm, provisório) | no lugar da explosão, 24 meteoros caem em tiles aleatórios em volta do sorcerer (raio 5) ao longo de 4s; cada um atinge uma cruz de 5 sqm com 75% do dano da fórmula |
| Rage of the Skies | A (Skyfall, provisório) | no lugar da explosão, 30 raios caem em tiles aleatórios em volta do sorcerer (raio 6) ao longo de 5s; cada um atinge uma cruz de 5 sqm com 80% do dano da fórmula |
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

**Magias novas do paladin** (`data/spells/spells.xml`, spellid 237 e 238): **Divine Grenade** (`exevo tempo mas san`, nível 82, 160 mana, 20s, alcance 7: a granada explode 2s depois no local do alvo, área 3x3 sagrada) e **Strong Ethereal Spear** (`exori gran con`, nível 90, 55 mana, 8s, alcance 7, cerca do dobro do dano da Ethereal Spear). As fórmulas de dano são nossas; ajuste no script de cada uma.

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

## NPC: Thalion Glyphweaver
Mago que escreve os glifos de quem fala com ele (`data/npc/Thalion Glyphweaver.xml`, `data/npc/scripts/glyphweaver.lua`), na posição **84, 55, 6** (`data/world/Styller-spawn.xml`). Cadastrado também no Remere's (`E:\rme-build\data\860\creatures.xml` e `854\creatures.xml`, com backup `creatures.xml.bak_pre_glyphweaver`).
- Só ensina as magias de sorcerer (e atende a staff, para teste). Cada vocação tem o seu mestre (ver acima).
- Falas: `glyphs`/`basics` (explica o sistema), `points` (pontos livres, ganhos e gastos), `list` (magias, nível exigido e preço em pontos, com `[A]`/`[B]` na que já tem glifo), o nome de uma magia (descreve os dois glifos, preços e o que você tem), depois `A` ou `B` e `yes`/`no`. Também aceita `flame strike a` direto.
- Compra pelo `Glyphs.choose`: primeira vez em pontos, troca em ouro. As mensagens de erro e as falas estão em inglês e português (`!language`); os nomes dos glifos ficam em inglês e as descrições têm versão em português (`descriptionPt`), escolhida pelo idioma do jogador.
- O comando `!glyphs` continua existindo para consulta; a compra e a troca podem ser feitas por ele ou pelo NPC.
