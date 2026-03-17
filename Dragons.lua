local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Theme = {
    Background = Color3.fromRGB(18, 18, 24),
    Sidebar = Color3.fromRGB(25, 25, 35),
    Element = Color3.fromRGB(35, 35, 45),
    Text = Color3.fromRGB(240, 240, 240),
    Accent = Color3.fromRGB(255, 50, 50),
    ToggleOff = Color3.fromRGB(60, 60, 70),
    Outline = Color3.fromRGB(50, 50, 60)
}

local Configs = {
    AutoFarm = false,
    AutoEgg = false,
    AutoCollect = false,
    EspMobs = false,
    EspEggs = false,
    EspResources = false,
    WalkSpeed = 16,
    JumpPower = 50,
    Fly = false,
    FlySpeed = 50,
    FarmDistance = 15,
    TweenSpeed = 100
}

local State = {
    TargetMob = nil,
    CurrentEggIndex = 1,
    Flying = false,
    WasFlying = false, 
    Tweening = false
}

local Cache = {
    Mobs = {},
    Eggs = {},
    Resources = {}
}

local ESP_Storage = {} 

local function GetRoot()
    return Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    return Player.Character and Player.Character:FindFirstChild("Humanoid")
end

Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PudimLinooHub_DA"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.Sidebar
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Text = "PudimLinoo hub - DA🐉"
Title.RichText = true
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Theme.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Accent
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.MouseButton1Click:Connect(function() 

    for _, data in pairs(ESP_Storage) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
    end
    ScreenGui:Destroy() 
end)

local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(0, 130, 1, -40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Theme.Sidebar
Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 10)

local TabList = Instance.new("UIListLayout", TabContainer)
TabList.Padding = UDim.new(0, 5)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.SortOrder = Enum.SortOrder.LayoutOrder

Instance.new("UIPadding", TabContainer).PaddingTop = UDim.new(0, 10)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -140, 1, -50)
ContentContainer.Position = UDim2.new(0, 135, 0, 45)
ContentContainer.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name, icon)
    local TabButton = Instance.new("TextButton", TabContainer)
    TabButton.Size = UDim2.new(0.9, 0, 0, 35)
    TabButton.BackgroundColor3 = Theme.Background
    TabButton.Text = name
    TabButton.TextColor3 = Theme.Text
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 14
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
    
    local Page = Instance.new("ScrollingFrame", ContentContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Theme.Accent
    
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    TabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Page.Visible = false t.Btn.BackgroundColor3 = Theme.Background t.Btn.TextColor3 = Theme.Text end
        Page.Visible = true
        TabButton.BackgroundColor3 = Theme.Accent
        TabButton.TextColor3 = Color3.new(1,1,1)
    end)
    
    table.insert(Tabs, {Btn = TabButton, Page = Page})
    return Page
end

local function CreateToggle(parent, text, configKey, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -10, 0, 40)
    Frame.BackgroundColor3 = Theme.Element
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextSize = 14
    
    local Button = Instance.new("TextButton", Frame)
    Button.Text = ""
    Button.Size = UDim2.new(0, 44, 0, 22)
    Button.Position = UDim2.new(1, -54, 0.5, -11)
    Button.BackgroundColor3 = Configs[configKey] and Theme.Accent or Theme.ToggleOff
    Instance.new("UICorner", Button).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", Button)
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = Configs[configKey] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    Circle.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    
    Button.MouseButton1Click:Connect(function()
        Configs[configKey] = not Configs[configKey]
        local state = Configs[configKey]
        
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
        
        if callback then callback(state) end
    end)
end

