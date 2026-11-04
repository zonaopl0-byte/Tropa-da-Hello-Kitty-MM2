--[[
    HELLO KITTY HUB - TELA DE CARREGAMENTO
    Roda junto com o hub.lua. Fica POR CIMA do hub (DisplayOrder 999).
    Espera DURACAO segundos, faz fade out e se destroi.
    O hub (que ja estava rodando embaixo) aparece normalmente.

    Se a tela nao sair, verifique:
    - Console (F9) por erros em vermelho
    - Se DURACAO esta em segundos (padrao 3)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local DURACAO = 5        -- segundos de loading
local FADE = 0.5         -- segundos de fade out

-- remove loader antigo (se rodou 2x)
local old = PlayerGui:FindFirstChild("HelloKittyLoader")
if old then old:Destroy() end

-- ScreenGui POR CIMA de tudo
local gui = Instance.new("ScreenGui")
gui.Name = "HelloKittyLoader"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

-- fundo rosa
local bg = Instance.new("Frame")
bg.Name = "BG"
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(255, 190, 220)
bg.BorderSizePixel = 0
bg.Parent = gui

-- titulo
local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 0, 60)
titulo.Position = UDim2.new(0, 0, 0.5, -90)
titulo.BackgroundTransparency = 1
titulo.Text = "🎀 HELLO KITTY HUB"
titulo.TextColor3 = Color3.fromRGB(255, 80, 140)
titulo.TextSize = 36
titulo.Font = Enum.Font.GothamBold
titulo.Parent = bg

-- subtitulo
local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, 0, 0, 30)
sub.Position = UDim2.new(0, 0, 0.5, -30)
sub.BackgroundTransparency = 1
sub.Text = "Carregando..."
sub.TextColor3 = Color3.fromRGB(255, 255, 255)
sub.TextSize = 18
sub.Font = Enum.Font.Gotham
sub.Parent = bg

-- barra de progresso (fundo)
local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0, 300, 0, 12)
barBg.Position = UDim2.new(0.5, -150, 0.5, 20)
barBg.BackgroundColor3 = Color3.fromRGB(200, 120, 160)
barBg.BorderSizePixel = 0
barBg.Parent = bg
local barBgCorner = Instance.new("UICorner")
barBgCorner.CornerRadius = UDim.new(1, 0)
barBgCorner.Parent = barBg

-- barra de progresso (preenchimento)
local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
barFill.BorderSizePixel = 0
barFill.Parent = barBg
local barFillCorner = Instance.new("UICorner")
barFillCorner.CornerRadius = UDim.new(1, 0)
barFillCorner.Parent = barFill

-- anima a barra de 0 a 100% durante DURACAO segundos
local tween = TweenService:Create(
    barFill,
    TweenInfo.new(DURACAO, Enum.EasingStyle.Linear),
    { Size = UDim2.new(1, 0, 1, 0) }
)
tween:Play()

-- espera o tempo
task.wait(DURACAO)

-- fade out
local fadeTween = TweenService:Create(
    bg,
    TweenInfo.new(FADE, Enum.EasingStyle.Linear),
    { BackgroundTransparency = 1 }
)
-- fade nos textos tambem
TweenService:Create(titulo, TweenInfo.new(FADE), { TextTransparency = 1 }):Play()
TweenService:Create(sub, TweenInfo.new(FADE), { TextTransparency = 1 }):Play()
TweenService:Create(barBg, TweenInfo.new(FADE), { BackgroundTransparency = 1 }):Play()
TweenService:Create(barFill, TweenInfo.new(FADE), { BackgroundTransparency = 1 }):Play()
fadeTween:Play()
fadeTween.Completed:Wait()

-- destroi a GUI (para de rodar)
gui:Destroy()

print("[HelloKittyLoader] Tela de carregamento finalizada e removida.")
