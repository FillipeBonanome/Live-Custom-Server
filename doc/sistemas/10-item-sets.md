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
