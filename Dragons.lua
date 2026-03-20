local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // CONFIGURAÇÕES VISUAIS
local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Sidebar = Color3.fromRGB(20, 20, 30),
    Element = Color3.fromRGB(30, 30, 45),
    Text = Color3.fromRGB(240, 240, 240),
    Accent = Color3.fromRGB(0, 255, 128), -- Verde Neon
    ToggleOff = Color3.fromRGB(50, 50, 60),
    Outline = Color3.fromRGB(40, 40, 50)
}

-- // VARIÁVEIS DE CONTROLE
local Configs = {
    -- Gerais
    AutoFarm = false,
    AutoEgg = false,
    AutoChest = false, -- [NOVO] Auto Baú
    AutoCollect = false,
    EspMobs = false,
    EspEggs = false,
    EspChests = false, -- [NOVO] ESP Baú
    EspResources = false,
    WalkSpeed = 16,
    JumpPower = 50,
    Fly = false,
    FlySpeed = 50,
    FarmDistance = 15,
    
    -- Riding
    AutoRiding = false,
    AutoStartRace = true,
    TweenSpeed = 190,
    SearchRadius = 1000,
    IgnoreTime = 5,
    
    -- Filtros Riding
    MinSize = 130,
    MaxTransparency = 0.9
}

local State = {
    TargetMob = nil,
    CurrentEggIndex = 1,
    Flying = false,
    WasFlying = false,
    Blacklist = {},
    LastPos = Vector3.new(0,0,0),
    StuckCount = 0
}

local Cache = { Mobs = {}, Eggs = {}, Resources = {}, Chests = {} }
local ESP_Storage = {} 

-- // FUNÇÕES ÚTEIS
local function GetRoot() return Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") end
local function GetHumanoid() return Player.Character and Player.Character:FindFirstChild("Humanoid") end

-- DETECTAR DRAGÃO
local function GetMoverPart()
    local char = Player.Character
    if not char then return nil end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid and humanoid.SeatPart then
        local vehicle = humanoid.SeatPart.Parent
        local dragonRoot = vehicle:FindFirstChild("HumanoidRootPart") or vehicle.PrimaryPart or vehicle:FindFirstChild("Torso")
        if dragonRoot then return dragonRoot end
    end
    return char:FindFirstChild("HumanoidRootPart")
end

-- // FUNÇÃO DE CLICK NA MIRA (QTE)
local function ClickTargetMinigame()
    local gui = Player:FindFirstChild("PlayerGui")
    if not gui then return end
    for _, screen in pairs(gui:GetChildren()) do
        if screen:IsA("ScreenGui") and screen.Enabled then
            for _, element in pairs(screen:GetDescendants()) do
                if element:IsA("ImageButton") or element:IsA("TextButton") then
                    if element.Visible and element.Active then
                        for _, conn in pairs(getconnections(element.MouseButton1Click)) do conn:Fire() end
                        for _, conn in pairs(getconnections(element.Activated)) do conn:Fire() end
                        for _, conn in pairs(getconnections(element.MouseButton1Down)) do conn:Fire() end
                    end
                end
            end
        end
    end
end

-- // FUNÇÃO DE AUTO CLICK NA UI (CLAIM)
local function AttemptAutoClaim()
    local gui = Player:FindFirstChild("PlayerGui")
    if not gui then return end
    local keywords = {"claim", "yes", "confirm", "collect", "take", "pick"}
    for _, screen in pairs(gui:GetChildren()) do
        if screen:IsA("ScreenGui") and screen.Enabled then
            for _, element in pairs(screen:GetDescendants()) do
                if element:IsA("TextButton") and element.Visible and element.Active then
                    local text = element.Text:lower()
                    if element.Name:lower():match("claim") then text = "claim" end
                    for _, key in pairs(keywords) do
                        if text:find(key) then
                            for _, connection in pairs(getconnections(element.MouseButton1Click)) do connection:Fire() end
                            return
                        end
                    end
                end
            end
        end
    end
end

