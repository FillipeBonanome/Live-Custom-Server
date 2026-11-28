-- Welcome message (blue) shown every time a character logs in, listing the commands of the custom systems.
-- Edit the list below to add/remove commands. The daily quest info is sent right after this message
-- by dailyquest_login.lua (it is registered after this event in creaturescripts.xml).
local commands = {"!help", "!daily", "!bestiary", "!trackbestiary", "!autoloot", "!attributes", "!language", "/commands"}

function onLogin(cid)
	if(getPlayerAccountManager(cid) ~= MANAGER_NONE) then
		return true
	end

	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Seja bem vindo ao servidor! Aqui est\227o alguns comandos que descrevem os nossos novos sistemas: " .. table.concat(commands, ", ") .. ".")

	return true
end