local function CreateSlider(parent, text, min, max, configKey)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -10, 0, 55)
    Frame.BackgroundColor3 = Theme.Element
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text .. ": " .. Configs[configKey]
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextSize = 14
    
    local SliderBg = Instance.new("TextButton", Frame)
    SliderBg.Text = ""
    SliderBg.Size = UDim2.new(1, -20, 0, 6)
    SliderBg.Position = UDim2.new(0, 10, 0, 35)
    SliderBg.BackgroundColor3 = Theme.Background
    SliderBg.AutoButtonColor = false
    Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)
    
    local SliderFill = Instance.new("Frame", SliderBg)
    SliderFill.Size = UDim2.new((Configs[configKey] - min)/(max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Theme.Accent
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
    
    local function Update(input)
        local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        Configs[configKey] = val
        Label.Text = text .. ": " .. val
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
    end
    
    local sliding = false
    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            Update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
    end)
end

local FarmTab = CreateTab("Auto Farm")
local EspTab = CreateTab("Visuals / ESP")
local PlayerTab = CreateTab("Player")

CreateToggle(FarmTab, "Auto Farm Mobs", "AutoFarm", function(state)
    if not state then
        State.TargetMob = nil
        local root = GetRoot()
        if root then root.Velocity = Vector3.new(0,0,0) end
    end
end)
CreateSlider(FarmTab, "Distância do Mob", 5, 50, "FarmDistance")
CreateToggle(FarmTab, "Auto Coletar Ovos (TP)", "AutoEgg", function(state)
    if not state then State.CurrentEggIndex = 1 end
end)
CreateSlider(FarmTab, "Velocidade do TP", 50, 300, "TweenSpeed")
CreateToggle(FarmTab, "Auto Coletar (Recursos)", "AutoCollect")

CreateToggle(EspTab, "ESP Mobs (Vermelho)", "EspMobs", function(state)
    if not state then
        for model, data in pairs(ESP_Storage) do
            if data.Type == "Mob" then
                if data.Highlight then data.Highlight:Destroy() end
                if data.Billboard then data.Billboard:Destroy() end
                ESP_Storage[model] = nil
            end
        end
    end
end)
CreateToggle(EspTab, "ESP Ovos (Dourado)", "EspEggs", function(state)
    if not state then
        for model, data in pairs(ESP_Storage) do
            if data.Type == "Egg" then
                if data.Highlight then data.Highlight:Destroy() end
                if data.Billboard then data.Billboard:Destroy() end
                ESP_Storage[model] = nil
            end
        end
    end
end)
CreateToggle(EspTab, "ESP Recursos (Verde)", "EspResources", function(state)
    if not state then
        for model, data in pairs(ESP_Storage) do
            if data.Type == "Res" then
                if data.Highlight then data.Highlight:Destroy() end
                if data.Billboard then data.Billboard:Destroy() end
                ESP_Storage[model] = nil
            end
        end
    end
end)

CreateToggle(PlayerTab, "Ativar Voo (G)", "Fly", function(state)
    if not state then
        State.Flying = false
        local root = GetRoot()
        local hum = GetHumanoid()
        if root then root.Velocity = Vector3.new(0,0,0) end
        if hum then hum.PlatformStand = false end
    end
end)
CreateSlider(PlayerTab, "Velocidade Voo", 20, 200, "FlySpeed")
CreateSlider(PlayerTab, "Velocidade Andar", 16, 200, "WalkSpeed")
CreateSlider(PlayerTab, "Força do Pulo", 50, 300, "JumpPower")

Tabs[1].Btn.BackgroundColor3 = Theme.Accent
Tabs[1].Btn.TextColor3 = Color3.new(1,1,1)
Tabs[1].Page.Visible = true

local function CreateESP(model, color, name, typeTag)
    if ESP_Storage[model] then return end
    local basePart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not basePart then return end

    local hl = Instance.new("Highlight")
    hl.Parent = CoreGui
    hl.Adornee = model
    hl.FillColor = color
    hl.OutlineColor = Color3.new(1,1,1)
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0.2
    
    local bill = Instance.new("BillboardGui")
    bill.Adornee = basePart
    bill.Size = UDim2.new(0, 100, 0, 20)
    bill.AlwaysOnTop = true
    bill.Parent = CoreGui
    
    local text = Instance.new("TextLabel", bill)
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = color
    text.TextStrokeTransparency = 0
    text.Font = Enum.Font.GothamBold
    text.TextSize = 12
    text.Text = name
    
    ESP_Storage[model] = {Highlight = hl, Billboard = bill, TextLabel = text, Type = typeTag}
    
    model.AncestryChanged:Connect(function(_, parent)
        if not parent and ESP_Storage[model] then
            hl:Destroy()
            bill:Destroy()
            ESP_Storage[model] = nil
        end
    end)
end

RunService.RenderStepped:Connect(function()
    local root = GetRoot()
    if not root then return end

    for model, data in pairs(ESP_Storage) do

        local shouldShow = false
        if data.Type == "Mob" then shouldShow = Configs.EspMobs
        elseif data.Type == "Egg" then shouldShow = Configs.EspEggs
        elseif data.Type == "Res" then shouldShow = Configs.EspResources end
        
        if data.Highlight then data.Highlight.Enabled = shouldShow end
        if data.Billboard then data.Billboard.Enabled = shouldShow end
        
        if shouldShow and model and model.Parent then
            local targetPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                local dist = (root.Position - targetPart.Position).Magnitude
                data.TextLabel.Text = string.format("%s [%dm]", data.Type == "Mob" and "MOB" or (data.Type == "Egg" and "OVO" or "REC"), math.floor(dist))
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do

        if Configs.EspMobs or Configs.AutoFarm then
            Cache.Mobs = {}
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= Player.Character then
                    if v.Humanoid.Health > 0 then
                        table.insert(Cache.Mobs, v)
                        if Configs.EspMobs then CreateESP(v, Color3.fromRGB(255, 50, 50), "MOB", "Mob") end
                    end
                end
            end
        end

        if Configs.EspEggs or Configs.EspResources or Configs.AutoEgg or Configs.AutoCollect then
            Cache.Eggs = {}
            Cache.Resources = {}
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Model") then
                    local isEgg = v.Name:lower():match("egg")
                    local hasPrompt = v:FindFirstChildWhichIsA("ProximityPrompt", true)
                    
                    if isEgg then
                        table.insert(Cache.Eggs, v)
                        if Configs.EspEggs then CreateESP(v, Color3.fromRGB(255, 215, 0), "OVO", "Egg") end
                    elseif hasPrompt and not isEgg then
                        table.insert(Cache.Resources, v)
                        if Configs.EspResources then CreateESP(v, Color3.fromRGB(50, 255, 50), "REC", "Res") end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if Configs.AutoFarm then
            local root = GetRoot()
            if root then
                -- Selecionar Alvo
                if not State.TargetMob or not State.TargetMob.Parent or State.TargetMob.Humanoid.Health <= 0 then
                    local closest, dist = nil, math.huge
                    for _, mob in ipairs(Cache.Mobs) do
                        if mob and mob:FindFirstChild("HumanoidRootPart") then
                            local d = (root.Position - mob.HumanoidRootPart.Position).Magnitude
                            if d < dist then closest = mob; dist = d end
                        end
                    end
                    State.TargetMob = closest
                end
                if State.TargetMob then
                    local mobRoot = State.TargetMob:FindFirstChild("HumanoidRootPart")
                    if mobRoot then

                        root.CFrame = CFrame.new(mobRoot.Position + Vector3.new(0, Configs.FarmDistance, 0), mobRoot.Position)
                        root.Velocity = Vector3.new(0,0,0)
                        VirtualUser:ClickButton1(Vector2.new())
                    end
                end
            end
        else
            if State.TargetMob then State.TargetMob = nil end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if Configs.AutoEgg and #Cache.Eggs > 0 then
            local root = GetRoot()
            if not root then continue end
            
            if State.CurrentEggIndex > #Cache.Eggs then State.CurrentEggIndex = 1 end
            local egg = Cache.Eggs[State.CurrentEggIndex]
            
            if egg and egg.Parent then
                local eggPart = egg:FindFirstChild("HumanoidRootPart") or egg:FindFirstChildWhichIsA("BasePart")
                if eggPart then
                    local dist = (root.Position - eggPart.Position).Magnitude
                    
                    if dist > 5 then
                        local tweenInfo = TweenInfo.new(dist / Configs.TweenSpeed, Enum.EasingStyle.Linear)
                        local tween = TweenService:Create(root, tweenInfo, {CFrame = eggPart.CFrame * CFrame.new(0, 3, 0)})
                        tween:Play()
                        tween.Completed:Wait()
                    end
                    
                    root.CFrame = eggPart.CFrame
                    local prompt = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then
                        fireproximityprompt(prompt)
                        task.wait(0.3)
                    end
                    State.CurrentEggIndex = State.CurrentEggIndex + 1
                else
                    State.CurrentEggIndex = State.CurrentEggIndex + 1
                end
            else
                State.CurrentEggIndex = State.CurrentEggIndex + 1
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if Configs.AutoCollect then
            local root = GetRoot()
            if root then
                for _, res in ipairs(Cache.Resources) do
                    if res and res.Parent then
                        local prompt = res:FindFirstChildWhichIsA("ProximityPrompt", true)
                        local part = res:FindFirstChildWhichIsA("BasePart") or (res:FindFirstChild("HumanoidRootPart"))
                        if prompt and part then
                            local dist = (root.Position - part.Position).Magnitude
                            if dist < 20 then
                                fireproximityprompt(prompt)
                            end
                        end
                    end
                end
            end
        end
    end
end)
RunService.RenderStepped:Connect(function()
    local hum = GetHumanoid()
    local root = GetRoot()
    
    if hum then
        hum.WalkSpeed = Configs.WalkSpeed
        hum.JumpPower = Configs.JumpPower
    end
    
    local isFlying = Configs.Fly and State.Flying
    
    if isFlying and root then
        hum.PlatformStand = true
        local cam = Camera.CFrame
        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
        
        root.Velocity = move * Configs.FlySpeed
        State.WasFlying = true
    else
        if State.WasFlying then
            if root then root.Velocity = Vector3.new(0,0,0) end
            if hum then hum.PlatformStand = false end
            State.WasFlying = false
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.G then
        State.Flying = not State.Flying
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "PudimLinoo Hub",
    Text = "Script Dragon Adventures Carregado! 🐉",
    Duration = 5
})
