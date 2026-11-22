# Velocidade de ataque e Dual Wield

## O que faz
- **Fist skill acelera o ataque:** a velocidade de ataque de qualquer jogador é dividida por `1 + fist / fistSkillToDoubleAttackSpeed`. Com o valor 100, fist 100 = ataque 2x mais rápido; fist 50 = 1,5x. Conta o skill total (inclui buffs/itens).
- **Dual wield:** vocações com `canDualWield="1"` podem equipar duas armas de mão única (espada, clava, machado), uma em cada mão. As armas se alternam (esquerda, depois direita), o dano base é a média das duas, e o ataque ganha `dualWieldAttackSpeedBonus`% de velocidade. Armas de duas mãos, distância, varinhas e escudos não entram.

## Configuração (`config.lua`)
```lua
fistSkillToDoubleAttackSpeed = 100  -- 0 desativa
dualWieldAttackSpeedBonus = 35      -- % de bônus ao usar duas armas
```
Dual wield por vocação: atributo `canDualWield="1"` em `data/XML/vocations.xml`. Nenhuma vocação tem hoje: o Knight e o Elite Knight perderam, e o recurso fica reservado ao Assassin.

## Magia de teste
`utito fast` (Fast Attack): +100 de fist por 33 s (`data/spells/scripts/support/fast attack.lua`), dobrando a velocidade com a config padrão.

## Exemplo
Vocação com dual wield, fist 20 e duas espadas, ataque base 2000 ms: `2000 / 1,35 / (1 + 20/100)` ≈ 1235 ms. O valor aparece em `!attributes` (Attack Speed).
