# Raridade de itens

## O que faz
Armas e armaduras dropadas por monstros podem ganhar raridade, o que dá atributos aleatórios (estilo Diablo). A raridade aparece na descrição, e o corpo mostra efeito e texto colorido quando o item cai.

| Raridade | Atributos | Multiplicador |
|---|---|---|
| Uncommon | 1 | x1.0 |
| Rare | 2 | x1.5 |
| Epic | 3 | x2.0 |
| Legendary | 4 | x3.0 |

Valor final do atributo = `round(base * multiplicador)`, mínimo 1.

## Arquivos
- `data/XML/rarities.xml`: nome, multiplicador, nº de atributos, efeito e cor.
- `data/XML/rarity_archetypes.xml`: quais itens podem ter raridade (por `weapontype`/`slottype`) e quais atributos cada tipo sorteia. Vale o primeiro arquétipo que combinar.
- `data/XML/rarity_attributes.xml`: valor base de cada atributo.

## Configuração (`config.lua`)
```lua
rarityEnabled = true
rarityChanceUncommon = 10    -- % por item elegível
rarityChanceRare = 4
rarityChanceEpic = 1
rarityChanceLegendary = 0.25 -- aceita decimais
```
As chances são exclusivas e sorteadas da mais rara para a mais comum.

## Teste / Lua
```
/rarity magic sword, legendary     (access 5)
/rarity 2400, epic
```
`doItemSetRarity(uid, "Epic")`, `getItemRarity(uid)`. Nomes de raridade que não estão no XML só podem ser dados por script.

### Exemplo: novo arquétipo
```xml
<archetype name="boots" slottype="feet">
    <attribute name="speed"/>
    <attribute name="dodge"/>
    <attribute name="maxhealthpoints" base="30"/>
</archetype>
```
