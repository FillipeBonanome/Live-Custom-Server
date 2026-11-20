local focus = 0
local talk_start = 0
local target = 0
local following = false
local attacking = false

function onThingMove(creature, thing, oldpos, oldstackpos)

end


function onCreatureAppear(creature)

end


function onCreatureDisappear(cid, pos)
	if focus == cid then
		selfSay('Good bye then.')
		focus = 0
		talk_start = 0
	end
end


function onCreatureTurn(creature)

end


function msgcontains(txt, str)
	return (string.find(txt, str) and not string.find(txt, '(%w+)' .. str) and not string.find(txt, str .. '(%w+)'))
end


function onCreatureSay(cid, type, msg)
	msg = string.lower(msg)

	if (msgcontains(msg, 'hi') and (focus == 0)) and getDistanceToCreature(cid) < 4 then
		selfSay('Olá ' .. creatureGetName(cid) .. '! Eu troco alguns itens por itens de addons. Diga {help} para saber mais.')
		focus = cid
		talk_start = os.clock()

	elseif msgcontains(msg, 'hi') and (focus ~= cid) and getDistanceToCreature(cid) < 4 then
		selfSay('Sorry, ' .. creatureGetName(cid) .. '! I talk to you in a minute.')

	elseif focus == cid then
		talk_start = os.clock()

		if msgcontains(msg, 'help') or msgcontains(msg, 'ajuda') then
			selfSay("Eu troco {ceiron's wolf tooth chain}, {enchanted chicken wing}, {piece of royal steel}, {piece of draconian steel}, {piece of hell steel}, {huge chunk of crude iron}, {damaged steel helmet}, {warrior's sweat}, {soul stone}, {simon the beggar's favorite staff}, {Ceiron's Waterskin}, {Ceiron's Wolf Tooth Chain}, {fighting spirit}")
			talk_state = 1

		elseif msgcontains(msg, "ceiron's wolf tooth chain") or msgcontains(msg, "ceiron's wolf tooth chain.") then
			-- NOTA: o texto original perguntava por Boots of Haste / enchanted chicken wing nesta keyword
			selfSay('Você tem 1 Boots of Haste para trocar pelo {enchanted chicken wing}?')
			talk_state = 2

		elseif talk_state == 2 then
			if msgcontains(msg, 'yes') then
				local itemstatus = doPlayerRemoveItem(cid, 2195, 1) -- item que sera removido para trocar
				if itemstatus == 0 then
					selfSay('Sorry, you not have items.')
				else
					doPlayerAddItem(cid, 5891, 1) -- item que o player ganhara na troca
					selfSay('Thanks for items.')
				end
			end
			talk_state = 0

		elseif msgcontains(msg, 'bye') and getDistanceToCreature(cid) < 4 then
			selfSay('Good bye, ' .. creatureGetName(cid) .. '!')
			focus = 0
			talk_start = 0
		end
	end
end


function onCreatureChangeOutfit(creature)

end


function onThink()

	if (os.clock() - talk_start) > 30 then
		if focus > 0 then
			selfSay('Next Please...')
		end
		focus = 0
	end
	if focus ~= 0 then
		if getDistanceToCreature(focus) > 5 then
			selfSay('Good bye then.')
			focus = 0
		end
	end
end
