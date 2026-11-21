# Summon teleport

## O que faz
Summons de jogadores teleportam para perto do dono quando se afastam demais, em vez de ficarem para trás. Vale quando a distância (maior diferença em x ou y) passa do limite, ou quando dono e summon estão em andares diferentes.

## Configuração
```lua
summonTeleportDistance = 8  -- sqm; 0 desativa
maxPlayerSummons = 2
```

## Exemplo
Druid com um summon sobe uma escada: o summon aparece ao lado do dono em vez de ficar parado no andar de baixo.
