-- Guild levels (see data/lib/350-guildlevels.lua): creates the tables on startup and, every 30 seconds, applies or
-- removes the guild bonus of the online players (joining/leaving a guild and level ups are noticed here).
function onStartup()
	GuildLevels.createTables()
	return true
end

function onThink(interval, lastExecution)
	GuildLevels.syncAll()
	return true
end
