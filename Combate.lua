--[[
    HELLO KITTY HUB - DLC: COMBATE
    Cores sincronizadas com o tema e Knife Throw corrigido.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Espera o Hub principal carregar
local hubGui = PlayerGui:WaitForChild("HelloKittyHub", 10)
if not hubGui then return end

local pagesContainer = hubGui:FindFirstChild("Main") and hubGui.Main:FindFirstChild("PagesContainer")
local combatPage = pagesContainer and pagesContainer:FindFirstChild("COMBATE")
if not combatPage then return end

-- Limpa a DLC antiga
for _,child in ipairs(combatPage:GetChildren()) do
    if child.Name == "CombatDLC_Item" or child.Name == "CombatDLC_Layout" then child:Destroy() end
end

local function Create(className, properties, parent)
    local obj = Instance.new(className)
    for k, v in pairs(properties) do obj[k] = v end
    obj.Parent = parent
    return obj
end

-- ========== SISTEMA DE CORES DINÂMICO ==========
-- Pega as cores do próprio Hub para garantir que fique idêntico
local themeButton = Color3.fromRGB(255,145,190) -- Fallback
local themeTrack = Color3.fromRGB(150,85,115)   -- Fallback
local themeHeader = Color3.fromRGB(255,125,180) -- Fallback

-- Tenta achar um botão existente na página do Hub (ex: um botão de teleporte)
local sampleBtn = hubGui:FindFirstChild("Main") and hubGui.Main:FindFirstChild("PagesContainer") and hubGui.Main.PagesContainer:FindFirstChild("TELEPORT") and hubGui.Main.PagesContainer.TELEPORT:FindFirstChildWhichIsA("TextButton")
if sampleBtn then
    themeButton = sampleBtn.BackgroundColor3
end

-- Tenta achar o Header do Hub
local sampleHeader = hubGui:FindFirstChild("Main") and hubGui.Main:FindFirstChild("Header")
if sampleHeader then
    themeHeader = sampleHeader.BackgroundColor3
end

-- Tenta achar a cor do Track (fundo de sliders/listas)
local sampleTrack = hubGui:FindFirstChild("Main") and hubGui.Main:FindFirstChild("Sidebar")
if sampleTrack then
    themeTrack = sampleTrack.BackgroundColor3
end

-- ========== CRIAÇÃO DAS DUAS COLUNAS ==========
local LayoutFrame = Create("Frame", {
    Name = "CombatDLC_Layout",
    Size = UDim2.new(1, -6, 1, 0),
    BackgroundTransparency = 1,
}, combatPage)

local LeftCol = Create("Frame", {
    Name = "LeftCol_Xerife",
    Size = UDim2.new(0.5, -4, 1, 0),
    BackgroundTransparency = 1,
}, LayoutFrame)
Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, LeftCol)

local RightCol = Create("Frame", {
    Name = "RightCol_Murder",
    Size = UDim2.new(0.5, -4, 1, 0),
    Position = UDim2.new(0.5, 4, 0, 0),
    BackgroundTransparency = 1,
}, LayoutFrame)
Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, RightCol)

-- Títulos
Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
    Text = "SHERIFF / HERO", TextColor3 = Color3.new(1,1,1),
    TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center,
}, LeftCol)

Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
    Text = "MURDERER", TextColor3 = Color3.new(1,1,1),
    TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center,
}, RightCol)

