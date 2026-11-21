# Spell Id, grupos/cooldowns e `doCreatureCastSpell`

## Spell Id e cooldowns
Cada magia/runa em `data/spells/spells.xml` ganhou:
- `spellid`: id numérico único.
- `group`: `healing`, `attack`, `support` ou `special` (obrigatório quando há `spellid`, senão o servidor avisa no console).
- `cooldown`: recarga da própria magia (ms). Sem ele, usa o antigo `exhaustion`.
- `groupcooldown`: recarga compartilhada por todas as magias do mesmo grupo (ms).

```xml
<rune name="Poison Field" spellid="1" group="attack" cooldown="2000" groupcooldown="2000" id="2285" .../>
```
Existem as condições `CONDITION_SPELLCOOLDOWN` e `CONDITION_SPELLGROUPCOOLDOWN` e as constantes `SPELLGROUP_*`.

## `doCreatureCastSpell(cid, nomeDaMagia [, force = false])`
Faz uma criatura lançar uma magia instantânea pelo **nome** (ou pelas palavras).
- `force = true`: lança sem checar mana, nível, cooldown etc. (`castForce`).
- `force = false`: jogadores seguem as regras normais; monstros atacam o alvo atual.
Retorna `true` se lançou.

### Exemplo
`!exori` lança uma magia aleatória de knight (`data/talkactions/scripts/randomexori.lua`):
```lua
local spells = {"Berserk", "Fierce Berserk", "Groundshaker"}
function onSay(cid, words, param, channel)
	doCreatureCastSpell(cid, spells[math.random(#spells)], true)
	return true
end
```
