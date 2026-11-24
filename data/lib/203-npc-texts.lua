-- Portuguese version of the lines of the NPCs that are written in English (see the end of data/lib/202-language.lua).
-- Language.add(english line, portuguese line): "@" is any text, and comes back in the portuguese line as %1, %2...
-- To translate a new NPC: add its lines here and call Language.install() at the end of its script.
-- Never translate names of creatures, items or runes. Texts have no accents on purpose (encoding of the files).

-- WORDS the players may say in portuguese -> keyword of the script -------------------------------------------------------
Language.alias({"sim", "s"}, "yes")
Language.alias({"nao", "n"}, "no")
Language.alias({"oi", "ola", "e ai"}, "hi")
Language.alias({"tchau", "adeus", "ate logo"}, "bye")
Language.alias({"comprar", "vender", "negociar", "oferta", "ofertas", "loja", "troca", "trocar", "mercadoria"}, "trade")
Language.alias({"ajuda"}, "help")
Language.alias({"cancelar"}, "cancel")
Language.alias({"status", "estado"}, "status")
-- Obi (furniture)
Language.alias({"cadeiras"}, "chairs")
Language.alias({"mesas"}, "tables")
Language.alias({"plantas"}, "plants")
Language.alias({"moveis"}, "furniture")
Language.alias({"mais"}, "more")
Language.alias({"tapecarias"}, "destination")
Language.alias({"pequenas"}, "small")
Language.alias({"redondas"}, "round")
Language.alias({"quadradas"}, "square")
Language.alias({"almofadas"}, "pillows")
-- Raphael (buffs)
Language.alias({"invisivel"}, "invisible")
Language.alias({"escudo magico"}, "magic shield")
Language.alias({"corpo a corpo"}, "melee")
Language.alias({"escudo"}, "shield")
Language.alias({"distancia"}, "distance")
Language.alias({"magia"}, "magic")
-- Mad (equipment)
Language.alias({"capacetes", "elmos"}, "helmets")
Language.alias({"botas"}, "boots")
Language.alias({"armaduras"}, "armors")
Language.alias({"calcas"}, "legs")
Language.alias({"escudos"}, "shields")
Language.alias({"espadas"}, "swords")
Language.alias({"machados"}, "axes")
Language.alias({"clavas", "macas"}, "clubs")
-- King Johnny
Language.alias({"promocao", "promover", "promocoes"}, "promot")
-- Priest (marriage)
Language.alias({"casar", "casamento"}, "marry")
Language.alias({"divorcio", "divorciar"}, "divorce")
Language.alias({"prosseguir", "continuar"}, "proceed")
Language.alias({"amor"}, "love")
-- Dark Rodo
Language.alias({"primeira varinha"}, "first wand")
Language.alias({"primeiro cajado", "primeiro bastao"}, "first rod")
-- BURSAR HALVARD (guild treasurer)
Language.alias({"doar", "doacao"}, "donate")
Language.alias({"nivel", "guilda"}, "level")
Language.alias({"doadores", "ranking"}, "donors")
-- HUNTMASTER KAEL (prey)
Language.alias({"presa", "cacar"}, "prey")
Language.alias({"limpar", "remover"}, "clear")
Language.alias({"tempo"}, "time")

-- DEFAULT MESSAGES of the NPC system (npchandler.lua / modules.lua) --------------------------------------------------------
Language.add("Welcome, @! I have been expecting you.", "Bem-vindo, %1! Eu estava te esperando.")
Language.add("Good bye, @!", "Adeus, %1!")
Language.add("Do you want to buy @ @ for @ gold coins?", "Quer comprar %1 %2 por %3 moedas de ouro?")
Language.add("It was a pleasure doing business with you.", "Foi um prazer fazer negocios com voce.")
Language.add("Bought @x @ for @ gold.", "Comprou %1x %2 por %3 de ouro.")
Language.add("Do you want to sell @ @ for @ gold coins?", "Quer vender %1 %2 por %3 moedas de ouro?")
Language.add("Thank you for this @, @ gold.", "Obrigado por este %1, %2 de ouro.")
Language.add("Sold @x @ for @ gold.", "Vendeu %1x %2 por %3 de ouro.")
Language.add("Sorry, you don't have enough money.", "Desculpe, voce nao tem dinheiro suficiente.")
Language.add("You do not have enough money.", "Voce nao tem dinheiro suficiente.")
Language.add("You don't even have that item, @!", "Voce nem tem esse item, %1!")
Language.add("You do not have this object.", "Voce nao tem este objeto.")
Language.add("You do not have enough capacity.", "Voce nao tem capacidade suficiente.")
Language.add("You do not have enough capacity for all items.", "Voce nao tem capacidade para todos os itens.")
Language.add("Next, please!", "Proximo, por favor!")
Language.add("How rude!", "Que grosseria!")
Language.add("Not good enough, is it... ?", "Nao e bom o bastante, e... ?")
Language.add("Here's my offer, @. Don't you like it?", "Aqui esta minha oferta, %1. Nao gostou?")
Language.add("Sorry, I'm not offering anything.", "Desculpe, nao estou oferecendo nada.")
Language.add("Thank you, come back when you want something more.", "Obrigado, volte quando quiser algo mais.")
Language.add("@! I am already talking to you...", "%1! Eu ja estou falando com voce...")
Language.add("@, please wait for your turn. There are @ customers before you.", "%1, aguarde a sua vez. Ha %2 clientes antes de voce.")
Language.add("Sure!", "Claro!")
Language.add("Alright then. Come back when you got the neccessary items.", "Certo entao. Volte quando tiver os itens necessarios.")
Language.add("Farewell then..", "Entao adeus..")
Language.add("Farewell, human.", "Adeus, humano.")

