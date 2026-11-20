function onThink(interval, lastExecution)
  -- Configurações
    local cor = 25 -- Defina a cor da mensagem (22 = branco)
    local mensagens ={
[[No servidor, possui o sistema de War System, para invitar sua guild inimiga digite: [/war invite, guild inimiga, número de frags]. E para a guild inimiga aceitar, digite: [/war accept, nome da guild].
]]
}

  -- Fim de Configurações

  doBroadcastMessage(mensagens[math.random(1,table.maxn(mensagens))], cor)
return TRUE
end