# Prey

## Como funciona
- O **Prey Master** (NPC na posição 133, 54, 5) vende um bônus temporário contra **um monstro**. O jogador escolhe:
  1. o **monstro** (qualquer um que entra nos contratos das daily quests: hostil, atacável e com experiência);
  2. o **tipo** do bônus;
  3. a **força**: `weak`, `strong` ou `ultimate`.
- Só existe um prey ativo por jogador. Para trocar de monstro ou de bônus, diga `clear` ao NPC (**grátis**) e compre outro.
- A duração padrão é **2 horas** (`preyDuration = 7200`), em tempo real (continua passando com o jogador offline). O prey é salvo na tabela `player_prey` e reaplicado no login; se expirou, é apagado e o jogador é avisado.

## Tipos de bônus
| Tipo | Efeito (contra o monstro escolhido) |
|---|---|
| `experience` | +% de experiência ao matar (soma-se multiplicando ao bestiary e às criaturas premiadas) |
| `loot` | +% no bônus de loot do corpo (mesma conta de `BONUS_LOOT` e das criaturas premiadas) |
| `damage` | +% de dano causado pelo jogador ao monstro (ataques e magias; vem antes do crítico) |
| `defense` | -% de dano que o monstro causa ao jogador (máximo 100%) |

## Forças (`config.lua`)
| Força | Bônus (padrão) | Preço (padrão) |
|---|---|---|
| weak | `preyWeakBonus` = 10% | `preyWeakPrice` = 50000 |
| strong | `preyStrongBonus` = 25% | `preyStrongPrice` = 150000 |
| ultimate | `preyUltimateBonus` = 50% | `preyUltimatePrice` = 500000 |

Também: `preyEnabled` (liga/desliga) e `preyDuration` (segundos).

## Conversa com o NPC
`hi` -> `prey` -> nome do monstro -> `experience`/`loot`/`damage`/`defense` -> `weak`/`strong`/`ultimate` -> `yes`.
Em qualquer ponto: `cancel`. Outros comandos: `status` (tipo, bônus e tempo restante) e `clear` (remove o prey de graça).

## Comandos
- `!prey`: mostra o prey ativo e o tempo restante.

## Para scripts
- C++: `doPlayerSetPrey(cid, monsterName, type, bonusPercent, expireTimestamp)`, `doPlayerClearPrey(cid)` e `getPlayerPrey(cid)` (`{monster, type, bonus, expire}` ou `false`). Esses só mexem na memória do jogador; a persistência é da lib.
- Lua (`data/lib/320-prey.lua`): `Prey.set(cid, monster, type, strength)`, `Prey.clear(cid)`, `Prey.get(cid)`, `Prey.load(cid)`, `Prey.describe(prey)`.
- Aplicação no source: `Player::getPreyBonus` (`player.h`), usado em `Creature::onAttackedCreatureKilled` (xp), `MonsterType::dropLoot` (loot) e `Game::combatBlockHit` (dano e defesa).

## Arquivos
`data/npc/Prey Master.xml`, `data/npc/scripts/prey.lua`, `data/lib/320-prey.lua`, `data/creaturescripts/scripts/preylogin.lua` (login), `data/talkactions/scripts/prey.lua`, spawn em `data/world/Styller-spawn.xml`. Banco: tabela `player_prey` (versão 31, criada automaticamente em bancos antigos).