-- STANDARD MODULES (promotion) --------------------------------------------------------------------------------------------
Language.add("You are already promoted!", "Voce ja esta promovido!")
Language.add("I am sorry, but I can only promote you once you have reached level @.", "Sinto muito, mas so posso te promover quando voce alcancar o level %1.")
Language.add("You need a premium account in order to get promoted.", "Voce precisa de uma conta premium para ser promovido.")
Language.add("I can promote you for @ gold coins. Do you want me to promote you?", "Posso te promover por %1 moedas de ouro. Quer que eu te promova?")
Language.add("Congratulations! You are now promoted.", "Parabens! Agora voce esta promovido.")
Language.add("Alright then, come back when you are ready.", "Certo entao, volte quando estiver pronto.")

-- YASIR -------------------------------------------------------------------------------------------------------------------
Language.add("Hello, @! I buy {creature products} like dragon scales, leather, wings and more. Say {trade} to see what I buy.",
	"Ola, %1! Eu compro {creature products} como escamas de dragao, couro, asas e mais. Diga {trade} para ver o que eu compro.")
Language.add("Come back with more goods, @.", "Volte com mais mercadorias, %1.")

-- RASHID ------------------------------------------------------------------------------------------------------------------
Language.add("Hello @. I buy helmets, armors, legs, boots, weapons and shields, just {trade}.",
	"Ola %1. Eu compro elmos, armaduras, calcas, botas, armas e escudos, basta dizer {trade}.")

-- JOHN WAYNE --------------------------------------------------------------------------------------------------------------
Language.add("Hello @. Say {trade} to buy the mysterious pet.", "Ola %1. Diga {trade} para adquirir o mysterious pet.")
Language.add("Good bye.", "Adeus.")

-- OBI ---------------------------------------------------------------------------------------------------------------------
Language.add("Hello @. I sell chairs, tables, plants, containers, pillows, tapestries and more. Everything for 500 gold pieces.",
	"Ola %1. Eu vendo cadeiras, mesas, plantas, containers, almofadas, tapecarias e mais. Tudo por 500 moedas de ouro.")
Language.add("I sell wooden, sofa, red cushioned, green cushioned, tusk and ivory chairs.", "Eu vendo cadeiras de madeira, sofa, almofadadas vermelhas, almofadadas verdes, de presa e de marfim.")
Language.add("I sell big, square, round, small, stone, tusk, bamboo tables.", "Eu vendo mesas grandes, quadradas, redondas, pequenas, de pedra, de presa e de bambu.")
Language.add("I sell pink and green flowers, also christmas trees.", "Eu vendo flores rosas e verdes, tambem arvores de natal.")
Language.add("I sell large trunks, boxes, drawers, dressers, lockers and troughs.", "Eu vendo grandes bas, caixas, gavetas, comodas, armarios e cochos.")
Language.add("I sell coal basins, birdcages, harps, pianos, globes, clocks and lamps.", "Eu vendo braseiros, gaiolas, harpas, pianos, globos, relogios e lampadas.")
Language.add("I sell blue, green, orange, pink, red, white and yellow tapestries.", "Eu vendo tapecarias azuis, verdes, laranjas, rosas, vermelhas, brancas e amarelas.")
Language.add("I sell small purple, small green, small red, small blue, small orange, small turquiose and small white pillows.", "Eu vendo almofadas pequenas roxas, verdes, vermelhas, azuis, laranjas, turquesas e brancas.")
Language.add("I sell round blue, round red, round purple and round turquiose pillows.", "Eu vendo almofadas redondas azuis, vermelhas, roxas e turquesas.")
Language.add("I sell blue, red, green and yellow pillows.", "Eu vendo almofadas azuis, vermelhas, verdes e amarelas.")
Language.add("I sell heart, small, sqare and round pillows.", "Eu vendo almofadas de coracao, pequenas, quadradas e redondas.")

