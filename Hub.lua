--[[
    A TROPA DA HELLO KITTY HUB
    Versao 1.4.4 - MOBILE + PC
    by EOGuizin_X
]]

local HUB_VERSION = "1.4.4"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- CONFIGURACOES
local Settings = {
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 20,
    FarmSpeed = 22,
    MurdererRadius = 30,

    Fly = false,
    Noclip = false,
    AntiFling = false,
    AntiAfk = false,
    ESP = false,
    XRay = false,
    FullBright = false,

    AutoFarm = false,
    AvoidMurderer = true,
    ResetWhenFull = true
}

local Themes = {
    Kitty = {
        Main = Color3.fromRGB(255,190,220),
        Header = Color3.fromRGB(255,125,180),
        Button = Color3.fromRGB(255,145,190),
        Track = Color3.fromRGB(150,85,115)
    },
    Dark = {
        Main = Color3.fromRGB(35,35,42),
        Header = Color3.fromRGB(20,20,25),
        Button = Color3.fromRGB(65,65,75),
        Track = Color3.fromRGB(95,95,110)
    },
    Halloween = {
        Main = Color3.fromRGB(48,28,65),       -- roxo escuro
        Header = Color3.fromRGB(255,135,35),   -- laranja
        Button = Color3.fromRGB(205,105,35),   -- laranja queimado
        Track = Color3.fromRGB(105,65,130)     -- roxo medio
    },
    Christmas = {
        Main = Color3.fromRGB(35,75,55),
        Header = Color3.fromRGB(170,35,45),
        Button = Color3.fromRGB(195,55,65),
        Track = Color3.fromRGB(95,45,45)
    }
}

local CurrentTheme = "Kitty"
local OriginalCollision = {}
local OriginalTransparency = {}
local OriginalLighting
local ESPObjects = {}
local RoleCache = {}

local FlyVelocity
local FlyGyro
local FlyConnection

local FarmVelocity
local FarmAttachment
local FarmConnection

local UpHeld = false
local DownHeld = false

local SliderObjects = {}
local ToggleButtons = {}

local FarmNoclipBefore = false
local ResettingForFull = false
local LastResetTime = 0

local BagCurrent = nil
local BagMaximum = nil

local Remotes = ReplicatedStorage:WaitForChild("Remotes",10)
local Gameplay = Remotes and Remotes:WaitForChild("Gameplay",10)

local RoleRemote = Gameplay and Gameplay:FindFirstChild("GetCurrentPlayerData")
local CoinCollected = Gameplay and Gameplay:FindFirstChild("CoinCollected")
local CoinsStarted = Gameplay and Gameplay:FindFirstChild("CoinsStarted")
local RoundStart = Gameplay and Gameplay:FindFirstChild("RoundStart")
local RoundEnd = Gameplay and Gameplay:FindFirstChild("RoundEnd")

-- CRIAR OBJETOS
local function Create(className,properties,parent)
    local object = Instance.new(className)

    for property,value in pairs(properties) do
        object[property] = value
    end

    object.Parent = parent
    return object
end

-- REMOVER GUI ANTIGA
local old = PlayerGui:FindFirstChild("HelloKittyHub")
if old then
    old:Destroy()
end

-- GUI PRINCIPAL - LAYOUT 1.3.2
local TouchMode = UserInputService.TouchEnabled
local ScreenGui = Create("ScreenGui",{
    Name = "HelloKittyHub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
},PlayerGui)

local Main = Create("Frame",{
    Name = "Main",
    Size = TouchMode and UDim2.new(0.94,0,0.76,0) or UDim2.fromOffset(570,430),
    Position = UDim2.new(0.5,0,0.5,0),
    AnchorPoint = Vector2.new(0.5,0.5),
    BackgroundColor3 = Themes.Kitty.Main,
    BorderSizePixel = 0,
    Active = true
},ScreenGui)
Create("UISizeConstraint",{MinSize=Vector2.new(320,350),MaxSize=Vector2.new(570,480)},Main)
Create("UICorner",{CornerRadius=UDim.new(0,14)},Main)

local Header = Create("Frame",{
    Name = "Header", Size = UDim2.new(1,0,0,58),
    BackgroundColor3 = Themes.Kitty.Header, BorderSizePixel = 0, Active = true
},Main)
Create("UICorner",{CornerRadius=UDim.new(0,14)},Header)
Create("TextLabel",{
    Size=UDim2.new(1,-70,0,29), Position=UDim2.fromOffset(16,4),
    BackgroundTransparency=1, Text="🎀 HELLO KITTY HUB  •  v"..HUB_VERSION,
    TextColor3=Color3.new(1,1,1), TextSize=15, Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left
},Header)
Create("TextLabel",{
    Size=UDim2.new(1,-70,0,16), Position=UDim2.fromOffset(17,33),
    BackgroundTransparency=1, Text="by EOGuizin_X",
    TextColor3=Color3.fromRGB(255,235,245), TextSize=9, Font=Enum.Font.Gotham,
    TextXAlignment=Enum.TextXAlignment.Left
},Header)
local Minimize = Create("TextButton",{
    Size=UDim2.fromOffset(34,30), Position=UDim2.new(1,-46,0,14),
    BackgroundColor3=Color3.fromRGB(255,160,195), Text="—",
    TextColor3=Color3.new(1,1,1), TextSize=20, Font=Enum.Font.GothamBold
},Header)
Create("UICorner",{CornerRadius=UDim.new(0,8)},Minimize)

local Floating = Create("TextButton",{
    Name="FloatingButton", Size=UDim2.fromOffset(55,55),
    Position=UDim2.new(0,20,0.5,0), BackgroundColor3=Themes.Kitty.Header,
    Text="🎀", TextSize=28, Visible=false, Active=true
},ScreenGui)
Create("UICorner",{CornerRadius=UDim.new(1,0)},Floating)

local function MakeDraggable(object,handle)
    local dragging,dragStart,startPosition=false,nil,nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=input.Position; startPosition=object.Position
            input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local delta=input.Position-dragStart
            object.Position=UDim2.new(startPosition.X.Scale,startPosition.X.Offset+delta.X,startPosition.Y.Scale,startPosition.Y.Offset+delta.Y)
        end
    end)
end
MakeDraggable(Main,Header)
MakeDraggable(Floating,Floating)

