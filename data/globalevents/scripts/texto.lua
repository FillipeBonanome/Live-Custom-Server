local config = {
    positions = {
        ["Treiners"] = { x = 161, y = 46, z = 7 },
        ["Teleports"] = { x = 166, y = 49, z = 7 },
	["Quest"] = { x = 166, y = 51, z = 7 },
	["Templo"] = { x = 266, y = 115, z = 7 },
	["Nargor"] = { x = 269, y = 115, z = 7 },
	["Svargrond"] = { x = 272, y = 115, z = 7 },
	["Tiquanda"] = { x = 266, y = 121, z = 7 },
	["PVP-ARENA"] = { x = 272, y = 121, z = 7 },
	["VIP-City"] = { x = 152, y = 46, z = 7 },
	["Promotion"] = { x = 151, y = 52, z = 7 },
	["VIPS"] = { x = 233, y = 102, z = 6},
	["Templo"] = { x = 236, y = 96, z = 6 },
	["TeleportsVIP"] = { x = 235, y = 96, z = 6 },
	["Bem Vindo"] = { x = 153, y = 51, z = 6 },
	["Templo"] = { x = 463, y = 370, z = 7 },
	["Templo"] = { x = 463, y = 371, z = 7 },
    }
}

function onThink(cid, interval, lastExecution)
    for text, pos in pairs(config.positions) do
        doSendAnimatedText(pos, text, math.random(1, 255))
    end
    
    return TRUE
end  