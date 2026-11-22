# Live Custom Server (versão Lime)

Servidor baseado no The Forgotten Server (3777), já compilado para Windows x64.

## Rodar o servidor (Windows)

1. Baixe ou clone este repositório.
2. Copie o banco limpo para a raiz:
   ```
   copy schemas\theforgottenserver.s3db theforgottenserver.s3db
   ```
3. Copie a configuração de exemplo:
   ```
   copy config.lua.dist config.lua
   ```
4. Abra o `config.lua` e ajuste:
   ```lua
   sqlType = "sqlite"
   sqlFile = "theforgottenserver.s3db"
   ip = "127.0.0.1"   -- seu IP, se for jogar em rede
   ```
5. Execute `theforgottenserver.exe`.

As DLLs necessárias já estão na raiz. Não é preciso instalar nada.

## Funcionalidades customizadas

Sistemas adicionados sobre o TFS 3777 (✅ = já implementado). Cada um tem documentação própria em [`doc/sistemas/`](doc/sistemas/README.md); o histórico completo está em [`doc/ALTERACOES.md`](doc/ALTERACOES.md).

| | Sistema | Resumo | Comandos |
|---|---|---|---|
| ✅ | Velocidade de ataque + Dual Wield | Fist skill acelera o ataque; Knight e Elite Knight usam duas armas | `utito fast` |
| ✅ | Atributos extras | Dodge, crítico, leech, block count, penetração, on hit, cooldown reduction, amp elemental etc. | `!attributes` |
| ✅ | Regeneração por level | +50% de regen a cada 50 levels | |
| ✅ | Bestiary | Níveis por kills, com xp extra | `!bestiary`, `!trackbestiary` |
| ✅ | Monstros Epic | Spawns com vínculo elemental, mais vida, xp e loot | |
| ✅ | Spell Id, grupos e cooldowns | `doCreatureCastSpell` por nome de magia | `!exori` (teste) |
| ✅ | Summon teleport | Summons teleportam para o dono quando ficam longe | |
| ✅ | Autoloot | Itens da lista vão direto para o inventário; filtros por raridade, únicos e atributo, e lista de ignorados | `!autoloot` (`rarity`, `unique`, `attribute`, `ignore`, `filters`) |
| ✅ | Raridade de itens | Uncommon, Rare, Epic e Legendary com atributos aleatórios | `/rarity` (GM) |
| ✅ | Item sets | Bônus por peças equipadas | |
| ✅ | Itens únicos | Itens com nome e atributos próprios | `/unique` (GM) |
| ✅ | Encantamentos | Slots por raridade, aplicados com runas | |
| ✅ | Sistema de raças | 8 raças com outfits e bônus (Human com as outfits clássicas); NPC Race Master com cooldown de 24h entre trocas (`raceChangeCooldown`) | `!race` (GM) |
| ✅ | Perda de morte (Lua) | Itens, experiência, skills e blessings perdidos são decididos em `data/creaturescripts/scripts/deathloss.lua` | |
| ✅ | Fight mode (Lua) | `getPlayerFightMode(cid)` e callback de creaturescripts `onChangeFightMode(cid, oldMode, newMode)` | |
| ✅ | Contratos / Daily quests | Matar 50-100 de um monstro por nível, em experience ou gold; até 5 por categoria por dia, reset às 5h, progresso salvo no banco | `!daily` |
| ✅ | Criaturas premiadas | Sorteio a cada abertura do servidor: bônus de experiência e de loot em uma % dos monstros | `!rewarded` |
| ✅ | Prey | NPC Prey Master (133, 54, 5): bônus de xp, loot, dano ou defesa contra um monstro, weak/strong/ultimate, 2h; limpar é grátis | `!prey` |
| ✅ | Estátuas de ranking | Estátuas com o outfit e o nome do top 1 de cada ranking, em 150-154, 48-50, 6 | |
| ✅ | Tasks de caça | NPC Task Master (431, 351, 10): 25 tasks de matar criaturas, 1 por vez (pegar outra reinicia a atual), repetíveis; progresso em azul a cada kill; recompensa em ouro, experiência ou item; task points liberam tiers e ranks (7 tiers) | `!tasks` |
| ✅ | Mercado de creature products | NPC Yasir (79, 34, 7): compra 36 creature products (escamas, couros, asas etc.) | |
| ✅ | Níveis de guild | Membros doam ouro (NPC Guild Treasurer em 131, 54, 5 ou comando); o total doado define o nível (1 a 10) e dá bônus de atributos a todos os membros, após 24h na guild; ranking de doadores | `!guilddonate`, `!guildinfo` |
| ✅ | VFX (lib de efeitos) | Biblioteca `data/lib/360-vfx.lua` com 30 efeitos visuais (SkyFall, Rain, Lightning, Tornado, Meteor, Storm, Warning, Death, Buff etc.), sequências, perfis nomeados e elementos; só desenha, sem dano | `/vfx` (GM) |
| ✅ | Buffs | Buffs montados na hora com `addCreatureBuff` (porte do servidor antigo): categoria, stacks, duração em ms e callbacks `onActivate`/`onRemove`; da mesma categoria se sobrepõem; vale para players e monstros | `!buffs` |