-- RAPHAEL -----------------------------------------------------------------------------------------------------------------
Language.add("Hello, @. I can {magic shield} and {invisible}, upgrade your 'melee', {magic}, {distance} and {shield} skills.",
	"Ola, %1. Eu posso dar {escudo magico} e {invisivel}, e melhorar suas habilidades de 'corpo a corpo', {magia}, {distancia} e {escudo}.")
Language.add("Do you want to be invisible?", "Quer ficar invisivel?")
Language.add("Do you want to get magic shield effect?", "Quer receber o efeito de escudo magico?")
Language.add("Do you want to upgrade your melee skills for some time?", "Quer melhorar suas habilidades de corpo a corpo por um tempo?")
Language.add("Do you want to upgrade your shield skills for some time?", "Quer melhorar suas habilidades de escudo por um tempo?")
Language.add("Do you want to upgrade your distance skills for some time?", "Quer melhorar suas habilidades de distancia por um tempo?")
Language.add("Do you want to upgrade your magic skills for some time?", "Quer melhorar suas habilidades de magia por um tempo?")
Language.add("Then not.", "Entao nao.")
Language.add("Now you are invisible!", "Agora voce esta invisivel!")
Language.add("Your magic shield is on!", "Seu escudo magico esta ativo!")
Language.add("Your skills had been upgraded!", "Suas habilidades foram melhoradas!")
Language.add("You need @ gold coins to buff yourself.", "Voce precisa de %1 moedas de ouro para se fortalecer.")
Language.add("Only master sorcerers and elder druids can upgrade their magic skills.", "Apenas master sorcerers e elder druids podem melhorar suas habilidades de magia.")
Language.add("Uhm?", "Hum?")
Language.add("Ya?", "Sim?")

-- MAD ---------------------------------------------------------------------------------------------------------------------
Language.add("Hello @. I buy swords, clubs, axes, helmets, boots, legs, shields and armors.",
	"Ola %1. Eu compro espadas, clavas, machados, elmos, botas, calcas, escudos e armaduras.")
Language.add("I buy royal (40k), warrior (6k), crusader (9k), crown (5k), devil (4k), chain (35gp) and iron helmets (30gp), also mystic turbans (500gp).",
	"Eu compro elmos royal (40k), warrior (6k), crusader (9k), crown (5k), devil (4k), chain (35gp) e iron (30gp), tambem mystic turbans (500gp).")
Language.add("I buy golden boots (100k), steel boots (40k) and boots of haste (40k).", "Eu compro golden boots (100k), steel boots (40k) e boots of haste (40k).")
Language.add("I buy golden (30k), crown (20k), knight (5k), lady (7,5k), plate (400gp), brass (200gp) and chain armors (100gp), also mpa (100k), dsm (60k) and blue robes (15k).",
	"Eu compro armaduras golden (30k), crown (20k), knight (5k), lady (7,5k), plate (400gp), brass (200gp) e chain (100gp), tambem mpa (100k), dsm (60k) e blue robes (15k).")
Language.add("I buy golden (80k), crown (15k), knight (6k), plate (500gp) and brass legs (100gp).", "Eu compro calcas golden (80k), crown (15k), knight (6k), plate (500gp) e brass (100gp).")
Language.add("I buy blessed (150k), great (100k), demon (40k), vampire (25k), medusa (8k), amazon (4k), crown (5k), tower (4k), dragon (3k), guardian (2k), beholder (1k), and dwarven shields (100gp), also mms (80k).",
	"Eu compro escudos blessed (150k), great (100k), demon (40k), vampire (25k), medusa (8k), amazon (4k), crown (5k), tower (4k), dragon (3k), guardian (2k), beholder (1k) e dwarven (100gp), tambem mms (80k).")
