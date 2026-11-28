-- !help: guide of the systems of the server, in the language of the player (data/lib/202-language.lua).
-- !help lists the topics, !help <topic> explains one (the name of the topic works in english and in portuguese).
-- To add a topic: add an entry to TOPICS (each text is {en = {lines}, pt = {lines}}) and its words to WORDS.
-- Texts have no accents on purpose (encoding of the files).

local TOPICS = {
	tasks = {
		en = {
			"TASKS: task masters ask you to kill a number of a creature. Say the name of a creature to Brannoc (at the temple) or to the task masters in the hunting grounds, and say reward when done.",
			"Each task gives its reward and task points. Points raise your rank and unlock harder tasks. !tasks shows your task and progress. Brannoc pays in training time."
		},
		pt = {
			"TASKS: os mestres de tarefas pedem que voce mate um numero de uma criatura. Diga o nome da criatura a Brannoc (no templo) ou aos mestres de tarefas das terras de caca, e diga reward ao terminar.",
			"Cada task da a recompensa e pontos de task. Os pontos sobem o seu rank e liberam tasks mais dificeis. !tasks mostra a sua task e o progresso. Brannoc paga em tempo de treino."
		}
	},
	prey = {
		en = {
			"PREY: Huntmaster Kael (at the temple) sells a temporary bonus against ONE monster: more experience, better loot, more damage or less damage taken, in 3 strengths.",
			"The bonus lasts a few hours and costs gold. Say clear to Kael to drop it for free and pick another one. !prey shows the one you have."
		},
		pt = {
			"PREY: Huntmaster Kael (no templo) vende um bonus temporario contra UM monstro: mais experiencia, melhor loot, mais dano ou menos dano recebido, em 3 forcas.",
			"O bonus dura algumas horas e custa ouro. Diga clear ao Kael para larga-lo de graca e escolher outro. !prey mostra o que voce tem."
		}
	},
	daily = {
		en = {
			"DAILY CONTRACTS: every day you get a contract of experience and one of gold: kill a number of a monster chosen for your level. When it is done a harder one appears, up to 5 per kind each day.",
			"!daily shows them. They renew every morning. Daily login: the pillar gives a reward for each day you come back, and the streak makes it better."
		},
		pt = {
			"CONTRATOS DIARIOS: todo dia voce recebe um contrato de experiencia e um de ouro: mate um numero de um monstro escolhido para o seu level. Ao terminar nasce um mais dificil, ate 5 de cada tipo por dia.",
			"!daily os mostra. Eles renovam toda manha. Login diario: o pilar da uma recompensa por cada dia que voce volta, e a sequencia melhora o premio."
		}
	},
	bestiary = {
		en = {
			"BESTIARY: every creature you kill is counted. Each knowledge level you complete gives extra experience against that creature, and bestiary points, used to buy glyphs for your spells.",
			"!bestiary <creature> shows the progress and what you know about it. !trackbestiary on shows the count at every kill."
		},
		pt = {
			"BESTIARY: toda criatura que voce mata e contada. Cada nivel de conhecimento completo da experiencia extra contra ela e pontos de bestiary, usados para comprar glifos das suas magias.",
			"!bestiary <criatura> mostra o progresso e o que voce sabe dela. !trackbestiary on mostra a contagem a cada kill."
		}
	},
	autoloot = {
		en = {
			"AUTOLOOT: items on your list go straight from the corpse to your backpack. !autoloot add gold coin, !autoloot remove <item>, !autoloot list, !autoloot clear.",
			"Filters: !autoloot rarity epic takes epic or better, !autoloot unique on takes every unique, and !autoloot ignore add <item> never takes it. !autoloot alone shows all the options."
		},
		pt = {
			"AUTOLOOT: os itens da sua lista vao direto do corpo para a sua mochila. !autoloot add gold coin, !autoloot remove <item>, !autoloot list, !autoloot clear.",
			"Filtros: !autoloot rarity epic pega epic ou melhor, !autoloot unique on pega todo unique, e !autoloot ignore add <item> nunca o pega. !autoloot sozinho mostra todas as opcoes."
		}
	},
	items = {
		en = {
			"ITEMS: weapons and armor that drop can have a rarity: uncommon (1 attribute), rare (2), epic (3) and legendary (4), with random attributes like dodge, critical or leech. The higher the rarity, the stronger the attributes.",
			"Uniques are special named items that drop from certain monsters. Pieces of the same set worn together give bonuses (the item shows set: name). !attributes shows the attributes you have active."
		},
		pt = {
			"ITENS: armas e armaduras que dropam podem ter raridade: uncommon (1 atributo), rare (2), epic (3) e legendary (4), com atributos aleatorios como esquiva, critico ou leech. Quanto maior a raridade, mais fortes os atributos.",
			"Uniques sao itens especiais com nome que dropam de certos monstros. Pecas do mesmo set usadas juntas dao bonus (o item mostra set: nome). !attributes mostra os atributos que voce tem ativos."
		}
	},
	enchant = {
		en = {
			"ENCHANTMENTS: items with a rarity have free slots (uncommon 1, rare 2, epic 3, legendary 4). Use an enchantment rune on the item and a slot is filled with a permanent bonus.",
			"The runes are carved by Durnok Runebrand (at the temple) from blank runes, gold and gems. The mightier ones need his respect, earned with his missions."
		},
		pt = {
			"ENCANTAMENTOS: itens com raridade tem slots livres (uncommon 1, rare 2, epic 3, legendary 4). Use uma runa de encantamento no item e um slot e preenchido com um bonus permanente.",
			"As runas sao esculpidas por Durnok Runebrand (no templo) a partir de runas em branco, ouro e gemas. As mais poderosas exigem o respeito dele, ganho com as missoes."
		}
	},
	glyphs = {
		en = {
			"GLYPHS: every spell has two glyphs, A and B, and you choose ONE to change the spell. The first glyph of a spell costs bestiary points; switching to the other costs gold, and a lot.",
			"Each vocation has its own glyph master. !glyphs shows your points and the price of each spell, !glyphs <spell> shows its two glyphs."
		},
		pt = {
			"GLIFOS: toda magia tem dois glifos, A e B, e voce escolhe UM para alterar a magia. O primeiro glifo de uma magia custa pontos de bestiary; trocar para o outro custa ouro, e bastante.",
			"Cada vocacao tem o seu mestre de glifos. !glyphs mostra os seus pontos e o preco de cada magia, !glyphs <magia> mostra os dois glifos."
		}
	},
	buffs = {
		en = {
			"BUFFS: spells and items can leave a buff on you, with a time. Only one buff of each category stays active; a new one of the same category replaces the old one, and some stack.",
			"!buffs lists the ones you have, with stacks and time left. Buffs are lost when you die or leave the game."
		},
		pt = {
			"BUFFS: magias e itens podem deixar um buff em voce, com um tempo. Fica ativo so um buff de cada categoria; um novo da mesma categoria troca o antigo, e alguns acumulam.",
			"!buffs lista os que voce tem, com stacks e tempo restante. Os buffs sao perdidos quando voce morre ou sai do jogo."
		}
	},
	death = {
		en = {
			"DEATH: when you die you lose experience and skills, and may lose items from your backpack and equipment. Blessings reduce these losses, and an amulet protects what you wear.",
			"With a white skull or worse you can lose all your equipment. Do not hunt what you cannot beat: read the !bestiary first."
		},
		pt = {
			"MORTE: ao morrer voce perde experiencia e skills, e pode perder itens da mochila e do equipamento. As blessings reduzem essas perdas, e um amuleto protege o que voce veste.",
			"Com skull branca ou pior voce pode perder todo o equipamento. Nao cace o que voce nao pode vencer: leia o !bestiary antes."
		}
	},
	vocation = {
		en = {
			"VOCATION: !spells lists the spells of your vocation, with level and mana. Brannoc (at the temple) explains your vocation if you say vocation to him.",
			"Your race (chosen at the start) gives a permanent bonus. Races can be changed with Magister Cassian Vael, who makes you wait before changing again."
		},
		pt = {
			"VOCACAO: !spells lista as magias da sua vocacao, com level e mana. Brannoc (no templo) explica a sua vocacao se voce disser vocation a ele.",
			"A sua raca (escolhida no inicio) da um bonus permanente. A raca pode ser trocada com Magister Cassian Vael, que o faz esperar antes de trocar de novo."
		}
	},
	language = {
		en = {
			"LANGUAGE: !language english or !language portugues changes the language of the NPCs that are translated and of the combat messages."
		},
		pt = {
			"IDIOMA: !language english ou !language portugues muda o idioma dos NPCs traduzidos e das mensagens de combate."
		}
	}
}

