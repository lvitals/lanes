local lanes = require "lanes".configure()
local linda = lanes.linda()

-- Função que roda em paralelo
local function worker(id)
    for i = 1, 3 do
        print(string.format("Thread %d: passo %d", id, i))
        os.execute("sleep 1")  -- Simula trabalho pesado
    end
    return "Thread " .. id .. " concluído!"
end

-- Cria 3 threads
local threads = {
    lanes.gen("*", worker)(1),  -- '*' = thread normal (não prioritário)
    lanes.gen("*", worker)(2),
    lanes.gen("*", worker)(3)
}

-- Espera todos terminarem e pega resultados
for _, thread in ipairs(threads) do
    print(thread[1])  -- thread[1] contém o retorno
end