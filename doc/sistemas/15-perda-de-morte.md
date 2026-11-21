# Perda de morte (100% em Lua)

## O que mudou
A source não calcula mais o que o jogador perde ao morrer (itens, experiência, skills, magic level, blessings, amuletos). Ela só dispara o evento `onDeathLoss` e o script `data/creaturescripts/scripts/deathloss.lua` decide tudo. O script já vem com a mesma regra de antes; para casos customs, basta editá-lo.

O que continua na source: criar o corpo, a regra de zona hardcore (morte sem custo), remover condições de morte e mandar o jogador para a tela de relogin.

## Evento
Registrado em `data/creaturescripts/creaturescripts.xml` e no `login.lua`:
```xml
<event type="deathloss" name="DeathLoss" event="script" value="deathloss.lua"/>
```
```lua
registerCreatureEvent(cid, "DeathLoss")
```
```lua
function onDeathLoss(cid, corpse, deathList)
```
| Parâmetro | Descrição |
|---|---|
| `cid` | Jogador que morreu |
| `corpse` | Corpo criado (`corpse.uid` é `nil` se não houve corpo, por exemplo em zona hardcore) |
| `deathList` | Quem matou: uid da criatura ou nome, igual ao `onDeath` |

Retorno:
- `true`: o jogador vai para a tela de relogin (morte normal).
- `false`: o jogador continua no jogo e a source não faz mais nada.

Sem nenhum evento registrado, nada é perdido e o jogador vai para o relogin. Vários eventos `deathloss` podem coexistir: basta um retornar `true` para o relogin acontecer.

O corpo já está no chão quando o evento roda, então é nele que os itens são colocados.

## Configuração (topo do `deathloss.lua`)
| Opção | Padrão | O que faz |
|---|---|---|
| `blessItemBase` | 30 | Redução de perda de itens/containers da 1ª blessing |
| `blessItemDecrement` | 5 | Quanto cada blessing seguinte reduz a menos |
| `blessSkillReduction` | 8 | % menos de perda de exp/magic/skills por blessing |
| `expLowLevel`, `expLowLevelDivider` | 25, 10 | Até esse level a perda é `exp * % / divisor` |
| `dropAllSkull` | `SKULL_WHITE` | Skull acima desta dropa todo o equipamento |
| `ignoreAmuletSkull` | `SKULL_RED` | Desta skull em diante, amuletos não protegem |
| `loseExperience`, `loseMagicLevel`, `loseSkills`, `loseItems`, `loseBlessings` | `true` | Liga/desliga cada perda |
| `usePreventLoss`, `usePreventDrop` | `true` | Respeita `preventLoss`/`preventDrop` do `items.xml` (gasta 1 carga por morte) |

As opções `blessings` e `blessingOnlyPremium` do `config.lua` continuam valendo. Saíram do `config.lua` (e da source): `blessingReductionBase`, `blessingReductionDecrement` e `eachBlessReduction`.

Os percentuais por jogador (`PLAYERLOSS_EXPERIENCE`, `MANA`, `SKILLS`, `CONTAINERS`, `ITEMS`) e `lessloss` da vocação continuam sendo lidos: `getPlayerLossPercent(cid, tipo)` e `getVocationInfo(id).lessLoss`.

## Funções Lua novas
| Função | Descrição |
|---|---|
| `doPlayerRemoveSkillPercent(cid, skill, percent)` | Remove `percent` (0-100) de tudo que o jogador acumulou na skill. `SKILL__MAGLEVEL` para magic level. |
| `doPlayerRemoveBlessing(cid[, blessing])` | Remove uma blessing (1-16) ou todas, sem o 2º argumento |
| `doMoveItemToContainer(uid, containerUid[, count])` | Move o item (mantendo atributos, raridade, encantos) para o container |
| `getExperienceForLevel(level)` | Experiência necessária para o level |
| `getVocationInfo(id).lessLoss` | `lessloss` da vocação |

Para tirar experiência, use `doPlayerAddExperience(cid, -valor)` (já existia).

## Exemplos
Não perder nada em PvP:
```lua
-- no começo de onDeathLoss
if type(deathList[1]) == "number" and isPlayer(deathList[1]) then
	doPlayerSetLossSkill(cid, true)
	return true
end
```
Perder só experiência (sem skills nem itens): em `config`, deixe `loseMagicLevel`, `loseSkills`, `loseItems` e `loseBlessings` como `false`.

Dropar sempre o item mais caro: dentro de `onDeathLoss`, use `getPlayerSlotItem` + `doMoveItemToContainer(item.uid, corpse.uid)`.

## Diferenças em relação à regra antiga
- Itens cujo equip event não está ativo (ex.: item de outra vocação) agora também contam para `preventLoss`/`preventDrop`.
- O amuleto consumido é o que protegeu. Antes, por um bug, a source removia o `preventDrop` mesmo quando quem salvou a exp era outro.
- A perda de itens/containers nunca fica negativa com várias blessings (antes podia dar underflow).
- Skills/magic level atualizam a barra de porcentagem na hora.
