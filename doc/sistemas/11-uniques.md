# Itens únicos

## O que faz
Cria uma versão especial de um item existente, com nome, descrição, atributos de base e bônus próprios. Pode dropar naturalmente de monstros específicos.

## Configuração (`data/XML/uniques.xml`)
```xml
<unique name="Blade of Embers" id="2376" article="the" attack="42" defense="18"
        chance="0.5" monsters="Dragon,Dragon Lord" description="A sword forged in dragon fire.">
    <attribute name="onhitelementalfire" value="10"/>
    <attribute name="criticalchance" value="5"/>
    <attribute name="skillsword" value="3"/>
</unique>
```
- `id`: item base (não pode ser empilhável nem container).
- `attack`, `defense`, `armor`, `extraattack`, `extradefense`, `attackspeed`, `hitchance`, `shootrange`: substituem os valores do item original.
- `chance`: % de um item `id` dropado por `monsters` virar este unique. `monsters` vazio = qualquer monstro. Sem `chance` (o exemplo do arquivo usa `0`), o unique só existe por script ou comando.
- Pode ter raridade (copiada ao item quando vira unique) e ganha slots extras de encantamento (`enchantSlotsUnique`).

## Teste / Lua
```
/unique Blade of Embers      (access 5)
```
`doItemSetUnique(uid, nome)`, `getItemUnique(uid)`, `getUniqueItemId(nome)`.
