function onThink(interval, lastExecution)
  -- Configurações
    local cor = 30 -- Defina a cor da mensagem (22 = branco)
    local mensagens ={
[[Bem vindo ao Hardland OT.
Para ter acesso a nova cidade vip, digite [!buyvip]. Ela custa 5kk.
Na cidade vip, você poderá ter acesso a novos teleports e a novas quests.
]]
}

  -- Fim de Configurações

  doBroadcastMessage(mensagens[math.random(1,table.maxn(mensagens))], cor)
return TRUE
end