--[[
    HELLO KITTY HUB - TELA DE CARREGAMENTO COM PERFIL
    Roda junto com o hub.lua. Fica POR CIMA do hub (DisplayOrder 999).
    Mostra o perfil do criador, espera DURACAO segundos, faz fade out e se destroi.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- CONFIGURACOES DO PERFIL
local PROFILE_USER_ID = 493241893
local PROFILE_USERNAME = "Guilherme_FOX123"
local PROFILE_DISPLAYNAME = "OGuizin"

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

-- Fundo rosa
local bg = Instance.new("Frame")
bg.Name = "BG"
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(255, 190, 220)
bg.BorderSizePixel = 0
bg.Parent = gui

-- Título
local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 0, 60)
titulo.Position = UDim2.new(0, 0, 0.5, -150)
titulo.BackgroundTransparency = 1
titulo.Text = "🎀 HELLO KITTY HUB"
titulo.TextColor3 = Color3.fromRGB(255, 80, 140)
titulo.TextSize = 36
titulo.Font = Enum.Font.GothamBold
titulo.Parent = bg

-- Subtítulo
local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, 0, 0, 30)
sub.Position = UDim2.new(0, 0, 0.5, -90)
sub.BackgroundTransparency = 1
sub.Text = "Carregando..."
sub.TextColor3 = Color3.fromRGB(255, 255, 255)
sub.TextSize = 18
sub.Font = Enum.Font.Gotham
sub.Parent = bg

-- ========== CARTÃO DE PERFIL ==========
local profileFrame = Instance.new("Frame")
profileFrame.Size = UDim2.new(0, 260, 0, 80) -- Aumentei a altura de 60 para 80 para caber o texto
profileFrame.Position = UDim2.new(0.5, -130, 0.5, -20)
profileFrame.BackgroundColor3 = Color3.fromRGB(255, 160, 195)
profileFrame.BackgroundTransparency = 0.2
profileFrame.BorderSizePixel = 0
profileFrame.Parent = bg

local pCorner = Instance.new("UICorner")
pCorner.CornerRadius = UDim.new(0, 10)
pCorner.Parent = profileFrame

-- Foto do Avatar
local pImage = Instance.new("ImageLabel")
pImage.Size = UDim2.new(0, 44, 0, 44)
pImage.Position = UDim2.new(0, 8, 0, 8)
pImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
pImage.BackgroundTransparency = 0.5
pImage.Image = "rbxassetid://0"
pImage.Parent = profileFrame

local iCorner = Instance.new("UICorner")
iCorner.CornerRadius = UDim.new(0, 8)
iCorner.Parent = pImage

-- Nome de Exibição
local pDisplay = Instance.new("TextLabel")
pDisplay.Size = UDim2.new(1, -60, 0, 20)
pDisplay.Position = UDim2.new(0, 60, 0, 8)
pDisplay.BackgroundTransparency = 1
pDisplay.Text = PROFILE_DISPLAYNAME
pDisplay.TextColor3 = Color3.new(1, 1, 1)
pDisplay.TextSize = 14
pDisplay.Font = Enum.Font.GothamBold
pDisplay.TextXAlignment = Enum.TextXAlignment.Left
pDisplay.Parent = profileFrame

-- @Username
local pUser = Instance.new("TextLabel")
pUser.Size = UDim2.new(1, -60, 0, 15)
pUser.Position = UDim2.new(0, 60, 0, 28)
pUser.BackgroundTransparency = 1
pUser.Text = "@" .. PROFILE_USERNAME
pUser.TextColor3 = Color3.fromRGB(255, 235, 245)
pUser.TextSize = 11
pUser.Font = Enum.Font.Gotham
pUser.TextXAlignment = Enum.TextXAlignment.Left
pUser.Parent = profileFrame

-- Texto "Criador"
local pRole = Instance.new("TextLabel")
pRole.Size = UDim2.new(1, -60, 0, 15)
pRole.Position = UDim2.new(0, 60, 0, 45)
pRole.BackgroundTransparency = 1
pRole.Text = "Criador"
pRole.TextColor3 = Color3.fromRGB(255, 255, 255)
pRole.TextSize = 11
pRole.Font = Enum.Font.GothamBold
pRole.TextXAlignment = Enum.TextXAlignment.Left
pRole.Parent = profileFrame

-- Puxar a foto do avatar
task.spawn(function()
    local success, imageUrl = pcall(function()
        return Players:GetUserThumbnailAsync(
            PROFILE_USER_ID,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
    end)
    if success and imageUrl then
        pImage.Image = imageUrl
    end
end)

-- ========== BARRA DE PROGRESSO ==========
local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0, 300, 0, 12)
barBg.Position = UDim2.new(0.5, -150, 0.5, 80)
barBg.BackgroundColor3 = Color3.fromRGB(200, 120, 160)
barBg.BorderSizePixel = 0
barBg.Parent = bg
local barBgCorner = Instance.new("UICorner")
barBgCorner.CornerRadius = UDim.new(1, 0)
barBgCorner.Parent = barBg

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
barFill.BorderSizePixel = 0
barFill.Parent = barBg
local barFillCorner = Instance.new("UICorner")
barFillCorner.CornerRadius = UDim.new(1, 0)
barFillCorner.Parent = barFill

-- Animação da barra de 0 a 100%
local tween = TweenService:Create(
    barFill,
    TweenInfo.new(DURACAO, Enum.EasingStyle.Linear),
    { Size = UDim2.new(1, 0, 1, 0) }
)
tween:Play()

-- Espera o tempo
task.wait(DURACAO)

-- Fade out (some tudo suavemente)
local fadeTween = TweenService:Create(
    bg,
    TweenInfo.new(FADE, Enum.EasingStyle.Linear),
    { BackgroundTransparency = 1 }
)
TweenService:Create(titulo, TweenInfo.new(FADE), { TextTransparency = 1 }):Play()
TweenService:Create(sub, TweenInfo.new(FADE), { TextTransparency = 1 }):Play()
TweenService:Create(barBg, TweenInfo.new(FADE), { BackgroundTransparency = 1 }):Play()
TweenService:Create(barFill, TweenInfo.new(FADE), { BackgroundTransparency = 1 }):Play()
TweenService:Create(profileFrame, TweenInfo.new(FADE), { BackgroundTransparency = 1 }):Play()
TweenService:Create(pDisplay, TweenInfo.new(FADE), { TextTransparency = 1 }):Play()
TweenService:Create(pUser, TweenInfo.new(FADE), { TextTransparency = 1 }):Play()
TweenService:Create(pRole, TweenInfo.new(FADE), { TextTransparency = 1 }):Play()
TweenService:Create(pImage, TweenInfo.new(FADE), { ImageTransparency = 1 }):Play()

fadeTween:Play()
fadeTween.Completed:Wait()

-- Destroi a GUI (para de rodar)
gui:Destroy()

print("[HelloKittyLoader] Tela de carregamento com perfil finalizada.")
