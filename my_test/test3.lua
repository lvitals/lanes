-- Configura o ambiente Lanes
local lanes = require "lanes".configure({
    nb_keepers = 1,       -- Apenas 1 thread "gerente" (padrão é 2)
    on_state_create = nil, -- Sem callback personalizado
    with_timers = true,   -- Habilita timers internos
    track_lanes = true    -- Monitora threads para debug
})

-- Função que será executada em um thread separado
local function tarefa_lenta()
    print("[Thread] Iniciando tarefa pesada...")
    os.execute("sleep 3")  -- Simula trabalho (3 segundos)
    return "Resultado importante!"
end

-- Cria e dispara o thread
local thread = lanes.gen("*", tarefa_lenta)()  -- '*' = thread normal

-- Espera o thread terminar (com timeout de 2 segundos)
local resultado, err = thread:join(2.0)

-- Verifica o resultado
if resultado == nil then
    print("[Main] O thread travou ou excedeu o tempo limite!")
    if err then print("Erro:", err) end
else
    print("[Main] Thread concluído:", resultado[1])  -- resultado[1] = retorno da função
end

print("[Main] Fim do programa.")