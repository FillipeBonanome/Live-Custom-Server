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
- **Autoloot** (`!autoloot`): lista por jogador salva no banco (`autoLootEnabled`, `autoLootMaxItems`).
- **Raridade** (Uncommon, Rare, Epic, Legendary): drop com atributos aleatórios (`rarityChance*`; dados em `data/XML/rarities.xml`, `rarity_archetypes.xml`, `rarity_attributes.xml`).
- **Item sets**: bônus por conjunto (`data/XML/itemsets.xml`).
- **Uniques**: itens únicos (`data/XML/uniques.xml`, `!unique`); correção da animação de crítico.
- **Encantamentos**: slots por raridade aplicados via item/runa (`enchant*`, `data/XML/enchantments.xml`).

## Jogador
- **Sistema de raças**: Human, Orc, Dwarf, Undead, Elf, Minotaur, Goblin e Lizard, cada uma com outfits e bônus próprios (`data/lib/200-races.lua`), NPC *Race Master* e comando `!race` (god).

- **Fight mode na Lua**: `getPlayerFightMode(cid)` e callback `onChangeFightMode(cid, oldMode, newMode)` (evento `changefightmode` em `creaturescripts.xml`), disparada só quando o fight mode muda.

## Arquivos relevantes
- Código C++: `src/` (novos: `rarity`, `itemsets`, `uniques`, `enchants`, `autoloot`).
- Dados: `data/XML/`, `data/talkactions/`, `data/creaturescripts/`, `data/npc/`.
- Banco: `schemas/` ganhou tabelas do autoloot.
- O executável `theforgottenserver.exe` é recompilado a cada feature.
