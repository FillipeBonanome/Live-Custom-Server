# Item sets

## O que faz
Equipar peças **diferentes** de um conjunto ativa bônus acumulativos. A descrição do item mostra `set: Nome (equipadas/total)`.

## Configuração (`data/XML/itemsets.xml`)
```xml
<set name="Crown Set">
    <item id="2491"/> <item id="2487"/> <item id="2488"/> <item id="2519"/>
    <bonus pieces="2">
        <attribute name="dodge" value="3"/>
        <attribute name="maxhealthpoints" value="50"/>
    </bonus>
    <bonus pieces="4">
        <attribute name="criticaldamage" value="10"/>
    </bonus>
</set>
```
- Um item só pode pertencer a um set.
- Bônus de menos peças continuam ativos (somam).
- Aceita qualquer atributo de `rarity_attributes.xml`, exceto `attack`, `defense` e `armor`.

## Exemplo
O Crown Set já configurado, completo (4 peças), soma: dodge 3+5, vida +50, crítico 3%, block count +1, crit damage +10 e life leech 2%.

## Sets do jogo (chances em % do XML; `rateLoot` 2.0 dobra na prática)
| Set | Peças | Onde cai (chance) |
|---|---|---|
| Crown | helmet, armor, legs, shield | renegade knight, vile grandmaster, hero |
| Lightning (51–89) | headband, robe, legs, boots | giant spider 0,4 headband · massive energy elemental 0,3 robe + 0,15 headband · lich 0,3 legs · war golem 0,3 boots |
| Terra (69–137) | hood, mantle, legs, boots | massive earth elemental 0,3 hood · behemoth 0,3 boots · defiler 0,25 legs · medusa 0,25 mantle + 0,1 legs · blightwalker 0,1 mantle/legs |
| Glacier (69–84) | mask, robe, kilt, shoes | frost dragon 0,3 mask + 0,25 robe · sea serpent 0,25 kilt + 0,3 shoes |
| Magma (78–81) | monocle, coat, legs, boots | massive fire elemental 0,25 coat · dawnfire asura 0,25 monocle + 0,15 coat · infernalist 0,25 legs + 0,25 boots |
| Knight (54–79) | knight armor, knight legs, warrior helmet, dragon shield | hydra 0,2 armor + 0,25 helmet · hellspawn 0,15 armor, 0,2 legs, 0,2 helmet · destroyer 0,2 shield · dragon 0,3 shield · giant spider 0,15 armor/legs · medusa 0,2 armor · undead dragon 0,15 armor |
| Amazon (61–77, 3 peças) | helmet, armor, shield | werewolf 0,3 helmet · wyrm 0,25 armor · draken warmaster 0,25 shield |
| Golden (123–208) | helmet, armor, legs, boots | undead elite gladiator 0,15 helmet · juggernaut 0,2 armor + 0,1 legs · undead dragon 0,15 armor · dark torturer 0,2 legs · demon 0,1 legs · grim reaper 0,15 boots |
| Demon (143–171) | helmet, armor, legs, shield | demon 0,15 helmet + 0,15 shield · hellhound 0,1 armor · crypt warrior 0,15 legs · skeleton elite warrior 0,15 legs |

As peças que já caíam com 1–30% em monstros do pool (knight armor na medusa, terra/magma/lightning etc.) foram reduzidas para essas chances.
