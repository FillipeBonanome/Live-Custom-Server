# Buffs

## Como funciona
- A lib `data/lib/370-buffs.lua` define a tabela global `Buffs`. Cada buff é registrado uma vez com `Buffs.register` (os buffs do servidor ficam em `data/lib/371-buffs-list.lua`) e aplicado com `Buffs.add(cid, id)`.
- **Categoria**: só existe 1 buff ativo por categoria. Aplicar outro da mesma categoria (ou o mesmo buff de novo) remove o anterior (`onRemove` com `reason = "replace"`) e ativa o novo.
- Os buffs ficam só na memória: terminam (rodando `onRemove`) quando o jogador sai do jogo ou morre.
- Comando `!buffs`: lista os buffs ativos (nome, categoria, tempo restante e descrição).

## Registrar um buff
```lua
Buffs.register{
	id = "haste",                  -- id único (texto)
	name = "Haste",                -- nome mostrado no !buffs (padrão: o id)
	category = "speed",            -- buffs da mesma categoria se sobrepõem (padrão: o próprio id)
	duration = 60,                 -- duração padrão em segundos
	description = "Anda mais rápido.",
	onActivate = function(cid, buff) end,
	onExpire = function(cid, buff) end,
	onRemove = function(cid, buff, reason) end
}
```

## Eventos
| Evento | Quando roda |
|---|---|
| `onActivate(cid, buff)` | O buff começa (também ao renovar ou substituir outro) |
| `onExpire(cid, buff)` | Só quando o tempo acaba; roda antes do `onRemove` |
| `onRemove(cid, buff, reason)` | Sempre que o buff termina, por qualquer motivo: é o lugar de desfazer o que o `onActivate` fez |

`reason`: `"expire"` (tempo acabou), `"remove"` (`Buffs.remove`), `"replace"` (renovado ou substituído), `"logout"`, `"death"`.
`buff` é uma tabela com `id`, `name`, `category`, `description`, `duration`, `expires` (`os.time()`) e `definition`. Erros dentro dos eventos são capturados e aparecem no console como `[Error - Buffs]`.

## Funções
| Função | O que faz |
|---|---|
| `Buffs.add(cid, id [, segundos])` | Aplica o buff (duração opcional). `false` se o id não existe |
| `Buffs.remove(cid, idOuCategoria [, reason])` | Remove o buff ativo |
| `Buffs.removeAll(cid [, reason])` | Remove todos |
| `Buffs.has(cid, id)` / `Buffs.getTimeLeft(cid, id)` | Consulta |
| `Buffs.get(cid, idOuCategoria)` / `Buffs.getAll(cid)` | Dados dos buffs ativos (com `timeLeft`) |

## Buffs cadastrados
| Id | Categoria | Duração | Efeito |
|---|---|---|---|
| `blessing_vitality` | blessing | 30 min | +300 vida máxima |
| `blessing_wisdom` | blessing | 30 min | +300 mana máxima |
| `exp_boost` | experience | 1 h | +10% experiência |
| `loot_boost` | loot | 1 h | +10% loot |
| `iron_skin` | defense | 10 min | +3 armor e +2 defense |
| `fist_fury` | fist | 10 s | +20 fist fighting. Lançado pela magia `utito punho` (30 de mana, todas as vocações). Ao ativar manda mensagem azul; ao acabar mostra `CONST_ME_POFF` e avisa que terminou |

As duas blessings são da mesma categoria, então só uma fica ativa por vez.
