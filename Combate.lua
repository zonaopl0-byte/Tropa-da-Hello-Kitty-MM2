--[[
    HELLO KITTY HUB - DLC: COMBATE
    Auto Win: Inocente teleporta pro Lobby se for pro mapa.
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

-- ========== CORES ==========
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

-- ========== COLUNAS ==========
local LayoutFrame = Create("Frame", { Name = "CombatDLC_Layout", Size = UDim2.new(1, -6, 1, 0), BackgroundTransparency = 1 }, combatPage)
local LeftCol = Create("Frame", { Name = "LeftCol_Xerife", Size = UDim2.new(0.5, -4, 1, 0), BackgroundTransparency = 1 }, LayoutFrame)
Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, LeftCol)
local RightCol = Create("Frame", { Name = "RightCol_Murder", Size = UDim2.new(0.5, -4, 1, 0), Position = UDim2.new(0.5, 4, 0, 0), BackgroundTransparency = 1 }, LayoutFrame)
Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, RightCol)

Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "SHERIFF / HERO", TextColor3 = Color3.new(1,1,1), TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center }, LeftCol)
Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "MURDERER", TextColor3 = Color3.new(1,1,1), TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center }, RightCol)

-- ========== APOIO ==========
local function GetRole(player)
    local char = player.Character
    local bp = player:FindFirstChild("Backpack")
    local hasKnife = (char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
    local hasGun = (char and char:FindFirstChild("Gun")) or (bp and bp:FindFirstChild("Gun"))
    if hasKnife then return "Murderer" end
    if hasGun then 
        if player.Team and string.lower(player.Team.Name):find("hero") then return "Hero" end
        return "Sheriff" 
    end
    if player:GetAttribute("Dead") == true then return "Dead" end
    local r = player:GetAttribute("Role")
    if r then return tostring(r) end
    if player.Team then 
        local t = player.Team.Name
        if string.lower(t):find("murder") then return "Murderer" end
        if string.lower(t):find("sheriff") then return "Sheriff" end
        if string.lower(t):find("hero") then return "Hero" end
        return t
    end
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

local function GetAlivePlayers()
    local alive = {}
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then table.insert(alive, p) end
        end
    end
    return alive
end

-- ========== VERIFICA SE ESTÁ NO MAPA ==========
local function IsInMap()
    local map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("Map", true)
    if not map then return false end
    
    local myRoot = GetRoot(LocalPlayer)
    if not myRoot then return false end
    
    -- Verifica se o jogador está dentro da área do mapa
    -- (se a pasta Map for um Model, checa se está perto dela)
    if map:IsA("Model") then
        local mapPart = map.PrimaryPart or map:FindFirstChildWhichIsA("BasePart", true)
        if mapPart then
            return (myRoot.Position - mapPart.Position).Magnitude < 500
        end
    end
    
    return false
end

-- ========== AÇÕES ==========
local function TeleportToLobby()
    local lobby = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("Lobby", true)
    if not lobby then return end
    local spawns = lobby:FindFirstChild("Spawns", true)
    local part = spawns and (spawns:IsA("BasePart") and spawns or spawns:FindFirstChildWhichIsA("BasePart", true))
    local spawn = part or lobby:FindFirstChildWhichIsA("SpawnLocation", true) or lobby:FindFirstChildWhichIsA("BasePart", true)
    if not spawn then return end
    local r = GetRoot(LocalPlayer)
    if r then r.CFrame = spawn.CFrame + Vector3.new(0, 3, 0); r.AssemblyLinearVelocity = Vector3.zero end
end

local IsBusy = false

local function ShootTarget(targetPlayer)
    local gun = GetGun()
    local myRoot = GetRoot(LocalPlayer)
    local targetRoot = GetRoot(targetPlayer)
    if not gun or not myRoot or not targetRoot then return false end
    local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if gun.Parent ~= LocalPlayer.Character and h then h:EquipTool(gun); task.wait(0.2) end
    local att = myRoot:FindFirstChild("GunRaycastAttachment")
    local origin = (att and att.WorldCFrame) or myRoot.CFrame
    local ev = gun:FindFirstChild("Shoot")
    if ev then pcall(function() ev:FireServer(origin, targetRoot.CFrame) end); return true end
    return false
end

local function AutoShootMurderer()
    if IsBusy then return false, false end
    IsBusy = true
    local m = GetMurderer()
    if not m then IsBusy = false; return false, true end
    local myRoot = GetRoot(LocalPlayer)
    local tRoot = GetRoot(m)
    if not myRoot or not tRoot then IsBusy = false; return false, false end
    local home = myRoot.CFrame
    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 5)
    myRoot.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.15)
    local ok = ShootTarget(m)
    task.wait(0.4)
    local h = m.Character and m.Character:FindFirstChildOfClass("Humanoid")
    local dead = not h or h.Health <= 0
    if not dead then myRoot.CFrame = home; myRoot.AssemblyLinearVelocity = Vector3.zero end
    IsBusy = false
    return ok, dead