-- MENU LATERAL E AREA DE CONTEUDO
local Sidebar = Create("Frame",{
    Name="Sidebar", Size=UDim2.new(0,132,1,-74), Position=UDim2.fromOffset(8,66),
    BackgroundTransparency=1
},Main)
Create("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},Sidebar)
local PagesContainer = Create("Frame",{
    Name="PagesContainer", Size=UDim2.new(1,-154,1,-76), Position=UDim2.fromOffset(146,66),
    BackgroundTransparency=1
},Main)
local Pages,TabButtons={},{}
local function CreatePage(name)
    local page=Create("ScrollingFrame",{Name=name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        BorderSizePixel=0,ScrollBarThickness=4,CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},PagesContainer)
    Create("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},page)
    Create("UIPadding",{PaddingRight=UDim.new(0,6),PaddingTop=UDim.new(0,2)},page)
    Pages[name]=page; return page
end
local PlayerPage=CreatePage("PLAYER")
local VisualPage=CreatePage("VISUALS")
local FarmPage=CreatePage("FARM")
local ConfigPage=CreatePage("CONFIG")
local SavesPage=CreatePage("SALVOS")
local SelectedPageName="PLAYER"
local function SelectPage(name)
    SelectedPageName=name
    for pageName,page in pairs(Pages) do page.Visible=pageName==name end
    for tabName,button in pairs(TabButtons) do
        button.BackgroundTransparency=tabName==name and 0 or 0.48
        button.TextTransparency=tabName==name and 0 or 0.12
    end
end
local function CreateTab(name,label)
    local button=Create("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=Themes.Kitty.Button,
        BackgroundTransparency=0.48,Text=label,TextColor3=Color3.new(1,1,1),TextSize=10,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},Sidebar)
    Create("UICorner",{CornerRadius=UDim.new(0,9)},button)
    Create("UIPadding",{PaddingLeft=UDim.new(0,12)},button)
    TabButtons[name]=button
    button.MouseButton1Click:Connect(function() SelectPage(name) end)
end
CreateTab("PLAYER","👤  PLAYER")
CreateTab("VISUALS","👁  VISUALS")
CreateTab("FARM","🪙  FARM")
CreateTab("SALVOS","💾  SALVAR")
CreateTab("CONFIG","⚙  CONFIG")
SelectPage("PLAYER")

-- BOTOES
local function AddButton(page,text,callback)
    local button = Create("TextButton",{
        Size = UDim2.new(1,-6,0,30),
        BackgroundColor3 = Themes[CurrentTheme].Button,
        Text = text,
        TextColor3 = Color3.new(1,1,1),
        TextSize = 11,
        Font = Enum.Font.GothamBold
    },page)

    Create("UICorner",{CornerRadius=UDim.new(0,7)},button)

    button.MouseButton1Click:Connect(callback)
    return button
end

-- TOGGLES (chave deslizante no estilo Mario Hub)
local function AddToggle(page,title,setting,callback)
    local row = Create("Frame",{
        Name = "ToggleContainer",
        Size = UDim2.new(1,-6,0,34),
        BackgroundColor3 = Themes.Kitty.Button,
        BorderSizePixel = 0
    },page)
    Create("UICorner",{CornerRadius=UDim.new(0,7)},row)

    local label = Create("TextLabel",{
        Size = UDim2.new(1,-60,1,0),
        Position = UDim2.fromOffset(10,0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.new(1,1,1),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    },row)

    local track = Create("Frame",{
        Name = "ToggleTrack",
        Size = UDim2.fromOffset(36,20),
        Position = UDim2.new(1,-46,0.5,-10),
        BackgroundColor3 = Themes.Kitty.Track,
        BorderSizePixel = 0
    },row)
    Create("UICorner",{CornerRadius=UDim.new(1,0)},track)

    local knob = Create("Frame",{
        Name = "ToggleKnob",
        Size = UDim2.fromOffset(14,14),
        Position = UDim2.fromOffset(3,3),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0
    },track)
    Create("UICorner",{CornerRadius=UDim.new(1,0)},knob)

    local hitbox = Create("TextButton",{
        Name = "ToggleHitbox",
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    },row)

    local function updateVisual(enabled)
        track.BackgroundColor3 = enabled and Themes[CurrentTheme].Header or Themes[CurrentTheme].Track
        knob.Position = enabled and UDim2.new(1,-17,0,3) or UDim2.fromOffset(3,3)
    end

    hitbox.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        updateVisual(Settings[setting])
        if callback then callback(Settings[setting]) end
    end)

    ToggleButtons[setting] = {
        Row = row, Track = track, Knob = knob, Update = updateVisual, Title = title, Callback = callback
    }
    updateVisual(Settings[setting] == true)
    return row
end

local function SetToggleVisual(setting,enabled)
    local item = ToggleButtons[setting]
    if item and item.Update then item.Update(enabled) end
end

-- SLIDERS
local function AddSlider(page,title,setting,minimum,maximum,step)
    local frame = Create("Frame",{
        Name = "SliderContainer",
        Size = UDim2.new(1,-6,0,55),
        BackgroundColor3 = Themes.Kitty.Button,
        BorderSizePixel = 0
    },page)

    Create("UICorner",{CornerRadius=UDim.new(0,7)},frame)

    local label = Create("TextLabel",{
        Size = UDim2.new(1,-16,0,22),
        Position = UDim2.fromOffset(8,2),
        BackgroundTransparency = 1,
        TextColor3 = Color3.new(1,1,1),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    },frame)

    local bar = Create("Frame",{
        Name = "SliderBackground",
        Size = UDim2.new(1,-20,0,8),
        Position = UDim2.fromOffset(10,35),
        BackgroundColor3 = Themes.Kitty.Track,
        BorderSizePixel = 0,
        Active = true
    },frame)

    Create("UICorner",{CornerRadius=UDim.new(1,0)},bar)

    local fill = Create("Frame",{
        Name = "SliderFill",
        Size = UDim2.new(0,0,1,0),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0
    },bar)

    Create("UICorner",{CornerRadius=UDim.new(1,0)},fill)

    local knob = Create("Frame",{
        Name = "SliderKnob",
        Size = UDim2.fromOffset(16,16),
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0,0,0.5,0),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0
    },bar)

    Create("UICorner",{CornerRadius=UDim.new(1,0)},knob)

    local dragging = false

    local function Update(value)
        value = math.clamp(value,minimum,maximum)
        value = math.floor(value/step+0.5)*step

        Settings[setting] = math.clamp(value,minimum,maximum)

        local percent = (Settings[setting]-minimum)/(maximum-minimum)

        fill.Size = UDim2.new(percent,0,1,0)
        knob.Position = UDim2.new(percent,0,0.5,0)
        label.Text = title..": "..tostring(Settings[setting])
    end

    local function UpdateFromInput(input)
        if bar.AbsoluteSize.X <= 0 then return end

        local percent = math.clamp(
            (input.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,
            0,1
        )

        Update(minimum+(maximum-minimum)*percent)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateFromInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            UpdateFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    table.insert(SliderObjects,{
        Frame = frame,
        Bar = bar,
        Fill = fill,
        Knob = knob,
        Setting = setting,
        Set = Update, Minimum = minimum, Maximum = maximum, Step = step
    })

    Update(Settings[setting])
end

-- MOVIMENTACAO
local function ApplyMovement()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.WalkSpeed = Settings.WalkSpeed
        humanoid.UseJumpPower = true
        humanoid.JumpPower = Settings.JumpPower
    end
end


-- NOCLIP
local function RestoreCollision()
    for part,original in pairs(OriginalCollision) do
        if part and part.Parent then
            part.CanCollide = original
        end
    end

    table.clear(OriginalCollision)
end

local function SetNoclip(enabled)
    Settings.Noclip = enabled

    if not enabled then
        RestoreCollision()
    end

    SetToggleVisual("Noclip",enabled)
end

AddToggle(PlayerPage,"Noclip","Noclip",SetNoclip)

RunService.Stepped:Connect(function()
    if not Settings.Noclip then return end

    local character = LocalPlayer.Character
    if not character then return end

    for _,part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if OriginalCollision[part] == nil then
                OriginalCollision[part] = part.CanCollide
            end

            part.CanCollide = false
        end
    end
end)

-- ANTI-FLING
local AntiFlingConnection

local function SetAntiFling(enabled)
    Settings.AntiFling = enabled

    if AntiFlingConnection then
        AntiFlingConnection:Disconnect()
        AntiFlingConnection = nil
    end

    if enabled then
        AntiFlingConnection = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if not root or not humanoid or humanoid.Health <= 0 then
                return
            end

            local velocity = root.AssemblyLinearVelocity
            local angular = root.AssemblyAngularVelocity

            if velocity.Magnitude > 120 then
                root.AssemblyLinearVelocity = Vector3.new(
                    math.clamp(velocity.X,-60,60),
                    math.clamp(velocity.Y,-60,60),
                    math.clamp(velocity.Z,-60,60)
                )
            end

            if angular.Magnitude > 80 then
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end

    SetToggleVisual("AntiFling",enabled)
end

AddToggle(PlayerPage,"Anti-Fling","AntiFling",SetAntiFling)

-- FLY MOBILE
local FlyControls = Create("Frame",{
    Name = "FlyControls",
    Size = UDim2.fromOffset(110,100),
    Position = UDim2.new(1,-120,1,-230),
    BackgroundTransparency = 1,
    Visible = false,
    Active = true
},ScreenGui)

local UpButton = Create("TextButton",{
    Size = UDim2.fromOffset(48,42),
    Position = UDim2.fromOffset(55,0),
    BackgroundColor3 = Themes.Kitty.Header,
    Text = "⬆",
    TextSize = 22,
    TextColor3 = Color3.new(1,1,1)
},FlyControls)

local DownButton = Create("TextButton",{
    Size = UDim2.fromOffset(48,42),
    Position = UDim2.fromOffset(55,48),
    BackgroundColor3 = Themes.Kitty.Header,
    Text = "⬇",
    TextSize = 22,
    TextColor3 = Color3.new(1,1,1)
},FlyControls)

Create("UICorner",{CornerRadius=UDim.new(0,9)},UpButton)
Create("UICorner",{CornerRadius=UDim.new(0,9)},DownButton)

UpButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        UpHeld = true
    end
end)

UpButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        UpHeld = false
    end
end)

DownButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        DownHeld = true
    end
end)

DownButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        DownHeld = false
    end
end)

local function ClearFlyObjects()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    if FlyVelocity then
        FlyVelocity:Destroy()
        FlyVelocity = nil
    end

    if FlyGyro then
        FlyGyro:Destroy()
        FlyGyro = nil
    end

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    UpHeld = false
    DownHeld = false
end

local function StopFly()
    Settings.Fly = false
    ClearFlyObjects()
    SetToggleVisual("Fly",false)
    FlyControls.Visible = false
end

local function StartFly()
    ClearFlyObjects()

    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then
        Settings.Fly = false
        SetToggleVisual("Fly",false)
        return
    end

    Settings.Fly = true
    humanoid.PlatformStand = false
    humanoid.AutoRotate = false

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.Name = "KittyFlyVelocity"
    FlyVelocity.MaxForce = Vector3.new(1000000,1000000,1000000)
    FlyVelocity.P = 12500
    FlyVelocity.Velocity = Vector3.zero
    FlyVelocity.Parent = root

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.Name = "KittyFlyGyro"
    FlyGyro.MaxTorque = Vector3.new(1000000,1000000,1000000)
    FlyGyro.P = 15000
    FlyGyro.D = 1000
    FlyGyro.CFrame = Camera.CFrame
    FlyGyro.Parent = root

    FlyControls.Visible = UserInputService.TouchEnabled

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Settings.Fly or not root.Parent or not humanoid.Parent then
            StopFly()
            return
        end

        Camera = workspace.CurrentCamera

        local direction = humanoid.MoveDirection
        local vertical = 0

        if UpHeld or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vertical = vertical+1
        end

        if DownHeld or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            vertical = vertical-1
        end

        FlyVelocity.Velocity =
            direction*Settings.FlySpeed+
            Vector3.new(0,vertical*Settings.FlySpeed,0)

        FlyGyro.CFrame = Camera.CFrame
    end)

    SetToggleVisual("Fly",true)
end

AddToggle(PlayerPage,"Fly","Fly",function(enabled)
    if enabled then
        StartFly()
    else
        StopFly()
    end
end)

-- ESP
local RoleColors = {
    Innocent = Color3.fromRGB(0,255,70),
    Murderer = Color3.fromRGB(255,35,35),
    Sheriff = Color3.fromRGB(40,130,255),
    Hero = Color3.fromRGB(255,220,0),
    Dead = Color3.fromRGB(190,190,190),
    Unknown = Color3.fromRGB(235,235,235)
}

local function NormalizeRole(role)
    local value = string.lower(tostring(role or ""))

    if value:find("murder") or value == "assassino" then
        return "Murderer"
    end

    if value:find("sheriff") or value == "xerife" then
        return "Sheriff"
    end

    if value:find("hero") or value == "heroi" or value == "herói" then
        return "Hero"
    end

    if value:find("dead") or value == "morto" then
        return "Dead"
    end

    if value:find("innocent") or value == "inocente" then
        return "Innocent"
    end

    return nil
end

local RoleFetchBusy = false
local LastRoleFetch = 0

local function RefreshRoles(force)
    if RoleFetchBusy then return end

    if not force and os.clock()-LastRoleFetch < 1 then
        return
    end

    LastRoleFetch = os.clock()

    if not RoleRemote or not RoleRemote.Parent then
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local gameplay = remotes and remotes:FindFirstChild("Gameplay")
        RoleRemote = gameplay and gameplay:FindFirstChild("GetCurrentPlayerData")
    end

    if not RoleRemote or not RoleRemote:IsA("RemoteFunction") then
        return
    end

    RoleFetchBusy = true

    local success,roster = pcall(function()
        return RoleRemote:InvokeServer()
    end)

    RoleFetchBusy = false

    if success and type(roster) == "table" then
        RoleCache = roster
    end
end

-- VERIFICAR SE O PERSONAGEM ESTA VIVO
-- Nao exige workspace.Map: algumas versoes/servidores do MM2
-- organizam o mapa de outra forma ou demoram para replicar essa pasta.
local function IsLocalPlayerPlaying()
    local character = LocalPlayer.Character
    if not character or not character.Parent then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or humanoid.Health <= 0 or not root then
        return false
    end

    return true
end

local function GetPlayerTool(player,name)
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")

    return (character and character:FindFirstChild(name))
        or (backpack and backpack:FindFirstChild(name))
end

local function GetRole(player)
    local entry = RoleCache[player.Name]
        or RoleCache[player.UserId]
        or RoleCache[tostring(player.UserId)]

    if type(entry) == "table" then
        if entry.Dead == true or entry.dead == true then
            return "Dead"
        end

        local role = NormalizeRole(entry.Role or entry.role)

        if role then
            return role
        end

    elseif type(entry) == "string" then
        local role = NormalizeRole(entry)

        if role then
            return role
        end
    end

    if player:GetAttribute("Dead") == true then
        return "Dead"
    end

    local attributeRole = NormalizeRole(player:GetAttribute("Role"))

    if attributeRole then
        return attributeRole
    end

    if player.Team then
        local teamRole = NormalizeRole(player.Team.Name)

        if teamRole then
            return teamRole
        end
    end

    if GetPlayerTool(player,"Knife") then
        return "Murderer"
    end

    if GetPlayerTool(player,"Gun") then
        return "Sheriff"
    end

    return "Unknown"
end

local function RemoveESP(player)
    local objects = ESPObjects[player]

    if objects then
        if objects.Highlight then
            objects.Highlight:Destroy()
        end

        if objects.Billboard then
            objects.Billboard:Destroy()
        end

        ESPObjects[player] = nil
    end