Language.add("I buy giant (10k), bright (6k), fire (3k) serpent (1.5k), spike (800gp) and two handed swords (400gp), also ice rapiers (4k), magic longswords (150k), magic swords (90k), warlord swords (100k) broad swords (70gp), short swords (30gp), sabres (25gp) and swords (25gp).",
	"Eu compro espadas giant (10k), bright (6k), fire (3k), serpent (1.5k), spike (800gp) e two handed (400gp), tambem ice rapiers (4k), magic longswords (150k), magic swords (90k), warlord swords (100k), broad swords (70gp), short swords (30gp), sabres (25gp) e swords (25gp).")
Language.add("I buy fire (10k), guardian halberds (7,5k) knight (2k), double (200gp) and battle axes (100gp), also dragon lances (10k), stonecutters axes (90k), halberds (200gp) and hatchets (20gp).",
	"Eu compro machados fire (10k), guardian halberds (7,5k), knight (2k), double (200gp) e battle (100gp), tambem dragon lances (10k), stonecutters axes (90k), halberds (200gp) e hatchets (20gp).")
Language.add("I buy thunder hammers (90k), war (6k), dragon (2k) and battle hammers (60gp), also skull staffs (10k) and clerical maces (200gp).",
	"Eu compro thunder hammers (90k), war (6k), dragon (2k) e battle hammers (60gp), tambem skull staffs (10k) e clerical maces (200gp).")

-- DARK RODO (the quest of the first wand/rod) -----------------------------------------------------------------------------
Language.add("So you ask me for a {@} to begin your advanture?", "Entao voce me pede um {%1} para comecar a sua aventura?")
Language.add("What? I have already gave you one {@}!", "O que? Eu ja te dei um {%1}!")
Language.add("Sorry, you aren't a druid either a sorcerer.", "Desculpe, voce nao e nem druid nem sorcerer.")
Language.add("Here you are young adept, take care yourself.", "Aqui esta, jovem aprendiz, cuide-se.")
Language.add("Ok then.", "Tudo bem entao.")

-- PRIEST ------------------------------------------------------------------------------------------------------------------
Language.add("Hello @. To marry, say {marry}.", "Ola %1. Para se casar, diga {marry}.")
Language.add("Would you like to get married?", "Voce gostaria de se casar?")
Language.add("You already set a wedding date with {@}, now I must talk to your partner. Do you want to {cancel} it?", "Voce ja marcou um casamento com {%1}, agora preciso falar com o seu parceiro. Quer {cancel} isso?")
Language.add("You are already married. If you want to {divorce}, just say it.", "Voce ja e casado. Se quiser se {divorce}, e so dizer.")
Language.add("Would you like to divorce of your partner?", "Voce gostaria de se divorciar do seu parceiro?")
Language.add("You are not married. If you want to get married, just say {marry}.", "Voce nao e casado. Se quiser se casar, e so dizer {marry}.")
Language.add("And what's the name of your future partner?", "E qual e o nome do seu futuro parceiro?")
Language.add("{@} has set a wedding date with you. Do you want to {proceed} or {cancel} the wedding?", "{%1} marcou um casamento com voce. Quer {proceed} ou {cancel} o casamento?")
Language.add("A player with that name does not exists.", "Nao existe um jogador com esse nome.")
Language.add("Don't worry, you will always be married with yourself, kid.", "Nao se preocupe, voce sempre estara casado consigo mesmo, jovem.")
Language.add("You've just set a wedding date with {@}.", "Voce acabou de marcar um casamento com {%1}.")
Language.add("{@} has already set a wedding date with {@}.", "{%1} ja marcou um casamento com {%2}.")
Language.add("Sorry, but {@} is already married to {@}.", "Desculpe, mas {%1} ja e casado com {%2}.")
Language.add("Congratulations! Now you may kiss your partner! Everytime you wanna make this effect, just say {love}. You must be close to your partner.",
	"Parabens! Agora voce pode beijar o seu parceiro! Sempre que quiser fazer este efeito, diga {love}. Voce deve estar perto do seu parceiro.")
Language.add("Your partner must be close to you so you can marry!", "O seu parceiro deve estar perto de voce para que possam se casar!")
Language.add("You and your new partner must be online at the same time.", "Voce e o seu novo parceiro devem estar online ao mesmo tempo.")
Language.add("You just canceled your wedding date with {@}.", "Voce acabou de cancelar o seu casamento com {%1}.")
Language.add("You've just divorced of your old partner.", "Voce acabou de se divorciar do seu antigo parceiro.")

