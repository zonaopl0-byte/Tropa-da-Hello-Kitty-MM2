--[[
    HELLO KITTY HUB - DLC: COMBATE
    Auto Win com Auto Grab, e Auto Grab Gun com retorno garantido.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local hubGui = PlayerGui:WaitForChild("HelloKittyHub", 10)
if not hubGui then return end

local pagesContainer = hubGui:FindFirstChild("Main") and hubGui.Main:FindFirstChild("PagesContainer")
local combatPage = pagesContainer and pagesContainer:FindFirstChild("COMBATE")
if not combatPage then return end

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
local CurrentThemeButton = Color3.fromRGB(255,145,190)
local CurrentThemeTrack = Color3.fromRGB(150,85,115)
local CurrentThemeHeader = Color3.fromRGB(255,125,180)

local function UpdateThemeColors()
    local header = hubGui:FindFirstChild("Main") and hubGui.Main:FindFirstChild("Header")
    if header then CurrentThemeHeader = header.BackgroundColor3 end
    
    local teleportPage = hubGui.Main:FindFirstChild("PagesContainer") and hubGui.Main.PagesContainer:FindFirstChild("TELEPORT")
    if teleportPage then
        local btn = teleportPage:FindFirstChildWhichIsA("TextButton")
        if btn then CurrentThemeButton = btn.BackgroundColor3 end
    end
    
    local sidebar = hubGui:FindFirstChild("Main") and hubGui.Main:FindFirstChild("Sidebar")
    if sidebar then CurrentThemeTrack = sidebar.BackgroundColor3 end
end

UpdateThemeColors()
local AllUIElements = {}

-- ========== CRIAÇÃO DAS DUAS COLUNAS ==========
local LayoutFrame = Create("Frame", {
    Name = "CombatDLC_Layout", Size = UDim2.new(1, -6, 1, 0), BackgroundTransparency = 1,
}, combatPage)

local LeftCol = Create("Frame", {
    Name = "LeftCol_Xerife", Size = UDim2.new(0.5, -4, 1, 0), BackgroundTransparency = 1,
}, LayoutFrame)
Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, LeftCol)

local RightCol = Create("Frame", {
    Name = "RightCol_Murder", Size = UDim2.new(0.5, -4, 1, 0),
    Position = UDim2.new(0.5, 4, 0, 0), BackgroundTransparency = 1,
}, LayoutFrame)
Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, RightCol)

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

-- ========== TELEPORTE PARA O LOBBY ==========
local function TeleportToLobby()
    local lobby = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("Lobby", true)
    if not lobby then return end
    
    local spawns = lobby:FindFirstChild("Spawns", true)
    local part = spawns and (spawns:IsA("BasePart") and spawns or spawns:FindFirstChildWhichIsA("BasePart", true))
    local spawn = part or lobby:FindFirstChildWhichIsA("SpawnLocation", true) or lobby:FindFirstChildWhichIsA("BasePart", true)
    
    if not spawn then return end
    
    local myRoot = GetRoot(LocalPlayer)
    if myRoot then
        myRoot.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
        myRoot.AssemblyLinearVelocity = Vector3.zero
    end
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

-- ========== AUTO GRAB GUN (VAI E VOLTA GARANTIDO) ==========
local function AutoGrabGun()
    -- Se já tem a arma, não faz nada
    if GetGun() then return end
    
    local drop = workspace:FindFirstChild("GunDrop", true)
    if not drop then return end
    local part = drop:IsA("BasePart") and drop or drop:FindFirstChildWhichIsA("BasePart", true)
    if not part then return end
    
    local myRoot = GetRoot(LocalPlayer)
    if not myRoot then return end
    
    -- Salva a posição original
    local originalCFrame = myRoot.CFrame
    
    -- Vai para a arma
    myRoot.CFrame = part.CFrame
    myRoot.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.2)
    
    -- Toca na arma para pegar
    pcall(function()
        firetouchinterest(myRoot, part, 0)
        firetouchinterest(myRoot, part, 1)
    end)
    task.wait(0.3)
    
    -- Volta para a posição original SEMPRE
    myRoot.CFrame = originalCFrame
    myRoot.AssemblyLinearVelocity = Vector3.zero
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
        BackgroundColor3 = CurrentThemeButton, BorderSizePixel = 0
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
        BackgroundColor3 = CurrentThemeTrack, BorderSizePixel = 0
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
        track.BackgroundColor3 = enabled and CurrentThemeHeader or CurrentThemeTrack
        knob.Position = enabled and UDim2.new(1,-17,0,3) or UDim2.fromOffset(3,3)
    end

    hitbox.MouseButton1Click:Connect(function()
        if not hitbox.Active then return end
        state = not state
        updateVisual(state)
        if callback then callback(state) end
    end)
    
    updateVisual(state)
    table.insert(AllUIElements, {Type = "Row", Obj = row, Track = track})
    
    return { 
        Row = row, Hitbox = hitbox, Update = updateVisual, 
        GetState = function() return state end, 
        SetState = function(v) state = v; updateVisual(v) end,
        Lock = function() hitbox.Active = false; row.BackgroundTransparency = 0.5 end,
        Unlock = function() hitbox.Active = true; row.BackgroundTransparency = 0 end
    }