-- ========== FUNÇÕES DE APOIO ==========
local function GetRole(player)
    local char = player.Character
    local bp = player:FindFirstChild("Backpack")
    local hasKnife = (char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
    local hasGun = (char and char:FindFirstChild("Gun")) or (bp and bp:FindFirstChild("Gun"))
    
    if hasKnife then return "Murderer" end
    if hasGun then return "Sheriff" end
    if player:GetAttribute("Dead") == true then return "Dead" end
    local role = player:GetAttribute("Role")
    if role then return tostring(role) end
    if player.Team then return player.Team.Name end
    return "Innocent"
end

local function GetMurderer()
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and GetRole(p) == "Murderer" then return p end
    end
    return nil
end

local function GetGun()
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    return (char and char:FindFirstChild("Gun")) or (bp and bp:FindFirstChild("Gun"))
end

local function GetKnife()
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    return (char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
end

local function GetRoot(player)
    local char = player and player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ========== LÓGICA DE TIRO (XERIFE) ==========
local function ShootTarget(targetPlayer)
    local gun = GetGun()
    local myRoot = GetRoot(LocalPlayer)
    local targetRoot = GetRoot(targetPlayer)
    
    if not gun or not myRoot or not targetRoot then return false end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if gun.Parent ~= LocalPlayer.Character and humanoid then
        humanoid:EquipTool(gun)
        task.wait(0.2)
    end
    
    local attachment = myRoot:FindFirstChild("GunRaycastAttachment")
    local originCFrame = attachment and attachment.WorldCFrame or myRoot.CFrame
    local targetCFrame = targetRoot.CFrame
    
    local shootEvent = gun:FindFirstChild("Shoot")
    if shootEvent then
        shootEvent:FireServer(originCFrame, targetCFrame)
        return true
    end
    return false
end

local function ManualShootMurderer()
    local murderer = GetMurderer()
    if murderer then ShootTarget(murderer) end
end

local function AutoShootMurderer()
    local murderer = GetMurderer()
    if not murderer then return false, true end
    local myRoot = GetRoot(LocalPlayer)
    local targetRoot = GetRoot(murderer)
    if not myRoot or not targetRoot then return false, false end

    local originalCFrame = myRoot.CFrame
    myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 5)
    myRoot.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.15)
    
    local success = ShootTarget(murderer)
    task.wait(0.4)
    
    local targetHumanoid = murderer.Character and murderer.Character:FindFirstChildOfClass("Humanoid")
    local isDead = not targetHumanoid or targetHumanoid.Health <= 0
    
    if not isDead then
        myRoot.CFrame = originalCFrame
        myRoot.AssemblyLinearVelocity = Vector3.zero
    end
    return success, isDead
end

-- ========== AUTO GRAB GUN ==========
local function AutoGrabGun()
    if GetGun() then return end
    local drop = workspace:FindFirstChild("GunDrop", true)
    if not drop then return end
    local part = drop:IsA("BasePart") and drop or drop:FindFirstChildWhichIsA("BasePart", true)
    if not part then return end
    
    local myRoot = GetRoot(LocalPlayer)
    if not myRoot then return end
    local originalCFrame = myRoot.CFrame
    myRoot.CFrame = part.CFrame
    myRoot.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.15)
    pcall(function()
        firetouchinterest(myRoot, part, 0)
        firetouchinterest(myRoot, part, 1)
    end)
    task.wait(0.3)
    if not GetGun() then
        myRoot.CFrame = originalCFrame
        myRoot.AssemblyLinearVelocity = Vector3.zero
    end
end

-- ========== LÓGICA DO ASSASSINO (KILL) ==========
local function GetAlivePlayers()
    local alive = {}
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                table.insert(alive, p)
            end
        end
    end
    return alive
end

local function GetNearestPlayer()
    local myRoot = GetRoot(LocalPlayer)
    if not myRoot then return nil end
    
    local nearest = nil
    local shortestDistance = math.huge
    
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local targetRoot = GetRoot(p)
            if targetRoot then
                local distance = (targetRoot.Position - myRoot.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearest = p
                end
            end
        end
    end
    return nearest
end

local function StabTarget(targetPlayer)
    local knife = GetKnife()
    local myRoot = GetRoot(LocalPlayer)
    local targetRoot = GetRoot(targetPlayer)
    
    if not knife or not myRoot or not targetRoot then return false end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if knife.Parent ~= LocalPlayer.Character and humanoid then
        humanoid:EquipTool(knife)
        task.wait(0.1)
    end
    
    local standCFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
    myRoot.CFrame = standCFrame
    myRoot.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.1)
    
    local events = knife:FindFirstChild("Events")
    if events then
        events.KnifeStabbed:FireServer()
        task.wait()
        events.HandleTouched:FireServer(targetRoot)
        return true
    end
    return false
