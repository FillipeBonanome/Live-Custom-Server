# Alterações do servidor

Resumo das customizações feitas sobre a base original (ver `git log` para o detalhe de cada commit).
Opções configuráveis ficam em `config.lua` / `config.lua.dist`.

## Combate e atributos
- **Velocidade de ataque pelo fist skill + Dual Wield** (reservado ao futuro Assassin; Knight e Elite Knight perderam o dual wield): bônus de velocidade ao usar duas armas (`dualWieldAttackSpeedBonus`, vocações com `canDualWield="1"`).
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
- **Buffs** (porte do sistema do servidor antigo 8.6): `data/lib/370-buffs.lua` com `addCreatureBuff(cid, buff)`, `removeCreatureBuff`, `getCreatureBuffs`, `getCreatureBuffStacks` etc. Cada buff é uma tabela montada na hora, com categoria, duração em ms, stacks (`stackable`/`maxStacks`) e os callbacks `onActivate` e `onRemove`; buffs da mesma categoria se sobrepõem. Funciona em players e monstros. A lista dos buffs ativos também fica num storage da criatura, porque cada tipo de script roda num estado Lua separado. Comando `!buffs`. Detalhes em `doc/sistemas/23-buffs.md`.
- **Daily login**: pilar (item 1514, action id 9800, em 165, 53, 7) que dá uma recompensa por dia, com streak (dias seguidos), ciclo de 7 dias e bônus por ciclo completo; aviso no login. Lib `data/lib/380-dailylogin.lua`, opções `dailyLogin*`. Textos animados do templo (`texto.lua`, `placa*.lua`) agora são todos amarelos, incluindo o novo "Daily Streak". Detalhes em `doc/sistemas/26-daily-login.md`.
- **Vocação Cleric** (id 9, promoção Hierophant id 10): mago de holy com 15 magias (dano, cura e buffs, entre elas o Pillar of Light, área em volta do inimigo), helpers em `data/lib/372-cleric.lua` e 4 buffs novos. O Hierophant ganhou Sacred Wave, Divine Tempest, Divine Vitality e Radiant Strikes (evento `HolyResistDown`). Passiva **Faith**: buff stackável (máx. 5, 8s), +3% de dano e cura holy por stack; o Sacred Wave usa o debuff `Holy Vulnerability`. Detalhes em `doc/sistemas/24-cleric.md`.
- **Vocação Berserker** (id 15, promoção Warlord id 16): só machados, arma de duas mãos com escudo (`canTwoHandShield`: `Player::canTwoHandShield` e as regras de mão em `Player::__queryAdd`), leech passivo (8%/10%), Fúria (+2 axe skill por magia, até 10 stacks), Rage (+0,4% de dano físico por 1% de vida perdida, máx. 30%), magias que custam vida (novos atributos `health` e `healthpercent` nas magias do `spells.xml`, em `src/spells.cpp`; ids 194 a 203 e 204 a 207 do Warlord), lib `data/lib/375-berserker.lua`, globalevent `berserker` e o evento `UndyingRage`. Todas as health potions liberadas. Detalhes em `doc/sistemas/28-berserker.md`.
- **Vocação Assassin** (id 13, promoção Nightblade id 14): única com dual wield (`canDualWield`), só espadas (`weapons.xml`), vida 9 e mana 18 por level, fist 1.1, sword 1.1 e demais skills 4.0, sem strong/great/ultimate health potion (só great spirit). Passiva **Momentum** (stacks de crítico e fist/velocidade), 12 magias (spell ids 178 a 187, 192 e 193, incluindo Backstab, só pelas costas, e Deathblow, só em alvo abaixo de 25%) e 4 exclusivas do Nightblade (188 a 191: Thousand Cuts, Death Mark, Phantom Clones, Night Veil), lib `data/lib/374-assassin.lua`, 16 perfis de VFX e o monstro Assassin Clone. Detalhes em `doc/sistemas/27-assassin.md`.
- **Vocação Necromancer** (id 11, promoção Lich id 12): 5 summons (Skeleton, Ghoul, Banshee, Phantasm e Dragon Skeleton, que perde vida por segundo), 8 ataques de death/poison, 4 buffs, Bone Mend e Recall (spell ids 155 a 173), passiva **Soul Harvest** (soul ao matar), lib `data/lib/373-necromancer.lua` e `RingAttack` portado. O Lich ganhou Soul Siphon, Summon Bone Abomination, Corpse Explosion e Army of the Dead (ids 174 a 177). Mudanças na source: dono e summons não se ferem mais com dano (área ou não), summons de players não tiram XP do dono (dano creditado ao dono), causam 50% do dano em PvP (`summonPvpDamagePercent`), podem entrar em PZ e usam a penetração do dono; nova função Lua `doMonsterSetElementMod`. Detalhes em `doc/sistemas/25-necromancer.md`.

## Arquivos relevantes
- Código C++: `src/` (novos: `rarity`, `itemsets`, `uniques`, `enchants`, `autoloot`).
- Dados: `data/XML/`, `data/talkactions/`, `data/creaturescripts/`, `data/npc/`.
- Banco: `schemas/` ganhou as tabelas do autoloot (`player_autoloot`, `player_autoloot_filters`) e a `player_daily_quests`.
- O executável `theforgottenserver.exe` é recompilado a cada feature.