end

-- ========== BOTÕES FLUTUANTES ==========
local FloatingBtnShot = nil
local FloatingBtnKill = nil
local IsKilling = false

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
        BackgroundColor3 = CurrentThemeButton, 
        Text = "SHOT\nMURDER",
        TextColor3 = Color3.new(1,1,1), TextSize = 11, Font = Enum.Font.GothamBold, ZIndex = 999
    }, hubGui)
    Create("UICorner", { CornerRadius = UDim.new(0, 10) }, FloatingBtnShot)
    FloatingBtnShot.MouseButton1Click:Connect(ManualShootMurderer)
    table.insert(AllUIElements, {Type = "FloatShot", Obj = FloatingBtnShot})
end

local function CreateKillButton()
    if FloatingBtnKill then FloatingBtnKill:Destroy() end
    local basePos = GetJumpPosition()
    local killPos = UDim2.new(basePos.X.Scale, basePos.X.Offset, basePos.Y.Scale, basePos.Y.Offset - 70)

    FloatingBtnKill = Create("TextButton", {
        Name = "KillAllFloat", Size = UDim2.fromOffset(60, 60), Position = killPos,
        BackgroundColor3 = CurrentThemeButton, 
        Text = "KILL\nALL",
        TextColor3 = Color3.new(1,1,1), TextSize = 11, Font = Enum.Font.GothamBold, ZIndex = 999
    }, hubGui)
    Create("UICorner", { CornerRadius = UDim.new(0, 10) }, FloatingBtnKill)
    
    FloatingBtnKill.MouseButton1Click:Connect(function()
        if IsKilling then return end
        IsKilling = true
        task.spawn(function()
            KillAll()
            IsKilling = false
        end)
    end)
    
    table.insert(AllUIElements, {Type = "FloatKill", Obj = FloatingBtnKill})
end

-- ========== LÓGICAS DE LOOP ==========
local AutoShotActive = false
local AutoShotThread = nil
local FloatToggleObj = nil
local AutoShotToggleObj = nil
local WasFloatActiveBeforeAuto = false
local IsGrabbingGun = false

local AutoKillActive = false
local AutoKillThread = nil
local KillToggleObj = nil
local AutoKillToggleObj = nil
local WasKillFloatActiveBeforeAuto = false