end

local function CreateESP(player)
    if player == LocalPlayer then return end

    local character = player.Character
    local head = character and character:FindFirstChild("Head")

    if not character or not head then return end

    RemoveESP(player)

    local role = GetRole(player)
    local color = RoleColors[role] or RoleColors.Unknown

    local highlight = Instance.new("Highlight")
    highlight.Name = "KittyESP"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.55
    highlight.OutlineTransparency = 0
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "KittyESPInfo"
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(180,45)
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Create("TextLabel",{
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        Text = player.Name.." ["..role.."]",
        TextColor3 = color,
        TextStrokeTransparency = 0.25,
        TextStrokeColor3 = Color3.new(0,0,0),
        TextSize = 13,
        Font = Enum.Font.GothamBold
    },billboard)

    ESPObjects[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label,
        Character = character
    }
end

local function UpdateESP()
    if not Settings.ESP then return end

    RefreshRoles(false)

    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local head = character and character:FindFirstChild("Head")

            if head then
                local objects = ESPObjects[player]

                if not objects
                or objects.Character ~= character
                or not objects.Highlight
                or not objects.Highlight.Parent then

                    CreateESP(player)
                else
                    local role = GetRole(player)
                    local color = RoleColors[role] or RoleColors.Unknown

                    objects.Highlight.FillColor = color
                    objects.Highlight.OutlineColor = color

                    if objects.Label then
                        objects.Label.Text = player.Name.." ["..role.."]"
                        objects.Label.TextColor3 = color
                    end
                end
            else
                RemoveESP(player)
            end
        end
    end
end

local function EnableESP(enabled)
    if enabled then
        RefreshRoles(true)
        UpdateESP()
    else
        for player in pairs(ESPObjects) do
            RemoveESP(player)
        end
    end
end

AddToggle(VisualPage,"ESP por funcao","ESP",EnableESP)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
    RoleCache[player.Name] = nil
    RoleCache[player.UserId] = nil
end)

if RoundStart and RoundStart:IsA("RemoteEvent") then
    RoundStart.OnClientEvent:Connect(function()
        table.clear(RoleCache)

        if Settings.ESP then
            task.delay(1,function()
                RefreshRoles(true)
                UpdateESP()
            end)
        end
    end)
end

task.spawn(function()
    while ScreenGui.Parent do
        if Settings.ESP then
            UpdateESP()
        end

        task.wait(1)
    end
end)

-- X-RAY
local function SetXRay(enabled)
    if enabled then
        local character = LocalPlayer.Character

        for _,object in ipairs(workspace:GetDescendants()) do
            if object:IsA("BasePart")
            and not (character and object:IsDescendantOf(character)) then

                if OriginalTransparency[object] == nil then
                    OriginalTransparency[object] = object.LocalTransparencyModifier
                end

                object.LocalTransparencyModifier =
                    math.max(object.LocalTransparencyModifier,0.65)
            end
        end
    else
        for object,original in pairs(OriginalTransparency) do
            if object and object.Parent then
                object.LocalTransparencyModifier = original
            end
        end

        table.clear(OriginalTransparency)
    end
end

AddToggle(VisualPage,"X-Ray","XRay",SetXRay)

-- FULL BRIGHT
local function SetFullBright(enabled)
    if enabled then
        if not OriginalLighting then
            OriginalLighting = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient
            }
        end

        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)

    elseif OriginalLighting then
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient

        OriginalLighting = nil
    end
end

AddToggle(VisualPage,"Full Bright","FullBright",SetFullBright)

-- FARM - MM2
local FarmStatus = AddButton(FarmPage,"Status: aguardando",function() end)
FarmStatus.Active = false

local BagFrame = Create("Frame",{
    Name = "BagProgress",
    Size = UDim2.new(1,-6,0,58),
    BackgroundColor3 = Themes.Kitty.Button,
    BorderSizePixel = 0
},FarmPage)

Create("UICorner",{CornerRadius=UDim.new(0,8)},BagFrame)

local BagTitle = Create("TextLabel",{
    Size = UDim2.new(1,-16,0,20),
    Position = UDim2.fromOffset(8,3),
    BackgroundTransparency = 1,
    Text = "MOCHILA: aguardando dados...",
    TextColor3 = Color3.new(1,1,1),
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
},BagFrame)

local BagBackground = Create("Frame",{
    Size = UDim2.new(1,-16,0,14),
    Position = UDim2.fromOffset(8,30),
    BackgroundColor3 = Themes.Kitty.Track,
    BorderSizePixel = 0
},BagFrame)

Create("UICorner",{CornerRadius=UDim.new(1,0)},BagBackground)

local BagFill = Create("Frame",{
    Size = UDim2.new(0,0,1,0),
    BackgroundColor3 = Color3.fromRGB(100,255,130),
    BorderSizePixel = 0
},BagBackground)

Create("UICorner",{CornerRadius=UDim.new(1,0)},BagFill)

AddSlider(FarmPage,"Velocidade do Farm","FarmSpeed",5,28,1)

local AvoidToggle = AddToggle(FarmPage,"Evitar assassino","AvoidMurderer",function(enabled)
    FarmStatus.Text = enabled and
        "Status: procurando moedas seguras" or
        "Status: farm ativo"
end)

local ResetFullToggle = AddToggle(FarmPage,"Resetar com bolsa cheia","ResetWhenFull",function(enabled)
    FarmStatus.Text = enabled and
        "Status: reset automático ligado" or
        "Status: reset automático desligado"
end)

-- ESTADO DA RODADA
local RoundActive = false
local FarmPaused = true
local FarmTarget = nil
local FarmArrivedTarget = nil
local FarmResetPending = false
local LastTargetCheck = 0
local LastFarmReset = 0

local FarmResetUsedThisRound = false

local UpdateBagDisplay
local StartFarmMovement
local StopFarmMovement
local PauseFarmMovement

-- MOCHILA
UpdateBagDisplay = function()
    if not BagCurrent or not BagMaximum or BagMaximum <= 0 then
        BagTitle.Text = "MOCHILA: aguardando dados..."
        BagFill.Size = UDim2.new(0,0,1,0)
        BagFill.BackgroundColor3 = Color3.fromRGB(255,220,80)
        return
    end

    local percent = math.clamp(BagCurrent/BagMaximum,0,1)

    BagTitle.Text = string.format(
        "MOCHILA: %d/%d (%d%%)",
        BagCurrent,
        BagMaximum,
        math.floor(percent*100)
    )

    BagFill.Size = UDim2.new(percent,0,1,0)

    if percent >= 1 then
        BagFill.BackgroundColor3 = Color3.fromRGB(255,45,65)
    elseif percent >= 0.75 then
        BagFill.BackgroundColor3 = Color3.fromRGB(255,170,50)
    else
        BagFill.BackgroundColor3 = Color3.fromRGB(100,255,130)
    end
end

-- EVENTO DE COLETA
if CoinCollected and CoinCollected:IsA("RemoteEvent") then
    CoinCollected.OnClientEvent:Connect(function(_,current,maximum)
        current = tonumber(current)
        maximum = tonumber(maximum)

        if current and maximum and maximum > 0 then
            BagCurrent = current
            BagMaximum = maximum
            UpdateBagDisplay()
        end
    end)
else
    warn("[HelloKittyHub] CoinCollected nao encontrado")
