# Níveis de guild

## Como funciona
- Os membros **doam ouro** para a guild e o **total doado** define o nível dela (1 a 10). Quanto mais alto o nível, maiores os bônus de atributos de **todos os membros**.
- Doar: fale com o NPC **Guild Treasurer** (`donate`, ou `donate 100000`, e confirme com `yes`) ou use `!guilddonate valor`. A doação mínima é `guildLevelMinDonation` (10.000). O ouro é tirado do jogador e nunca devolvido; o servidor nunca cobra mais do que falta para o nível máximo.
- `!guildinfo` (ou `level` no NPC): nível, bônus atual, ouro que falta para o próximo nível (e o bônus dele), ranking dos 5 maiores doadores, quanto você já doou e, se for o caso, quanto falta para o seu bônus começar. `donors` no NPC mostra só o ranking.
- Quando a guild sobe de nível todos os membros online recebem uma mensagem e o bônus novo é aplicado em até 30 segundos. Também há uma mensagem a cada doação.

## Níveis e bônus
O custo é o ouro a doar para sair do nível anterior; os bônus são o **total** do nível (não somam com os dos níveis abaixo).

| Nível | Custo | Total acumulado | Bônus |
|---|---|---|---|
| 1 | - | 0 | nenhum |
| 2 | 1.000.000 | 1M | +2% exp, +50 vida |
| 3 | 2.000.000 | 3M | +3% exp, +2% loot, +100 vida, +100 mana |
| 4 | 4.000.000 | 7M | +4% exp, +3% loot, +150 vida, +150 mana, +1 armor |
| 5 | 8.000.000 | 15M | +5% exp, +4% loot, +250 vida, +250 mana, +2 armor, +1 defense |
| 6 | 16.000.000 | 31M | +6% exp, +5% loot, +350 vida, +350 mana, +2 armor, +2 defense, +2% crit |
| 7 | 32.000.000 | 63M | +7% exp, +6% loot, +450 vida, +450 mana, +3 armor, +2 defense, +3% crit |
| 8 | 64.000.000 | 127M | +8% exp, +7% loot, +600 vida, +600 mana, +3 armor, +3 defense, +4% crit, +1% life leech |
| 9 | 128.000.000 | 255M | +9% exp, +8% loot, +750 vida, +750 mana, +4 armor, +3 defense, +5% crit, +2% life leech |
| 10 | 256.000.000 | 511M | +10% exp, +10% loot, +1000 vida, +1000 mana, +5 armor, +4 defense, +6% crit, +3% life leech |

Os bônus usam uma condição de atributos própria (sub id 8201), então somam com o bônus da raça.

## Proteção anti-abuso
O bônus só vale depois de o jogador ficar `guildLevelJoinWait` segundos (24h por padrão; 0 desativa) na guild atual. A guild e o horário em que o jogador foi visto nela ficam em storages (54100 e 54101) e são verificados a cada 30 segundos e no login. Quem sai da guild perde o bônus e, ao entrar em outra, espera de novo. Jogadores que já estavam em uma guild ao ativar o sistema também esperam o prazo uma vez.

## Banco de dados
As tabelas `guild_levels` (ouro total por guild) e `guild_donations` (ouro doado por jogador a cada guild, usado no ranking) são criadas sozinhas na primeira vez que o servidor sobe (SQLite ou MySQL), sem recompilar.

## Onde mexer
- `data/lib/350-guildlevels.lua`: `GuildLevels.levels` (custos e bônus; os bônus aceitam experience, loot, health, mana, armor, defense, critical e leech).
- `config.lua`: `guildLevelsEnabled`, `guildLevelMinDonation`, `guildLevelJoinWait`.
- NPC: `data/npc/Guild Treasurer.xml` e `data/npc/scripts/guildtreasurer.lua` (posição em `data/world/Styller-spawn.xml`).
- Comandos: `data/talkactions/scripts/guildlevel.lua`. Aplicação do bônus: `data/globalevents/scripts/guildlevels.lua` e `data/creaturescripts/scripts/guildlevel_login.lua`.
