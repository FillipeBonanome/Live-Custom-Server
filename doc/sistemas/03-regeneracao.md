# Regeneração por level

## O que faz
A cada `regenBonusLevels` levels, a regeneração base de vida e mana do jogador aumenta 50% (cumulativo): `bônus = 1 + 0,5 * floor(level / regenBonusLevels)`. Continua sem regenerar em zona de proteção, como antes.

## Configuração
```lua
regenBonusLevels = 50  -- 0 desativa
```

## Exemplo
Vocação que ganha 250 de vida por tick:
- level 49: 250
- level 50: 375 (+50%)
- level 100: 500 (+100%)