end

-- ========== KNIFE THROW (CORRIGIDO) ==========
local function ThrowKnife(targetPlayer)
    local knife = GetKnife()
    local myRoot = GetRoot(LocalPlayer)
    local targetRoot = GetRoot(targetPlayer)
    
    if not knife or not myRoot or not targetRoot then return false end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if knife.Parent ~= LocalPlayer.Character and humanoid then
        humanoid:EquipTool(knife)
        task.wait(0.2) -- Espera a faca carregar
    end
    
    local events = knife:FindFirstChild("Events")
    if not events then return false end
    
    -- O MM2 espera a posição de origem e a posição do alvo
    -- Usamos o CFrame da mão/corpo e a posição da cabeça do alvo
    local targetHead = targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head")
    local aimPos = targetHead and targetHead.Position or targetRoot.Position
    
    -- Dispara o evento de lançar (KnifeThrown ou Throw)
    local throwEvent = events:FindFirstChild("KnifeThrown") or events:FindFirstChild("Throw")
    if throwEvent then
        throwEvent:FireServer(myRoot.CFrame, aimPos)
        return true
    end
    
    -- Fallback: alguns servidores esperam apenas a posição do mouse
    local mouseEvent = events:FindFirstChild("MouseEvent")
    if mouseEvent then
        mouseEvent:FireServer(aimPos)
        return true
    end
    
    return false
end

local function KillAll()
    local targets = GetAlivePlayers()
    for _, target in ipairs(targets) do
        local knife = GetKnife()
        if knife then
            StabTarget(target)
            task.wait(0.5)
        end
    end
end

-- ========== CRIAÇÃO DO TOGGLE ==========
local function AddCustomToggle(title, initial, callback, parent)
    local row = Create("Frame", {
        Name = "CombatDLC_Item", Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = themeButton, BorderSizePixel = 0
    }, parent)
    Create("UICorner", { CornerRadius = UDim.new(0,7) }, row)

    local label = Create("TextLabel", {
        Size = UDim2.new(1,-60,1,0), Position = UDim2.fromOffset(10,0),
        BackgroundTransparency = 1, Text = title,
        TextColor3 = Color3.new(1,1,1), TextSize = 11,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left
    }, row)

    local track = Create("Frame", {
        Name = "ToggleTrack", Size = UDim2.fromOffset(36,20),
        Position = UDim2.new(1,-46,0.5,-10),
        BackgroundColor3 = themeTrack, BorderSizePixel = 0
    }, row)
    Create("UICorner", { CornerRadius = UDim.new(1,0) }, track)

    local knob = Create("Frame", {
        Name = "ToggleKnob", Size = UDim2.fromOffset(14,14),
        Position = UDim2.fromOffset(3,3),
        BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0
    }, track)
    Create("UICorner", { CornerRadius = UDim.new(1,0) }, knob)

    local hitbox = Create("TextButton", {
        Name = "ToggleHitbox", Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false
    }, row)

    local state = initial
    local function updateVisual(enabled)
        track.BackgroundColor3 = enabled and themeHeader or themeTrack
        knob.Position = enabled and UDim2.new(1,-17,0,3) or UDim2.fromOffset(3,3)
    end

    hitbox.MouseButton1Click:Connect(function()
        if not hitbox.Active then return end
        state = not state
        updateVisual(state)
        if callback then callback(state) end
    end)
    
    updateVisual(state)
    
    return { 
        Row = row, Hitbox = hitbox, Update = updateVisual, 
        GetState = function() return state end, 
        SetState = function(v) state = v; updateVisual(v) end,
        Lock = function() hitbox.Active = false end,
        Unlock = function() hitbox.Active = true end
    }
end

-- ========== BOTÕES FLUTUANTES ==========
local FloatingBtnShot = nil
local FloatingBtnKnife = nil

