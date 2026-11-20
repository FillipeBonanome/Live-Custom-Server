function onThink(interval, lastExecution)
  -- Configurações
    local cor = 22 -- Defina a cor da mensagem (22 = branco)
    local mensagens ={
[[Para a melhoria do servidor, estamos abrindo um sistema de doação para que possamos pagar um dedicado para que o servidor permaneça um bom tempo online para a diversão de todos, para mais informações, procure algum membro da Equipe Hardland.
]]
}

  -- Fim de Configurações

  doBroadcastMessage(mensagens[math.random(1,table.maxn(mensagens))], cor)
return TRUE
end