-- ANTI AFK
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- // UI LIBRARY
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PudimHub_V15_Chests"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Top Bar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.Sidebar
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Text = "PudimHub - DA 🐉 (V15)"
Title.RichText = true
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Theme.Accent
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- Arrastar UI
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end end)
TopBar.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
RunService.RenderStepped:Connect(function() if dragging and dragInput then local delta = dragInput.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 5); CloseBtn.BackgroundTransparency = 1; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Theme.Accent; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 18
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Tabs
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(0, 130, 1, -40); TabContainer.Position = UDim2.new(0, 0, 0, 40); TabContainer.BackgroundColor3 = Theme.Sidebar
Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 10)
local TabList = Instance.new("UIListLayout", TabContainer); TabList.Padding = UDim.new(0, 5); TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center; TabList.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", TabContainer).PaddingTop = UDim.new(0, 10)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -140, 1, -50); ContentContainer.Position = UDim2.new(0, 135, 0, 45); ContentContainer.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local TabButton = Instance.new("TextButton", TabContainer)
    TabButton.Size = UDim2.new(0.9, 0, 0, 35); TabButton.BackgroundColor3 = Theme.Background; TabButton.Text = name; TabButton.TextColor3 = Theme.Text; TabButton.Font = Enum.Font.GothamSemibold; TabButton.TextSize = 14
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
    local Page = Instance.new("ScrollingFrame", ContentContainer)
    Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 2; Page.ScrollBarImageColor3 = Theme.Accent
    local PageLayout = Instance.new("UIListLayout", Page); PageLayout.Padding = UDim.new(0, 8); PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabButton.MouseButton1Click:Connect(function() for _, t in pairs(Tabs) do t.Page.Visible = false; t.Btn.BackgroundColor3 = Theme.Background; t.Btn.TextColor3 = Theme.Text end; Page.Visible = true; TabButton.BackgroundColor3 = Theme.Accent; TabButton.TextColor3 = Color3.new(0,0,0) end)
    table.insert(Tabs, {Btn = TabButton, Page = Page})
    return Page
end

local function CreateToggle(parent, text, configKey, callback)
    local Frame = Instance.new("Frame", parent); Frame.Size = UDim2.new(1, -10, 0, 40); Frame.BackgroundColor3 = Theme.Element; Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local Label = Instance.new("TextLabel", Frame); Label.Text = text; Label.Size = UDim2.new(0.7, 0, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.BackgroundTransparency = 1; Label.TextColor3 = Theme.Text; Label.Font = Enum.Font.GothamSemibold; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.TextSize = 14
    local Button = Instance.new("TextButton", Frame); Button.Text = ""; Button.Size = UDim2.new(0, 44, 0, 22); Button.Position = UDim2.new(1, -54, 0.5, -11); Button.BackgroundColor3 = Configs[configKey] and Theme.Accent or Theme.ToggleOff
    Instance.new("UICorner", Button).CornerRadius = UDim.new(1, 0)
    local Circle = Instance.new("Frame", Button); Circle.Size = UDim2.new(0, 18, 0, 18); Circle.Position = Configs[configKey] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9); Circle.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    Button.MouseButton1Click:Connect(function() Configs[configKey] = not Configs[configKey]; local state = Configs[configKey]; TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff}):Play(); TweenService:Create(Circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play(); if callback then callback(state) end end)
end

local function CreateSlider(parent, text, min, max, configKey)
    local Frame = Instance.new("Frame", parent); Frame.Size = UDim2.new(1, -10, 0, 55); Frame.BackgroundColor3 = Theme.Element; Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local Label = Instance.new("TextLabel", Frame); Label.Text = text .. ": " .. Configs[configKey]; Label.Size = UDim2.new(1, -20, 0, 20); Label.Position = UDim2.new(0, 10, 0, 5); Label.BackgroundTransparency = 1; Label.TextColor3 = Theme.Text; Label.Font = Enum.Font.GothamSemibold; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.TextSize = 14
    local SliderBg = Instance.new("TextButton", Frame); SliderBg.Text = ""; SliderBg.Size = UDim2.new(1, -20, 0, 6); SliderBg.Position = UDim2.new(0, 10, 0, 35); SliderBg.BackgroundColor3 = Theme.Background; SliderBg.AutoButtonColor = false; Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)
    local SliderFill = Instance.new("Frame", SliderBg); SliderFill.Size = UDim2.new((Configs[configKey] - min)/(max - min), 0, 1, 0); SliderFill.BackgroundColor3 = Theme.Accent; Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
    local function Update(input) local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1); local val = math.floor(min + (max - min) * pos); Configs[configKey] = val; Label.Text = text .. ": " .. val; SliderFill.Size = UDim2.new(pos, 0, 1, 0) end
    local sliding = false; SliderBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; Update(input) end end); UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end); UserInputService.InputChanged:Connect(function(input) if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end end)
end

-- CRIAÇÃO DAS ABAS
local FarmTab = CreateTab("Auto Farm")
local EspTab = CreateTab("Visuals / ESP")
local PlayerTab = CreateTab("Player")