end

-- NOVA RODADA
local function ResetRoundState()
    table.clear(RoleCache)
    RefreshRoles(true)

    RoundActive = IsLocalPlayerPlaying()
    FarmPaused = not RoundActive

    FarmTarget = nil
    FarmResetPending = false
    ResettingForFull = false
    FarmResetUsedThisRound = false

    BagCurrent = 0
    BagMaximum = nil

    UpdateBagDisplay()

    if Settings.AutoFarm then
        if RoundActive then
            FarmStatus.Text = "Status: nova rodada, retomando..."

            task.delay(1,function()
                if Settings.AutoFarm
                and RoundActive
                and not FarmResetUsedThisRound then
                    StartFarmMovement()
                end
            end)
        else
            FarmStatus.Text = "Status: aguardando entrar na rodada"
        end
    end
end

-- INICIO DAS MOEDAS
if CoinsStarted and CoinsStarted:IsA("RemoteEvent") then
    CoinsStarted.OnClientEvent:Connect(function()
        ResetRoundState()
    end)
end

-- INICIO DA RODADA
if RoundStart and RoundStart:IsA("RemoteEvent") then
    RoundStart.OnClientEvent:Connect(function()
        ResetRoundState()

        if Settings.ESP then
            task.delay(1,function()
                RefreshRoles(true)
                UpdateESP()
            end)
        end
    end)
end

-- FIM DA RODADA
if RoundEnd and RoundEnd:IsA("RemoteEvent") then
    RoundEnd.OnClientEvent:Connect(function()
        RoundActive = false
        FarmPaused = true
        FarmTarget = nil
        FarmResetPending = false
        ResettingForFull = false

        table.clear(RoleCache)
        StopFarmMovement()

        if Settings.AutoFarm then
            FarmStatus.Text = "Status: aguardando próxima rodada"
        end
    end)
end

local function IsBagFull()
    return BagCurrent ~= nil
        and BagMaximum ~= nil
        and BagMaximum > 0
        and BagCurrent >= BagMaximum
end

-- LOCALIZAR CONTAINER DE MOEDAS
local function GetCoinContainer()
    local map = workspace:FindFirstChild("Map")

    if map then
        local container = map:FindFirstChild("CoinContainer",true)

        if container then
            return container
        end
    end

    return workspace:FindFirstChild("CoinContainer",true)
end

-- VERIFICAR MOEDA
local function IsCoin(part)
    if not part or not part.Parent then
        return false
    end

    if not part:IsA("BasePart") then
        return false
    end

    if part:GetAttribute("Collected") == true then
        return false
    end

    return part:FindFirstChild("CoinVisual") ~= nil
end

-- PROCURAR MOEDA MAIS PROXIMA
local function GetNearestCoin()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not root then
        return nil
    end

    local container = GetCoinContainer()

    if not container then
        return nil
    end

    local nearest = nil
    local shortestDistance = math.huge

    for _,coin in ipairs(container:GetDescendants()) do
        if IsCoin(coin) then
            local distance = (coin.Position-root.Position).Magnitude

            if distance < shortestDistance then
                shortestDistance = distance
                nearest = coin
            end
        end
    end

    return nearest
end

-- VALIDAR ALVO
local function IsTargetValid(target)
    if not target or not target.Parent then
        return false
    end

    if not IsCoin(target) then
        return false
    end

    local container = GetCoinContainer()

    if not container then
        return false
    end

    return target:IsDescendantOf(container)
end

-- ASSASSINO MAIS PROXIMO
local function GetNearestMurderer()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root then
        return nil,nil
    end

    local nearest = nil
    local shortestDistance = math.huge

    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and GetRole(player) == "Murderer" then
            local enemyCharacter = player.Character
            local enemyRoot = enemyCharacter and enemyCharacter:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = enemyCharacter and enemyCharacter:FindFirstChildOfClass("Humanoid")

            if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
                local distance = (enemyRoot.Position-root.Position).Magnitude

                if distance < shortestDistance then
                    shortestDistance = distance
                    nearest = enemyRoot
                end
            end
        end
    end

    return nearest,shortestDistance
end

-- PROCURAR MOEDA LONGE DO ASSASSINO
local function GetCoinFarFromMurderer()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root then
        return nil
    end

    local container = GetCoinContainer()

    if not container then
        return nil
    end

    local murdererRoot = nil

    if Settings.AvoidMurderer then
        murdererRoot = GetNearestMurderer()
    end

    if not murdererRoot then
        return GetNearestCoin()
    end

    local nearestSafeCoin = nil
    local nearestSafeDistance = math.huge

    local safestCoin = nil
    local safestDistance = -math.huge

    for _,coin in ipairs(container:GetDescendants()) do
        if IsCoin(coin) then
            local distanceToPlayer = (coin.Position-root.Position).Magnitude
            local distanceToMurderer = (coin.Position-murdererRoot.Position).Magnitude

            if distanceToMurderer > safestDistance then
                safestDistance = distanceToMurderer
                safestCoin = coin
            end

            if distanceToMurderer > Settings.MurdererRadius then
                if distanceToPlayer < nearestSafeDistance then
                    nearestSafeDistance = distanceToPlayer
                    nearestSafeCoin = coin
                end
            end
        end
    end

    if nearestSafeCoin then
        return nearestSafeCoin
    end

    return safestCoin
end

-- PARAR MOVIMENTO DO FARM
StopFarmMovement = function()
    if FarmConnection then
        FarmConnection:Disconnect()
        FarmConnection = nil
    end

    if FarmVelocity then
        FarmVelocity:Destroy()
        FarmVelocity = nil
    end

    if FarmAttachment then
        FarmAttachment:Destroy()
        FarmAttachment = nil
    end

    FarmTarget = nil
    FarmArrivedTarget = nil
end

-- PAUSAR MOVIMENTO
PauseFarmMovement = function()
    FarmTarget = nil
    FarmArrivedTarget = nil

    if FarmVelocity and FarmVelocity.Parent then
        FarmVelocity.VectorVelocity = Vector3.zero
    end
end

