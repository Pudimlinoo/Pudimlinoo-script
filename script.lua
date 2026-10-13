-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Pudimlinoo/Pudimlinoo-script/main/script.lua"))()

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- Nome EXCLUSIVO do seu Hub (Para não confundir com o Tracker)
-- Nome EXCLUSIVO do seu Hub 
local NOME_DO_HUB = "PudimHub_Main_Interface"

-- 1. Remove APENAS o Hub se ele já estiver aberto
-- Remove APENAS o Hub se ele já estiver aberto
if player and player:FindFirstChild("PlayerGui") then
    if player.PlayerGui:FindFirstChild(NOME_DO_HUB) then
        player.PlayerGui[NOME_DO_HUB]:Destroy()
    end
end

if CoreGui:FindFirstChild(NOME_DO_HUB) then
    CoreGui[NOME_DO_HUB]:Destroy()
end

-- ================= SERVIÇOS =================
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local FILENAME = "BloxFruits_Tracker_Final.json"

-- ================= TEMA REDZ =================
local Theme = {

	Main = Color3.fromRGB(5,5,8),       -- fundo principal
	Second = Color3.fromRGB(13,8,11),     -- fundo interno
	Button = Color3.fromRGB(26,10,15),     -- botão neutro

	Red = Color3.fromRGB(240,30,55),       -- vermelho principal
	DarkRed = Color3.fromRGB(95,10,25),   -- vermelho escuro

	Text = Color3.fromRGB(240,240,240),
	Stroke = Color3.fromRGB(60,60,60)

}
-- ================= FUNÇÕES PLAYER =================
local function getChar()
	return player.Character or player.CharacterAdded:Wait()
end

local function getHumanoid()
	return getChar():WaitForChild("Humanoid")
end

local function getRoot()
	return getChar():WaitForChild("HumanoidRootPart")
end


local function fastClick()
	mouse1click()
end

-- ================= BUSCAR NPC =================

local function getClosestEnemy()

-- ================= FAST ATTACK =================

local VirtualUser = game:GetService("VirtualUser")

	local closest
	local dist = math.huge

	local enemiesFolder = workspace:FindFirstChild("Enemies")
if not enemiesFolder then return nil end

for _,v in pairs(enemiesFolder:GetChildren()) do

		local hum = v:FindFirstChild("Humanoid")
		local root = v:FindFirstChild("HumanoidRootPart")

		if hum and root and hum.Health > 0 then

			local d = (getRoot().Position - root.Position).Magnitude

			if d < dist then
				dist = d
				closest = v
			end

		end
	end

	return closest
end

-- Estado de interface e registro dos controles (sem ativar funções ao carregar).
local HUD = {sliders = {}, jump = 60, scale = 100, status = true, alive = true, connections = {}, collisions = setmetatable({}, {__mode = "k"}), espLoops = {}}
function HUD.connect(signal, callback)
    local connection = signal:Connect(function(...)
        if HUD.alive then callback(...) end
    end)
    table.insert(HUD.connections, connection)
    return connection
end
-- ================= GUI =================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = NOME_DO_HUB -- <--- AQUI: Usa o nome único definido lá em cima
gui.ResetOnSpawn = false
HUD.travelActive = false
HUD.travelSpeed = 250
HUD.farmPaused = false
HUD.farmRadius = 800
HUD.farmFilter = ""
HUD.autoEquip = false
HUD.farmSearchAt = 0
HUD.farmAttackAt = 0
HUD.attackHz = 10
HUD.attackReach = 4
HUD.autoNear = false
HUD.manualFarmHeight = false
HUD.localHitbox = false
HUD.hitboxWidth = 8
HUD.hitboxPart = nil
HUD.hitboxOriginal = nil
function HUD.restoreHitbox()
    local part, saved = HUD.hitboxPart, HUD.hitboxOriginal
    HUD.hitboxPart, HUD.hitboxOriginal = nil, nil
    if part and part.Parent and saved then
        part.Size = saved.size
        part.CanCollide = saved.collide
    end
end
function HUD.applyHitbox(npc)
    local part = npc and npc:FindFirstChild("HumanoidRootPart")
    if not HUD.localHitbox or not part then HUD.restoreHitbox(); return end
    if HUD.hitboxPart ~= part then
        HUD.restoreHitbox()
        HUD.hitboxPart = part
        HUD.hitboxOriginal = {size=part.Size,collide=part.CanCollide}
    end
    local size = HUD.hitboxOriginal.size
    part.Size = Vector3.new(math.max(size.X,HUD.hitboxWidth),size.Y,math.max(size.Z,HUD.hitboxWidth))
    part.CanCollide = false
end
-- Distância à superfície das partes do corpo, sem usar acessórios como hitbox.
function HUD.bodyDistance(npc, position)
    local nearest = math.huge
    for _, part in ipairs(npc:GetChildren()) do
        if part:IsA("BasePart") then
            local size = (part == HUD.hitboxPart and HUD.hitboxOriginal) and HUD.hitboxOriginal.size or part.Size
            local half = size * 0.5
            local localPoint = part.CFrame:PointToObjectSpace(position)
            local outside = Vector3.new(math.max(0,math.abs(localPoint.X)-half.X),math.max(0,math.abs(localPoint.Y)-half.Y),math.max(0,math.abs(localPoint.Z)-half.Z))
            nearest = math.min(nearest,outside.Magnitude)
        end
    end
    return nearest
end
function HUD.isCombatTool(tool)
    return tool and tool:IsA("Tool") and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword")
end
function HUD.tryAttack(npc, tool, root, now, fast)
    if not HUD.isCombatTool(tool) then return "Equipe uma ferramenta Melee ou Sword." end
    local targetHum = npc and npc:FindFirstChildOfClass("Humanoid")
    if not targetHum or targetHum.Health <= 0 then return "Alvo indisponível." end
    if UserInputService:GetFocusedTextBox() then return "Ataque pausado enquanto você digita." end
    local distance = HUD.bodyDistance(npc,root.Position)
    if distance > HUD.attackReach then return string.format("Fora da distância de ataque / %.1f studs",distance) end
    if not tool.Enabled then return "Aguardando a ferramenta ficar disponível." end
    if now < HUD.farmAttackAt then return "Alvo em alcance / aguardando próximo ataque." end
    HUD.farmAttackAt = now + (fast and 1 / HUD.attackHz or 0.3)
    local ok = pcall(function() tool:Activate() end)
    if not ok then return "A ferramenta não aceitou a ativação." end
    task.delay(0.025,function()
        if HUD.alive and tool.Parent == player.Character and tool.Enabled then
            pcall(function() tool:Deactivate() end)
        end
    end)
    return "Atacando: "..npc.Name.." / "..tool.Name
end
HUD.manualHold = 0
HUD.seaBusy = false
HUD.seaToken = 0
gui.Destroying:Connect(function()
    HUD.alive = false
    for _, connection in ipairs(HUD.connections) do connection:Disconnect() end
    table.clear(HUD.connections)
end)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,460,0,520)
frame.Position = UDim2.new(0.03,0,0.35,0)
frame.BackgroundColor3 = Theme.Main
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke",frame)
stroke.Color = Theme.Red
stroke.Thickness = 1.5
-- ================= HUD V002 =================
local TweenService = game:GetService("TweenService")
local OPEN_SIZE = UDim2.fromOffset(600, 600)
local OPEN_TRANSP = 0.18
frame.Size = OPEN_SIZE
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.BackgroundColor3 = Theme.Main
frame.ClipsDescendants = false
stroke.Color = Theme.Red
stroke.Transparency = 0.25
stroke.Thickness = 1
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local hudScale = Instance.new("UIScale", frame)
local function fitHUD()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local view = cam.ViewportSize
    hudScale.Scale = math.max(0.1, math.min(HUD.scale / 100, (view.X - 24) / 600, (view.Y - 60) / 600))
end
fitHUD()
local viewportConnection
local function bindViewport()
    Camera = workspace.CurrentCamera
    if viewportConnection then viewportConnection:Disconnect() end
    local cam = workspace.CurrentCamera
    if cam then viewportConnection = cam:GetPropertyChangedSignal("ViewportSize"):Connect(fitHUD) end
    fitHUD()
end
bindViewport()
local cameraConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewport)
gui.Destroying:Connect(function()
    if viewportConnection then viewportConnection:Disconnect() end
    cameraConnection:Disconnect()
end)

-- sombra
local shadow = Instance.new("ImageLabel", frame)
shadow.AnchorPoint = Vector2.new(0.5,0.5)
shadow.Position = UDim2.new(0.5,0,0.5,0)
shadow.Size = UDim2.new(1,40,1,40)
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.6
shadow.BackgroundTransparency = 1
shadow.ZIndex = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,38)
title.BackgroundColor3 = Theme.DarkRed
title.BackgroundTransparency = 0
title.Text = "🍮 PudimLinoo Hub"
title.TextColor3 = Theme.Text
title.Font = Enum.Font.GothamBold
title.TextSize = 20
Instance.new("UICorner", title).CornerRadius = UDim.new(0,16)

-- Cabeçalho e arraste com mouse/toque
title.Size = UDim2.new(1, 0, 0, 64)
title.BackgroundColor3 = Theme.Second
title.BackgroundTransparency = 0.15
title.Text = "  🍮 PUDIMHUB"
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 19
local subtitle = Instance.new("TextLabel", frame)
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.new(1, -150, 0, 20)
subtitle.Size = UDim2.fromOffset(130, 24)
subtitle.Text = "V010  /  BLOX FRUITS"
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 11
subtitle.TextColor3 = Color3.fromRGB(156, 161, 177)
local dragging, dragStart, startPos, dragTouch
title.Active = true
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, input.Position, frame.Position
        dragTouch = input.UserInputType == Enum.UserInputType.Touch and input or nil
    end
