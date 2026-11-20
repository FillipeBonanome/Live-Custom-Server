function onThink(interval, lastExecution)
  -- Configurações
    local cor = 25 -- Defina a cor da mensagem (22 = branco)
    local mensagens ={
[[Aos moradores da cidade VIP, prestem bastante atenção nas placas que a cidade lhe oferece, pois elas podem te levar a vender itens mais caros e até mesmo comprar potions mais baratas.
Prestem bastante atenção.
]]
}

  -- Fim de Configurações

  doBroadcastMessage(mensagens[math.random(1,table.maxn(mensagens))], cor)
return TRUE
end