-- BURSAR HALVARD (guild treasurer) ---------------------------------------------------------------------------------------------------------
Language.add("Hello @! Gold you {donate} to your guild raises its level and gives bonuses to all its members. Ask for the {level} of your guild or the top {donors}.",
	"Ola %1! O ouro que voce {donate} a sua guild aumenta o nivel dela e da bonus a todos os membros. Pergunte pelo {level} da sua guild ou pelos maiores {donors}.")
Language.add("Do you want to donate {@ gold coins} to your guild? {yes} or {no}.", "Quer doar {%1 moedas de ouro} a sua guild? {yes} ou {no}.")
Language.add("The guild levels are disabled.", "Os niveis de guild estao desativados.")
Language.add("Alright, nothing was donated.", "Certo, nada foi doado.")
Language.add("Thank you! You donated @ gold coins. Your guild is level @.", "Obrigado! Voce doou %1 moedas de ouro. Sua guild e level %2.")
Language.add("Tell me a number of gold coins, or {cancel}.", "Diga-me um numero de moedas de ouro, ou {cancel}.")
Language.add("You are not in a guild.", "Voce nao esta em uma guild.")
Language.add("How much gold do you want to donate? The minimum is @. Tell me the number or {cancel}.", "Quanto ouro quer doar? O minimo e %1. Diga-me o numero ou {cancel}.")
Language.add("Nobody donated to your guild yet.", "Ninguem doou para a sua guild ainda.")
Language.add("Top donors: @.", "Maiores doadores: %1.")

-- HUNTMASTER KAEL (prey) -------------------------------------------------------------------------------------------------------------
Language.add("Hello @! I can give you a temporary {prey} bonus against one monster. You can also ask for your {status} or {clear} the current one for free.",
	"Ola %1! Eu posso te dar um bonus temporario de {prey} contra um monstro. Voce tambem pode pedir o seu {status} ou {clear} o atual de graca.")
Language.add("Good hunting, @.", "Boa cacada, %1.")
Language.add("The prey system is disabled.", "O sistema de prey esta desativado.")
Language.add("Alright, nothing was changed.", "Certo, nada foi alterado.")
Language.add("Your prey was cleared for free. Say {prey} when you want a new one.", "Sua prey foi removida de graca. Diga {prey} quando quiser uma nova.")
Language.add("You have no active prey.", "Voce nao tem prey ativa.")
Language.add("You have no active prey. Say {prey} to get one.", "Voce nao tem prey ativa. Diga {prey} para conseguir uma.")
Language.add("Which monster do you want to hunt? Tell me its name (or {cancel}). The bonus lasts @.", "Qual monstro quer cacar? Diga-me o nome (ou {cancel}). O bonus dura %1.")
Language.add("I do not know any huntable creature called @. Tell me another name or say {cancel}.", "Nao conheco nenhuma criatura cacavel chamada %1. Diga outro nome ou diga {cancel}.")
Language.add("Which bonus do you want against @? @.", "Qual bonus quer contra %1? %2.")
Language.add("Choose one of: @.", "Escolha um destes: %1.")
Language.add("How strong? @.", "Qual a forca? %1.")
Language.add("Alright, nothing was bought. Say {prey} to choose again.", "Certo, nada foi comprado. Diga {prey} para escolher de novo.")
Language.add("@ +@% against @ for @ costs @ gold. Do you accept? {yes} or {no}.", "%1 +%2%% contra %3 por %4 custa %5 de ouro. Voce aceita? {yes} ou {no}.")
Language.add("Done! Good hunt. @", "Pronto! Boa cacada. %1")
Language.add("You already have a prey. @ Say {clear} to remove it for free and pick another one.", "Voce ja tem uma prey. %1 Diga {clear} para remove-la de graca e escolher outra.")
Language.add("Your prey: @", "Sua prey: %1")
Language.alias({"experiencia"}, "experience")
Language.alias({"dano"}, "damage")
Language.alias({"defesa"}, "defense")
Language.alias({"fraco"}, "weak")
Language.alias({"forte"}, "strong")
Language.alias({"supremo", "definitivo"}, "ultimate")
Language.add("Guild @: level @/@ (@ gold donated).", "Guild %1: level %2/%3 (%4 de ouro doado).")
Language.add("Bonus of the level: @.", "Bonus do level: %1.")
Language.add("Next level: @ gold missing. It gives @.", "Proximo level: faltam %1 de ouro. Ele da %2.")
Language.add("The guild reached the maximum level!", "A guild alcancou o level maximo!")
Language.add("Your bonus starts in @ (time needed in the guild).", "Seu bonus comeca em %1 (tempo necessario na guild).")