end)
local dragChanged = HUD.connect(UserInputService.InputChanged, function(input)
    if dragging and (input == dragTouch or (not dragTouch and input.UserInputType == Enum.UserInputType.MouseMovement)) then
        local delta = input.Position - dragStart
        local cam = workspace.CurrentCamera
        if not cam then return end
        local view = cam.ViewportSize
        local half = Vector2.new(300, 300) * hudScale.Scale
        local x = startPos.X.Scale * view.X + startPos.X.Offset + delta.X
        local y = startPos.Y.Scale * view.Y + startPos.Y.Offset + delta.Y
        x = math.clamp(x, half.X, math.max(half.X, view.X - half.X))
        y = math.clamp(y, half.Y, math.max(half.Y, view.Y - half.Y - 36))
        frame.Position = UDim2.fromOffset(x, y)
    end
end)
local dragEnded = HUD.connect(UserInputService.InputEnded, function(input)
    if input == dragTouch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging, dragTouch = false, nil
    end
end)
gui.Destroying:Connect(function() dragChanged:Disconnect(); dragEnded:Disconnect() end)

-- Navegação com rolagem independente
local sidebar = Instance.new("ScrollingFrame", frame)
sidebar.Size = UDim2.new(0, 132, 1, -124)
sidebar.Position = UDim2.fromOffset(12, 76)
sidebar.BackgroundTransparency = 1
sidebar.BorderSizePixel = 0
sidebar.CanvasSize = UDim2.new()
sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebar.ScrollBarThickness = 2
sidebar.ScrollBarImageColor3 = Theme.Red
sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 8)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
local container = Instance.new("Frame", frame)
container.Size = UDim2.new(1, -166, 1, -170)
container.Position = UDim2.fromOffset(154, 122)
container.BackgroundTransparency = 1
local tabs, tabButtons = {}, {}
local currentTab
local function createTab(name)
    task.wait()
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -6, 0, 42)
    btn.LayoutOrder = #tabs + 1
    btn.BackgroundColor3 = Theme.Second
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = name
    btn.Font = Enum.Font.GothamMedium
    btn.TextColor3 = Color3.fromRGB(155, 161, 180)
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local page = Instance.new("ScrollingFrame", container)
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new()
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Theme.Red
    page.ScrollBarImageTransparency = 0.25
    page.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    page.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    page.Visible = false
    local padding = Instance.new("UIPadding", page)
    padding.PaddingTop = UDim.new(0, 2)
    padding.PaddingBottom = UDim.new(0, 16)
    padding.PaddingLeft = UDim.new(0, 2)
    padding.PaddingRight = UDim.new(0, 8)
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    local nextOrder = 0
    page.ChildAdded:Connect(function(child)
        if child:IsA("GuiObject") then
            nextOrder += 1
            child.LayoutOrder = nextOrder
        end
    end)
    table.insert(tabs, page)
    tabButtons[page] = btn
    local function selectTab()
        for _, other in ipairs(tabs) do
            other.Visible = other == page
            TweenService:Create(tabButtons[other], TweenInfo.new(0.15), {
                BackgroundColor3 = other == page and Theme.DarkRed or Theme.Second,
                TextColor3 = other == page and Theme.Text or Color3.fromRGB(155,161,180)
            }):Play()
        end
        currentTab = page
    end
    btn.Activated:Connect(selectTab)
    if not currentTab then selectTab() end
    return page
end

local tabOverview = createTab("INÍCIO")
local tabPlayer = createTab("PLAYER")
local tabFarm = createTab("Auto-Farm")
local tabESP = createTab("ESP")
local tabTeleport = createTab("TELEPORT")
local tabAimbot = createTab("AIMBOT")
local tabSistema = createTab("SISTEMA")
local tabSettings = createTab("AJUSTES")


-- ================= UI HELPERS =================
local function roundUI(object, radius)
    Instance.new("UICorner", object).CornerRadius = UDim.new(0, radius or 8)
