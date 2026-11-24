-- !spells : lista as magias da vocação do jogador com informações básicas
function onSay(cid, words, param, channel)
	local list = {}
	local count = getPlayerInstantSpellCount(cid)
	for i = 0, count - 1 do
		local spell = getPlayerInstantSpellInfo(cid, i)
		if(spell) then
			table.insert(list, spell)
		end
	end

	if(#list == 0) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Voce nao possui magias disponiveis.")
		return true
	end

	table.sort(list, function(a, b)
		if(a.level ~= b.level) then
			return a.level < b.level
		end

		return a.name < b.name
	end)

	local level = getPlayerLevel(cid)
	local text = "Magias de " .. getPlayerVocationName(cid) .. " (" .. #list .. ")\n"
	text = text .. "Formato: palavras - nome | level | magic level | mana\n"
	for _, spell in ipairs(list) do
		local mana = spell.mana
		if(spell.manapercent and spell.manapercent > 0) then
			mana = spell.manapercent .. "%"
		end

		text = text .. "\n" .. spell.words .. " - " .. spell.name .. " | lvl " .. spell.level
			.. " | ml " .. spell.mlevel .. " | mana " .. mana
		if(spell.level > level) then
			text = text .. " (bloqueada)"
		end
	end

	doShowTextDialog(cid, 2175, text)
	return true
end
