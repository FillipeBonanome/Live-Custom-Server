# Bestiary

## O que faz
Conta as kills de cada monstro por jogador e libera níveis de conhecimento. Cada nível concluído dá xp extra ao matar aquele monstro.

## Comandos
- `!bestiary` explica o sistema.
- `!bestiary rotworm` mostra o progresso e o que o jogador já sabe do monstro.
- `!trackbestiary on/off` mostra o progresso a cada kill, ex.: `Rotworm [766/1000]`. A escolha fica salva em storage (`bestiaryTrackStorage`).

## Configuração (`config.lua`)
```lua
bestiaryKillsPerLevel = "10, 100, 500, 1000"  -- kills para cada nível
bestiaryExperiencePerLevel = 2                -- % de xp extra por nível concluído
bestiaryTrackStorage = 52000
```
Com os padrões, são 4 níveis: 100 kills de um Rotworm = nível 2 = +4% de xp nele.

## Por monstro
Todo monstro precisa do atributo `monsterId` no XML (já adicionado aos existentes). Para mudar as kills de um monstro:
```xml
<monster monsterId="44" name="Bones" bestiaryKills="5, 25, 100" ...>
```

## Lua
`doPlayerSendBestiary`, `getPlayerBestiaryKills`, `getPlayerBestiaryTracking`, `doPlayerSetBestiaryTracking`, `getMonsterBestiaryId`.
