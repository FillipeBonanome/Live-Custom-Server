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
