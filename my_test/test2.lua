local lanes = require "lanes".configure()
local linda = lanes.linda()  -- Canal de comunicação

-- Thread produtor
local function produtor()
    for i = 1, 5 do
        linda:send("dados", i)  -- Envia dados
        print("[Produtor] Enviou:", i)
        os.execute("sleep 0.5")
    end
    linda:send("dados", nil)  -- Sinaliza fim
end

-- Thread consumidor
local function consumidor()
    while true do
        local dado = linda:receive("dados")  -- Bloqueia até receber algo
        if dado == nil then break end
        print("[Consumidor] Recebeu:", dado)
    end
end

-- Inicia os threads
local p = lanes.gen("*", produtor)()
local c = lanes.gen("*", consumidor)()

-- Espera ambos terminarem
p:join()
c:join()