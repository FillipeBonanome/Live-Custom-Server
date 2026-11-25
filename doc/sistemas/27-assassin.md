# Vocação Assassin (e promoção Nightblade)

## O que é
Duelista de espadas gêmeas: frágil, rápido e com muito dano em rajada. Ganha pelo **Momentum** (passiva), por esquiva, leech e pelas magias de finalização, não por aguentar dano. É a única vocação com **dual wield**.

| Id | Nome | Premium | Promoção de |
|---|---|---|---|
| 13 | Assassin | não | |
| 14 | Nightblade | sim | Assassin (`fromvoc="13"`); também usa todas as magias do Assassin |

Definidas em `data/XML/vocations.xml`. `isAssassin(cid)` em `data/lib/031-vocations.lua` vale para as duas.

## Atributos
| | Assassin | Nightblade | Knight (comparação) |
|---|---|---|---|
| Vida por level | 9 | 9 | 15 |
| Mana por level | 18 | 18 | 5 |
| Cap por level | 18 | 18 | 25 |
| Regen de vida / mana | 4 / 5 | 7 / 9 | 6 / 2 |
| Mana multiplier | 2.0 | 2.0 | 3.0 |
| Fórmula de defesa e armor | 0.8 | 0.8 | 1.0 |
| Soul máximo | 100 | 200 | |
| Perda na morte | normal | -30% | |

Skills (multiplicador, quanto maior mais lento treinar): **sword 1.1, fist 1.1**, club 4.0, axe 4.0, distance 4.0, shielding 4.0. A velocidade de ataque vem do **fist skill**, como nas outras vocações (`doc/sistemas/01-velocidade-ataque-dual-wield.md`), então o Assassin treina fist à mão se quiser atacar mais rápido.

## Restrições
- **Dual wield:** `canDualWield="1"` só no Assassin e no Nightblade. O Knight e o Elite Knight perderam. Aceita duas espadas de uma mão, uma em cada mão.
- **Só espadas:** em `data/weapons/weapons.xml`, as espadas que já tinham lista de vocações ganharam `<vocation id="13"/>` (o 14 entra pela promoção). Clavas, machados e armas de distância sem lista agora têm uma lista com as outras vocações, então o Assassin não consegue usá-las (equipa, mas não causa dano). Varinhas e rods já eram restritas. Munição não foi alterada.
- **Potions:** não pode usar **strong health, great health nem ultimate health** nem strong/great mana. Pode usar small health, health, mana e a **great spirit potion** (`data/actions/scripts/liquids/potions.lua`, que agora lista paladinos e assassinos).

## Fórmulas
- **Poder do Assassin:** `P = sword skill + ataque da espada` (média das duas espadas no dual wield). Todo dano é `nível/5 + P × fator`. Em sword 80 com espada de ataque 40, P = 120.
- **Veneno** (Venom Edge): `nível/20 + P/20` por segundo, 8s.
- **Sangramento** (Bleeding Cut): `P × 0.08 + nível/20` por segundo, 6s, dobrado com 3 ou mais stacks. Não existe condition de sangramento na source, então é um timer em Lua.
- Os números ficam em `data/lib/374-assassin.lua` e no topo de cada script em `data/spells/scripts/assassin/`.

## Passiva: Momentum
Cada magia ofensiva do Assassin dá **1 stack** (máx. 5, 6s, renovado a cada magia). Cada stack dá **+2% de crítico** e **+2 de fist** (que acelera o ataque). Blade Dance, Execute e Thousand Cuts **gastam** os stacks para causar mais dano; o Bleeding Cut lê os stacks (dobra o sangramento com 3 ou mais) sem gastá-los. O Momentum aparece em `!buffs`. Só magias dão stack, o ataque básico não.

## Magias do Assassin (ids 178 a 187, 192 e 193)
Todas com `needlearn="0"`, sem premium. As de corpo a corpo exigem uma espada equipada (`needweapon`).

| Magia | Palavras | Lvl | Mana | Cd | Efeito |
|---|---|---|---|---|---|
| Quick Slash | `exori lam` | 8 | 10 | 1s | Corte rápido em 1 alvo adjacente, P × 0.7 a 1.1. +1 Momentum |
| Shadow Step | `exani umbra` | 12 | 30 | 6s | Teleporta para trás do alvo (alcance 5, precisa de linha livre), olha para ele e ganha +25% de dodge por 1,5s. +1 Momentum |
| Twin Fang | `exori duo` | 16 | 40 | 2s | Dois cortes seguidos (0,3s) em 1 alvo, P × 0.55 a 0.9 cada, +25% com duas espadas. +1 Momentum |
| Venom Edge | `exori toxi` | 20 | 35 | 4s | Corte de veneno, P × 0.5 a 0.8, envenena por 8s e dá o buff Venom Blade (+12% do dano dos ataques básicos como poison, 8s). +1 Momentum |
| Bleeding Cut | `exori cruor` | 25 | 45 | 8s | Corte, P × 0.5 a 0.8, e sangramento por 6s. +1 Momentum |
| Smoke Bomb | `exevo mas fumo` | 30 | 60 | 15s | Fumaça em raio 2, P × 0.4 a 0.7, e invisibilidade por 3s. +1 Momentum |
| Blade Dance | `exori mas lam` | 35 | 70 | 6s | Gira e acerta tudo em volta (3x3), P × 0.7 a 1.2, **+15% por stack gasto** |
| Bloodthirst | `utito cruor` | 40 | 80 | 30s | Buff de 12s: +12% life leech e +5% de crítico. É a principal cura do Assassin |
| Execute | `exori gran lam` | 46 | 120 | 10s | Finalização em 1 alvo adjacente, P × 1.6 a 2.4 (a faca cai 0,4s depois da conjuração), **×1,75 se o alvo estiver com menos de 30% de vida**, +20% por stack gasto |
| Vanish | `utana umbra` | 54 | 150 | 45s | Invisível por 5s; 4s de críticos garantidos. +1 Momentum |
| Backstab | `exori tergum` | 28 | 90 | 8s | Corte pesado, P × 2.6 a 3.6, **só funciona se você estiver nas costas do alvo** (o alvo precisa estar olhando para longe de você). Fora das costas dá erro e não gasta mana nem cooldown. O Shadow Step vira o alvo para longe e libera o Backstab por 3s. +1 Momentum |
| Deathblow | `exori finis` | 50 | 130 | 12s | Corte enorme, P × 4.5 a 6.0, **só funciona em alvo com menos de 25% de vida**. Gasta os stacks: +20% por stack |