-- INICIAR MOVIMENTO
StartFarmMovement = function()
    if FarmConnection then
        return
    end

    if not Settings.AutoFarm
    or not RoundActive
    or FarmPaused
    or FarmResetUsedThisRound
    or FarmResetPending
    or ResettingForFull then
        return
    end

    if not IsLocalPlayerPlaying() then
        return
    end

    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root then
        return
    end

    FarmAttachment = Instance.new("Attachment")
    FarmAttachment.Name = "KittyFarmAttachment"
    FarmAttachment.Parent = root

    FarmVelocity = Instance.new("LinearVelocity")
    FarmVelocity.Name = "KittyFarmVelocity"
    FarmVelocity.Attachment0 = FarmAttachment
    FarmVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    FarmVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    FarmVelocity.ForceLimitsEnabled = false
    FarmVelocity.VectorVelocity = Vector3.zero
    FarmVelocity.Parent = root

    FarmConnection = RunService.Heartbeat:Connect(function()
        if not Settings.AutoFarm then
            StopFarmMovement()
            return
        end

        if not root.Parent or not FarmVelocity or not FarmVelocity.Parent then
            StopFarmMovement()
            return
        end

        if not IsLocalPlayerPlaying() then
            RoundActive = false
            FarmPaused = true
            PauseFarmMovement()
            FarmStatus.Text = "Status: aguardando entrar na rodada"
            return
        end

        UpdateBagDisplay()

        if not RoundActive or FarmPaused then
            PauseFarmMovement()
            FarmStatus.Text = "Status: aguardando próxima rodada"
            return
        end

        if FarmResetUsedThisRound then
            PauseFarmMovement()
            FarmStatus.Text = "Status: aguardando próxima rodada"
            return
        end

        if IsBagFull() then
            PauseFarmMovement()
            FarmStatus.Text = "Status: mochila cheia!"

            if Settings.ResetWhenFull
            and RoundActive
            and not FarmResetUsedThisRound
            and not FarmResetPending then

                FarmResetUsedThisRound = true
                FarmResetPending = true
                ResettingForFull = true
                LastFarmReset = os.clock()

                FarmStatus.Text = "Status: resetando mochila..."

                local humanoid = character:FindFirstChildOfClass("Humanoid")

                if humanoid then
                    task.delay(0.5,function()
                        if humanoid.Parent
                        and RoundActive
                        and FarmResetUsedThisRound then
                            humanoid.Health = 0
                        end
                    end)
                end
            end

            return
        end

        if FarmResetPending or ResettingForFull then
            PauseFarmMovement()
            return
        end

        if not IsTargetValid(FarmTarget) then
            FarmTarget = nil
            FarmArrivedTarget = nil
            FarmVelocity.VectorVelocity = Vector3.zero
        end

        if not FarmTarget then
            if Settings.AvoidMurderer then
                FarmTarget = GetCoinFarFromMurderer()
            else
                FarmTarget = GetNearestCoin()
            end
            FarmArrivedTarget = nil
        end

        if not FarmTarget then
            FarmVelocity.VectorVelocity = Vector3.zero
            FarmStatus.Text = "Status: procurando moedas..."
            return
        end

        if not IsTargetValid(FarmTarget) then
            FarmTarget = nil
            FarmVelocity.VectorVelocity = Vector3.zero
            FarmStatus.Text = "Status: procurando outra moeda..."
            return
        end

        -- Depois de alcançar a moeda, mantém o movimento parado nela
        -- até a coleta ser confirmada (a moeda desaparecer).
        -- Isso evita alternar entre velocidade máxima e zero a cada frame.
        if FarmArrivedTarget == FarmTarget then
            FarmVelocity.VectorVelocity = Vector3.zero
            if humanoid and humanoid.Parent then
                humanoid:Move(Vector3.zero, true)
            end
            FarmStatus.Text = "Status: confirmando coleta..."
            return
        end

        local targetPosition = FarmTarget.Position
        local delta = targetPosition-root.Position
        local distance = delta.Magnitude

        FarmStatus.Text = "Status: coletando moedas..."

        if distance > 0.05 then
            -- Mantém a velocidade configurada, sem desacelerar na aproximação.
            FarmVelocity.VectorVelocity = delta.Unit*Settings.FarmSpeed
        else
            FarmVelocity.VectorVelocity = Vector3.zero
            if humanoid and humanoid.Parent then
                humanoid:Move(Vector3.zero, true)
            end
            FarmArrivedTarget = FarmTarget
        end
    end)
end

-- ATIVAR E DESATIVAR AUTOFARM
local function SetAutoFarm(enabled)
    Settings.AutoFarm = enabled

    if enabled then
        FarmNoclipBefore = Settings.Noclip

        Settings.Noclip = true
        SetToggleVisual("Noclip",true)

        FarmResetPending = FarmResetUsedThisRound
        ResettingForFull = FarmResetUsedThisRound
        FarmTarget = nil
        FarmArrivedTarget = nil

        table.clear(RoleCache)
        RefreshRoles(true)

        if IsLocalPlayerPlaying() and not FarmResetUsedThisRound then
            RoundActive = true
            FarmPaused = false

            StartFarmMovement()
            FarmStatus.Text = "Status: AutoFarm ativado"
        else
            RoundActive = false
            FarmPaused = true
            FarmStatus.Text = "Status: aguardando entrar na rodada"
        end
    else
        StopFarmMovement()

        Settings.Noclip = FarmNoclipBefore
        SetToggleVisual("Noclip",FarmNoclipBefore)

        if not FarmNoclipBefore then
            RestoreCollision()
        end

        FarmResetPending = false
        ResettingForFull = false
        FarmPaused = false

        FarmStatus.Text = "Status: AutoFarm desligado"
    end
end

local AutoFarmToggle = AddToggle(FarmPage,"Auto Farm","AutoFarm",SetAutoFarm)

-- MONITORAR PARTICIPACAO NA RODADA
task.spawn(function()
    while ScreenGui.Parent do
        if Settings.AutoFarm then
            RefreshRoles(false)

            local playing = IsLocalPlayerPlaying()

            if playing then
                if not RoundActive and not FarmResetUsedThisRound then
                    RoundActive = true
                    FarmPaused = false
                    FarmTarget = nil
                    FarmResetPending = false
                    ResettingForFull = false

                    BagCurrent = 0
                    BagMaximum = nil
                    UpdateBagDisplay()
                end

                if RoundActive
                and not FarmConnection
                and not FarmResetUsedThisRound
                and not FarmResetPending then
                    StartFarmMovement()
                end
            else
                RoundActive = false
                FarmPaused = true
                PauseFarmMovement()

                FarmStatus.Text = "Status: aguardando entrar na rodada"
            end
        end

        task.wait(1)
    end
end)

-- ATUALIZAR MOCHILA
task.spawn(function()
    while ScreenGui.Parent do
        UpdateBagDisplay()
        task.wait(0.25)
    end
end)

-- RENASCER
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)

    ApplyMovement()

    if Settings.Fly then
        StopFly()
    end

    if Settings.AutoFarm then
        StopFarmMovement()

        RefreshRoles(true)

        if IsLocalPlayerPlaying()
        and RoundActive
        and not FarmPaused
        and not FarmResetUsedThisRound
        and not FarmResetPending then

            ResettingForFull = false

            StartFarmMovement()
            FarmStatus.Text = "Status: Farm retomado"
        else
            FarmStatus.Text = "Status: aguardando próxima rodada"
        end
    end

    if Settings.ESP then
        task.delay(1,function()
            RefreshRoles(true)
            UpdateESP()
        end)
    end
end)

-- TEMAS
local function ApplyTheme(name)
    local theme = Themes[name]
    if not theme then return end

    CurrentTheme = name

    Main.BackgroundColor3 = theme.Main
    Header.BackgroundColor3 = theme.Header
    Floating.BackgroundColor3 = theme.Header
    Sidebar.BackgroundColor3 = theme.Main
    Minimize.BackgroundColor3 = theme.Button

    for _,button in pairs(TabButtons) do
        button.BackgroundColor3 = theme.Button
    end

    for _,page in pairs(Pages) do
        -- Percorre todos os descendentes para incluir os temas dentro do seletor.
        for _,object in ipairs(page:GetDescendants()) do
            if object:IsA("TextButton") then
                object.BackgroundColor3 = theme.Button
            elseif object:IsA("TextBox") then
                object.BackgroundColor3 = theme.Button
            elseif object:IsA("Frame") and (object.Name == "SliderContainer" or object.Name == "ToggleContainer") then
                object.BackgroundColor3 = theme.Button
                if object.Name == "ToggleContainer" then
                    local track = object:FindFirstChild("ToggleTrack")
                    if track then
                        local settingName
                        for key,item in pairs(ToggleButtons) do
                            if item.Row == object then settingName = key break end
                        end
                        track.BackgroundColor3 = (settingName and Settings[settingName]) and theme.Header or theme.Track
                    end
                end
            end
        end
    end

    for _,slider in ipairs(SliderObjects) do
        if slider.Bar and slider.Bar.Parent then
            slider.Bar.BackgroundColor3 = theme.Track
        end
    end

    BagFrame.BackgroundColor3 = theme.Button
    BagBackground.BackgroundColor3 = theme.Track
    UpButton.BackgroundColor3 = theme.Header
    DownButton.BackgroundColor3 = theme.Header
