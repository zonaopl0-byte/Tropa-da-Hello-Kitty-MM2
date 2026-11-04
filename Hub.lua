-- LOADER - Hello Kitty Hub v2.0
local PART1_URL = "https://raw.githubusercontent.com/zonaopl0-byte/Auto-Rejoin-MM2/refs/heads/main/Parte1.lua"
local PART2_URL = "https://raw.githubusercontent.com/zonaopl0-byte/Auto-Rejoin-MM2/refs/heads/main/Parte2.lua"

print("[HK] Baixando parte 1...")
local ok1, src1 = pcall(game.HttpGet, game, PART1_URL)
if not ok1 or not src1 then warn("[HK] Falha ao baixar parte 1: " .. tostring(src1)); return end
print("[HK] Parte 1 baixada (" .. #src1 .. " bytes). Executando...")

local fn1, err1 = loadstring(src1)
if not fn1 then warn("[HK] Erro de sintaxe na parte 1: " .. tostring(err1)); return end
local okRun1, errRun1 = pcall(fn1)
if not okRun1 then warn("[HK] Erro ao executar parte 1: " .. tostring(errRun1)); return end

task.wait(0.5)

print("[HK] Baixando parte 2...")
local ok2, src2 = pcall(game.HttpGet, game, PART2_URL)
if not ok2 or not src2 then warn("[HK] Falha ao baixar parte 2: " .. tostring(src2)); return end
print("[HK] Parte 2 baixada (" .. #src2 .. " bytes). Executando...")

local fn2, err2 = loadstring(src2)
if not fn2 then warn("[HK] Erro de sintaxe na parte 2: " .. tostring(err2)); return end
local okRun2, errRun2 = pcall(fn2)
if not okRun2 then warn("[HK] Erro ao executar parte 2: " .. tostring(errRun2)); return end

print("[HK] Hub v2.0 carregado com sucesso!")
