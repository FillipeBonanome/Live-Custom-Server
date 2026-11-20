function onThink(interval, lastExecution)
  -- Configurações
    local cor = 22 -- Defina a cor da mensagem (22 = branco)
    local mensagens ={
[[Para ter acesso à cidades como Nargor, Svargrond, Tiquanda e Blood City, utilizem o barco localizado ao lado direita da cidade principal. Nessas cidades você poderá encontrar várias hunts diferentes.
]]
}

  -- Fim de Configurações

  doBroadcastMessage(mensagens[math.random(1,table.maxn(mensagens))], cor)
return TRUE
end