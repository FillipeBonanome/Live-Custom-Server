# Live Custom Server (versão Cyan)

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
| ✅ | Velocidade de ataque + Dual Wield | Fist skill acelera o ataque; vocações com `canDualWield="1"` usam duas armas (nenhuma por enquanto, reservado ao futuro Assassin) | - |
| ✅ | Atributos extras | Dodge, crítico, leech, block count, penetração, on hit, cooldown reduction, amp elemental etc. | `!attributes` |
| ✅ | Regeneração por level | +50% de regen a cada 50 levels | |
| ✅ | Bestiary | Níveis por kills, com xp extra. Cada nível concluído também dá **pontos de bestiário** (base por nível e multiplicador pela experiência do monstro, ou `bestiaryPoints` no XML), contados a partir das kills e gastos nos glifos de magia | `!bestiary`, `!trackbestiary` |
| ✅ | Monstros Epic | Spawns com vínculo elemental, mais vida, xp e loot | |
| ✅ | Spell Id, grupos e cooldowns | `doCreatureCastSpell` por nome de magia | `!exori` (teste) |
| ✅ | Summon teleport | Summons teleportam para o dono quando ficam longe | |
| ✅ | Autoloot | Itens da lista vão direto para o inventário; filtros por raridade, únicos e atributo, e lista de ignorados | `!autoloot` (`rarity`, `unique`, `attribute`, `ignore`, `filters`) |
| ✅ | Raridade de itens | Uncommon, Rare, Epic e Legendary com atributos aleatórios | `/rarity` (GM) |
| ✅ | Item sets | Bônus por peças equipadas | |
| ✅ | Itens únicos | Itens com nome e atributos próprios | `/unique` (GM) |
| ✅ | Encantamentos | Slots por raridade, aplicados com runas | |
| ✅ | Runecarving | Runas de encantamento não são mais vendidas nem dropadas: só a blank rune é vendida por NPC. O runesmith **Durnok Runebrand** (145, 54, 7) entalha a runa (blank rune + ouro + gemas do elemento); 4 tiers pela raridade do encantamento (Uncommon a Legendary). Os tiers acima do primeiro são liberados por **respeito**, ganho entregando creature products e itens de boss em 12 missões; ele explica cada runa antes de entalhar | |
| ✅ | Sistema de raças | 8 raças com outfits e bônus (Human com as outfits clássicas); NPC Magister Cassian Vael (erudito, outfit yalahari) mostra um text dialog com a história, os bônus e as outfits da raça antes de confirmar; cooldown entre trocas em `raceChangeCooldown` (hoje 0 = sem limite) | `!race` (GM) |
| ✅ | Perda de morte (Lua) | Itens, experiência, skills e blessings perdidos são decididos em `data/creaturescripts/scripts/deathloss.lua` | |
| ✅ | Fight mode (Lua) | `getPlayerFightMode(cid)` e callback de creaturescripts `onChangeFightMode(cid, oldMode, newMode)` | |
| ✅ | Contratos / Daily quests | Matar 50-100 de um monstro por nível, em experience ou gold; até 5 por categoria por dia, reset às 5h, progresso salvo no banco | `!daily` |
| ✅ | Criaturas premiadas | Sorteio a cada abertura do servidor: bônus de experiência e de loot em uma % dos monstros | `!rewarded` |
| ✅ | Prey | NPC Huntmaster Kael (133, 54, 5): bônus de xp, loot, dano ou defesa contra um monstro, weak/strong/ultimate, 2h; limpar é grátis | `!prey` |
| ✅ | Estátuas de ranking | Estátuas com o outfit e o nome do top 1 de cada ranking, em 150-154, 48-50, 6 | |
| ✅ | Tasks de caça | NPC Task Master (431, 351, 10): 25 tasks de matar criaturas, 1 por vez (pegar outra reinicia a atual), repetíveis; progresso em azul a cada kill; recompensa em ouro, experiência ou item; task points liberam tiers e ranks (7 tiers) | `!tasks` |
| ✅ | Mercado de creature products | NPC Yasir (79, 34, 7): compra 36 creature products (escamas, couros, asas etc.) | |
| ✅ | Níveis de guild | Membros doam ouro (NPC Bursar Halvard em 131, 54, 5 ou comando); o total doado define o nível (1 a 10) e dá bônus de atributos a todos os membros, após 24h na guild; ranking de doadores | `!guilddonate`, `!guildinfo` |
| ✅ | VFX (lib de efeitos) | Biblioteca `data/lib/360-vfx.lua` com 30 efeitos visuais (SkyFall, Rain, Lightning, Tornado, Meteor, Storm, Warning, Death, Buff etc.), sequências, perfis nomeados e elementos; só desenha, sem dano | `/vfx` (GM) |
| ✅ | Daily login | Pilar em 165, 53, 7 (item 1514, action id 9800): recompensa uma vez por dia, ciclo de 7 dias com streak e bônus por ciclo completo | |
| ✅ | Buffs | Buffs montados na hora com `addCreatureBuff` (porte do servidor antigo): categoria, stacks, duração em ms e callbacks `onActivate`/`onRemove`; da mesma categoria se sobrepõem; vale para players e monstros | `!buffs` |
| ✅ | Deuses e estátuas | Os Onze deuses (lore em `doc/sistemas/39-deuses-e-estatuas.md`): usar a estátua de um deus dá a sua benção por 2h, sem acumular e aparecendo no `!buffs`: +15% de resistência a um elemento (7 deuses), life leech, mana leech, magic level ou +skills (menos fishing). Sobrevive ao logout e se perde na morte | `/godstatue` (GM) |
| ✅ | Invasões | Evento de mundo a cada 2h (prelúdio de 5 min no broadcast): ondas de monstros ao redor de uma cidade, força pelo nível médio dos jogadores online, score por dano, recompensa e bônus de servidor de 60 min ao derrotar o boss (+25% xp, +30% loot ou +50% de treino) | `!invasion`, `/invasion` (GM) |
| ✅ | IA de monstros e bosses | Máquina de estados + árvore de decisão que escolhe magias do `spells.xml`, ataques telegrafados (`Telegraph`) e 24 bosses de invasão em 5 tiers, com fases, escudo e magias próprias | `/boss` (GM) |
| ✅ | Loot dos bosses | Os 24 bosses de invasão dropam no corpo 2 uniques próprios cada (20% a 12% por unique, conforme o tier, ex.: Ruzad's Warbrand, Zulkarath's Hellbrand) e runas de encantamento garantidas (1 a 3, tier da runa pelo tier do boss, 60% do elemento do boss). Anúncio no servidor quando um unique cai | |
| ✅ | Mass Challenge | `exeta mas res` e `exeta gran mas res` (Elite Knight): taunt em área que também deixa os monstros com range 1 por 12 s e 20 s | `exeta mas res`, `exeta gran mas res` |
| ✅ | Level dos monstros | Level calculado pela vida e pelo dano dos ataques, fixo na tabela `MonsterLevels` (usado por contratos, prey e criaturas premiadas) | `/monsterlevels` (GM) |
| ✅ | Glifos de magia | As 13 magias de ataque do Sorcerer têm 2 glifos cada (A e B), e o jogador fica com um por magia. O primeiro glifo se compra com **pontos de bestiário** (orçamento: 20% de todos os pontos para ter um glifo em cada magia), trocar para o outro custa **só ouro**. Exige nível (nível da magia x 4). Efeitos como empurrar o alvo, chain lightning, dano repetido, veneno, curse, queimadura, paralisia, linha que atravessa, redução de resistência, chuva de meteoros ou raios, invocações infernais e buffs. O NPC **Thalion Glyphweaver** (84, 55, 6) escreve os glifos; tudo ajustável em `config.lua` (chaves `glyph*`). Nomes e valores ainda provisórios; outras vocações virão com um NPC cada | `!glyphs`, `/glyph` (GM) |
| ✅ | Empurrão (Push) | Lib `data/lib/404-push.lua` sobre `doCreaturePush(cid, direção)`: empurra uma criatura 1 sqm, inclusive monstros com `pushable="0"` (bosses). O servidor recusa o empurrão contra PZ, casas, mudança de andar, teleportes, campos mágicos e tiles bloqueados (a criatura fica parada e a função devolve o motivo). Usado nos glifos (Flame Strike A e Energy Wave A) | `/glyph push` (GM) |
| ✅ | Resistência de monstros por condition | Monstros agora leem `CONDITION_ATTRIBUTES` com `CONDITION_PARAM_ABSORB_<elemento>` (o mesmo das bênçãos dos deuses): valor negativo faz o monstro receber mais dano. Dura o tempo da condition, renova ao reaplicar e pode ser removida; usado nos glifos que reduzem a resistência | |
| ✅ | Cooldowns das classes antigas | As magias mais fortes de Sorcerer, Druid, Paladin e Knight ganharam cooldown individual (4 a 40 s); mana e dano não mudaram | |