end
local function criarSecao(txt, y, p)
    local label = Instance.new("TextLabel", p)
    label.Size = UDim2.new(1, 0, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = txt
    label.TextColor3 = Color3.fromRGB(237, 116, 127)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
end
local function criarBotaoToggle(txt, y, p, cb)
    local row = Instance.new("TextButton", p)
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = Theme.Second
    row.BackgroundTransparency = 0.2
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    roundUI(row)
    local label = Instance.new("TextLabel", row)
    label.Position = UDim2.fromOffset(12, 0)
    label.Size = UDim2.new(1, -76, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = txt
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    local toggle = Instance.new("Frame", row)
    toggle.Size = UDim2.fromOffset(40, 22)
    toggle.Position = UDim2.new(1, -52, 0.5, -11)
    toggle.BackgroundColor3 = Color3.fromRGB(55,18,25)
    roundUI(toggle, 11)
    local circle = Instance.new("Frame", toggle)
    circle.Size = UDim2.fromOffset(16, 16)
    circle.Position = UDim2.fromOffset(3, 3)
    circle.BackgroundColor3 = Theme.Text
    roundUI(circle, 8)
    local state = false
    row.Activated:Connect(function()
        state = not state
        TweenService:Create(toggle, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.Red or Color3.fromRGB(55,18,25)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.15), {Position = UDim2.fromOffset(state and 21 or 3, 3)}):Play()
        cb(state)
    end)
end

local function criarSlider(txt, min, max, init, y, p, cb)
    task.wait()
    -- Um único cartão por slider: título, valor e barra rolam juntos.
    local row = Instance.new("Frame", p)
    row.Size = UDim2.new(1, 0, 0, 82)
    row.BackgroundColor3 = Theme.Second
    row.BackgroundTransparency = 0.2
    row.BorderSizePixel = 0
    roundUI(row)
    local label = Instance.new("TextLabel", row)
    label.Position = UDim2.fromOffset(12, 10)
    label.Size = UDim2.new(1, -88, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = txt
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    local valueBox = Instance.new("TextBox", row)
    valueBox.Size = UDim2.fromOffset(58, 26)
    valueBox.Position = UDim2.new(1, -70, 0, 8)
    valueBox.BackgroundColor3 = Color3.fromRGB(30, 9, 15)
    valueBox.TextColor3 = Theme.Text
    valueBox.Font = Enum.Font.GothamBold
    valueBox.TextSize = 12
    valueBox.ClearTextOnFocus = false
    roundUI(valueBox, 6)
    local hit = Instance.new("TextButton", row)
    hit.Position = UDim2.fromOffset(16, 38)
    hit.Size = UDim2.new(1, -32, 0, 36)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.AutoButtonColor = false
    local bar = Instance.new("Frame", hit)
    bar.Size = UDim2.new(1, 0, 0, 6)
    bar.Position = UDim2.new(0, 0, 0.5, -3)
    bar.BackgroundColor3 = Color3.fromRGB(59, 14, 24)
    roundUI(bar, 3)
    local fill = Instance.new("Frame", bar)
    fill.BackgroundColor3 = Theme.Red
    fill.BorderSizePixel = 0
    roundUI(fill, 3)
    local knob = Instance.new("Frame", bar)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.fromOffset(16, 16)
    knob.BackgroundColor3 = Theme.Text
    roundUI(knob, 8)
    local value, activeInput, scrollWasEnabled
    local function setValue(newValue)
        if newValue ~= newValue then return end
        newValue = math.clamp(math.floor(newValue + 0.5), min, max)
        local ratio = (newValue - min) / (max - min)
        fill.Size = UDim2.fromScale(ratio, 1)
        knob.Position = UDim2.fromScale(ratio, 0.5)
        valueBox.Text = tostring(newValue)
        if value ~= newValue then value = newValue; cb(value) end
    end
    local function fromPosition(position)
        if bar.AbsoluteSize.X <= 0 then return end
        setValue(min + math.clamp((position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1) * (max - min))
    end
    local function stopDrag()
        if not activeInput then return end
        activeInput = nil
        p.ScrollingEnabled = scrollWasEnabled
    end
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if activeInput then return end
            activeInput = input
            scrollWasEnabled = p.ScrollingEnabled
            p.ScrollingEnabled = false
            fromPosition(input.Position)
        end
    end)
    local moveConnection = HUD.connect(UserInputService.InputChanged, function(input)
        if activeInput and (input == activeInput or (activeInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement)) then
            fromPosition(input.Position)
        end
    end)
    local endConnection = HUD.connect(UserInputService.InputEnded, function(input)
        if input == activeInput or (activeInput and activeInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1) then stopDrag() end
    end)
    local focusConnection = HUD.connect(UserInputService.WindowFocusReleased, stopDrag)
    p:GetPropertyChangedSignal("Visible"):Connect(function() if not p.Visible then stopDrag() end end)
    valueBox.FocusLost:Connect(function() setValue(tonumber(valueBox.Text) or value) end)
    row.Destroying:Connect(function()
        stopDrag()
        moveConnection:Disconnect()
        endConnection:Disconnect()
        focusConnection:Disconnect()
    end)
    local key = p.Name .. "/" .. txt
    HUD.sliders[key] = {set = setValue, get = function() return value end, default = init, min = min, max = max}
    setValue(init)
end
-- ================= VARIÁVEIS =================
local noclip = false
local floorEnabled = false
local floor
local tpSpeed = 0
local altPressed = false
-- ESP
local espOnlyEnemies = false
local espObjects = {}
local boatTransparencyEnabled = false
local BOAT_TRANSPARENCY = 0.6
local ESPAtivo = false
-- ESP FRUTAS
local fruitESPEnabled = false
local fruitEspObjects = {}
-- auto safe
local autoSafeEnabled = false
local autoSafePercent = 30 -- 30% da sua vida máxima
local autoSafeHeight = 10000
local emFuga = false
-- ================= AUTO FARM VARIÁVEIS =================

local autoFarmEnabled = false
local farmHeight = 15
local farmDistance = 4
local farmTarget = nil
local attacking = false
local fastAttackSpeed = 0.02

local fastAttackEnabled = false

-- ================= AUTO FARM MENU =================
criarSecao("AUTO FARM NPC",0,tabFarm)

criarBotaoToggle("AUTO FARM",30,tabFarm,function(v)
	autoFarmEnabled = v
	farmTarget = nil
    HUD.farmPaused = false
    HUD.farmSearchAt = 0
end)

criarBotaoToggle("FAST ATTACK",70,tabFarm,function(v)
	fastAttackEnabled = v
end)



criarSlider("ALTURA FARM",5,30,farmHeight,150,tabFarm,function(v)
	farmHeight = v
end)

criarSlider("DISTÂNCIA NPC",2,10,farmDistance,190,tabFarm,function(v)
	farmDistance = v
end)

criarSlider("RAIO DE BUSCA NPC",100,3000,800,0,tabFarm,function(v) HUD.farmRadius = v end)
criarBotaoToggle("EQUIPAR MELEE / ESPADA",0,tabFarm,function(v) HUD.autoEquip = v end)
do
    local filter = Instance.new("TextBox", tabFarm)
    filter.Size = UDim2.new(1,0,0,40)
    filter.BackgroundColor3 = Theme.Second
    filter.TextColor3 = Theme.Text
    filter.PlaceholderText = "Nome do NPC (vazio = qualquer um)"
    filter.PlaceholderColor3 = Color3.fromRGB(180,140,145)
    filter.Text = ""
    filter.TextSize = 12
    filter.Font = Enum.Font.GothamMedium
    filter.ClearTextOnFocus = false
    roundUI(filter,8)
    filter.FocusLost:Connect(function()
        HUD.farmFilter = string.lower(filter.Text):match("^%s*(.-)%s*$")
        farmTarget = nil
        HUD.farmSearchAt = 0
    end)
    HUD.farmStatus = Instance.new("TextLabel", tabFarm)
    HUD.farmStatus.Size = UDim2.new(1,0,0,54)
    HUD.farmStatus.BackgroundTransparency = 1
    HUD.farmStatus.TextColor3 = Theme.Text
    HUD.farmStatus.Font = Enum.Font.GothamMedium
    HUD.farmStatus.TextSize = 12
    HUD.farmStatus.TextWrapped = true
    HUD.farmStatus.Text = "Auto farm desligado."
    local resume = Instance.new("TextButton", tabFarm)
    resume.Size = UDim2.new(1,0,0,38)
    resume.BackgroundColor3 = Theme.DarkRed
    resume.TextColor3 = Theme.Text
    resume.Font = Enum.Font.GothamMedium
    resume.TextSize = 12
    resume.Text = "RETOMAR FARM APÓS VIAGEM"
    roundUI(resume,8)
    resume.Activated:Connect(function()
        if not HUD.travelActive and not HUD.seaBusy then HUD.farmPaused = false; HUD.farmSearchAt = 0 end
    end)
end

criarSecao("CONTROLE DE ATAQUE",0,tabFarm)
criarSlider("Tentativas por segundo",2,15,10,0,tabFarm,function(v) HUD.attackHz = v end)
criarSlider("Distância de ativação",1,8,4,0,tabFarm,function(v) HUD.attackReach = v end)
criarBotaoToggle("ATAQUE PERTO DE NPC (SEM FARM)",0,tabFarm,function(v) HUD.autoNear = v; if not v then HUD.restoreHitbox() end end)
criarBotaoToggle("MANTER ALTURA MANUAL",0,tabFarm,function(v) HUD.manualFarmHeight = v end)
criarBotaoToggle("HITBOX LOCAL DO NPC",0,tabFarm,function(v)
    HUD.localHitbox = v
    if not v then HUD.restoreHitbox() end
end)
criarSlider("Largura da hitbox local",4,16,8,0,tabFarm,function(v) HUD.hitboxWidth = v end)
do
    local note = Instance.new("TextLabel",tabFarm)
    note.Size = UDim2.new(1,0,0,94)
    note.BackgroundTransparency = 1
    note.Font = Enum.Font.GothamMedium
    note.TextSize = 12
    note.TextColor3 = Theme.Text
    note.TextWrapped = true
    note.Text = "Sem altura manual, o farm se aproxima para atacar. A frequência controla tentativas; dano e velocidade real dependem da arma. A hitbox é local e não garante alcance extra no servidor."
end
-- ================= ESP FRUTAS =================

local FruitRarity = {

	["Rocket"] = "Common",
	["Spin"] = "Common",
	["Chop"] = "Common",
	["Spring"] = "Common",
	["Bomb"] = "Common",
	["Smoke"] = "Common",
	["Spike"] = "Common",

	["Flame"] = "Uncommon",
	["Falcon"] = "Uncommon",
	["Ice"] = "Uncommon",
	["Sand"] = "Uncommon",
	["Dark"] = "Uncommon",
	["Diamond"] = "Uncommon",

	["Light"] = "Rare",
	["Rubber"] = "Rare",
	["Barrier"] = "Rare",
	["Ghost"] = "Rare",
	["Magma"] = "Rare",

	["Quake"] = "Legendary",
	["Buddha"] = "Legendary",
	["Love"] = "Legendary",
	["Spider"] = "Legendary",
	["Sound"] = "Legendary",
	["Phoenix"] = "Legendary",
	["Portal"] = "Legendary",
	["Rumble"] = "Legendary",
	["Pain"] = "Legendary",
	["Blizzard"] = "Legendary",

	["Gravity"] = "Mythical",
	["Dough"] = "Mythical",
	["Shadow"] = "Mythical",
	["Venom"] = "Mythical",
	["Control"] = "Mythical",
	["Spirit"] = "Mythical",
	["Dragon"] = "Mythical",
	["Leopard"] = "Mythical",
	["Kitsune"] = "Mythical"

}

local RarityColors = {

	Common = Color3.fromRGB(180,180,180),
	Uncommon = Color3.fromRGB(80,255,80),
	Rare = Color3.fromRGB(80,150,255),
	Legendary = Color3.fromRGB(255,170,0),
	Mythical = Color3.fromRGB(255,70,70)

}

local function createFruitESP(tool)

	if not HUD.alive or not fruitESPEnabled or not tool:IsDescendantOf(workspace) or fruitEspObjects[tool] then return end

	local part = tool:FindFirstChildWhichIsA("BasePart")
	if not part then return end

	local bill = Instance.new("BillboardGui")
	bill.Size = UDim2.new(0,200,0,60)
	bill.AlwaysOnTop = true
	bill.Adornee = part
	bill.Parent = part

	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1,0,1,0)
	txt.BackgroundTransparency = 1
	txt.Font = Enum.Font.GothamBold
	txt.TextScaled = false
	txt.TextSize = 14
	txt.TextStrokeTransparency = 0
	txt.Parent = bill
	txt.TextStrokeTransparency = 0
	txt.TextStrokeColor3 = Color3.new(0,0,0)
	bill.Size = UDim2.new(0,120,0,40)	

	fruitEspObjects[tool] = {
		gui = bill,
		label = txt,
		part = part
	}

end
-- ================= PLAYER =================
criarSecao("PLAYER",0,tabPlayer)

criarBotaoToggle("NOCLIP",30,tabPlayer,function(v)
	noclip = v
end)

criarBotaoToggle("CHÃO INFINITO",70,tabPlayer,function(v)
	floorEnabled = v
	if not v and floor then
		floor:Destroy()
		floor = nil
	end
end)

-- ================= MOVIMENTO =================
criarSecao("MOVIMENTO",120,tabPlayer)

criarSlider("Pulo",60,500,60,150,tabPlayer,function(v)
	HUD.jump = v
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.JumpPower = v end
end)

criarSlider("Velocidade TP",0,10,0,220,tabPlayer,function(v)
	tpSpeed = v
end)

criarSecao("AUTO SAFE", 270, tabPlayer)
criarBotaoToggle("AUTO SAFE", 300, tabPlayer, function(v) autoSafeEnabled = v; if not v then emFuga = false end end)
criarSlider("Limite % Vida", 5, 95, autoSafePercent, 340, tabPlayer, function(v) autoSafePercent = v end)
criarSlider("Altura Safe", 200, 20000, autoSafeHeight, 410, tabPlayer, function(v) autoSafeHeight = v end)
-- ================= ESP =================
criarSecao("ESP",0,tabESP)
criarBotaoToggle("ESP JOGADORES",30,tabESP,function(v)
	ESPAtivo = v
end)

criarBotaoToggle("SÓ INIMIGOS",70,tabESP,function(v)
	espOnlyEnemies = v
end)

criarBotaoToggle("ESP FRUTAS",110,tabESP,function(v)
	fruitESPEnabled = v
    if HUD.setFruitESP then HUD.setFruitESP(v) end
end)

-- ================= SISTEMA =================
criarSecao("SISTEMA",0,tabSistema)

local rejoin = Instance.new("TextButton",tabSistema)
rejoin.Position = UDim2.new(0,10,0,30)
rejoin.Size = UDim2.new(1,-20,0,32)
rejoin.BackgroundColor3 = Theme.Red
rejoin.Text="REJOIN"
rejoin.TextColor3=Color3.new(1,1,1)
rejoin.Font=Enum.Font.GothamMedium
rejoin.TextSize=18
Instance.new("UICorner",rejoin)

rejoin.MouseButton1Click:Connect(function()
	local TeleportService = game:GetService("TeleportService")
	local Players = game:GetService("Players")

	TeleportService:TeleportToPlaceInstance(
		game.PlaceId,
		game.JobId,
		Players.LocalPlayer
	)
end)

-- ================= TIME =================
criarSecao("TIME (BLOX FRUITS)",80,tabSistema)

local function setTeam(team)
	pcall(function()
		CommF:InvokeServer("SetTeam",team)
	end)
end

local marine = Instance.new("TextButton",tabSistema)
marine.Position = UDim2.new(0,10,0,110)
marine.Size = UDim2.new(1,-20,0,32)
marine.BackgroundColor3 = Color3.fromRGB(0,90,160)
marine.Text="ENTRAR MARINE"
marine.TextColor3=Color3.new(1,1,1)
marine.Font=Enum.Font.GothamMedium
marine.TextSize=18
Instance.new("UICorner",marine)
marine.MouseButton1Click:Connect(function()
	setTeam("Marines")
end)

local pirate = Instance.new("TextButton",tabSistema)
pirate.Position = UDim2.new(0,10,0,150)
pirate.Size = UDim2.new(1,-20,0,32)
pirate.BackgroundColor3 = Color3.fromRGB(160,40,40)
pirate.Text="ENTRAR PIRATA"
pirate.TextColor3=Color3.new(1,1,1)
pirate.Font=Enum.Font.GothamMedium
pirate.TextSize=18
Instance.new("UICorner",pirate)
pirate.MouseButton1Click:Connect(function()
	setTeam("Pirates")
end)
-- ================= TELEPORT =================
-- Seleção manual: nenhum mar escolhido ao abrir.
HUD.currentSea = nil
-- Coordenadas: Sea 2 preservado da versão anterior.
-- Sea 1: https://github.com/MUXHUB169/BloxFruits-Auto-farm
-- Sea 3: https://github.com/GooD1020/sazx-hub
HUD.islandsBySea = {
    [1] = {
        {nome="Starter Island", cf=CFrame.new(1071.2832,16.3085976,1426.86792)},
        {nome="Marine Starter", cf=CFrame.new(-2573.3374,6.88881969,2046.99817)},
        {nome="Middle Town", cf=CFrame.new(-655.824158,7.88708115,1436.67908)},
        {nome="Jungle", cf=CFrame.new(-1249.77222,11.8870859,341.356476)},
        {nome="Pirate Village", cf=CFrame.new(-1122.34998,4.78708982,3855.91992)},
        {nome="Desert", cf=CFrame.new(1094.14587,6.47350502,4192.88721)},
        {nome="Frozen Village", cf=CFrame.new(1198.00928,27.0074959,-1211.73376)},
        {nome="Marine Fortress", cf=CFrame.new(-4505.375,20.687294,4260.55908)},
        {nome="Colosseum", cf=CFrame.new(-1428.35474,7.38933945,-3014.37305)},
        {nome="Skylands", cf=CFrame.new(-4970.21875,717.707275,-2622.35449)},
        {nome="Prison", cf=CFrame.new(4854.16455,5.68742752,740.194641)},
        {nome="Magma Village", cf=CFrame.new(-5231.75879,8.61593437,8467.87695)},
        {nome="Fountain City", cf=CFrame.new(5132.7124,4.53632832,4037.8562)},
    },
    [2] = {
        {nome="Café", cf=CFrame.new(-380,80,300)},
        {nome="Mansão", cf=CFrame.new(-390,332,715)},
        {nome="Green Zone", cf=CFrame.new(-2221,80,-2704)},
        {nome="Graveyard", cf=CFrame.new(-5429,55,-745)},
        {nome="Cursed Ship", cf=CFrame.new(-6528,90,-162)},
        {nome="Snow Mountain", cf=CFrame.new(950,440,-5181)},
        {nome="Hot and Cold", cf=CFrame.new(-5701,15,-5003)},
        {nome="Ice Castle", cf=CFrame.new(5589,35,-6354)},
        {nome="Forgotten Island", cf=CFrame.new(-3050,255,-10170)},
    },
    [3] = {
        {nome="Port Town", cf=CFrame.new(-610.309692,57.8323097,6436.33594)},
        {nome="Hydra Island", cf=CFrame.new(5229.99561,603.916565,345.154022)},
        {nome="Great Tree", cf=CFrame.new(2174.94873,28.7312393,-6728.83154)},
        {nome="Castle on the Sea", cf=CFrame.new(-5477.62842,313.794739,-2808.4585)},
        {nome="Floating Turtle", cf=CFrame.new(-10919.2998,331.788452,-8637.57227)},
        {nome="Mansão", cf=CFrame.new(-12553.8125,332.403961,-7621.91748)},
        {nome="Peanut Island", cf=CFrame.new(-2142,48,-10031)},
        {nome="Ice Cream Island", cf=CFrame.new(-949,59,-10907)},
    },
}

criarSecao("TELEPORT / ESCOLHA SEU SEA",190,tabTeleport)
local currentTween = nil
local travelConnection
local travelRoot
local travelHumanoid
local travelStatus = Instance.new("TextLabel", tabTeleport)
travelStatus.Size = UDim2.new(1,0,0,56)
travelStatus.BackgroundTransparency = 1
travelStatus.TextColor3 = Theme.Text
travelStatus.TextSize = 12
travelStatus.Font = Enum.Font.GothamMedium
travelStatus.TextWrapped = true
travelStatus.Text = "Selecione abaixo o Sea em que você está para carregar as ilhas."
local function CancelTeleport(message)
    if travelConnection then travelConnection:Disconnect(); travelConnection = nil end
    local oldTween = currentTween
    currentTween = nil
    HUD.travelActive = false
    travelRoot, travelHumanoid = nil, nil
    if oldTween then oldTween:Cancel() end
    if message then travelStatus.Text = message end
end
local function TweenTeleport(cf)
    if HUD.seaBusy then travelStatus.Text = "Aguarde a troca de Sea."; return end
    if not HUD.currentSea then travelStatus.Text = "Escolha primeiro o Sea em que você está."; return end
    CancelTeleport()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then travelStatus.Text = "Aguarde o personagem renascer."; return end
    if HUD.stopFly then HUD.stopFly() end
    if root.Anchored then travelStatus.Text = "Personagem preso. Aguarde antes de viajar."; return end
    HUD.farmPaused = true
    HUD.travelActive = true
    travelRoot, travelHumanoid = root, hum
    local duration = math.max(0.1, (root.Position - cf.Position).Magnitude / HUD.travelSpeed)
    travelStatus.Text = string.format("Viajando / %.0f s estimados / farm pausado",duration)
    local tween = TweenService:Create(root,TweenInfo.new(duration,Enum.EasingStyle.Linear),{CFrame=cf})
    currentTween = tween
    travelConnection = tween.Completed:Connect(function(state)
        if currentTween ~= tween then return end
        local arrived = state == Enum.PlaybackState.Completed and root.Parent and (root.Position-cf.Position).Magnitude < 12
        CancelTeleport(arrived and "Percurso concluído. Retome o farm quando quiser." or "Percurso interrompido. Confira a posição antes de tentar novamente.")
        HUD.manualHold = os.clock() + 0.5
    end)
    tween:Play()
end
criarSlider("Velocidade da viagem",50,350,250,0,tabTeleport,function(v) HUD.travelSpeed = v end)
HUD.connect(RunService.Heartbeat,function()
    if HUD.travelActive and (not travelRoot or not travelRoot.Parent or not travelHumanoid or travelHumanoid.Health <= 0 or player.Character ~= travelRoot.Parent) then
        CancelTeleport("Viagem cancelada: personagem indisponível.")
    end
end)
HUD.connect(player.CharacterAdded,function()
    CancelTeleport("Personagem renasceu. Escolha o destino novamente.")
    farmTarget = nil
    emFuga = false
    HUD.farmSearchAt = 0
end)

-- ================= SELETOR MANUAL DE SEA =================
do
    local selectedLabel = Instance.new("TextLabel",tabTeleport)
    selectedLabel.Size = UDim2.new(1,0,0,46)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.TextColor3 = Theme.Text
    selectedLabel.Font = Enum.Font.GothamMedium
    selectedLabel.TextSize = 12
    selectedLabel.TextWrapped = true
    selectedLabel.Text = "Em qual Sea você está? Escolha para mostrar as ilhas."
    local selector = Instance.new("Frame",tabTeleport)
    selector.Size = UDim2.new(1,0,0,40)
    selector.BackgroundTransparency = 1
    local buttons = {}
    for sea = 1,3 do
        local button = Instance.new("TextButton",selector)
        button.Size = UDim2.new(1/3,-6,1,0)
        button.Position = UDim2.new((sea-1)/3,0,0,0)
        button.BackgroundColor3 = Theme.Button
        button.TextColor3 = Theme.Text
        button.Text = "SEA "..sea
        button.TextSize = 13
        button.Font = Enum.Font.GothamBold
        roundUI(button,8)
        buttons[sea] = button
    end
    local dropdownBtn = Instance.new("TextButton",tabTeleport)
    dropdownBtn.Size = UDim2.new(1,0,0,38)
    dropdownBtn.BackgroundColor3 = Theme.Button
    dropdownBtn.TextColor3 = Theme.Text
    dropdownBtn.Text = "ESCOLHA UM SEA ACIMA"
    dropdownBtn.TextSize = 13
    dropdownBtn.Font = Enum.Font.GothamBold
    roundUI(dropdownBtn,8)
    local list = Instance.new("Frame",tabTeleport)
    list.Size = UDim2.new(1,0,0,0)
    list.BackgroundTransparency = 1
    list.ClipsDescendants = true
    local open = false
    local entries = {}
    local function renderSize()
        list.Size = UDim2.new(1,0,0,open and #entries*36 or 0)
        dropdownBtn.Text = HUD.currentSea and ("ILHAS DO SEA "..HUD.currentSea..(open and " ▲" or " ▼")) or "ESCOLHA UM SEA ACIMA"
    end
    local function selectSea(sea)
        if not HUD.islandsBySea[sea] then return end
        CancelTeleport("SEA "..sea.." selecionado. Escolha uma ilha.")
        HUD.currentSea = sea
        for _, child in ipairs(list:GetChildren()) do child:Destroy() end
        entries = HUD.islandsBySea[sea]
        for index, island in ipairs(entries) do
            local button = Instance.new("TextButton",list)
            button.Size = UDim2.new(1,0,0,32)
            button.Position = UDim2.fromOffset(0,(index-1)*36)
            button.BackgroundColor3 = Theme.Button
            button.BackgroundTransparency = 0.15
            button.TextColor3 = Theme.Text
            button.Font = Enum.Font.GothamMedium
            button.TextSize = 13
            button.Text = island.nome
            roundUI(button,7)
            button.Activated:Connect(function() TweenTeleport(island.cf) end)
        end
        for index, button in ipairs(buttons) do
            button.BackgroundColor3 = index == sea and Theme.DarkRed or Theme.Button
            button.Text = "SEA "..index..(index == sea and " ✓" or "")
        end
        selectedLabel.Text = "SEA "..sea.." selecionado / "..#entries.." destinos. Esta escolha só altera a lista."
        open = true
        renderSize()
    end
    for sea, button in ipairs(buttons) do
        button.Activated:Connect(function() selectSea(sea) end)
    end
    dropdownBtn.Activated:Connect(function()
        if not HUD.currentSea then return end
        open = not open
        renderSize()
    end)
end

-- ================= BOTÃO CANCELAR =================
local cancelBtn = Instance.new("TextButton", tabTeleport)
cancelBtn.Position = UDim2.new(0,10,0,302)
cancelBtn.Size = UDim2.new(1,-20,0,32)
cancelBtn.BackgroundColor3 = Color3.fromRGB(140,40,40)
cancelBtn.Text = "CANCELAR TP"
cancelBtn.TextColor3 = Color3.new(1,1,1)
cancelBtn.Font = Enum.Font.GothamMedium
cancelBtn.TextSize = 16
Instance.new("UICorner", cancelBtn)

cancelBtn.MouseButton1Click:Connect(function()
	CancelTeleport("Viagem cancelada.")
end)
do
    criarSecao("VIAJAR ENTRE SEAS",0,tabTeleport)
    local note = Instance.new("TextLabel",tabTeleport)
    note.Size = UDim2.new(1,0,0,62)
    note.BackgroundTransparency = 1
    note.TextColor3 = Theme.Text
    note.Font = Enum.Font.GothamMedium
    note.TextSize = 12
    note.TextWrapped = true
    note.Text = "O servidor verifica seu acesso ao destino. A viagem não desbloqueia mares."
    local destinations = {
        {name="SEA 1", id=2753915549, command="TravelMain"},
        {name="SEA 2", id=4442272183, command="TravelDressrosa"},
        {name="SEA 3", id=7449423635, command="TravelZou"}
    }
    for _, destination in ipairs(destinations) do
        local button = Instance.new("TextButton",tabTeleport)
        button.Size = UDim2.new(1,0,0,40)
        button.BackgroundColor3 = Theme.DarkRed
        button.BackgroundTransparency = 0.15
        button.TextColor3 = Theme.Text
        button.Font = Enum.Font.GothamMedium
        button.TextSize = 13
        button.Text = destination.name .. (game.PlaceId == destination.id and " / ATUAL" or " / VIAJAR")
        roundUI(button,8)
        button.Activated:Connect(function()
            if game.PlaceId == destination.id then note.Text = "Você já está no "..destination.name.."."; return end
            if HUD.seaBusy then return end
            CancelTeleport("Solicitando troca de Sea…")
            if HUD.stopFly then HUD.stopFly() end
            HUD.farmPaused, HUD.seaBusy = true, true
            HUD.seaToken += 1
            local token = HUD.seaToken
            note.Text = "Solicitando "..destination.name.." ao servidor…"
            task.delay(15,function()
                if HUD.alive and token == HUD.seaToken and HUD.seaBusy then
                    HUD.seaBusy = false
                    HUD.seaToken += 1
                    note.Text = "Viagem não confirmada. Verifique o acesso ao Sea e tente pelo NPC de viagem."
                end
            end)
            task.spawn(function()
                local ok = pcall(function() CommF:InvokeServer(destination.command) end)
                if not HUD.alive or token ~= HUD.seaToken then return end
                if not ok then
                    HUD.seaBusy = false
                    HUD.seaToken += 1
                    note.Text = "Não foi possível solicitar a viagem. Tente novamente depois."
                end
            end)
        end)
    end
    HUD.connect(TeleportService.TeleportInitFailed,function(who)
        if who == player and HUD.seaBusy then
            HUD.seaBusy = false
            HUD.seaToken += 1
            note.Text = "O servidor não iniciou a viagem. Confira seu acesso e tente novamente."
        end
    end)
end

-- ================= AIMBOT (DEPOIS DO TELEPORT) =================
criarSecao("AIMBOT",0,tabAimbot)

local AIM_MAX_DISTANCE = 500
local AIM_MIN_FOV = 50
local AIM_MAX_FOV = 500
local AIM_FOV_RADIUS = 200

local aimbotEnabled = false
local aimMode = "ALL"       -- ALL | ENEMIES
local aimPartMode = "BOTH" -- HEAD | TORSO | BOTH

local lockedPart, lockedHumanoid

local function getTorso(char)
	return char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
end

local function sameTeam(plr)
	if player.Team and plr.Team then
		return player.Team == plr.Team
	end
	if player.TeamColor and plr.TeamColor then
		return player.TeamColor == plr.TeamColor
	end
	return false
end

local function isEnemyAim(plr)
	return aimMode == "ALL" or not sameTeam(plr)
end

local function hasLineOfSight(char, part)
	local origin = Camera.CFrame.Position
	local direction = (part.Position - origin)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {player.Character}
	params.IgnoreWater = true

	local result = workspace:Raycast(origin, direction, params)

	if result then
		return result.Instance:IsDescendantOf(char)
	end

	return false
end

local function getTarget()
	local bestPart, bestHum
	local bestDist = math.huge

	local camPos = Camera.CFrame.Position
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and isEnemyAim(plr) then
			local hum = plr.Character:FindFirstChild("Humanoid")
			if hum and hum.Health > 0 then
				local head = plr.Character:FindFirstChild("Head")
				local torso = getTorso(plr.Character)

				local parts = {}
				if aimPartMode == "HEAD" and head then
					parts = { head }
				elseif aimPartMode == "TORSO" and torso then
					parts = { torso }
				else
					if head then table.insert(parts, head) end
					if torso then table.insert(parts, torso) end
				end

				for _, part in ipairs(parts) do
					local dist = (part.Position - camPos).Magnitude
					if dist <= AIM_MAX_DISTANCE and dist < bestDist then
						local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
						if onScreen 
	                     and (Vector2.new(sp.X, sp.Y) - center).Magnitude <= AIM_FOV_RADIUS
	                     and hasLineOfSight(plr.Character, part) 
                    then
							bestDist = dist
							bestPart = part
							bestHum = hum
						end
					end
				end
			end
		end
	end

	lockedHumanoid = bestHum
	return bestPart
end

HUD.connect(RunService.RenderStepped, function()
	if not aimbotEnabled then return end

	if not lockedPart then
		lockedPart = getTarget()
	end

	if lockedPart and lockedHumanoid and lockedHumanoid.Health > 0 then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedPart.Position)
	else
		lockedPart, lockedHumanoid = nil, nil
	end
end)

-- Botões no menu
-- ================= TOGGLE AIMBOT NA TECLA F =================
HUD.connect(UserInputService.InputBegan, function(i, gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.F then
		aimbotEnabled = not aimbotEnabled
		lockedPart, lockedHumanoid = nil, nil
	end
end)

criarBotaoToggle("SÓ INIMIGOS",40,tabAimbot,function(v)
	aimMode = v and "ENEMIES" or "ALL"
	lockedPart = nil
end)

criarBotaoToggle("MIRA: CABEÇA",80,tabAimbot,function(v)
	if v then
		aimPartMode = "HEAD"
	else
		aimPartMode = "BOTH"
	end
	lockedPart = nil
end)

criarSlider("FOV AIM",AIM_MIN_FOV,AIM_MAX_FOV,AIM_FOV_RADIUS,120,tabAimbot,function(v)
	AIM_FOV_RADIUS = v
end)
-- Círculo FOV nativo: não depende da biblioteca Drawing.
local fovCircle = Instance.new("Frame", gui)
fovCircle.Name = "AimFOV"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
roundUI(fovCircle, 9999)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Thickness = 1.5
fovStroke.Color = Theme.Red
HUD.connect(RunService.RenderStepped, function()
    if not aimbotEnabled then fovCircle.Visible = false; return end
    local currentCamera = workspace.CurrentCamera
    if not currentCamera then return end
    local inset = game:GetService("GuiService"):GetGuiInset()
    fovCircle.Visible = aimbotEnabled
    fovCircle.Size = UDim2.fromOffset(AIM_FOV_RADIUS * 2, AIM_FOV_RADIUS * 2)
    fovCircle.Position = UDim2.fromOffset(currentCamera.ViewportSize.X / 2 - inset.X, currentCamera.ViewportSize.Y / 2 - inset.Y)
end)
-- ================= LOOP =================
HUD.connect(RunService.RenderStepped, function(dt)
    if not (autoSafeEnabled or autoFarmEnabled or tpSpeed > 0 or noclip or floorEnabled or next(HUD.collisions) or HUD.hitboxPart) then return end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then HUD.restoreHitbox(); return end

    if autoSafeEnabled then
        if hum and hum.Health > 0 then
            -- CALCULA O LIMITE BASEADO NA SUA VIDA MÁXIMA
            local limite = hum.MaxHealth * (autoSafePercent / 100)

            if hum.Health > limite and emFuga == true then
                emFuga = false
            end
            if hum.Health <= limite and emFuga == false then
                emFuga = true
                CancelTeleport("Viagem interrompida pelo Auto Safe.")
                if HUD.stopFly then HUD.stopFly() end
                if root then
                    root.CFrame = root.CFrame + Vector3.new(0, autoSafeHeight, 0)
                end
            end
        else
            emFuga = false
        end
    end
-- ================= AUTO FARM =================
local now = os.clock()
local farmCanMove = autoFarmEnabled and not HUD.farmPaused and not HUD.travelActive and not HUD.seaBusy and not HUD.flying and not emFuga and now >= HUD.manualHold
if farmCanMove then
    local enemies = workspace:FindFirstChild("Enemies")
    local function validTarget(npc)
        if not npc or not enemies or npc.Parent ~= enemies then return false end
        local targetHum = npc:FindFirstChildOfClass("Humanoid")
        local targetRoot = npc:FindFirstChild("HumanoidRootPart")
        return targetHum and targetRoot and targetHum.Health > 0
            and (targetRoot.Position-root.Position).Magnitude <= HUD.farmRadius
            and (HUD.farmFilter == "" or string.find(string.lower(npc.Name),HUD.farmFilter,1,true) ~= nil)
    end
    if not validTarget(farmTarget) then
        farmTarget = nil
        if enemies and now >= HUD.farmSearchAt then
            HUD.farmSearchAt = now + 0.4
            local nearest = HUD.farmRadius
            for _, npc in ipairs(enemies:GetChildren()) do
                if validTarget(npc) then
                    local distance = (npc.HumanoidRootPart.Position-root.Position).Magnitude
                    if distance <= nearest then nearest, farmTarget = distance, npc end
                end
            end
        end
    end
    if farmTarget then
        local targetRoot = farmTarget.HumanoidRootPart
        local offset = Vector3.new(0,farmHeight,farmDistance)
        if not HUD.manualFarmHeight then
            local size = targetRoot == HUD.hitboxPart and HUD.hitboxOriginal.size or targetRoot.Size
            local limit = math.max(1,math.min(size.X,size.Y,size.Z)*0.5 + HUD.attackReach*0.8)
            if offset.Magnitude > limit then offset = offset.Unit * limit end
        end
        root.CFrame = CFrame.new(targetRoot.Position + offset,targetRoot.Position)
        HUD.applyHitbox(farmTarget)
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool and HUD.autoEquip and now >= (HUD.equipAt or 0) then
            HUD.equipAt = now + 1
            local backpack = player:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, candidate in ipairs(backpack:GetChildren()) do
                    if candidate:IsA("Tool") and (candidate.ToolTip == "Melee" or candidate.ToolTip == "Sword") then
                        hum:EquipTool(candidate)
                        tool = candidate
                        break
                    end
                end
            end
        end
        HUD.farmStatus.Text = HUD.tryAttack(farmTarget,tool,root,now,fastAttackEnabled)
    else
        HUD.restoreHitbox()
        HUD.farmStatus.Text = "Procurando NPC vivo no raio e filtro escolhidos…"
    end
elseif not autoFarmEnabled then
    if not HUD.autoNear then HUD.restoreHitbox() end
    if not HUD.autoNear then HUD.farmStatus.Text = "Auto farm desligado." end
elseif HUD.farmPaused then
    HUD.restoreHitbox()
    HUD.farmStatus.Text = "Farm pausado pela viagem. Use Retomar farm."
else
    HUD.restoreHitbox()
    HUD.farmStatus.Text = "Farm aguardando movimento manual, voo ou Auto Safe."
end

    if tpSpeed > 0 and hum.MoveDirection.Magnitude > 0 and not HUD.travelActive and not HUD.seaBusy and not HUD.flying and not farmCanMove and not emFuga and now >= HUD.manualHold then
        root.CFrame += hum.MoveDirection * tpSpeed * math.min(dt, 0.05) * 60
    end


	if noclip then
		for _,v in ipairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				if HUD.collisions[v] == nil then HUD.collisions[v] = v.CanCollide end
                v.CanCollide = false
			end
		end
	end

	if not noclip then
        for part, collision in pairs(HUD.collisions) do
            if part.Parent then part.CanCollide = collision end
            HUD.collisions[part] = nil
        end
    end
    if floorEnabled then
		if not floor then
			floor = Instance.new("Part",Workspace)
			floor.Anchored = true
			floor.CanCollide = true
			floor.Size = Vector3.new(500,1,500)
			floor.Transparency = 0.2
		end
		floor.Position = Vector3.new(root.Position.X,-4,root.Position.Z)
	end
end)

-- ================= ESP SOB DEMANDA =================
do
    local scanToken = 0
    local function clearFruitESP()
        for tool, entry in pairs(fruitEspObjects) do
            entry.gui:Destroy()
            fruitEspObjects[tool] = nil
        end
    end
    HUD.setFruitESP = function(enabled)
        scanToken += 1
        local token = scanToken
        if not enabled then clearFruitESP(); return end
        -- Uma busca cancelável por ativação, distribuída entre quadros.
        task.spawn(function()
            local pending = {workspace}
            local processed = 0
            while #pending > 0 and HUD.alive and fruitESPEnabled and token == scanToken do
                local item = table.remove(pending)
                if item == workspace or item:IsDescendantOf(workspace) then
                    if item:IsA("Tool") and item.Name:find("Fruit") then createFruitESP(item) end
                    for _, child in ipairs(item:GetChildren()) do
                        table.insert(pending,child)
                    end
                end
                processed += 1
                if processed >= 50 then processed = 0; task.wait() end
            end
        end)
    end
    HUD.connect(workspace.DescendantAdded,function(item)
        if not fruitESPEnabled then return end
        local tool = item:IsA("Tool") and item or (item:IsA("BasePart") and item.Parent)
        if tool and tool:IsA("Tool") and tool.Name:find("Fruit") then createFruitESP(tool) end
    end)
    local elapsed = 0
    HUD.connect(RunService.Heartbeat,function(dt)
        if not fruitESPEnabled and not ESPAtivo and next(espObjects) == nil then return end
        elapsed += dt
        if elapsed < 0.2 then return end
        elapsed = 0
        local character = player.Character
        local ownRoot = character and character:FindFirstChild("HumanoidRootPart")
        if fruitESPEnabled then
            for tool, entry in pairs(fruitEspObjects) do
                if not tool:IsDescendantOf(workspace) or not entry.part:IsDescendantOf(workspace) then
                    entry.gui:Destroy()
                    fruitEspObjects[tool] = nil
                else
                    entry.gui.Enabled = ownRoot ~= nil
                    if ownRoot then
                        local name = tool.Name:gsub(" Fruit","")
                        local rarity = FruitRarity[name] or "Common"
                        entry.label.TextColor3 = RarityColors[rarity]
                        entry.label.Text = name.."\n"..math.floor((ownRoot.Position-entry.part.Position).Magnitude).." studs / "..rarity
                    end
                end
            end
        end
        for plr, bill in pairs(espObjects) do
            local char = plr.Character
            if not ESPAtivo or not plr.Parent or not char or not bill.Parent or bill.Parent ~= char:FindFirstChild("Head") then
                bill:Destroy()
                espObjects[plr] = nil
            end
        end
        if not ESPAtivo then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local char = plr.Character
                local head = char and char:FindFirstChild("Head")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local sameTeam = player.Team ~= nil and plr.Team == player.Team
                local visible = ownRoot and head and root and hum and hum.Health > 0 and (not espOnlyEnemies or not sameTeam)
                local bill = espObjects[plr]
                if visible then
                    if not bill then
                        bill = Instance.new("BillboardGui")
                        bill.Size = UDim2.fromOffset(200,80)
                        bill.AlwaysOnTop = true
                        bill.Adornee = head
                        bill.Parent = head
                        local text = Instance.new("TextLabel",bill)
                        text.Name = "Info"
                        text.Size = UDim2.fromScale(1,1)
                        text.BackgroundTransparency = 1
                        text.TextStrokeTransparency = 0
                        text.Font = Enum.Font.GothamMedium
                        text.TextSize = 14
                        espObjects[plr] = bill
                    end
                    local data = plr:FindFirstChild("Data")
                    local level = data and data:FindFirstChild("Level")
                    bill.Info.TextColor3 = sameTeam and Color3.fromRGB(0,170,255) or Theme.Red
                    bill.Info.Text = plr.Name.."\nHP: "..math.floor(hum.Health).." / LVL: "..(level and tostring(level.Value) or "?").."\n"..math.floor((ownRoot.Position-root.Position).Magnitude).." studs"
                end
                if bill then bill.Enabled = not not visible end
            end
        end
    end)
    if fruitESPEnabled then HUD.setFruitESP(true) end
end

-- ================= TOGGLE MENU ANIMADO NO G & BOTÃO MOBILE =================

local menuOpen = true
local busy = false

-- OPEN_SIZE definido antes da animação
local CLOSED_SIZE = UDim2.new(0,0,0,0)

-- OPEN_TRANSP definido antes da animação
local CLOSED_TRANSP = 1

-- estado inicial (já abre com animação)
frame.Visible = true
frame.Size = CLOSED_SIZE
frame.BackgroundTransparency = 1

local tweenOpen = TweenService:Create(
	frame,
	TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	{Size = OPEN_SIZE, BackgroundTransparency = OPEN_TRANSP}
)

local tweenClose = TweenService:Create(
	frame,
	TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	{Size = CLOSED_SIZE, BackgroundTransparency = CLOSED_TRANSP}
)

-- animação inicial
tweenOpen:Play()

-- TECLADO (Botão G)
HUD.connect(UserInputService.InputBegan, function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.G then
		if busy then return end
		busy = true

		if menuOpen then
			tweenClose:Play()
			tweenClose.Completed:Wait()
			frame.Visible = false
			menuOpen = false
		else
			frame.Visible = true
			tweenOpen:Play()
			menuOpen = true
		end

		task.wait(0.05)
		busy = false
	end
end)

-- Botão mobile removido. Abrir/recolher pela tecla G.
-- Iluminação original preservada. Sem destruição de Atmosphere ou ativação de sombras na abertura.
-- ================= ZOOM =================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= FLY TELEPORT =================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local flying = false
HUD.flying = false
HUD.stopFly = function()
    local wasFlying = flying
    flying, HUD.flying = false, false
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if wasFlying and root then root.Anchored = false end
end
local speed = 3

local keys = {
	W=false, A=false, S=false, D=false,
	Space=false, Ctrl=false
}

local function getFlyRoot()
	return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

-- ================= INPUT =================
HUD.connect(UserInputService.InputBegan, function(i, gp)
	if gp then return end

	-- ALT pressionado
	if i.KeyCode == Enum.KeyCode.LeftAlt or i.KeyCode == Enum.KeyCode.RightAlt then
		altPressed = true
	end

	-- ALT + CLICK ESQUERDO
	if altPressed and i.UserInputType == Enum.UserInputType.MouseButton1 and not HUD.seaBusy then
		CancelTeleport("Viagem cancelada pelo comando de voo.")
        flying = not flying
        HUD.flying = flying
		local root = getFlyRoot()
		if root then
			root.Anchored = flying
		end
	end

	if i.KeyCode == Enum.KeyCode.W then keys.W = true end
	if i.KeyCode == Enum.KeyCode.A then keys.A = true end
	if i.KeyCode == Enum.KeyCode.S then keys.S = true end
	if i.KeyCode == Enum.KeyCode.D then keys.D = true end
	if i.KeyCode == Enum.KeyCode.Space then keys.Space = true end
	if i.KeyCode == Enum.KeyCode.LeftControl then keys.Ctrl = true end
end)

HUD.connect(UserInputService.InputEnded, function(i)
	if i.KeyCode == Enum.KeyCode.LeftAlt or i.KeyCode == Enum.KeyCode.RightAlt then
		altPressed = false
	end

	if i.KeyCode == Enum.KeyCode.W then keys.W = false end
	if i.KeyCode == Enum.KeyCode.A then keys.A = false end
	if i.KeyCode == Enum.KeyCode.S then keys.S = false end
	if i.KeyCode == Enum.KeyCode.D then keys.D = false end
	if i.KeyCode == Enum.KeyCode.Space then keys.Space = false end
	if i.KeyCode == Enum.KeyCode.LeftControl then keys.Ctrl = false end
end)


-- ================= LOOP DO FLY =================
HUD.connect(RunService.RenderStepped, function()
	if not flying or HUD.travelActive or HUD.seaBusy then return end

	local root = getFlyRoot()
	if not root then return end

	local cam = workspace.CurrentCamera
	local move = Vector3.zero

	if keys.W then move += cam.CFrame.LookVector end
	if keys.S then move -= cam.CFrame.LookVector end
	if keys.A then move -= cam.CFrame.RightVector end
	if keys.D then move += cam.CFrame.RightVector end
	if keys.Space then move += Vector3.new(0,1,0) end
	if keys.Ctrl then move -= Vector3.new(0,1,0) end

	if move.Magnitude > 0 then
		local dir = move.Unit

		local newPos = root.Position + (dir * speed)

		root.CFrame = CFrame.new(
			newPos,
			newPos + cam.CFrame.LookVector
		)
	else

		root.CFrame = CFrame.new(
			root.Position,
			root.Position + cam.CFrame.LookVector
		)
	end
end)

HUD.connect(player.CharacterAdded, function(char)
	task.wait(1)
	local root = char:FindFirstChild("HumanoidRootPart")
	if root then
		root.Anchored = false
	end
	flying = false
    HUD.flying = false
end)
-- ================= TELEPORTE TECLA B =================
local emCooldownTP = false
local ALTURA_TELEPORT = 3.5

HUD.connect(UserInputService.InputBegan, function(input, gp)
    -- Se estiver digitando no chat ou interagindo com a UI, não teleporta
    if gp then return end

    -- Verifica se a tecla pressionada é o B
    if input.KeyCode == Enum.KeyCode.B then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        -- Só teleporta se estiver vivo e não estiver em cooldown
        if root and hum and hum.Health > 0 and not emCooldownTP then
            local mousePos = player:GetMouse().Hit
            
            if mousePos then
                emCooldownTP = true
                CancelTeleport("Viagem cancelada pelo teleporte no cursor.")
                HUD.manualHold = os.clock() + 1
                if autoFarmEnabled then HUD.farmPaused = true end
                
                -- Executa o teleporte para a posição do cursor
                -- Mantém a rotação original do corpo para não bugar a visão
                root.CFrame = CFrame.new(mousePos.Position + Vector3.new(0, ALTURA_TELEPORT, 0)) * root.CFrame.Rotation
                
                -- Cooldown ultra rápido de 10ms (0.01 segundos)
                task.delay(0.01, function()
                    emCooldownTP = false
                end)
            end
        end
    end
end)
-- ================= PAINEL / BUSCA / PREFERÊNCIAS V010 =================
do
    local function textCard(parent, text, height)
        local card = Instance.new("TextLabel", parent)
        card.Size = UDim2.new(1, 0, 0, height or 68)
        card.BackgroundColor3 = Theme.Second
        card.BackgroundTransparency = 0.2
        card.BorderSizePixel = 0
        card.Text = text
        card.TextColor3 = Theme.Text
        card.TextSize = 13
        card.Font = Enum.Font.GothamMedium
        card.TextWrapped = true
        card.TextXAlignment = Enum.TextXAlignment.Left
        roundUI(card, 10)
        local pad = Instance.new("UIPadding", card)
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        return card
    end
    local function action(parent, text, callback)
        local button = Instance.new("TextButton", parent)
        button.Size = UDim2.new(1, 0, 0, 42)
        button.BackgroundColor3 = Theme.Button
        button.BorderSizePixel = 0
        button.TextColor3 = Theme.Text
        button.Font = Enum.Font.GothamMedium
        button.TextSize = 13
        button.Text = text
        roundUI(button, 8)
        button.Activated:Connect(callback)
        return button
    end

    criarSecao("SEU PERSONAGEM", 0, tabOverview)
    local profile = textCard(tabOverview, "Carregando personagem…", 74)
    local health = textCard(tabOverview, "Vida: aguardando personagem", 62)
    local track = Instance.new("Frame", health)
    track.Position = UDim2.new(0, 0, 1, -10)
    track.Size = UDim2.new(1, 0, 0, 4)
    track.BackgroundColor3 = Theme.Button
    roundUI(track, 2)
    local healthFill = Instance.new("Frame", track)
    healthFill.Size = UDim2.fromScale(1, 1)
    healthFill.BackgroundColor3 = Color3.fromRGB(86, 205, 159)
    healthFill.BorderSizePixel = 0
    roundUI(healthFill, 2)
    local resources = textCard(tabOverview, "Beli: —   |   Fragmentos: —", 62)
    criarSecao("ATALHOS", 0, tabOverview)
    textCard(tabOverview, "G  ·  Abrir / recolher menu\nF  ·  Alternar mira\nB  ·  Teleporte no cursor\nAlt + clique  ·  Alternar voo", 110)
    textCard(tabOverview, "Movimento: clique ou arraste as barras. Você também pode digitar um valor. O pulo começa em 60.", 78)
    action(tabOverview, "Centralizar janela", function() frame.Position = UDim2.fromScale(0.5, 0.5) end)

    local footer = Instance.new("TextLabel", frame)
    footer.Position = UDim2.new(0, 18, 1, -34)
    footer.Size = UDim2.new(1, -36, 0, 22)
    footer.BackgroundTransparency = 1
    footer.TextXAlignment = Enum.TextXAlignment.Left
    footer.TextSize = 11
    footer.Font = Enum.Font.GothamMedium
    footer.TextColor3 = Color3.fromRGB(156, 161, 177)
    footer.Text = "PUDIM HUB  /  V010"
    local sessionStart = os.clock()
    local elapsed, frames = 0, 0
    HUD.connect(RunService.Heartbeat, function(dt)
        elapsed += dt
        frames += 1
        if elapsed < 0.5 then return end
        local fps = math.floor(frames / elapsed + 0.5)
        elapsed, frames = 0, 0
        footer.Visible = HUD.status
        local data = player:FindFirstChild("Data")
        local function stat(name)
            local entry = data and data:FindFirstChild(name)
            return entry and tostring(entry.Value) or "—"
        end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local team = player.Team and player.Team.Name or "Sem time"
        profile.Text = player.DisplayName .. "  (@" .. player.Name .. ")\nNível " .. stat("Level") .. "  /  " .. team
        resources.Text = "Beli: " .. stat("Beli") .. "\nFragmentos: " .. stat("Fragments")
        local ratio = humanoid and math.clamp(humanoid.Health / math.max(1, humanoid.MaxHealth), 0, 1) or 0
        health.Text = humanoid and ("Vida  " .. math.floor(humanoid.Health) .. " / " .. math.floor(humanoid.MaxHealth)) or "Aguardando respawn…"
        healthFill.Size = UDim2.fromScale(ratio, 1)
        healthFill.BackgroundColor3 = ratio < 0.3 and Theme.Red or Color3.fromRGB(86,205,159)
        local seconds = math.floor(os.clock() - sessionStart)
        footer.Text = string.format("%d FPS  /  %d jogadores  /  %02d:%02d nesta sessão  /  G: menu", fps, #Players:GetPlayers(), math.floor(seconds / 60), seconds % 60)
    end)

    -- Busca somente na aba atual, sem modificar os valores dos controles.
    local search = Instance.new("TextBox", frame)
    search.Position = UDim2.fromOffset(154, 76)
    search.Size = UDim2.new(1, -166, 0, 34)
    search.BackgroundColor3 = Theme.Second
    search.BorderSizePixel = 0
    search.PlaceholderText = "Buscar nesta aba…"
    search.PlaceholderColor3 = Color3.fromRGB(143,149,169)
    search.Text = ""
    search.TextSize = 13
    search.TextColor3 = Theme.Text
    search.Font = Enum.Font.GothamMedium
    search.ClearTextOnFocus = false
    search.TextXAlignment = Enum.TextXAlignment.Left
    roundUI(search, 8)
    local searchPadding = Instance.new("UIPadding", search)
    searchPadding.PaddingLeft = UDim.new(0, 12)
    local empty = Instance.new("TextLabel", container)
    empty.Size = UDim2.new(1, 0, 0, 56)
    empty.BackgroundTransparency = 1
    empty.Text = "Nenhuma opção encontrada nesta aba."
    empty.TextColor3 = Theme.Text
    empty.Font = Enum.Font.GothamMedium
    empty.TextSize = 12
    empty.Visible = false
    local function normalize(text)
        text = string.lower(text)
        for from, to in pairs({["á"]="a", ["à"]="a", ["ã"]="a", ["â"]="a", ["é"]="e", ["ê"]="e", ["í"]="i", ["ó"]="o", ["ô"]="o", ["õ"]="o", ["ú"]="u", ["ç"]="c", ["Á"]="a", ["Ã"]="a", ["Â"]="a", ["É"]="e", ["Ê"]="e", ["Í"]="i", ["Ó"]="o", ["Ô"]="o", ["Õ"]="o", ["Ú"]="u", ["Ç"]="c"}) do
            text = text:gsub(from, to)
        end
        return text
    end
    local function filter()
        local query = normalize(search.Text):match("^%s*(.-)%s*$")
        local count = 0
        for _, page in ipairs(tabs) do
            for _, row in ipairs(page:GetChildren()) do
                if row:IsA("GuiObject") then
                    local labels = {}
                    if row:IsA("TextLabel") or row:IsA("TextButton") then table.insert(labels, row.Text) end
                    for _, part in ipairs(row:GetDescendants()) do
                        if part:IsA("TextLabel") or part:IsA("TextButton") then table.insert(labels, part.Text) end
                    end
                    local visible = query == "" or string.find(normalize(table.concat(labels, " ")), query, 1, true) ~= nil
                    row.Visible = visible
                    if page == currentTab and visible then count += 1 end
                end
            end
        end
        empty.Visible = count == 0 and query ~= ""
    end
    search:GetPropertyChangedSignal("Text"):Connect(function()
        filter()
        if currentTab then currentTab.CanvasPosition = Vector2.zero end
    end)
    for _, page in ipairs(tabs) do
        page:GetPropertyChangedSignal("Visible"):Connect(function()
            if page.Visible then
                search.Text = ""
                task.defer(filter)
            end
        end)
    end

    criarSecao("INTERFACE", 0, tabSettings)
    criarSlider("Escala do HUD %", 65, 115, 100, 0, tabSettings, function(value)
        HUD.scale = value
        fitHUD()
    end)
    action(tabSettings, "Mostrar / ocultar informações de sessão", function()
        HUD.status = not HUD.status
        footer.Visible = HUD.status
    end)
    action(tabSettings, "Centralizar janela", function() frame.Position = UDim2.fromScale(0.5, 0.5) end)
    criarSecao("PREFERÊNCIAS", 0, tabSettings)
    local feedback = textCard(tabSettings, "Salve os valores dos sliders e a escala. Os botões de funções não são ativados ao carregar.", 88)
    local settingsFile = "PudimHub_UI_v005.json"
    action(tabSettings, "Salvar preferências", function()
        if type(writefile) ~= "function" then feedback.Text = "Este ambiente não oferece salvamento em arquivo."; return end
        local values = {}
        for key, control in pairs(HUD.sliders) do values[key] = control.get() end
        local ok = pcall(function()
            writefile(settingsFile, HttpService:JSONEncode({version = 1, values = values, status = HUD.status}))
        end)
        feedback.Text = ok and "Preferências salvas. Use Carregar para aplicá-las." or "Não foi possível salvar as preferências."
    end)
    action(tabSettings, "Carregar preferências", function()
        if type(readfile) ~= "function" then feedback.Text = "Este ambiente não oferece leitura de arquivo."; return end
        local ok, saved = pcall(function() return HttpService:JSONDecode(readfile(settingsFile)) end)
        if not ok or type(saved) ~= "table" or saved.version ~= 1 or type(saved.values) ~= "table" then
            feedback.Text = "Nenhuma preferência válida encontrada. Salve primeiro."
            return
        end
        for key, value in pairs(saved.values) do
            local control = HUD.sliders[key]
            if control and type(value) == "number" and value == value and math.abs(value) < math.huge then control.set(value) end
        end
        if type(saved.status) == "boolean" then HUD.status = saved.status end
        feedback.Text = "Preferências carregadas."
    end)
    action(tabSettings, "Restaurar valores padrão dos sliders", function()
        for _, control in pairs(HUD.sliders) do control.set(control.default) end
        feedback.Text = "Valores padrão restaurados. Pulo: 60."
    end)
    HUD.connect(player.CharacterAdded, function(character)
        local humanoid = character:WaitForChild("Humanoid", 10)
        if humanoid and HUD.alive then humanoid.JumpPower = HUD.jump end
    end)
    gui.Destroying:Connect(function()
        HUD.alive = false
        for _, connection in ipairs(HUD.connections) do connection:Disconnect() end
    end)
    -- Botão discreto para recolher, além do G.
    local minimize = Instance.new("TextButton", title)
    minimize.Size = UDim2.fromOffset(30, 30)
    minimize.Position = UDim2.new(1, -38, 0, 17)
    minimize.BackgroundColor3 = Theme.Button
    minimize.Text = "−"
    minimize.TextColor3 = Theme.Text
    minimize.TextSize = 20
    roundUI(minimize, 8)
    subtitle.Position = UDim2.new(1, -192, 0, 20)
    minimize.Activated:Connect(function()
        if busy then return end
        busy = true
        tweenClose:Play()
        tweenClose.Completed:Wait()
        frame.Visible, menuOpen = false, false
        busy = false
    end)
end
-- Remove os objetos criados por esta execução ao substituir a interface.
gui.Destroying:Connect(function()
    HUD.restoreHitbox()
    local wasFlying = flying
    autoFarmEnabled, fastAttackEnabled, flying = false, false, false
    CancelTeleport()
    if floor then floor:Destroy() end
    for _, bill in pairs(espObjects) do bill:Destroy() end
    for _, entry in pairs(fruitEspObjects) do entry.gui:Destroy() end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root and wasFlying then root.Anchored = false end
    for part, collision in pairs(HUD.collisions) do
        if part.Parent then part.CanCollide = collision end
    end
end)
do
    local accent = Instance.new("Frame",frame)
    accent.Position = UDim2.fromOffset(18,62)
    accent.Size = UDim2.new(1,-36,0,1)
    accent.BorderSizePixel = 0
    accent.BackgroundColor3 = Theme.Red
    local gradient = Instance.new("UIGradient",accent)
    gradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.85),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,0.85)})
    for _, page in ipairs(tabs) do
        for _, row in ipairs(page:GetChildren()) do
            if (row:IsA("Frame") or row:IsA("TextButton") or row:IsA("TextBox")) and row.BackgroundTransparency < 1 then
                local edge = Instance.new("UIStroke",row)
                edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                edge.Color = Theme.Red
                edge.Thickness = 1
                edge.Transparency = 0.8
            end
        end
    end
