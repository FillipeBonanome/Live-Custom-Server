function onThink(interval, lastExecution)
  -- Configurações
    local cor = 10 -- Defina a cor da mensagem (22 = branco)
    local mensagens ={
[[Aos players que gravarem vídeos dentro do ot, em wars, quests. Envie para mattheeus.c@hotmail.com, com esses vídeos, faremos uma sessão para vídeos em nosso site que está quase pronto!
]]
}

  -- Fim de Configurações

  doBroadcastMessage(mensagens[math.random(1,table.maxn(mensagens))], cor)
return TRUE
end