end

-- ANTI-AFK (mesmo metodo usado no Murder Mystery 2.txt do Mario Hub)
local AntiAfkConnection
local function SetAntiAfk(enabled)
    Settings.AntiAfk = enabled

    if enabled then
        if not AntiAfkConnection then
            AntiAfkConnection = LocalPlayer.Idled:Connect(function()
                if Settings.AntiAfk then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end)
        end
    elseif AntiAfkConnection then
        AntiAfkConnection:Disconnect()
        AntiAfkConnection = nil
    end
end

local AntiAfkToggle = AddToggle(PlayerPage, "Anti-AFK", "AntiAfk", SetAntiAfk)

-- ORDEM DA ABA PLAYER
local AntiFlingToggle = ToggleButtons.AntiFling.Row
local NoclipToggle = ToggleButtons.Noclip.Row
local FlyToggle = ToggleButtons.Fly.Row
AntiFlingToggle.LayoutOrder = 1
AntiAfkToggle.LayoutOrder = 2
NoclipToggle.LayoutOrder = 3
FlyToggle.LayoutOrder = 4
AddSlider(PlayerPage,"Fly Speed","FlySpeed",10,150,1)
AddSlider(PlayerPage,"WalkSpeed","WalkSpeed",16,200,1)
AddSlider(PlayerPage,"JumpForce","JumpPower",50,200,1)
for _, slider in ipairs(SliderObjects) do
    if slider.Setting == "FlySpeed" then slider.Frame.LayoutOrder = 5 end
    if slider.Setting == "WalkSpeed" then slider.Frame.LayoutOrder = 6 end
    if slider.Setting == "JumpPower" then slider.Frame.LayoutOrder = 7 end
end

