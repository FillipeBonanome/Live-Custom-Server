# Encantamentos

## O que faz
Itens com raridade (ou unique) têm slots de encantamento. Um encantamento é aplicado **usando o item-encantamento** sobre o equipamento. Aqui são usadas as antigas runas, que não podem mais ser lançadas. O uso consome uma unidade do item e o encantamento vira permanente. A descrição mostra os encantamentos e os slots livres.

## Slots (`config.lua`)
```lua
enchantEnabled = true
enchantSlotsNone = 0       -- sem raridade
enchantSlotsUncommon = 1
enchantSlotsRare = 2
enchantSlotsEpic = 3
enchantSlotsLegendary = 4
enchantSlotsUnique = 2     -- somado aos slots do unique
```

## Definição (`data/XML/enchantments.xml`)
```xml
<enchantment name="Flaming" item="2301" types="sword,club,axe,distance,wand">
    <attribute name="onhitelementalfire" value="3"/>
</enchantment>
```
- `item`: id do item que aplica (um encantamento por id).
- `types`: `all`, `weapon`, `sword`, `club`, `axe`, `distance`, `shield`, `fist`, `wand`, `head`, `armor`, `legs`, `feet`, `necklace`, `ring`, `ammo`, `backpack`.
- `effect` (opcional): efeito mostrado no jogador ao encantar.
- `attack`, `defense` e `armor` somam ao item; os demais valem enquanto equipado.

## Exemplo
Jogador com uma espada Rare (2 slots) usa uma Fire Field rune (id 2301) nela. A espada fica "Flaming" (+3 on hit de fogo) e sobra 1 slot. Por script: `doItemEnchant(uid, "Flaming")`.