end

-- ========== AUTO GRAB GUN (SÓ INOCENTE) ==========
local function AutoGrabGun()
    if GetRole(LocalPlayer) ~= "Innocent" then return end
    if IsBusy then return end
    IsBusy = true
    
    if not GetGun() then
        local drop = workspace:FindFirstChild("GunDrop", true)
        if drop then
            local part = drop:IsA("BasePart") and drop or drop:FindFirstChildWhichIsA("BasePart", true)
            if part then
                local myRoot = GetRoot(LocalPlayer)
                if myRoot then
                    local home = myRoot.CFrame
                    myRoot.CFrame = part.CFrame
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                    task.wait(0.2)
                    pcall(function()
                        firetouchinterest(myRoot, part, 0)
                        firetouchinterest(myRoot, part, 1)
                    end)
                    task.wait(0.3)
                    myRoot.CFrame = home
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end
    end
    
    IsBusy = false
end

local function StabTarget(targetPlayer)
    local knife = GetKnife()
    local myRoot = GetRoot(LocalPlayer)
    local tRoot = GetRoot(targetPlayer)
    if not knife or not myRoot or not tRoot then return false end
    local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if knife.Parent ~= LocalPlayer.Character and h then h:EquipTool(knife); task.wait(0.1) end
    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2)
    myRoot.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.1)
    local ev = knife:FindFirstChild("Events")
    if ev then
        ev.KnifeStabbed:FireServer()
        task.wait()
        ev.HandleTouched:FireServer(tRoot)
        return true
    end
    return false
end