local function GetJumpPosition()
    local jumpButton = nil
    pcall(function()
        local touchGui = LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
        if touchGui then
            local jumpFrame = touchGui:FindFirstChild("JumpButton")
            if jumpFrame then jumpButton = jumpFrame end
        end
    end)
    
    if jumpButton then
        return UDim2.new(
            jumpButton.Position.X.Scale, jumpButton.Position.X.Offset - 120, 
            jumpButton.Position.Y.Scale, jumpButton.Position.Y.Offset - 90 
        )
    end
    return UDim2.new(1, -150, 1, -180)
end

local function CreateShotButton()
    if FloatingBtnShot then FloatingBtnShot:Destroy() end
    local pos = GetJumpPosition()

    FloatingBtnShot = Create("TextButton", {
        Name = "ShotMurderFloat", Size = UDim2.fromOffset(60, 60), Position = pos,
        BackgroundColor3 = themeButton, 
        Text = "SHOT\nMURDER",
        TextColor3 = Color3.new(1,1,1), TextSize = 11, Font = Enum.Font.GothamBold, ZIndex = 999
    }, hubGui)
    Create("UICorner", { CornerRadius = UDim.new(0, 10) }, FloatingBtnShot)
    FloatingBtnShot.MouseButton1Click:Connect(ManualShootMurderer)
end

local function CreateKnifeButton()
    if FloatingBtnKnife then FloatingBtnKnife:Destroy() end
    local basePos = GetJumpPosition()
    local knifePos = UDim2.new(basePos.X.Scale, basePos.X.Offset, basePos.Y.Scale, basePos.Y.Offset - 70)

    FloatingBtnKnife = Create("TextButton", {
        Name = "ThrowKnifeFloat", Size = UDim2.fromOffset(60, 60), Position = knifePos,
        BackgroundColor3 = themeTrack, 
        Text = "THROW\nKNIFE", 
        TextColor3 = Color3.new(1,1,1), TextSize = 11, Font = Enum.Font.GothamBold, ZIndex = 999
    }, hubGui)
    Create("UICorner", { CornerRadius = UDim.new(0, 10) }, FloatingBtnKnife)
    
    FloatingBtnKnife.MouseButton1Click:Connect(function()
        local nearest = GetNearestPlayer()
        if nearest then ThrowKnife(nearest) end
    end)
end

-- ========== LÓGICAS DE LOOP ==========
local AutoShotActive = false
local AutoShotThread = nil
local FloatToggleObj = nil
local AutoShotToggleObj = nil
local WasFloatActiveBeforeAuto = false

local function ToggleAutoShot(enabled)
    if enabled and not AutoShotActive then
        AutoShotActive = true
        WasFloatActiveBeforeAuto = FloatToggleObj.GetState()
        
        if FloatingBtnShot then FloatingBtnShot.Visible = false end
        if FloatToggleObj then
            FloatToggleObj.SetState(false)
            FloatToggleObj.Lock()
            FloatToggleObj.Row.BackgroundTransparency = 0.5
        end
        
        AutoShotThread = task.spawn(function()
            while AutoShotActive do
                local murderer = GetMurderer()
                local gun = GetGun()
                if not murderer or not gun then task.wait(1); continue end
                
                local success, isDead = AutoShootMurderer()
                if isDead then
                    AutoShotActive = false
                    if AutoShotToggleObj then AutoShotToggleObj.SetState(false) end
                    break
                end
                task.wait(1)
            end
            if not AutoShotActive then
                if FloatToggleObj then
                    FloatToggleObj.Unlock()
                    FloatToggleObj.Row.BackgroundTransparency = 0
                    FloatToggleObj.SetState(WasFloatActiveBeforeAuto)
                    if WasFloatActiveBeforeAuto then CreateShotButton()
                    else if FloatingBtnShot then FloatingBtnShot:Destroy(); FloatingBtnShot = nil end end
                end
            end
        end)
    else
        AutoShotActive = false
        if AutoShotThread then task.cancel(AutoShotThread); AutoShotThread = nil end
        if FloatToggleObj then
            FloatToggleObj.Unlock()
            FloatToggleObj.Row.BackgroundTransparency = 0
            FloatToggleObj.SetState(WasFloatActiveBeforeAuto)
            if WasFloatActiveBeforeAuto then CreateShotButton()
            else if FloatingBtnShot then FloatingBtnShot:Destroy(); FloatingBtnShot = nil end end
        end
    end