-- SEÇÃO RIDING
local RidingLabel = Instance.new("TextLabel", FarmTab)
RidingLabel.Text = "--- RIDING FARM ---"
RidingLabel.Size = UDim2.new(1, 0, 0, 25); RidingLabel.BackgroundTransparency = 1; RidingLabel.TextColor3 = Theme.Accent; RidingLabel.Font = Enum.Font.GothamBold; RidingLabel.TextSize = 14

CreateToggle(FarmTab, "Auto Riding", "AutoRiding", function(state) if state then State.Blacklist = {} end end)
CreateSlider(FarmTab, "Velocidade do Dragão", 100, 400, "TweenSpeed")

local FarmLabel = Instance.new("TextLabel", FarmTab)
FarmLabel.Text = "--- FARM NORMAL ---"
FarmLabel.Size = UDim2.new(1, 0, 0, 25); FarmLabel.BackgroundTransparency = 1; FarmLabel.TextColor3 = Theme.Accent; FarmLabel.Font = Enum.Font.GothamBold; FarmLabel.TextSize = 14

CreateToggle(FarmTab, "Auto Farm Mobs", "AutoFarm")
CreateToggle(FarmTab, "Auto Coletar Ovos (Mira)", "AutoEgg")
CreateToggle(FarmTab, "Auto Coletar Baús", "AutoChest") -- [NOVO]
CreateToggle(FarmTab, "Auto Coletar Recursos", "AutoCollect")
CreateSlider(FarmTab, "Distância Farm", 5, 50, "FarmDistance")

-- Configurações Visuals
CreateToggle(EspTab, "ESP Mobs (Vermelho)", "EspMobs")
CreateToggle(EspTab, "ESP Ovos (Dourado)", "EspEggs")
CreateToggle(EspTab, "ESP Baús (Azul)", "EspChests") -- [NOVO]
CreateToggle(EspTab, "ESP Recursos (Verde)", "EspResources")

-- Configurações Player
CreateToggle(PlayerTab, "Fly (G)", "Fly")
CreateSlider(PlayerTab, "Fly Speed", 20, 200, "FlySpeed")
CreateSlider(PlayerTab, "Walk Speed", 16, 200, "WalkSpeed")
CreateSlider(PlayerTab, "Jump Power", 50, 300, "JumpPower")

Tabs[1].Btn.BackgroundColor3 = Theme.Accent; Tabs[1].Btn.TextColor3 = Color3.new(0,0,0); Tabs[1].Page.Visible = true

-- // SISTEMA ESP
local function CreateESP(model, color, name, typeTag)
    if ESP_Storage[model] then return end
    local basePart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not basePart then return end
    local hl = Instance.new("Highlight", CoreGui); hl.Adornee = model; hl.FillColor = color; hl.OutlineColor = Color3.new(1,1,1); hl.FillTransparency = 0.6; hl.OutlineTransparency = 0.2
    local bill = Instance.new("BillboardGui", CoreGui); bill.Adornee = basePart; bill.Size = UDim2.new(0, 100, 0, 20); bill.AlwaysOnTop = true
    local text = Instance.new("TextLabel", bill); text.Size = UDim2.new(1, 0, 1, 0); text.BackgroundTransparency = 1; text.TextColor3 = color; text.Font = Enum.Font.GothamBold; text.TextSize = 12; text.Text = name
    ESP_Storage[model] = {Highlight = hl, Billboard = bill, TextLabel = text, Type = typeTag}
    model.AncestryChanged:Connect(function(_, parent) if not parent and ESP_Storage[model] then hl:Destroy(); bill:Destroy(); ESP_Storage[model] = nil end end)
end

RunService.RenderStepped:Connect(function()
    local root = GetRoot()
    if not root then return end
    for model, data in pairs(ESP_Storage) do
        if not model.Parent then
            if data.Highlight then data.Highlight:Destroy() end
            if data.Billboard then data.Billboard:Destroy() end
            ESP_Storage[model] = nil
            continue
        end

        local show = false
        if data.Type == "Mob" then show = Configs.EspMobs
        elseif data.Type == "Egg" then show = Configs.EspEggs
        elseif data.Type == "Chest" then show = Configs.EspChests -- [NOVO]
        elseif data.Type == "Res" then show = Configs.EspResources end
        
        if data.Highlight then data.Highlight.Enabled = show end
        if data.Billboard then data.Billboard.Enabled = show end
        
        if show then
            local t = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
            if t then data.TextLabel.Text = string.format("%s [%dm]", data.TextLabel.Text:split(" ")[1], math.floor((root.Position - t.Position).Magnitude)) end
        end
    end
end)

