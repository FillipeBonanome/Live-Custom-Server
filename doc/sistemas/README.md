# Documentação por sistema

| Arquivo | Sistema |
|---|---|
| [01-velocidade-ataque-dual-wield.md](01-velocidade-ataque-dual-wield.md) | Velocidade de ataque por fist skill e dual wield |
| [02-atributos.md](02-atributos.md) | Atributos de item/condição e `!attributes` |
| [03-regeneracao.md](03-regeneracao.md) | Regeneração por level |
| [04-bestiary.md](04-bestiary.md) | Bestiary |
| [05-monstros-epic.md](05-monstros-epic.md) | Monstros Epic |
| [06-spell-id-castforce.md](06-spell-id-castforce.md) | Spell Id, grupos/cooldowns e `doCreatureCastSpell` |
| [07-summon-teleport.md](07-summon-teleport.md) | Summon teleport |
| [08-autoloot.md](08-autoloot.md) | Autoloot |
| [09-raridade.md](09-raridade.md) | Raridade de itens |
| [10-item-sets.md](10-item-sets.md) | Item sets |
| [11-uniques.md](11-uniques.md) | Itens únicos |
| [12-encantamentos.md](12-encantamentos.md) | Encantamentos |
| [13-racas.md](13-racas.md) | Sistema de raças |
| [14-fight-mode.md](14-fight-mode.md) | `getPlayerFightMode` e callback `onChangeFightMode` |
| [15-perda-de-morte.md](15-perda-de-morte.md) | Perda de itens, experiência e skills na morte (Lua) |
| [16-daily-quests.md](16-daily-quests.md) | Contratos / Daily quests (`!daily`) |
| [17-criaturas-premiadas.md](17-criaturas-premiadas.md) | Criaturas premiadas (bônus de experiência e loot) |
| [18-prey.md](18-prey.md) | Prey (bônus temporário contra um monstro, via NPC) |
| [19-estatuas-ranking.md](19-estatuas-ranking.md) | Estátuas dos melhores jogadores de cada ranking |
| [20-tasks.md](20-tasks.md) | Tasks de matar criaturas dadas por NPC (1 por vez, progresso em azul) |
| [21-guild-levels.md](21-guild-levels.md) | Níveis de guild por doação de ouro, com bônus de atributos para os membros |
| [22-vfx.md](22-vfx.md) | Biblioteca de efeitos visuais (`VFX`): SkyFall, Rain, Lightning, Meteor, Storm etc. e o comando `/vfx` |
| [23-buffs.md](23-buffs.md) | Sistema de buffs com categorias, duração e eventos (`onActivate`, `onExpire`, `onRemove`), comando `!buffs` |
| [24-cleric.md](24-cleric.md) | Vocação Cleric (e promoção Hierophant): magias de holy com dano, cura e buffs |
| [25-necromancer.md](25-necromancer.md) | Vocação Necromancer (Lich reservado): invocações a partir de corpo e soul, magias de death e poison |
| [26-daily-login.md](26-daily-login.md) | Daily login: pilar com recompensa diária e streak |
| [27-assassin.md](27-assassin.md) | Vocação Assassin (e promoção Nightblade): dual wield, só espadas, Momentum e magias de rajada |
| [28-berserker.md](28-berserker.md) | Vocação Berserker (e promoção Warlord): armas de duas mãos com escudo, magias que custam vida, leech, Fúria e Rage |
| [29-cooldowns-classes-antigas.md](29-cooldowns-classes-antigas.md) | Cooldowns individuais das magias fortes de Sorcerer, Druid, Paladin e Knight |
| [30-mass-challenge.md](30-mass-challenge.md) | Taunt em área do Elite Knight que mantém os monstros com range 1 |
| [31-nivel-dos-monstros.md](31-nivel-dos-monstros.md) | Level dos monstros calculado pela vida e pelo dano (média e burst) dos ataques |
| [32-planejamento-hunts.md](32-planejamento-hunts.md) | Proposta de hunts por nível dos monstros, incluindo os portados |
| [33-monstros-canary.md](33-monstros-canary.md) | Comparação com os monstros do Canary e port do grupo A (`Ported Monsters`) |

Configurações globais ficam em `config.lua` (modelo em `config.lua.dist`). Mudanças em `config.lua` e no C++ exigem reiniciar/recompilar o servidor; XMLs e scripts Lua podem ser recarregados com os comandos de reload quando disponíveis.
