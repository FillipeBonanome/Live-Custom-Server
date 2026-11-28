-- Cria o salao de exposicao dos uniques ao ligar o servidor (ver data/lib/405-museum.lua).
function onStartup()
	local exposed = Museum.build()
	print(">> Unique museum built: " .. tostring(exposed or "failed") .. " uniques")
	return true
end