-- // SCANNER GERAL
task.spawn(function()
    while task.wait(1) do
        if Configs.EspMobs or Configs.AutoFarm then
            Cache.Mobs = {}
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= Player.Character and v.Humanoid.Health > 0 then
                    table.insert(Cache.Mobs, v)
                    if Configs.EspMobs then CreateESP(v, Color3.fromRGB(255, 50, 50), "MOB", "Mob") end
                end
            end
        end
        if Configs.EspEggs or Configs.EspResources or Configs.EspChests or Configs.AutoEgg or Configs.AutoCollect or Configs.AutoChest then
            Cache.Eggs = {}; Cache.Resources = {}; Cache.Chests = {}
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Model") then
                    local name = v.Name:lower()
                    if name:match("egg") then
                        table.insert(Cache.Eggs, v); if Configs.EspEggs then CreateESP(v, Color3.fromRGB(255, 215, 0), "OVO", "Egg") end
                    elseif name:find("chest") or name:find("treasure") then -- [NOVO] Check para baús
                        table.insert(Cache.Chests, v); if Configs.EspChests then CreateESP(v, Color3.fromRGB(0, 170, 255), "BAÚ", "Chest") end
                    elseif v:FindFirstChildWhichIsA("ProximityPrompt", true) then
                        table.insert(Cache.Resources, v); if Configs.EspResources then CreateESP(v, Color3.fromRGB(50, 255, 50), "REC", "Res") end
                    end
                end
            end
        end
    end
end)

-- // AUTO START RACE
task.spawn(function()
    while task.wait(1) do
        if Configs.AutoRiding and Configs.AutoStartRace then
            local root = GetRoot()
            if root then
                for _, prompt in pairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        if prompt.ObjectText:lower():find("race") or prompt.ActionText:lower():find("race") or prompt.Parent.Name:lower():find("start") then
                            if (root.Position - prompt.Parent.Position).Magnitude < 15 then fireproximityprompt(prompt); task.wait(1) end
                        end
                    end
                end
            end
        end
    end
end)

-- // AUTO RIDING V11
task.spawn(function()
    while task.wait() do
        if Configs.AutoRiding then
            local mover = GetMoverPart()
            if not mover then task.wait(0.5) continue end
            local interactions = Workspace:FindFirstChild("Interactions")
            local ridingRings = interactions and interactions:FindFirstChild("RidingRings")
            local createdRings = ridingRings and ridingRings:FindFirstChild("CreatedRings")
            if createdRings then
                local bestRing = nil
                local closestDist = Configs.SearchRadius
                for _, obj in pairs(createdRings:GetChildren()) do
                    if obj:IsA("BasePart") and tonumber(obj.Name) then
                        local isRingSize = obj.Size.Magnitude > Configs.MinSize
                        local isActive = obj.Transparency < Configs.MaxTransparency
                        if isRingSize and isActive then
                            if not State.Blacklist[obj] then
                                local dist = (mover.Position - obj.Position).Magnitude
                                if dist < closestDist then closestDist = dist; bestRing = obj end
                            end
                        end
                    end
                end
                if bestRing then
                    if (mover.Position - State.LastPos).Magnitude > 2 then State.StuckCount = 0 else State.StuckCount = State.StuckCount + 1 end
                    State.LastPos = mover.Position
                    if State.StuckCount > 30 then mover.CFrame = mover.CFrame * CFrame.new(0, 5, 0); State.StuckCount = 0 end
                    local dist = (mover.Position - bestRing.Position).Magnitude
                    local speed = dist / Configs.TweenSpeed
                    if speed < 0.1 then speed = 0.1 end
                    local tween = TweenService:Create(mover, TweenInfo.new(speed, Enum.EasingStyle.Linear), {CFrame = bestRing.CFrame})
                    tween:Play()
                    local reached = false
                    local conn = RunService.RenderStepped:Connect(function()
                        if not Configs.AutoRiding or not bestRing.Parent or bestRing.Transparency > 0.9 then tween:Cancel(); reached = true else
                            if (mover.Position - bestRing.Position).Magnitude < 8 then reached = true end
                        end
                    end)
                    repeat task.wait() until reached; if conn then conn:Disconnect() end
                    if reached and Configs.AutoRiding then State.Blacklist[bestRing] = tick(); mover.CFrame = bestRing.CFrame; task.wait(0.05) end
                else task.wait(0.1) end
            end
        else task.wait(0.5) end
    end
end)

