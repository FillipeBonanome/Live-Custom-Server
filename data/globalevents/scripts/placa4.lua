local pos =
{
    {{x = 152, y = 46, z = 7}, {x = 152, y = 46, z = 7, stackpos = 252}},
    }
function onThink(cid, interval, lastExecution)
    for _, positions in pairs(pos) do
        doSendMagicEffect(positions[1], 56)
        if getThingFromPos(positions[2]).itemid > 0 then
            for _, name in pairs(getOnlinePlayers()) do
                local player = getPlayerByName(name)
                    doSendAnimatedText(positions[1], "VIP-City", 18)
            end
        end
    end
return TRUE
end  