## Magias do Nightblade (ids 188 a 191)
Todas premium e exclusivas da vocação 14.

| Magia | Palavras | Lvl | Mana | Cd | Efeito |
|---|---|---|---|---|---|
| Thousand Cuts | `exori gran mas lam` | 58 | 300 | 40s | 8 cortes em 2,4s em 1 alvo a até 2 SQM, P × 0.35 a 0.55 cada, +10% por stack gasto |
| Death Mark | `exori mort sig` | 62 | 280 | 30s | Marca o alvo (alcance 4) por 6s; ao fim detona em death 3x3, P × 2.0 a 3.0, na última posição do alvo, mesmo que ele tenha morrido |
| Phantom Clones | `exevo res umbra` | 66 | 400 | 60s | 2 clones com o seu outfit, mesma velocidade, vida `150 + 3 × nível`, lutam por 12s e causam P × 0.5 a 0.8 (monstro "Assassin Clone", id 458). Não ocupam slot de summon |
| Night Veil | `utamo umbra` | 70 | 200 | 60s | Buff de 12s: +25% de dodge, +6 armor e +4 defense |

## Glifos
As 16 magias (Assassin e Nightblade) têm 2 glifos cada, de tipos diferentes, com o NPC mestre **Vesper Shadowbinder** (ainda sem posição no mapa). A tabela completa está em [42-glifos.md](42-glifos.md). Os scripts leem o glifo com `Assassin.glyph(cid, "nome da magia")`; o dano das magias do assassin não passa pelo `SpellBalance`, então os multiplicadores são aplicados pelos próprios scripts.

## VFX
Paleta preta/roxa (sombra), vermelha (sangue) e verde (veneno), com efeitos curtos. Perfis registrados com `VFX.register` em `data/lib/374-assassin.lua`: `assassin_slash`, `assassin_step`, `assassin_twin`, `assassin_poison`, `assassin_blood`, `assassin_smoke`, `assassin_dance`, `assassin_bloodthirst`, `assassin_execute`, `assassin_vanish`, `assassin_cuts`, `assassin_mark`, `assassin_mark_blast`, `assassin_clone` e `assassin_veil`. Dá para testá-los com `/vfx <perfil>`; os que usam origem e destino recebem `from` pelas magias. As chamadas passam por `Assassin.fx`, que nunca interrompe uma magia se uma opção estiver errada.

## Buffs
Sub ids `8400` a `8405` (Momentum, Shadow Dodge, Venom Blade, Bloodthirst, Vanish, Night Veil), `8406` (Assassin's Prey, glifo do Backstab) e `8407` (Veil of Reflection, glifo do Night Veil). Todos usam `addCreatureBuff` e aparecem em `!buffs`.

## Arquivos
| Arquivo | Função |
|---|---|
| `data/lib/374-assassin.lua` | Tabela `Assassin`: poder, dano, Momentum, buffs (inclusive as versões dos glifos), veneno, sangramento, clones e VFX |
| `data/spells/scripts/assassin/` | Uma magia por arquivo; `summon/clone slash.lua` é o ataque do clone |
| `data/lib/403-glyphs.lua`, `data/npc/Vesper Shadowbinder.xml`, `data/npc/scripts/glyphmaster_assassin.lua` | Glifos das 16 magias e o NPC mestre |
| `data/monster/Assassin Summons/assassin clone.xml` | Clone (registrado em `monsters.xml`) |
| `data/XML/vocations.xml`, `data/spells/spells.xml` | Vocações 13 e 14 e as magias 178 a 191 |
| `data/weapons/weapons.xml` | Restrição a espadas |
| `data/actions/scripts/liquids/potions.lua` | Restrição das potions |

## Observações
- As magias ficam disponíveis pelo nível (sem `needlearn`), do nível 8 em diante.
- A promoção para Nightblade usa os NPCs de promoção que já existem (`StdModule.promotePlayer` troca para a vocação promovida, definida por `fromvoc="13"`).
- Nada deste sistema precisa recompilar: reinicie o servidor (vocações, armas e magias são lidas na inicialização).