-- Limpeza Blacklist
task.spawn(function()
    while task.wait(1) do
        local now = tick()
        for ring, timeAdded in pairs(State.Blacklist) do
            if now - timeAdded > Configs.IgnoreTime then State.Blacklist[ring] = nil end
        end
    end
end)

-- Auto Farm Mobs
task.spawn(function()
    while task.wait() do
        if Configs.AutoFarm and State.TargetMob and State.TargetMob.Parent and State.TargetMob.Humanoid.Health > 0 then
            local r = GetRoot(); local mr = State.TargetMob:FindFirstChild("HumanoidRootPart")
            if r and mr then
                r.CFrame = CFrame.new(mr.Position + Vector3.new(0, Configs.FarmDistance, 0), mr.Position)
                r.Velocity = Vector3.zero; VirtualUser:ClickButton1(Vector2.zero)
            else State.TargetMob = nil end
        elseif Configs.AutoFarm then
            local c, d = nil, math.huge
            for _, m in pairs(Cache.Mobs) do
                if m.Parent then local dist = (GetRoot().Position - m.HumanoidRootPart.Position).Magnitude; if dist < d then c = m; d = dist end end
            end
            State.TargetMob = c
        end
    end
end)

-- Auto Egg
task.spawn(function()
    while task.wait(0.5) do
        if Configs.AutoEgg and #Cache.Eggs > 0 then
            local r = GetRoot()
            if State.CurrentEggIndex > #Cache.Eggs then State.CurrentEggIndex = 1 end
            local e = Cache.Eggs[State.CurrentEggIndex]
            if e and e.Parent then
                local ep = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
                if ep then
                    r.CFrame = ep.CFrame
                    local p = e:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if p then 
                        fireproximityprompt(p)
                        task.wait(0.5); ClickTargetMinigame(); AttemptAutoClaim()
                        if ESP_Storage[e] then
                            if ESP_Storage[e].Highlight then ESP_Storage[e].Highlight:Destroy() end
                            if ESP_Storage[e].Billboard then ESP_Storage[e].Billboard:Destroy() end
                            ESP_Storage[e] = nil
                        end
                        task.wait(0.3) 
                    end
                end
            end
            State.CurrentEggIndex = State.CurrentEggIndex + 1
        end
    end
end)

-- [NOVO] AUTO CHEST
task.spawn(function()
    while task.wait(0.5) do
        if Configs.AutoChest and #Cache.Chests > 0 then
            local root = GetRoot()
            if root then
                -- Pega o baú mais próximo
                local closest, dist = nil, math.huge
                for _, chest in pairs(Cache.Chests) do
                    if chest and chest.Parent then
                        local part = chest:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local d = (root.Position - part.Position).Magnitude
                            if d < dist then closest = chest; dist = d end
                        end
                    end
                end
                
                if closest then
                    local part = closest:FindFirstChildWhichIsA("BasePart")
                    if part then
                        -- Teleporta
                        root.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                        task.wait(0.2)
                        
                        -- Tenta interagir
                        local prompt = closest:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            fireproximityprompt(prompt)
                            task.wait(0.5)
                            AttemptAutoClaim()
                        end
                        
                        -- Remove do Cache/ESP temporariamente para não travar nele
                        if ESP_Storage[closest] then
                            if ESP_Storage[closest].Highlight then ESP_Storage[closest].Highlight:Destroy() end
                            if ESP_Storage[closest].Billboard then ESP_Storage[closest].Billboard:Destroy() end
                            ESP_Storage[closest] = nil
                        end
                        -- Remove da lista para ir pro próximo
                        for i,v in pairs(Cache.Chests) do if v == closest then table.remove(Cache.Chests, i) end end
                    end
                end
            end
        end
    end
end)

-- Fly e Player Mods
RunService.RenderStepped:Connect(function()
    local h, r = GetHumanoid(), GetRoot()
    if h then h.WalkSpeed = Configs.WalkSpeed; h.JumpPower = Configs.JumpPower end
    if Configs.Fly and State.Flying and r then
        h.PlatformStand = true; local cam = Camera.CFrame; local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        r.Velocity = move * Configs.FlySpeed
    elseif State.WasFlying then
        if r then r.Velocity = Vector3.zero end; if h then h.PlatformStand = false end
        State.WasFlying = false
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.G then State.Flying = not State.Flying
    elseif input.KeyCode == Enum.KeyCode.H then MainFrame.Visible = not MainFrame.Visible end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "PudimHub - DA🐉", Text = "Carregado com Sucesso!", Duration = 5})