-- order of the list, and the words that open each topic (english and portuguese)
local ORDER = {"tasks", "prey", "daily", "bestiary", "autoloot", "items", "enchant", "glyphs", "buffs", "death", "vocation", "language"}
local WORDS = {
	tasks = {"task", "tasks", "tarefa", "tarefas", "missao", "missoes"},
	prey = {"prey", "presa"},
	daily = {"daily", "dailies", "diario", "diarios", "contrato", "contratos", "contract", "contracts", "login"},
	bestiary = {"bestiary", "bestiario"},
	autoloot = {"autoloot", "loot"},
	items = {"items", "item", "itens", "rarity", "raridade", "sets", "set", "unique", "uniques", "attributes", "atributos"},
	enchant = {"enchant", "enchants", "enchantment", "enchantments", "encantamento", "encantamentos", "runa", "runas", "rune", "runes"},
	glyphs = {"glyph", "glyphs", "glifo", "glifos"},
	buffs = {"buff", "buffs"},
	death = {"death", "die", "morte", "morrer", "skull"},
	vocation = {"vocation", "vocations", "vocacao", "vocacoes", "spells", "magias", "race", "raca", "classe", "class"},
	language = {"language", "idioma", "lingua"}
}

local function findTopic(param)
	param = param:lower():trim()
	for _, key in ipairs(ORDER) do
		if(key == param or isInArray(WORDS[key], param)) then
			return key
		end
	end

	return nil
end

function onSay(cid, words, param, channel)
	local key = findTopic(param or "")
	if(not key) then
		local intro = {
			en = "HELP: say !help <topic> in the chat. Topics: ",
			pt = "AJUDA: diga !help <assunto> no chat. Assuntos: "
		}
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, Language.text(cid, intro) .. table.concat(ORDER, ", ") .. ".")
		return true
	end

	for _, line in ipairs(Language.text(cid, TOPICS[key])) do
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, line)
	end

	return true
end