-- SELETOR DE TEMAS
local ThemeOptions
local ThemeSelector = AddButton(ConfigPage,"Tema: "..CurrentTheme.."  ▼",function()
    ThemeOptions.Visible = not ThemeOptions.Visible
end)
ThemeSelector.LayoutOrder = 1
ThemeOptions = Create("Frame",{
    Name="ThemeOptions", Size=UDim2.new(1,-6,0,148), BackgroundTransparency=1,
    Visible=false, LayoutOrder=2
},ConfigPage)
Create("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},ThemeOptions)
for _, themeName in ipairs({"Kitty","Dark","Halloween","Christmas"}) do
    local option = AddButton(ThemeOptions,themeName,function()
        ApplyTheme(themeName)
        ThemeSelector.Text = "Tema: "..themeName.."  ▼"
        ThemeOptions.Visible = false
    end)
    option.Size = UDim2.new(1,0,0,29)
end

-- SISTEMA DE CONFIGURACOES SALVAS (ARQUIVOS JSON)
local SaveFolder = "HelloKittyHub"
local AutoLoadPath = SaveFolder.."/autoload.txt"
local SelectedConfig = nil
local SaveStatus, ConfigList
local function FileSystemReady()
    return type(makefolder)=="function" and type(isfolder)=="function" and
        type(writefile)=="function" and type(readfile)=="function" and
        type(isfile)=="function" and type(listfiles)=="function" and type(delfile)=="function"
end
local function EnsureSaveFolder()
    if not FileSystemReady() then return false,"Seu executor nao oferece suporte completo a arquivos." end
    local ok,err=pcall(function() if not isfolder(SaveFolder) then makefolder(SaveFolder) end end)
    if not ok then return false,tostring(err) end
    return true
end
local function CleanConfigName(name)
    name=tostring(name or ""):gsub("^%s+",""):gsub("%s+$","")
    name=name:gsub("[^%w%s_%-]","_"):gsub("%s+","_")
    if name=="" then return nil end
    return name
end
local function ConfigPath(name) return SaveFolder.."/"..name..".json" end
local function SetSaveStatus(message)
    if SaveStatus and SaveStatus.Parent then SaveStatus.Text="Status: "..message end
end
local function MakeSnapshot()
    local data={Version=1,Theme=CurrentTheme,Settings={}}
    for key,value in pairs(Settings) do
        if type(value)=="boolean" or type(value)=="number" then data.Settings[key]=value end
    end
    return data
end
local function SaveConfig(name)
    local ok,err=EnsureSaveFolder(); if not ok then SetSaveStatus(err); return false end
    name=CleanConfigName(name); if not name then SetSaveStatus("Digite um nome valido."); return false end
    local encodedOk,contents=pcall(function() return HttpService:JSONEncode(MakeSnapshot()) end)
    if not encodedOk then SetSaveStatus("Erro ao preparar configuracao."); return false end
    local writeOk,writeErr=pcall(writefile,ConfigPath(name),contents)
    if not writeOk then SetSaveStatus("Falha ao salvar: "..tostring(writeErr)); return false end
    SelectedConfig=name; SetSaveStatus("Configuracao '"..name.."' salva!"); return true
end
local function LoadConfig(name)
    local ok,err=EnsureSaveFolder(); if not ok then SetSaveStatus(err); return false end
    name=CleanConfigName(name); if not name or not isfile(ConfigPath(name)) then SetSaveStatus("Configuracao nao encontrada."); return false end
    local readOk,contents=pcall(readfile,ConfigPath(name)); if not readOk then SetSaveStatus("Nao foi possivel ler o arquivo."); return false end
    local decodeOk,data=pcall(function() return HttpService:JSONDecode(contents) end)
    if not decodeOk or type(data)~="table" or type(data.Settings)~="table" then SetSaveStatus("Arquivo de configuracao invalido."); return false end
    -- Primeiro restaura os valores numericos e a aparencia dos controles.
    for _,slider in ipairs(SliderObjects) do
        local value=data.Settings[slider.Setting]
        if type(value)=="number" then slider.Set(value) end
    end
    -- Desliga recursos ativos antes de aplicar o estado salvo.
    for key,item in pairs(ToggleButtons) do
        if Settings[key]==true and item.Callback then pcall(item.Callback,false) end
        Settings[key]=false; item.Update(false)
    end
    local order={"AntiFling","AntiAfk","XRay","FullBright","ESP","Fly","Noclip","AvoidMurderer","ResetWhenFull","AutoFarm"}
    for _,key in ipairs(order) do
        local item=ToggleButtons[key]
        local value=data.Settings[key]
        if item and type(value)=="boolean" then
            Settings[key]=value; item.Update(value)
            if item.Callback then pcall(item.Callback,value) end
        end
    end
    if type(data.Theme)=="string" and Themes[data.Theme] then
        ApplyTheme(data.Theme)
        if ThemeSelector then ThemeSelector.Text="Tema: "..data.Theme.."  ▼" end
    end
    SelectedConfig=name; SetSaveStatus("'"..name.."' carregada!"); return true
end
local function RefreshConfigs()
    local ok,err=EnsureSaveFolder(); if not ok then SetSaveStatus(err); return end
    if ConfigList then for _,child in ipairs(ConfigList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end end
    local found={}
    local listOk,files=pcall(listfiles,SaveFolder)
    if listOk and type(files)=="table" then
        for _,path in ipairs(files) do
            local base=tostring(path):match("([^/\\]+)%.json$")
            if base then table.insert(found,base) end
        end
    end
    table.sort(found)
    for i,name in ipairs(found) do
        local entry=AddButton(ConfigList,name,function() SelectedConfig=name; ConfigNameBox.Text=name; SetSaveStatus("Selecionada: "..name) end)
        entry.LayoutOrder=i; entry.Size=UDim2.new(1,-4,0,27)
    end
    SetSaveStatus(#found.." configuracao(oes) encontrada(s).")
end

local SaveTitle=Create("TextLabel",{Size=UDim2.new(1,-6,0,26),BackgroundTransparency=1,Text="CONFIGURACOES SALVAS",TextColor3=Color3.new(1,1,1),TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1},SavesPage)
local ConfigNameBox=Create("TextBox",{Size=UDim2.new(1,-6,0,34),BackgroundColor3=Themes.Kitty.Button,TextColor3=Color3.new(1,1,1),PlaceholderText="Nome da configuracao...",PlaceholderColor3=Color3.fromRGB(235,220,230),Text="",TextSize=12,Font=Enum.Font.Gotham,ClearTextOnFocus=false,LayoutOrder=2},SavesPage)
Create("UICorner",{CornerRadius=UDim.new(0,7)},ConfigNameBox)
SaveStatus=Create("TextLabel",{Size=UDim2.new(1,-6,0,34),BackgroundTransparency=1,Text="Status: Pronto.",TextColor3=Color3.new(1,1,1),TextSize=10,Font=Enum.Font.Gotham,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=11},SavesPage)
local SaveButton=AddButton(SavesPage,"💾  Salvar configuracao",function() SaveConfig(ConfigNameBox.Text); RefreshConfigs() end); SaveButton.LayoutOrder=3
local LoadButton=AddButton(SavesPage,"📂  Carregar configuracao",function() LoadConfig(ConfigNameBox.Text~="" and ConfigNameBox.Text or SelectedConfig) end); LoadButton.LayoutOrder=7
local DeleteButton=AddButton(SavesPage,"🗑  Excluir configuracao",function()
    local ok,err=EnsureSaveFolder(); if not ok then SetSaveStatus(err); return end
    local name=CleanConfigName(ConfigNameBox.Text~="" and ConfigNameBox.Text or SelectedConfig)
    if not name or not isfile(ConfigPath(name)) then SetSaveStatus("Configuracao nao encontrada."); return end
    local deleted,deleteErr=pcall(delfile,ConfigPath(name))
    if deleted then if SelectedConfig==name then SelectedConfig=nil end; SetSaveStatus("Configuracao excluida."); RefreshConfigs() else SetSaveStatus("Falha ao excluir: "..tostring(deleteErr)) end
end); DeleteButton.LayoutOrder=8
local AutoLoadButton=AddButton(SavesPage,"⭐  Definir como carregamento automatico",function()
    local ok,err=EnsureSaveFolder(); if not ok then SetSaveStatus(err); return end
    local name=CleanConfigName(ConfigNameBox.Text~="" and ConfigNameBox.Text or SelectedConfig)
    if not name or not isfile(ConfigPath(name)) then SetSaveStatus("Salve ou selecione uma configuracao primeiro."); return end
    local wrote,writeErr=pcall(writefile,AutoLoadPath,name)
    if wrote then SetSaveStatus("'"..name.."' sera carregada ao iniciar!") else SetSaveStatus("Falha no Auto Load: "..tostring(writeErr)) end
end); AutoLoadButton.LayoutOrder=9
local ClearAutoLoadButton=AddButton(SavesPage,"Remover carregamento automatico",function()
    if type(isfile)=="function" and type(delfile)=="function" and isfile(AutoLoadPath) then pcall(delfile,AutoLoadPath) end
    SetSaveStatus("Carregamento automatico removido.")
end); ClearAutoLoadButton.LayoutOrder=10
local RefreshButton=AddButton(SavesPage,"🔄  Atualizar lista",function() RefreshConfigs() end); RefreshButton.LayoutOrder=6
local ListTitle=Create("TextLabel",{Size=UDim2.new(1,-6,0,23),BackgroundTransparency=1,Text="TOQUE EM UMA CONFIGURACAO PARA SELECIONAR",TextColor3=Color3.new(1,1,1),TextSize=9,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=4},SavesPage)
ConfigList=Create("Frame",{Size=UDim2.new(1,-6,0,4),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=5},SavesPage)
Create("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},ConfigList)

-- DESEXECUTAR (DENTRO DE CONFIGURACOES, COM CONFIRMACAO)
local UnloadButton
local UnloadPending=false
local function UnloadHub()
    Settings.AutoFarm=false; Settings.Fly=false; Settings.Noclip=false
    Settings.AntiAfk=false
    if AntiAfkConnection then AntiAfkConnection:Disconnect(); AntiAfkConnection=nil end
    Settings.ESP=false; Settings.AntiFling=false
    StopFly(); StopFarmMovement(); RestoreCollision()
    if AntiFlingConnection then AntiFlingConnection:Disconnect(); AntiFlingConnection=nil end
    EnableESP(false)
    Settings.XRay=false; SetXRay(false)
    Settings.FullBright=false; SetFullBright(false)
    ScreenGui:Destroy()
end
UnloadButton=AddButton(ConfigPage,"⏻  Desexecutar Hub",function()
    if not UnloadPending then
        UnloadPending=true
        UnloadButton.Text="Confirmar desexecucao? Clique novamente"
        task.delay(5,function()
            if UnloadButton and UnloadButton.Parent and UnloadPending then
                UnloadPending=false
                UnloadButton.Text="⏻  Desexecutar Hub"
            end
        end)
        return
    end
    UnloadPending=false
    UnloadHub()
end)

-- MINIMIZAR
Minimize.MouseButton1Click:Connect(function()
    Main.Visible = false
    Floating.Visible = true
end)

Floating.MouseButton1Click:Connect(function()
    Main.Visible = true
    Floating.Visible = false
end)

-- MOVIMENTO
RunService.Heartbeat:Connect(function()
    if ScreenGui.Parent then
        ApplyMovement()
    end
end)

-- ORDEM DAS ABAS FARM E CONFIGURACAO
FarmStatus.LayoutOrder = 1
AutoFarmToggle.LayoutOrder = 2
for _, slider in ipairs(SliderObjects) do
    if slider.Setting == "FarmSpeed" then slider.Frame.LayoutOrder = 3 end
end
AvoidToggle.LayoutOrder = 4
ResetFullToggle.LayoutOrder = 5
BagFrame.LayoutOrder = 6
UnloadButton.LayoutOrder = 3

ApplyTheme("Kitty")
RefreshConfigs()
-- Carrega a configuracao escolhida para iniciar automaticamente, se existir.
task.defer(function()
    if type(isfile)=="function" and type(readfile)=="function" and isfile(AutoLoadPath) then
        local ok,name=pcall(readfile,AutoLoadPath)
        if ok and type(name)=="string" then task.wait(0.5); LoadConfig(name) end
    end
end)

print("Hello Kitty Hub v"..HUB_VERSION.." carregado!")