## Vocações adicionais

Vocações novas, além das clássicas (Sorcerer, Druid, Paladin e Knight). Cada uma tem documentação própria em [`doc/sistemas/`](doc/sistemas/README.md).

| | Vocação | Id (promoção) | Resumo | Doc |
|---|---|---|---|---|
| ✅ | Cleric | 9 (Hierophant, 10) | O Hierophant ganha magias de área grande (chuva de holy, wave que reduz a resistência a holy, buffs de vida/mana e de dano holy para a party). Mago de holy: dano médio, curas e buffs leves, com magias que ferem inimigos e curam aliados ao mesmo tempo. Range média (4 SQM) e áreas médias. Inclui o Pillar of Light, magia de área em volta do inimigo que substitui as runas | [`24-cleric.md`](doc/sistemas/24-cleric.md) |
| ✅ | Necromancer | 11 (Lich, 12) | Mago invocador: levanta Skeleton, Ghoul, Banshee e Phantasm a partir de corpo + 6 soul (o soul vem da passiva Soul Harvest) e, com 4 ou mais summons, o Dragon Skeleton, que perde vida aos poucos. Ataques de death e poison (bolas, waves, chuva, tornado) e buffs que consomem summons. Começa com Summon Skeleton e Death Touch no nível 8. O Lich ganha Soul Siphon, Bone Abomination, Corpse Explosion e Army of the Dead | [`25-necromancer.md`](doc/sistemas/25-necromancer.md) |

### Informações importantes

- **Configuração:** as opções de cada sistema estão em `config.lua`. Mudanças nele exigem reiniciar o servidor.
- **Banco de dados:** o autoloot criou tabelas novas (`player_autoloot` e `player_autoloot_filters`, em `schemas/`). Um banco antigo é atualizado automaticamente ao iniciar, mas faça backup antes.
- **Penalidade de morte:** não existe mais na source. Edite `data/creaturescripts/scripts/deathloss.lua` (as opções `blessingReduction*` e `eachBlessReduction` saíram do `config.lua` e foram para o topo desse script).
- **Ids de storage reservados:** `52000` (bestiary tracking), `52200` e `52201` (raça e cooldown de troca), `52400` (lista de buffs ativos da criatura), `54000` a `54003` (tasks e task points) e `54100` e `54101` (guild e horário de entrada, bônus de guild). Evite usá-los em outros scripts.
- **Banco de dados (guild):** as tabelas `guild_levels` e `guild_donations` são criadas sozinhas pelo Lua na primeira vez que o servidor sobe, sem recompilar.
- **Monstros:** todos precisam do atributo `monsterId` no XML para entrar no bestiary.
- **Runas antigas:** as runas de ataque (Fire Field, Poison Bomb etc.) viraram itens de encantamento e não podem mais ser lançadas.
- **Comandos de GM** (`/rarity`, `/unique`, `!race`) exigem access 5.
- **Compilação:** o `theforgottenserver.exe` da raiz já inclui todos os sistemas; `compilar.bat` gera um novo.

### Conta de teste

O banco limpo traz uma conta padrão: login `1`, senha `1`.
Ela tem acesso total (god). **Troque ou apague antes de abrir o servidor para outras pessoas.**

### Banco do zero (opcional)

Para recriar o banco a partir do schema, com o `sqlite3` instalado:
```
sqlite3 theforgottenserver.s3db < schemas\sqlite.sql
```
Para MySQL, use `schemas\mysql.sql` e configure `sqlType = "mysql"` no `config.lua`.

## Compilar

Para compilar no Windows (MSYS2 UCRT64 + Ninja), edite o caminho `MSYS` em `compilar.bat` e execute:
```
compilar.bat
```
O exe novo é copiado para a raiz e o anterior é salvo como `.bak`.


---

## Useful links
### Binaries
- Windows x32: https://github.com/Fir3element/binaries/raw/master/x32-windows.zip
- Windows x64: https://github.com/Fir3element/binaries/raw/master/x64-windows.zip

### Source
- https://github.com/Fir3element/3777/archive/master.zip

## Libraries for Visual Studio 2022 (using vcpkg)

- x32:
```
.\vcpkg install luajit sqlite3 libmariadb libxml2 gmp boost-filesystem boost-regex boost-thread boost-asio boost-foreach boost-any openssl
```

- x64:
```
.\vcpkg install --triplet x64-windows luajit sqlite3 libmariadb libxml2 gmp boost-filesystem boost-regex boost-thread boost-asio
```

## Build instruction for Ubuntu

```
sudo apt-get update
```

```
sudo apt-get install --no-install-recommends -y git autoconf automake pkg-config build-essential cmake liblua5.1-0-dev libsqlite3-dev libmysqlclient-dev libxml2-dev libgmp3-dev libboost-filesystem-dev libboost-regex-dev libboost-thread-dev
```

```
git clone https://github.com/Fir3element/3777.git
```

```
cd /3777-master
```

```
mkdir build
```

```
cd build
```

```
cmake ..
```

```
make -j$(grep processor /proc/cpuinfo | wc -l)
```