-- FUNÇÃO AUTO SHOT
local function ToggleAutoShot(enabled)
    if enabled and not AutoShotActive then
        AutoShotActive = true
        WasFloatActiveBeforeAuto = FloatToggleObj.GetState()
        
        if FloatingBtnShot then FloatingBtnShot.Visible = false end
        if FloatToggleObj then
            FloatToggleObj.SetState(false)
            FloatToggleObj.Lock()
        end
        
        AutoShotThread = task.spawn(function()
            while AutoShotActive do
                if IsGrabbingGun then task.wait(0.5); continue end
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
            FloatToggleObj.SetState(WasFloatActiveBeforeAuto)
            if WasFloatActiveBeforeAuto then CreateShotButton()
            else if FloatingBtnShot then FloatingBtnShot:Destroy(); FloatingBtnShot = nil end end
        end
    end
end

-- FUNÇÃO AUTO GRAB
local AutoGrabActive = false
local AutoGrabThread = nil
local AutoGrabToggleObj = nil

local function ToggleAutoGrab(enabled)
    if enabled and not AutoGrabActive then
        AutoGrabActive = true
        AutoGrabThread = task.spawn(function()
            while AutoGrabActive do
                if AutoShotActive then task.wait(0.5); continue end
                IsGrabbingGun = true
                AutoGrabGun()
                IsGrabbingGun = false
                task.wait(1)
            end
        end)
    else
        AutoGrabActive = false
        if AutoGrabThread then task.cancel(AutoGrabThread); AutoGrabThread = nil end
    end
end

-- FUNÇÃO AUTO KILL ALL
local function ToggleAutoKill(enabled)
    if enabled and not AutoKillActive then
        AutoKillActive = true
        WasKillFloatActiveBeforeAuto = KillToggleObj.GetState()
        
        if FloatingBtnKill then FloatingBtnKill.Visible = false end
        if KillToggleObj then
            KillToggleObj.SetState(false)
            KillToggleObj.Lock()
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
        
        if KillToggleObj then
            KillToggleObj.Unlock()
            KillToggleObj.SetState(WasKillFloatActiveBeforeAuto)
            
            if WasKillFloatActiveBeforeAuto then 
                CreateKillButton() 
            else 
                if FloatingBtnKill then FloatingBtnKill:Destroy(); FloatingBtnKill = nil end 
            end
        end
    end
end

-- ========== AUTO WIN ==========
local AutoWinActive = false
local AutoWinThread = nil
local AutoWinToggleObj = nil

local function ToggleAutoWin(enabled)
    if enabled and not AutoWinActive then
        AutoWinActive = true
        
        -- Desliga o que estiver ligado
        if AutoShotActive then ToggleAutoShot(false); if AutoShotToggleObj then AutoShotToggleObj.SetState(false) end end
        if AutoKillActive then ToggleAutoKill(false); if AutoKillToggleObj then AutoKillToggleObj.SetState(false) end end
        if AutoGrabActive then ToggleAutoGrab(false); if AutoGrabToggleObj then AutoGrabToggleObj.SetState(false) end end
        
        -- Bloqueia os toggles manuais
        if AutoShotToggleObj then AutoShotToggleObj.Lock() end
        if AutoKillToggleObj then AutoKillToggleObj.Lock() end
        if FloatToggleObj then FloatToggleObj.Lock() end
        if KillToggleObj then KillToggleObj.Lock() end
        if AutoGrabToggleObj then AutoGrabToggleObj.Lock() end
        
        AutoWinThread = task.spawn(function()
            while AutoWinActive do
                local role = GetRole(LocalPlayer)
                
                if role == "Murderer" then
                    -- Assassino: Auto Kill All ligado, Auto Shot e Grab desligados
                    if not AutoKillActive then ToggleAutoKill(true); if AutoKillToggleObj then AutoKillToggleObj.SetState(true) end end
                    if AutoShotActive then ToggleAutoShot(false); if AutoShotToggleObj then AutoShotToggleObj.SetState(false) end end
                    if AutoGrabActive then ToggleAutoGrab(false); if AutoGrabToggleObj then AutoGrabToggleObj.SetState(false) end end
                    
                elseif role == "Sheriff" or role == "Hero" then
                    -- Xerife/Herói: Auto Shot + Auto Grab ligados
                    if not AutoShotActive then ToggleAutoShot(true); if AutoShotToggleObj then AutoShotToggleObj.SetState(true) end end
                    if not AutoGrabActive then ToggleAutoGrab(true); if AutoGrabToggleObj then AutoGrabToggleObj.SetState(true) end end
                    if AutoKillActive then ToggleAutoKill(false); if AutoKillToggleObj then AutoKillToggleObj.SetState(false) end end
                    
                elseif role == "Innocent" then
                    -- Inocente: Teleporta pro Lobby
                    if AutoShotActive then ToggleAutoShot(false); if AutoShotToggleObj then AutoShotToggleObj.SetState(false) end end
                    if AutoKillActive then ToggleAutoKill(false); if AutoKillToggleObj then AutoKillToggleObj.SetState(false) end end
                    if AutoGrabActive then ToggleAutoGrab(false); if AutoGrabToggleObj then AutoGrabToggleObj.SetState(false) end end
                    TeleportToLobby()
                end
                
                task.wait(1)
            end
        end)
    else
        AutoWinActive = false
        if AutoWinThread then task.cancel(AutoWinThread); AutoWinThread = nil end
        
        -- Desliga tudo que o Auto Win ligou
        if AutoShotActive then ToggleAutoShot(false); if AutoShotToggleObj then AutoShotToggleObj.SetState(false) end end
        if AutoKillActive then ToggleAutoKill(false); if AutoKillToggleObj then AutoKillToggleObj.SetState(false) end end
        if AutoGrabActive then ToggleAutoGrab(false); if AutoGrabToggleObj then AutoGrabToggleObj.SetState(false) end end
        
        -- Desbloqueia os toggles
        if AutoShotToggleObj then AutoShotToggleObj.Unlock() end
        if AutoKillToggleObj then AutoKillToggleObj.Unlock() end
        if FloatToggleObj then FloatToggleObj.Unlock() end
        if KillToggleObj then KillToggleObj.Unlock() end
        if AutoGrabToggleObj then AutoGrabToggleObj.Unlock() end
    end
end

-- ========== INICIALIZAÇÃO ==========
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

KillToggleObj = AddCustomToggle("🔪 Botão Flutuante (Kill All)", false, function(state)
    if state then CreateKillButton()
    else if FloatingBtnKill then FloatingBtnKill:Destroy(); FloatingBtnKill = nil end end
end, RightCol)

AutoKillToggleObj = AddCustomToggle("🤖 Auto Kill All", false, function(state)
    ToggleAutoKill(state)
end, RightCol)

AutoWinToggleObj = AddCustomToggle("👑 Auto Win", false, function(state)
    ToggleAutoWin(state)
end, LeftCol)

-- ========== LOOP DE ATUALIZAÇÃO DE CORES ==========
task.spawn(function()
    while task.wait(2) do
        UpdateThemeColors()
        
        for _, item in ipairs(AllUIElements) do
            if item.Obj and item.Obj.Parent then
                if item.Type == "Row" then
                    item.Obj.BackgroundColor3 = CurrentThemeButton
                    if item.Track then item.Track.BackgroundColor3 = CurrentThemeTrack end
                elseif item.Type == "Btn" then
                    item.Obj.BackgroundColor3 = CurrentThemeButton
                elseif item.Type == "FloatShot" then
                    item.Obj.BackgroundColor3 = CurrentThemeButton
                elseif item.Type == "FloatKill" then
                    item.Obj.BackgroundColor3 = CurrentThemeButton
                end
            end
        end
    end
end)

print("[HelloKitty DLC] Aba Combate com Auto Win completo e Auto Grab com retorno!")
