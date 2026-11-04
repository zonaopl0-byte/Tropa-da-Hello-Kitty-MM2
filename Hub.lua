-- 1) Carrega o Hub Principal
loadstring(game:HttpGet("https://raw.githubusercontent.com/zonaopl0-byte/Tropa-da-Hello-Kitty-MM2/refs/heads/main/Script.lua"))()

-- Espera o Hub carregar na tela
task.wait(0.5)

-- 2) Carrega a Tela de Carregamento (cobre o hub por 5s)
loadstring(game:HttpGet("https://raw.githubusercontent.com/zonaopl0-byte/Tropa-da-Hello-Kitty-MM2/refs/heads/main/Load.lua"))()

-- 3) Carrega a DLC de Combate
-- (A DLC vai procurar a aba Combate que o Hub acabou de criar)
loadstring(game:HttpGet("https://raw.githubusercontent.com/zonaopl0-byte/Tropa-da-Hello-Kitty-MM2/refs/heads/main/Combate.lua"))()