## Vocações adicionais

Vocações novas, além das clássicas (Sorcerer, Druid, Paladin e Knight). Cada uma tem documentação própria em [`doc/sistemas/`](doc/sistemas/README.md).

| | Vocação | Id (promoção) | Resumo | Doc |
|---|---|---|---|---|
| ✅ | Cleric | 9 (Hierophant, 10) | O Hierophant ganha magias de área grande (chuva de holy, wave que reduz a resistência a holy, buffs de vida/mana e de dano holy para a party). Mago de holy: dano médio, curas e buffs leves, com magias que ferem inimigos e curam aliados ao mesmo tempo. Range média (4 SQM) e áreas médias. Inclui o Pillar of Light, magia de área em volta do inimigo que substitui as runas | [`24-cleric.md`](doc/sistemas/24-cleric.md) |
| ✅ | Berserker | 15 (Warlord, 16) | Guerreiro de machado com armas de duas mãos (e escudo junto, via `canTwoHandShield` na source). As magias gastam vida em vez de mana; leech passivo, Fúria (+2 axe skill por magia, até +20) e Rage (+0,4% de dano físico por 1% de vida perdida, máx. +30%). 10 magias: Cleave, Savage Leap, Rending Blow, Warcry, Whirlwind, Ground Slam, Blood Pact, Rampage, Skullsplitter e Roar of Fury. O Warlord ganha Earthshatter, Blood Frenzy, Titan's Wrath e Undying Rage | [`28-berserker.md`](doc/sistemas/28-berserker.md) |
| ✅ | Archer | 17 (Ranger, 18) | Arqueiro elemental, só arco e flecha. Escolhe um encantamento (fogo, veneno, gelo ou raio) e todas as magias mudam de elemento e de efeito: queimadura, stacks de veneno, geada que congela e choque que salta. Trocar de elemento dispara reações (Ignite, Shatter, Conduct, Corrode). 14 magias: Elemental Shot, Piercing Arrow (atravessa todos), Twin Shot, Elemental Trap, Disengage, Arrow Fan, Rain of Arrows (chuva em área), Elemental Surge, Overcharge Shot e Convergence. O Ranger ganha Arrow Tempest (flecha que ricocheteia, sem atravessar paredes nem atingir PZ), Elemental Avatar, Spirit Falcon e Perfect Shot | [`34-archer.md`](doc/sistemas/34-archer.md) |
| ✅ | Assassin | 13 (Nightblade, 14) | Duelista de espadas gêmeas (única vocação com dual wield, só usa espadas): pouca vida, muita mana, sem great/ultimate health potion (só spirit). Passiva Momentum (stacks de crítico e velocidade) e 12 magias: Quick Slash, Shadow Step, Twin Fang, Venom Edge, Bleeding Cut, Smoke Bomb, Blade Dance, Bloodthirst, Execute, Vanish, Backstab (só pelas costas) e Deathblow (só em alvo abaixo de 25% de vida). O Nightblade ganha Thousand Cuts, Death Mark, Phantom Clones e Night Veil | [`27-assassin.md`](doc/sistemas/27-assassin.md) |
| ✅ | Necromancer | 11 (Lich, 12) | Mago invocador: levanta Skeleton, Ghoul, Banshee e Phantasm a partir de corpo + 6 soul (o soul vem da passiva Soul Harvest) e, com 4 ou mais summons, o Dragon Skeleton, que perde vida aos poucos. Ataques de death e poison (bolas, waves, chuva, tornado) e buffs que consomem summons. Começa com Summon Skeleton e Death Touch no nível 8. O Lich ganha Soul Siphon, Bone Abomination, Corpse Explosion e Army of the Dead | [`25-necromancer.md`](doc/sistemas/25-necromancer.md) |