-- ========== TOGGLE ==========
local function AddCustomToggle(title, initial, callback, parent)
    local row = Create("Frame", { Name = "CombatDLC_Item", Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = CurrentThemeButton, BorderSizePixel = 0 }, parent)
    Create("UICorner", { CornerRadius = UDim.new(0,7) }, row)
    local label = Create("TextLabel", { Size = UDim2.new(1,-60,1,0), Position = UDim2.fromOffset(10,0), BackgroundTransparency = 1, Text = title, TextColor3 = Color3.new(1,1,1), TextSize = 11, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left }, row)
    local track = Create("Frame", { Name = "ToggleTrack", Size = UDim2.fromOffset(36,20), Position = UDim2.new(1,-46,0.5,-10), BackgroundColor3 = CurrentThemeTrack, BorderSizePixel = 0 }, row)
    Create("UICorner", { CornerRadius = UDim.new(1,0) }, track)
    local knob = Create("Frame", { Name = "ToggleKnob", Size = UDim2.fromOffset(14,14), Position = UDim2.fromOffset(3,3), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0 }, track)
    Create("UICorner", { CornerRadius = UDim.new(1,0) }, knob)
    local hitbox = Create("TextButton", { Name = "ToggleHitbox", Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, row)
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
    return { Row = row, Hitbox = hitbox, GetState = function() return state end, SetState = function(v) state = v; updateVisual(v) end, Lock = function() hitbox.Active = false; row.BackgroundTransparency = 0.5 end, Unlock = function() hitbox.Active = true; row.BackgroundTransparency = 0 end }
end

-- ========== BOTÕES FLUTUANTES ==========
local FloatingBtnShot = nil
local FloatingBtnKill = nil

local function GetJumpPos()
    local jb = nil
    pcall(function()
        local tg = LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
        if tg then jb = tg:FindFirstChild("JumpButton") end
    end)
    if jb then return UDim2.new(jb.Position.X.Scale, jb.Position.X.Offset - 120, jb.Position.Y.Scale, jb.Position.Y.Offset - 90) end
    return UDim2.new(1, -150, 1, -180)
end

local function CreateShotButton()
    if FloatingBtnShot then FloatingBtnShot:Destroy() end
    local pos = GetJumpPos()
    FloatingBtnShot = Create("TextButton", { Name = "ShotMurderFloat", Size = UDim2.fromOffset(60, 60), Position = pos, BackgroundColor3 = CurrentThemeButton, Text = "SHOT\nMURDER", TextColor3 = Color3.new(1,1,1), TextSize = 11, Font = Enum.Font.GothamBold, ZIndex = 999 }, hubGui)
    Create("UICorner", { CornerRadius = UDim.new(0, 10) }, FloatingBtnShot)
    FloatingBtnShot.MouseButton1Click:Connect(function()
        local m = GetMurderer()
        if m then ShootTarget(m) end
    end)
    table.insert(AllUIElements, {Type = "FloatShot", Obj = FloatingBtnShot})
end

local function CreateKillButton()
    if FloatingBtnKill then FloatingBtnKill:Destroy() end
    local base = GetJumpPos()
    local pos = UDim2.new(base.X.Scale, base.X.Offset, base.Y.Scale, base.Y.Offset - 70)
    FloatingBtnKill = Create("TextButton", { Name = "KillAllFloat", Size = UDim2.fromOffset(60, 60), Position = pos, BackgroundColor3 = CurrentThemeButton, Text = "KILL\nALL", TextColor3 = Color3.new(1,1,1), TextSize = 11, Font = Enum.Font.GothamBold, ZIndex = 999 }, hubGui)
    Create("UICorner", { CornerRadius = UDim.new(0, 10) }, FloatingBtnKill)
    FloatingBtnKill.MouseButton1Click:Connect(function()
        task.spawn(function()
            for _, t in ipairs(GetAlivePlayers()) do
                if GetKnife() then StabTarget(t); task.wait(0.5) end
            end
        end)
    end)
    table.insert(AllUIElements, {Type = "FloatKill", Obj = FloatingBtnKill})
end

-- ========== LOOPS ==========
local AutoShotActive = false
local FloatToggleObj, AutoShotToggleObj, AutoGrabToggleObj, KillToggleObj, AutoKillToggleObj, AutoWinToggleObj

local function ToggleAutoShot(enabled)
    if enabled then
        if AutoShotActive then return end
        AutoShotActive = true
        if FloatingBtnShot then FloatingBtnShot.Visible = false end
        if FloatToggleObj then FloatToggleObj.SetState(false); FloatToggleObj.Lock() end
        task.spawn(function()
            while AutoShotActive do
                pcall(function()
                    local m = GetMurderer()
                    local gun = GetGun()
                    if m and gun then AutoShootMurderer() end
                end)
                task.wait(0.5)
            end
            if FloatToggleObj then FloatToggleObj.Unlock(); FloatToggleObj.SetState(false) end
            if FloatingBtnShot then FloatingBtnShot.Visible = true end
        end)
    else
        AutoShotActive = false
        if FloatToggleObj then FloatToggleObj.Unlock() end
        if FloatingBtnShot then FloatingBtnShot.Visible = true end
    end
end

local AutoGrabActive = false
local function ToggleAutoGrab(enabled)
    if enabled then
        if AutoGrabActive then return end
        AutoGrabActive = true
        task.spawn(function()
            while AutoGrabActive do
                pcall(AutoGrabGun)
                task.wait(1)
            end
        end)
    else
        AutoGrabActive = false
    end
end

local AutoKillActive = false
local function ToggleAutoKill(enabled)
    if enabled then
        if AutoKillActive then return end
        AutoKillActive = true
        if FloatingBtnKill then FloatingBtnKill.Visible = false end
        if KillToggleObj then KillToggleObj.SetState(false); KillToggleObj.Lock() end
        task.spawn(function()
            while AutoKillActive do
                pcall(function()
                    local knife = GetKnife()
                    if knife then
                        for _, t in ipairs(GetAlivePlayers()) do
                            if not AutoKillActive then break end
                            StabTarget(t)
                            task.wait(0.4)
                        end
                    end
                end)
                task.wait(1)
            end
            if KillToggleObj then KillToggleObj.Unlock(); KillToggleObj.SetState(false) end
            if FloatingBtnKill then FloatingBtnKill.Visible = true end
        end)
    else
        AutoKillActive = false
        if KillToggleObj then KillToggleObj.Unlock() end
        if FloatingBtnKill then FloatingBtnKill.Visible = true end
    end
end

-- ========== AUTO WIN ==========
local AutoWinActive = false
local function ToggleAutoWin(enabled)
    if enabled then
        if AutoWinActive then return end
        AutoWinActive = true
        
        ToggleAutoShot(false); ToggleAutoGrab(false); ToggleAutoKill(false)
        
        if AutoShotToggleObj then AutoShotToggleObj.Lock() end
        if AutoGrabToggleObj then AutoGrabToggleObj.Lock() end
        if AutoKillToggleObj then AutoKillToggleObj.Lock() end
        if FloatToggleObj then FloatToggleObj.Lock() end
        if KillToggleObj then KillToggleObj.Lock() end
        
        task.spawn(function()
            while AutoWinActive do
                pcall(function()
                    local role = GetRole(LocalPlayer)
                    
                    if role == "Murderer" then
                        -- Assassino: Mata
                        local knife = GetKnife()
                        if knife then
                            for _, t in ipairs(GetAlivePlayers()) do
                                if not AutoWinActive then break end
                                StabTarget(t)
                                task.wait(0.5)
                            end
                        end
                        
                    elseif role == "Sheriff" or role == "Hero" then
                        -- Xerife/Herói: Atira
                        local m = GetMurderer()
                        if m then AutoShootMurderer() end
                        
                    elseif role == "Innocent" then
                        -- Inocente: Se foi pro mapa, volta pro Lobby
                        if IsInMap() then
                            TeleportToLobby()
                        else
                            -- Se já está no lobby e não tem arma, tenta pegar se cair
                            if not GetGun() then
                                AutoGrabGun()
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    else
        AutoWinActive = false
        if AutoShotToggleObj then AutoShotToggleObj.Unlock() end
        if AutoGrabToggleObj then AutoGrabToggleObj.Unlock() end
        if AutoKillToggleObj then AutoKillToggleObj.Unlock() end
        if FloatToggleObj then FloatToggleObj.Unlock() end
        if KillToggleObj then KillToggleObj.Unlock() end
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

AutoGrabToggleObj = AddCustomToggle("🔫 Auto Grab Gun (Inocente)", false, function(state)
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

-- ========== LOOP DE CORES ==========
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
                elseif item.Type == "FloatShot" or item.Type == "FloatKill" then
                    item.Obj.BackgroundColor3 = CurrentThemeButton
                end
            end
        end
    end
end)

print("[HelloKitty DLC] Aba Combate com Auto Win: Inocente foge pro Lobby se for pro mapa!")
