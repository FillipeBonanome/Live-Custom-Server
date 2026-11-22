# Buffs

Sistema de buffs portado do servidor antigo 8.6 (`data/lib/060-buffs.lua`, que por sua vez veio do WoL Canary): o buff é uma tabela montada na hora e entregue com `addCreatureBuff(cid, buff)`, com categoria, stacks e callbacks.

## Como funciona
- A lib `data/lib/370-buffs.lua` define as funções globais abaixo. O buff é uma tabela criada dentro da própria magia (ou script), com os callbacks que quiser.
- **Categoria**: só existe 1 buff ativo por categoria. Dar outro da mesma categoria remove o anterior (rodando o `onRemove` dele) e ativa o novo. Sem categoria, usa `"Primary"`.
- **Stacks**: com `stackable = true`, cada `addCreatureBuff` na mesma categoria soma 1 stack (até `maxStacks`) e renova a duração. Sem `stackable`, o buff sempre tem 1 stack.
- **Duração em milissegundos** (padrão 15000). Quando acaba, o buff é removido e roda o `onRemove`.
- O buff **não aplica nada sozinho**: o efeito (normalmente uma `CONDITION_ATTRIBUTES` com o mesmo tempo) é criado no `onActivate` e desfeito no `onRemove`, como nas magias do servidor antigo. `attributes` é só um campo livre, somado por `calculateCreatureBuffsAttributes`.
- Funciona também em monstros (debuffs).
- Comando `!buffs`: lista os buffs ativos (nome, stacks, tempo restante e descrição).

### Por que existe uma lista em storage
Cada tipo de script (magias, talkactions, creaturescripts) roda num estado Lua separado, e uma tabela Lua comum (`CreatureBuffs`) não é vista por outros estados. Por isso os callbacks e o timer ficam no estado de quem deu o buff, e a lista dos buffs ativos (categoria, nome, tempo, stacks, descrição) também é escrita num storage da criatura (`52400`), que todos os estados enxergam. As funções de consulta (`getCreatureBuffs`, `getCreatureBuffByCategory`, `getCreatureBuffStacks`, `hasCreatureBuff`) leem esse storage, e é por isso que o `!buffs` e o evento `HolyResistDown` enxergam buffs dados por magias.

Limites:
- Um buff removido ou substituído a partir de **outro** estado Lua que o criou não roda o `onRemove` dele (as conditions criadas com duração terminam sozinhas).
- Os players perdem os buffs no logout, na morte e no login (`clearCreatureBuffs`, sem rodar os callbacks).
- `calculateCreatureBuffsAttributes` só soma os buffs dados pelo mesmo estado Lua.

## Criar um buff
```lua
local DURATION = 10000
local SUB_ID = 8306

function onCastSpell(cid, var)
	return addCreatureBuff(cid, {
		name = "Fist Fury",           -- nome no !buffs (padrão: a categoria)
		category = "Fist Fury",       -- só 1 por categoria
		duration = DURATION,          -- milissegundos
		description = "+20 fist fighting.",
		-- stackable = true, maxStacks = 5,
		onActivate = function(id, stacks)
			local condition = createConditionObject(CONDITION_ATTRIBUTES, DURATION, true, SUB_ID)
			setConditionParam(condition, CONDITION_PARAM_SKILL_FIST, 20)
			doAddCondition(id, condition)
		end,
		onRemove = function(id)
			if(isCreature(id)) then
				doRemoveCondition(id, CONDITION_ATTRIBUTES, SUB_ID)
			end
		end
	})
end
```
Use um `SUB_ID` próprio para cada buff, senão as conditions se substituem. Os sub ids usados: 8306 (Fist Fury), 8310 a 8315 e 8320 (Cleric) — ver abaixo.

## Funções
| Função | O que faz |
|---|---|
| `addCreatureBuff(cid, buff)` | Dá o buff. `false` se `cid` não é uma criatura |
| `removeCreatureBuff(cid, categoria)` | Remove o buff da categoria (roda o `onRemove`) |
| `clearCreatureBuffs(cid)` | Remove todos os buffs da criatura |
| `getCreatureBuffs(cid)` | Tabela `categoria -> info`, ou `false` se não há buffs |
| `getCreatureBuffByCategory(cid, categoria)` | Info do buff, ou `false` |
| `getCreatureBuffStacks(cid, categoria)` | Stacks (0 se não há buff na categoria) |
| `hasCreatureBuff(cid, categoria)` | `true` se há buff ativo na categoria |
| `calculateCreatureBuffsAttributes(cid [, base])` | Soma os `attributes` (vezes os stacks) |

`info` = `{category, name, description, duration (s), expires (os.time), timeLeft (s), stacks}`.

## Buffs do servidor
| Categoria | Duração | Onde | Efeito |
|---|---|---|---|
| Fist Fury | 10s | `support/fist fury.lua` (`utito punho`, todas as vocações) | +20 fist fighting. Mensagens ao ativar e ao acabar |
| Holy Fury, Divine Grace, Wall of Light | 15s, 15s, 10s | `Cleric.addBuff` | Buffs do Cleric (ver [24-cleric.md](24-cleric.md)) |
| Shield of Faith | 6s | `support/shield of faith.lua` | +8 armor e +6 defense; cura ao acabar |
| Divine Vitality, Radiant Strikes | 2 min, 1 min | `Cleric.addBuff` | Buffs do Hierophant |
| Faith | 8s | `Cleric.faith` | Passiva do Cleric, **stackável** (até 5): +3% de dano e cura holy por stack |
| Holy Vulnerability | 8s | `attack/sacred wave.lua` | Debuff em monstros atingidos pelo Sacred Wave: -10% de resistência a holy |
| Bone Armor, Unholy Frenzy | 20s | `Necro.addBuff` | Buffs do Necromancer nos summons (ver [25-necromancer.md](25-necromancer.md)) |
| Soul Sacrifice, Bone Shell, Venom Corrosion | 15s, 15s, 10s | `Necro.addBuff` | Buffs do Necromancer: dano death/poison, armor/defense e penetração de poison |

Os buffs genéricos que existiam antes (blessings, exp boost, loot boost, Iron Skin) eram só exemplos e não eram usados por nenhuma magia, então foram removidos. Para recriá-los, use `addCreatureBuff` como no exemplo acima.