end

-- Ataque próximo sem mover o personagem. Compartilha o relógio do farm.
do
    local elapsed = 0
    HUD.connect(RunService.Heartbeat,function(dt)
        elapsed += dt
        if elapsed < 0.05 then return end
        elapsed = 0
        if autoFarmEnabled or not HUD.autoNear then return end
        if HUD.travelActive or HUD.seaBusy or HUD.flying or emFuga or os.clock() < HUD.manualHold then
            HUD.restoreHitbox()
            return
        end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local tool = character and character:FindFirstChildOfClass("Tool")
        local enemies = workspace:FindFirstChild("Enemies")
        if not root or not humanoid or humanoid.Health <= 0 or not enemies or not HUD.isCombatTool(tool) then HUD.restoreHitbox(); return end
        local target, closest = nil, HUD.attackReach
        for _, npc in ipairs(enemies:GetChildren()) do
            local targetHum = npc:FindFirstChildOfClass("Humanoid")
            local targetRoot = npc:FindFirstChild("HumanoidRootPart")
            if targetHum and targetRoot and targetHum.Health > 0 and (targetRoot.Position-root.Position).Magnitude < 100
                and (HUD.farmFilter == "" or string.find(string.lower(npc.Name),HUD.farmFilter,1,true)) then
                local distance = HUD.bodyDistance(npc,root.Position)
                if distance <= closest then target, closest = npc, distance end
            end
        end
        HUD.applyHitbox(target)
        if target then HUD.farmStatus.Text = HUD.tryAttack(target,tool,root,os.clock(),true)
        else HUD.farmStatus.Text = "Ataque por proximidade: aguardando NPC em alcance." end
    end)
end
