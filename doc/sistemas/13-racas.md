# Sistema de raças

## O que faz
Cada jogador escolhe uma raça, que libera outfits próprias e dá um bônus de atributos. A raça Human libera as outfits clássicas de player (Citizen, Hunter, Mage, Knight, Nobleman, Summoner, Warrior, Barbarian, Druid, Wizard, Nomad, Pirate, Assassin, Beggar, Shaman, Norseman, Nightmare, Jester, Brotherhood, Demonhunter, Yalaharian, Warmaster e Wayfarer), sem addons; as outfits da raça são reentregues a cada login. As outfits antigas são removidas ao trocar de raça. A raça fica em storage (`RACE_STORAGE = 52200`) e o bônus é reaplicado a cada login (`racelogin.lua`).

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
- **NPC Race Master** (adicionado em `data/world/Styller-spawn.xml`): fale `races` ou o nome da raça e confirme com `yes`. É grátis, mas tem **cooldown**: depois de cada troca o jogador espera `raceChangeCooldown` segundos (`config.lua`, padrão 86400 = 24h; 0 desativa) para trocar de novo. A primeira escolha de raça não tem cooldown. O NPC avisa o tempo restante (e o tempo de espera antes de confirmar a troca). O horário da última troca fica em `RACE_COOLDOWN_STORAGE = 52201`. O comando `!race` (GOD) ignora o cooldown.
- **`!race Orc`** (apenas access 5).

## Personalizar (`data/lib/200-races.lua`)
```lua
{name = "Orc", outfits = {2, 5, 6, 7, 8, 59},
    bonus = {[CONDITION_PARAM_STAT_MAXHEALTH] = 100, [CONDITION_PARAM_SKILL_MELEE] = 3}},
```
Os ids de `outfits` são os `looktype`s de `data/XML/outfits.xml`. As chaves de `bonus` são constantes `CONDITION_PARAM_*`. A outfit padrão é a Wisp (294).

API Lua: `doPlayerSetRace`, `getPlayerRace`, `getRaceByName`, `doPlayerApplyRaceBonus`.
