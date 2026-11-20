        smp_id = 7589 -- Item a ser vendido
        backpacksmp_id = 7342 -- Backpack
		custosmp_id = 13000 -- Valor
		cargassmp_id = 100 -- Cargas

local name = getItemNameById(smp_id)
----- End Config -----
function onUse(cid, item, fromPosition, itemEx, toPosition)
        if doPlayerRemoveMoney(cid, custosmp_id) == TRUE then
                local bag = doPlayerAddItem(cid, backpacksmp_id, 1)
                        doSendAnimatedText(fromPosition, "", TEXTCOLOR_YELLOW)
                        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You have purchased a backpack of ".. name .."s for ".. custosmp_id .." gold.")
						for i=1,3 do
                        doAddContainerItem(bag, smp_id, cargassmp_id)
                end
                else
                        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "You need ".. custosmp_id .." gold coins for a backpack of ".. name .."s.")
                end
        return FALSE
end