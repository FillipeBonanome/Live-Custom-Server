function onThink(interval, lastExecution)
  -- Configurações
    local cor = 20 -- Defina a cor da mensagem (22 = branco)
    local mensagens ={
[[Em breve, Hard coins serão inseridas no jogo, onde com elas vocês poderão adquirir alguns items que estará exposto em nosso site. Para saber como fazer a doação, envie mensagem à algum membro da Equipe, tanto em private quanto em help chat. Staff
]]
}

  -- Fim de Configurações

  doBroadcastMessage(mensagens[math.random(1,table.maxn(mensagens))], cor)
return TRUE
end