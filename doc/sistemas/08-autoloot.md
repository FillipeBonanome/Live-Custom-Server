# Autoloot

## O que faz
Itens que estão na lista do jogador são movidos direto do corpo do monstro morto para o inventário dele. A lista fica salva no banco (tabela de autoloot em `schemas/`).

## Comandos
```
!autoloot add gold coin     (por nome ou id)
!autoloot add 2148
!autoloot remove gold coin
!autoloot list
!autoloot clear
```
`!autoloot` sem parâmetros mostra a ajuda.

## Configuração
```lua
autoLootEnabled = true
autoLootMaxItems = 200   -- itens por jogador
```
Um banco já existente é atualizado automaticamente na inicialização (`databasemanager.cpp`). API Lua: `doPlayerAutoloot(cid, param)`.

## Filtros avançados
Além da lista de itens, cada jogador pode ligar filtros. Item que bate em **qualquer** filtro é pego, mesmo fora da lista, a menos que esteja na lista de ignorados (que tem prioridade sobre tudo).
```
!autoloot rarity epic            (epic ou melhor; "off" desliga)
!autoloot unique on              (todo item único)
!autoloot attribute add dodge    (itens que rolaram esse atributo de raridade)
!autoloot attribute remove dodge
!autoloot ignore add magic sword (nunca pega esse item)
!autoloot ignore remove magic sword
!autoloot filters                (mostra os filtros)
!autoloot filters clear          (reseta todos)
```
- A ordem das raridades vem do multiplicador em `rarities.xml`; "ou melhor" significa multiplicador igual ou maior.
- Atributos válidos são os de `rarity_attributes.xml`. Máximo de 20 filtros de atributo; a lista de ignorados usa `autoLootMaxItems`.
- `!autoloot list` também mostra os filtros.
- Salvos na tabela `player_autoloot_filters` (`type` = rarity/unique/attribute/ignore). O banco sobe para a versão 29 sozinho na inicialização.
