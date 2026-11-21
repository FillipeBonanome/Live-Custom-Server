# Sistema de raças

## O que faz
Cada jogador escolhe uma raça, que libera outfits próprias e dá um bônus de atributos. As outfits antigas são removidas ao trocar de raça. A raça fica em storage (`RACE_STORAGE = 52200`) e o bônus é reaplicado a cada login (`racelogin.lua`).

| Raça | Bônus |
|---|---|
| Human | +5% xp, +3% loot, +3% cooldown reduction |
| Orc | +100 vida, +3 melee, +10 crit damage |
| Dwarf | +3 armor, +3 defense, +1 block count, +50 vida |
| Undead | +3% life leech, +10% amp morte, +5% penetração morte |
| Elf | +5% dodge, +3 distance, +3% crit chance |
| Minotaur | +150 vida, +2 armor, +2 melee |
| Goblin | +10% loot, +3% dodge, +2% xp |
| Lizard | +10% amp terra, +5% penetração terra, +100 mana |

## Como trocar
- **NPC Race Master** (adicionado em `data/world/Styller-spawn.xml`): fale `races` ou o nome da raça e confirme com `yes`. É grátis e ilimitado.
- **`!race Orc`** (apenas access 5).

## Personalizar (`data/lib/200-races.lua`)
```lua
{name = "Orc", outfits = {2, 5, 6, 7, 8, 59},
    bonus = {[CONDITION_PARAM_STAT_MAXHEALTH] = 100, [CONDITION_PARAM_SKILL_MELEE] = 3}},
```
Os ids de `outfits` são os `looktype`s de `data/XML/outfits.xml`. As chaves de `bonus` são constantes `CONDITION_PARAM_*`. A outfit padrão é a Wisp (294).

API Lua: `doPlayerSetRace`, `getPlayerRace`, `getRaceByName`, `doPlayerApplyRaceBonus`.