end

local AutoGrabActive = false
local AutoGrabThread = nil
local AutoGrabToggleObj = nil

local function ToggleAutoGrab(enabled)
    if enabled and not AutoGrabActive then
        AutoGrabActive = true
        AutoGrabThread = task.spawn(function()
            while AutoGrabActive do
                AutoGrabGun()
                task.wait(1)
            end
        end)
    else
        AutoGrabActive = false
        if AutoGrabThread then task.cancel(AutoGrabThread); AutoGrabThread = nil end
    end
end

local AutoKillActive = false
local AutoKillThread = nil
local AutoKillToggleObj = nil
local KillAllBtnObj = nil
local IsKilling = false

local function OnKillAllClicked()
    if AutoKillActive or IsKilling then return end
    IsKilling = true
    task.spawn(function()
        KillAll()
        IsKilling = false
    end)
end

local function ToggleAutoKill(enabled)
    if enabled and not AutoKillActive then
        AutoKillActive = true
        if KillAllBtnObj then
            KillAllBtnObj.Active = false
            KillAllBtnObj.BackgroundTransparency = 0.5
        end
        AutoKillThread = task.spawn(function()
            while AutoKillActive do
                local knife = GetKnife()
                if not knife then task.wait(1); continue end
                local targets = GetAlivePlayers()
                if #targets == 0 then task.wait(1); continue end
                for _, target in ipairs(targets) do
                    if not AutoKillActive then break end
                    StabTarget(target)
                    task.wait(0.4)
                end
                task.wait(1)
            end
        end)
    else
        AutoKillActive = false
        if AutoKillThread then task.cancel(AutoKillThread); AutoKillThread = nil end
        if KillAllBtnObj then
            KillAllBtnObj.Active = true
            KillAllBtnObj.BackgroundTransparency = 0
        end
    end
end

-- ========== INICIALIZAÇÃO ==========
-- Coluna Esquerda (Xerife)
FloatToggleObj = AddCustomToggle("🎯 Botão Flutuante (Shot)", false, function(state)
    if state then CreateShotButton()
    else if FloatingBtnShot then FloatingBtnShot:Destroy(); FloatingBtnShot = nil end end
end, LeftCol)

AutoShotToggleObj = AddCustomToggle("🤖 Auto Shot", false, function(state)
    ToggleAutoShot(state)
end, LeftCol)

AutoGrabToggleObj = AddCustomToggle("🔫 Auto Grab Gun", false, function(state)
    ToggleAutoGrab(state)
end, LeftCol)

-- Coluna Direita (Assassino)
local KnifeToggleObj = AddCustomToggle("🔪 Botão Flutuante (Knife)", false, function(state)
    if state then CreateKnifeButton()
    else if FloatingBtnKnife then FloatingBtnKnife:Destroy(); FloatingBtnKnife = nil end end
end, RightCol)

KillAllBtnObj = Create("TextButton", {
    Name = "CombatDLC_Item",
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundColor3 = themeButton,
    Text = "🔪 Kill All",
    TextColor3 = Color3.new(1,1,1),
    TextSize = 11,
    Font = Enum.Font.GothamBold,
}, RightCol)
Create("UICorner", { CornerRadius = UDim.new(0,7) }, KillAllBtnObj)
KillAllBtnObj.MouseButton1Click:Connect(OnKillAllClicked)

AutoKillToggleObj = AddCustomToggle("🤖 Auto Kill All", false, function(state)
    ToggleAutoKill(state)
end, RightCol)

print("[HelloKitty DLC] Aba Combate carregada e cores sincronizadas!")
