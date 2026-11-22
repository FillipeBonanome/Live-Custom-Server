# Alterações do servidor

Resumo das customizações feitas sobre a base original (ver `git log` para o detalhe de cada commit).
Opções configuráveis ficam em `config.lua` / `config.lua.dist`.

## Combate e atributos
- **Velocidade de ataque pelo fist skill + Dual Wield** (Knight): bônus de velocidade ao usar duas armas (`dualWieldAttackSpeedBonus`, vocações com `canDualWield="1"`).
- **Atributos de item/condição** (`data/lib/000-constant.lua`, `src/items.cpp`, `src/condition.cpp`): damage amp elemental, armor, defense, soul, cooldown reduction, leech (vida/mana), bônus de xp e loot, dodge, critical (chance, dano e cura), block count, penetração elemental e efeitos *on hit*.
- **Attack origin**: distinção da origem do ataque no cálculo de dano.
- **Comando `!attributes`**: mostra os atributos ativos do jogador.
- **Regeneração por level**: +50% de regen a cada `regenBonusLevels` (padrão 50) levels.

## Monstros
- **Bestiary**: níveis de conhecimento por kills (`bestiaryKillsPerLevel`), xp extra por nível e `!trackbestiary`.
- **Monstros Epic**: chance de nascer com vínculo elemental (Blazing, Frozen, Venomous, Storm, Radiant, Cursed, Tidal), mais vida, xp, dano elemental, resistência e loot extra (`epicMonster*`).
- **Spell Id** e **`castForce` por nome de spell** (Lua API).
- **Summon teleport**: summons de jogadores teleportam até o dono quando ficam longe (`summonTeleportDistance`, padrão 8).

## Itens
- **Autoloot** (`!autoloot`): lista por jogador salva no banco (`autoLootEnabled`, `autoLootMaxItems`). Filtros avançados: raridade mínima, itens únicos, atributo e lista de ignorados (`player_autoloot_filters`).
- **Raridade** (Uncommon, Rare, Epic, Legendary): drop com atributos aleatórios (`rarityChance*`; dados em `data/XML/rarities.xml`, `rarity_archetypes.xml`, `rarity_attributes.xml`).
- **Item sets**: bônus por conjunto (`data/XML/itemsets.xml`).
- **Uniques**: itens únicos (`data/XML/uniques.xml`, `!unique`); correção da animação de crítico.
- **Encantamentos**: slots por raridade aplicados via item/runa (`enchant*`, `data/XML/enchantments.xml`).

## Jogador
- **Sistema de raças**: Human, Orc, Dwarf, Undead, Elf, Minotaur, Goblin e Lizard, cada uma com outfits e bônus próprios (`data/lib/200-races.lua`), NPC *Race Master* e comando `!race` (god).

- **Fight mode na Lua**: `getPlayerFightMode(cid)` e callback `onChangeFightMode(cid, oldMode, newMode)` (evento `changefightmode` em `creaturescripts.xml`), disparada só quando o fight mode muda.

- **Perda de morte 100% em Lua**: a source não calcula mais perda de itens, experiência, skills nem blessings. O evento `deathloss` (`onDeathLoss(cid, corpse, deathList)`) chama `data/creaturescripts/scripts/deathloss.lua`, que replica o comportamento antigo e é todo configurável. Novas funções Lua: `doPlayerRemoveSkillPercent`, `doPlayerRemoveBlessing`, `doMoveItemToContainer`, `getExperienceForLevel` e o campo `lessLoss` em `getVocationInfo`. Saíram do `config.lua`: `blessingReductionBase`, `blessingReductionDecrement` e `eachBlessReduction`.
- **Contratos / Daily quests**: missões diárias de matar 50-100 de um monstro, em duas categorias (experience e gold), geradas pelo nível do jogador; ao completar uma nasce outra mais difícil (até 5 por categoria), reset às 5h, progresso salvo no banco (`player_daily_quests`) e comando `!daily`. Nova função Lua `getMonsterList()` e comandos staff `/dailymonsters` e `/dailyreset`. Opções `dailyQuest*` no `config.lua`.
- **Criaturas premiadas**: a cada abertura do servidor uma % dos monstros é sorteada para dar bônus de experiência e outra para bônus de loot (sem repetir na mesma categoria). Lista enviada no login e comando `!rewarded`. Novas funções Lua `setRewardedMonsters` e `getRewardedMonsters`; opções `rewardedMonsters*` no `config.lua`.
- **Prey**: o NPC Prey Master (133, 54, 5) vende um bônus temporário (2h, `preyDuration`) contra um monstro: experiência, loot, dano ou defesa, em força weak/strong/ultimate (`prey*` no `config.lua`). Limpar o prey é grátis. Salvo na tabela `player_prey` (db versão 31); comando `!prey`; funções Lua `doPlayerSetPrey`, `doPlayerClearPrey`, `getPlayerPrey`.
- **Estátuas de ranking**: top 1 de level, magic e de cada skill vira uma estátua (monstro `Rank Statue`, invulnerável) com o outfit e o nome do jogador, atualizada na abertura e a cada 10 min. Nova função Lua `doCreateNamedMonster`; lib `data/lib/330-rankstatues.lua`.
- **VFX (lib de efeitos visuais)**: `data/lib/360-vfx.lua` com a tabela global `VFX`: 30 efeitos feitos de distance shoots e magic effects (SkyFall, Rain, Fountain, Spiral, Circle, Explosion, Implosion, Beam, Orbit, Lightning, Tornado, Helix, Burst, Barrage, Comet, Snow, Wave, Line, Pulse, Cross, Star, Ring, Meteor, Summon, LevelUp, Teleport, Warning, Death, Storm, Buff), handles canceláveis (`VFX.stop`), `VFX.Sequence`, perfis (`VFX.register`/`VFX.play`) e elementos. Comando de teste `/vfx` (acesso 4). Detalhes em `doc/sistemas/22-vfx.md`.
- **Buffs**: `data/lib/370-buffs.lua` (tabela global `Buffs`) e `371-buffs-list.lua` (buffs cadastrados). Cada buff tem id, duração, categoria, descrição e os eventos `onActivate`, `onExpire` e `onRemove`; buffs da mesma categoria se sobrepõem. Terminam no logout e na morte. Comando `!buffs`. Detalhes em `doc/sistemas/23-buffs.md`.
- **Vocação Cleric** (id 9, promoção Hierophant id 10): mago de holy com 15 magias (dano, cura e buffs, entre elas o Pillar of Light, área em volta do inimigo), helpers em `data/lib/372-cleric.lua` e 4 buffs novos. Detalhes em `doc/sistemas/24-cleric.md`.

## Arquivos relevantes
- Código C++: `src/` (novos: `rarity`, `itemsets`, `uniques`, `enchants`, `autoloot`).
- Dados: `data/XML/`, `data/talkactions/`, `data/creaturescripts/`, `data/npc/`.
- Banco: `schemas/` ganhou as tabelas do autoloot (`player_autoloot`, `player_autoloot_filters`) e a `player_daily_quests`.
- O executável `theforgottenserver.exe` é recompilado a cada feature.
