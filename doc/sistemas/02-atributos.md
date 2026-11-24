# Atributos de combate e `!attributes`

## O que faz
Adiciona atributos extras a itens, condições (buffs) e ao jogador. Eles são lidos de `items.xml`, de raridade, sets, uniques e encantamentos, e também podem ser aplicados por condições em scripts.

| Grupo | Atributos |
|---|---|
| Defesa | `bonusarmor`, `bonusarmorpercent`, `bonusdefense`, `bonusdefensepercent`, `blockcount`, `dodge`, `soulamount` |
| Ofensivos | `criticalchance`, `criticaldamage`, `criticalhealing`, `elementalamplification<elemento>` (ou `all`), `elementalpenetration<elemento>`, `onhitelemental<elemento>` |
| Recursos | `lifeleech`, `manaleech`, `maxhealthpoints`, `maxmanapoints`, `magiclevelpoints`, `speed` |
| Economia | `bonusexperience`, `bonusloot`, `cooldownreduction` |
| Skills | `skillfist`, `skillclub`, `skillsword`, `skillaxe`, `skilldist`, `skillshield`, `skillfish` |

Elementos: physical, energy, earth, fire, ice, holy, death, drown.

**Resistência elemental por condition:** `CONDITION_PARAM_ABSORB_<ELEMENTO>` (ex.: `CONDITION_PARAM_ABSORB_FIRE`, valores 85 a 92) dá `+X%` de resistência ao elemento enquanto a `CONDITION_ATTRIBUTES` durar. É somada ao absorb dos itens, do outfit e da vocação em `Player::blockHit` (o dano elemental recebido cai X%) e aparece em `getPlayerElementalResistance` e no `!attributes`. Em Lua o valor do jogador é `getPlayerBonus(cid, PLAYER_BONUS_ABSORB_<ELEMENTO>)`. Exemplo: `setConditionParam(condition, CONDITION_PARAM_ABSORB_FIRE, 15)`.
Críticos têm animação própria, e cada ataque registra sua *origem* (arma, magia etc.) para o cálculo de on hit, leech e crítico.

## Uso em `items.xml`
```xml
<item id="2376" name="sword">
    <attribute key="dodge" value="5"/>
    <attribute key="criticalchance" value="3"/>
    <attribute key="onhitelementalfire" value="10"/>
</item>
```

## Uso em Lua (buff por condição)
```lua
local condition = createConditionObject(CONDITION_ATTRIBUTES)
setConditionParam(condition, CONDITION_PARAM_TICKS, 60000)
setConditionParam(condition, CONDITION_PARAM_ELEMENTAL_AMP_PHYSICAL, 500) -- +500% dano físico
setConditionParam(condition, CONDITION_PARAM_BUFF, true)
```
Exemplo completo: `data/spells/scripts/support/amp test.lua`. As constantes `CONDITION_PARAM_*` estão em `data/lib/000-constant.lua`.

## Comando `!attributes`
Abre uma janela com status, combate, skills, bônus, amplificação, penetração, on hit e resistência elemental do jogador. Para scripts: `getPlayerBonus(cid, PLAYER_BONUS_*)`, `getPlayerCriticalChance`, `getPlayerElementalAmplification`, `getPlayerAttackSpeed`.
