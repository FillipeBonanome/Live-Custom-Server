# Fight mode (Lua API e callback)

Permite ler o fight mode do jogador em Lua e reagir quando ele troca de modo.

## Constantes

Definidas em `data/lib/000-constant.lua`:

| Constante | Valor | Modo |
|---|---|---|
| `FIGHTMODE_ATTACK` | 0 | Offensive |
| `FIGHTMODE_BALANCED` | 1 | Balanced |
| `FIGHTMODE_DEFENSE` | 2 | Defensive |

## Função Lua

```lua
getPlayerFightMode(cid)
```

Retorna o fight mode atual (0, 1 ou 2). Se o jogador não existir, gera erro de Lua e retorna `false`.

Já existia `getPlayerModes(cid)`, que devolve uma tabela com `fight`, `chase` e `secure`. O novo getter é um atalho para ler só o fight mode.

```lua
if getPlayerFightMode(cid) == FIGHTMODE_DEFENSE then
	-- jogador está em modo defensivo
end
```

## Callback `onChangeFightMode`

```lua
function onChangeFightMode(cid, oldMode, newMode)
```

| Parâmetro | Descrição |
|---|---|
| `cid` | Jogador que trocou de modo |
| `oldMode` | Fight mode anterior (`FIGHTMODE_*`) |
| `newMode` | Novo fight mode (`FIGHTMODE_*`) |

Regras:
- Dispara só quando o fight mode muda. Trocar apenas o chase mode ou o secure mode não chama a callback.
- É apenas informativa: o retorno é ignorado, pois o cliente já aplicou a mudança.
- O jogador já está com o novo modo quando a callback roda, então `getPlayerFightMode(cid)` devolve `newMode`.

### Registro

Em `data/creaturescripts/creaturescripts.xml`:

```xml
<event type="changefightmode" name="FightModeChange" script="fightmode.lua"/>
```

No login do jogador (por exemplo em `login.lua`):

```lua
registerCreatureEvent(cid, "FightModeChange")
```

### Exemplo

`data/creaturescripts/scripts/fightmode.lua`:

```lua
function onChangeFightMode(cid, oldMode, newMode)
	if newMode == FIGHTMODE_DEFENSE then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Modo defensivo ativado.")
	end
	return true
end
```

## Arquivos

- `src/creatureevent.cpp`/`.h`: tipo `CREATURE_EVENT_CHANGE_FIGHTMODE` e `executeChangeFightMode`.
- `src/game.cpp`: disparo em `Game::playerSetFightModes`.
- `src/luascript.cpp`/`.h`: `getPlayerFightMode`.