### Informações importantes

- **Configuração:** as opções de cada sistema estão em `config.lua`. Mudanças nele exigem reiniciar o servidor.
- **Banco de dados:** o autoloot criou tabelas novas (`player_autoloot` e `player_autoloot_filters`, em `schemas/`). Um banco antigo é atualizado automaticamente ao iniciar, mas faça backup antes.
- **Penalidade de morte:** não existe mais na source. Edite `data/creaturescripts/scripts/deathloss.lua` (as opções `blessingReduction*` e `eachBlessReduction` saíram do `config.lua` e foram para o topo desse script).
- **Ids de storage reservados:** `52000` (bestiary tracking), `52200` e `52201` (raça e cooldown de troca), `52400` (lista de buffs ativos da criatura), `54000` a `54003` (tasks e task points) e `54100` e `54101` (guild e horário de entrada, bônus de guild), `54200` e `54201` (daily login), `52300` (estátuas de ranking), `54300` (encantamento do Archer), `54400` e `54410`, `54700` a `54705` e `54710` a `54712` (invasões, globais), `54720` (invasor), `54730` e `54731` (IA dos bosses) e `56000` a `56012` (respeito e missões do Durnok Runebrand), `56100` a `56110` (bênçãos dos deuses) e `56200` a `56260` (glifos: pontos gastos, glifo de cada magia e pontos de teste). Evite usá-los em outros scripts.
- **Banco de dados (guild):** as tabelas `guild_levels` e `guild_donations` são criadas sozinhas pelo Lua na primeira vez que o servidor sobe, sem recompilar.
- **Monstros:** todos precisam do atributo `monsterId` no XML para entrar no bestiary.
- **Runas antigas:** as runas de ataque (Fire Field, Poison Bomb etc.) viraram itens de encantamento e não podem mais ser lançadas. NPCs só vendem a blank rune e monstros só dropam blank rune; as demais são entalhadas pelo Durnok Runebrand (ver Runecarving).
- **Comandos de GM** (`/rarity`, `/unique`, `!race`) exigem access 5.
- **Documentos de planejamento:** [`32-planejamento-hunts.md`](doc/sistemas/32-planejamento-hunts.md) (proposta de hunts por nível, ainda não implementada) e [`33-monstros-canary.md`](doc/sistemas/33-monstros-canary.md) (monstros do Canary ausentes aqui); catálogo de magias dos bosses em [`37-bosses-magias.md`](doc/sistemas/37-bosses-magias.md).
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
