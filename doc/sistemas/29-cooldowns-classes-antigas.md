# Cooldowns das classes antigas

## O que mudou
As magias das classes antigas (Sorcerer, Druid, Paladin e Knight) tinham todas `cooldown` igual ao `groupcooldown` (2 s nas de ataque, 1 s nas de suporte e cura), então só a mana limitava o uso das mais fortes. Agora as magias de maior impacto têm **cooldown individual**, como as vocações novas. O `groupcooldown` e a mana **não mudaram**, e o dano também não.

Só o atributo `cooldown` de cada magia em `data/spells/spells.xml` foi alterado. Os ataques básicos (Strikes, Ethereal Spear, Divine Missile) e as curas e buffs de uso contínuo continuam como estavam.

## Valores
| Magia | Vocações | Antes | Agora |
|---|---|---|---|
| Fire Wave, Ice Wave | Sorcerer / Druid | 2 s | 4 s |
| Energy Beam | Sorcerer | 2 s | 4 s |
| Great Energy Beam, Energy Wave | Sorcerer | 2 s | 8 s |
| Terra Wave | Druid | 2 s | 8 s |
| Rage of the Skies | Sorcerer | 2 s | 20 s |
| Wrath of Nature | Druid | 2 s | 20 s |
| Hells Core | Sorcerer | 2 s | 40 s |
| Eternal Winter | Druid | 2 s | 40 s |
| Whirlwind Throw | Knight | 2 s | 6 s |
| Berserk | Knight | 2 s | 6 s |
| Groundshaker | Knight | 2 s | 8 s |
| Fierce Berserk | Knight | 2 s | 12 s |
| Divine Caldera | Paladin | 2 s | 8 s |
| Divine Healing | Paladin | 1 s | 6 s |
| Mass Healing | Druid | 1 s | 6 s |
| Charge | Knight | 1 s | 15 s |
| Blood Rage, Protector | Knight | 1 s | 30 s |
| Sharpshooter, Swift Foot | Paladin | 1 s | 30 s |

Os buffs de combate (Blood Rage, Protector, Sharpshooter, Swift Foot) duram 10 s e o Charge 5 s, então o cooldown é de 3 vezes a duração. As promoções usam as mesmas magias e herdam os mesmos cooldowns.

## Como ajustar
Edite o atributo `cooldown` (em milissegundos) da magia em `data/spells/spells.xml` e reinicie o servidor ou recarregue as magias.
