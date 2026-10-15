-- PudimHub | Build a Boat | Base de interface
-- No Roblox Studio: use um LocalScript em StarterPlayer > StarterPlayerScripts.
-- Interface e controles locais; o servidor pode limitar movimento e recompensas.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
assert(player, "Execute este script no cliente, como LocalScript.")
local playerGui = player:WaitForChild("PlayerGui")
local HUB_NAME = "PudimHub_BuildABoat_Interface"
local previous = playerGui:FindFirstChild(HUB_NAME)
if previous then previous:Destroy() end

local Theme = {
    Main = Color3.fromRGB(5, 5, 8),
    Second = Color3.fromRGB(13, 8, 11),
    Red = Color3.fromRGB(240, 30, 55),
    DarkRed = Color3.fromRGB(95, 10, 25),
    Text = Color3.fromRGB(240, 240, 240),
    Muted = Color3.fromRGB(155, 161, 180),
    Button = Color3.fromRGB(26, 10, 15),
}

local function create(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties) do object[key] = value end
    object.Parent = parent
    return object
end

local function round(object, radius)
    create("UICorner", {CornerRadius = UDim.new(0, radius)}, object)
end
local function edge(object, transparency)
    return create("UIStroke", {Color = Theme.Red, Thickness = 1,
        Transparency = transparency or 0.82, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, object)
end
local function animate(object, properties)
    TweenService:Create(object, TweenInfo.new(0.15, Enum.EasingStyle.Quad), properties):Play()
end
local function feedback(button, outline)
    button.AutoButtonColor = false
    button.MouseEnter:Connect(function() animate(outline, {Transparency = 0.45}) end)
    button.MouseLeave:Connect(function() animate(outline, {Transparency = 0.82}) end)
end

local gui = create("ScreenGui", {
    Name = HUB_NAME,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

-- O quadro raiz acompanha a area util da tela, respeitando a barra do Roblox.
local root = create("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, gui)

local frame = create("Frame", {
    Size = UDim2.fromOffset(600, 600),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    BackgroundColor3 = Theme.Main,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
}, root)
round(frame, 12)
create("UIStroke", {Color = Theme.Red, Thickness = 1, Transparency = 0.25}, frame)
local scale = create("UIScale", {Scale = 1}, frame)

local title = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 64),
    BackgroundColor3 = Theme.Second,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Text = "  🍮 PUDIMHUB",
    Font = Enum.Font.GothamBlack,
    TextSize = 19,
    TextColor3 = Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Active = true,
}, frame)
round(title, 12)
create("TextLabel", {
    Position = UDim2.new(1, -252, 0, 20),
    Size = UDim2.fromOffset(190, 24),
    BackgroundTransparency = 1,
    Text = "V008  /  BUILD A BOAT",
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = Theme.Muted,
    TextXAlignment = Enum.TextXAlignment.Right,
}, frame)

local accent = create("Frame", {Position = UDim2.fromOffset(18, 62),
    Size = UDim2.new(1, -36, 0, 1), BackgroundColor3 = Theme.Red, BorderSizePixel = 0}, frame)
create("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.85),
    NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 0.85)})}, accent)
local minimize = create("TextButton", {Position = UDim2.new(1, -44, 0, 17),
    Size = UDim2.fromOffset(30, 30), BackgroundColor3 = Theme.Button,
    BorderSizePixel = 0, Text = "−", TextColor3 = Theme.Text, TextSize = 20,
    Font = Enum.Font.GothamMedium}, frame)
round(minimize, 8)
feedback(minimize, edge(minimize))
minimize.Activated:Connect(function() frame.Visible = false end)

local sidebar = create("Frame", {
    Position = UDim2.fromOffset(12, 76),
    Size = UDim2.new(0, 132, 1, -120),
    BackgroundTransparency = 1,
}, frame)
create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, sidebar)
local container = create("Frame", {
    Position = UDim2.fromOffset(154, 122),
    Size = UDim2.new(1, -166, 1, -166),
    BackgroundColor3 = Theme.Second,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, frame)
round(container, 8)
local search = create("TextBox", {Position = UDim2.fromOffset(154, 76),
    Size = UDim2.new(1, -166, 0, 34), BackgroundColor3 = Theme.Button,
    BorderSizePixel = 0, Text = "", PlaceholderText = "Buscar nesta aba…",
    PlaceholderColor3 = Theme.Muted, TextColor3 = Theme.Text, TextSize = 12,
    Font = Enum.Font.Gotham, ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left}, frame)
round(search, 8); edge(search)
create("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)}, search)

local tabs = {}
local currentTab
local emptySearch = create("TextLabel", {Size = UDim2.new(1, -16, 0, 56),
    Position = UDim2.fromOffset(8, 8), BackgroundTransparency = 1,
    Text = "Nenhum controle encontrado nesta aba.", TextColor3 = Theme.Muted,
    TextSize = 12, Font = Enum.Font.GothamMedium, TextWrapped = true,
    Visible = false, ZIndex = 5}, container)
local function filterPage()
    if not currentTab then return end
    local query = string.lower(search.Text)
    local found = false
    for _, item in ipairs(currentTab.page:GetChildren()) do
        if item:IsA("GuiObject") then
            local text = item:GetAttribute("SearchText") or ""
            if item:IsA("TextLabel") or item:IsA("TextButton") then text = text .. " " .. item.Text end
            for _, child in ipairs(item:GetDescendants()) do
                if child:IsA("TextLabel") then text = text .. " " .. child.Text end
            end
            item.Visible = query == "" or string.find(string.lower(text), query, 1, true) ~= nil
            found = found or item.Visible
        end
    end
    emptySearch.Visible = query ~= "" and not found
    currentTab.page.CanvasPosition = Vector2.zero
end
search:GetPropertyChangedSignal("Text"):Connect(filterPage)
local function selectTab(selected)
    currentTab = selected
    search.Text = ""
    search.PlaceholderText = "Buscar em " .. selected.page.Name .. "…"
    for _, tab in ipairs(tabs) do
        local active = tab == selected
        tab.page.Visible = active
        animate(tab.button, {BackgroundColor3 = active and Theme.DarkRed or Theme.Second,
            TextColor3 = active and Theme.Text or Theme.Muted})
        tab.indicator.Visible = active
    end
    filterPage()
end

local function createTab(name)
    local button = create("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1, -6, 0, 42),
        LayoutOrder = #tabs + 1,
        BackgroundColor3 = Theme.Second,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = name,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.Muted,
        TextSize = 12,
    }, sidebar)
    round(button, 8)
    feedback(button, edge(button))
    local indicator = create("Frame", {Size = UDim2.fromOffset(3, 18),
        Position = UDim2.new(0, 0, 0.5, -9), BackgroundColor3 = Theme.Red,
        BorderSizePixel = 0, Visible = false}, button)
    round(indicator, 2)
    local page = create("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Red,
        Visible = false,
    }, container)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 8),
    }, page)
    create("UIListLayout", {
        Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)
    local tab = {button = button, page = page, indicator = indicator}
    table.insert(tabs, tab)
    button.Activated:Connect(function() selectTab(tab) end)
    return page
end

local tabHome = createTab("Início")
local tabPlayer = createTab("Player")
local tabAutoFarm = createTab("Auto Farm")
local tabStats = createTab("Estatísticas")
local tabVisual = createTab("Visual")
local tabSettings = createTab("Ajustes")
selectTab(tabs[1])
-- Adicione os futuros controles em tabPlayer ou tabAutoFarm.

local connections = {}
local function connect(signal, callback)
    table.insert(connections, signal:Connect(callback))
end
local function placeInside(x, y)
    local area = root.AbsoluteSize
    local half = 300 * scale.Scale
    frame.Position = UDim2.fromOffset(
        math.clamp(x, half, math.max(half, area.X - half)),
        math.clamp(y, half, math.max(half, area.Y - half))
    )
end
local function fitHUD()
    local area = root.AbsoluteSize
    if area.X <= 0 or area.Y <= 0 then return end
    scale.Scale = math.max(0.01, math.min(1, (area.X - 24) / 600, (area.Y - 24) / 600))
    placeInside(area.X / 2, area.Y / 2)
end
connect(root:GetPropertyChangedSignal("AbsoluteSize"), fitHUD)
fitHUD()

local dragging, dragTouch, dragStart, startPosition
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragTouch = input.UserInputType == Enum.UserInputType.Touch and input or nil
        dragStart = input.Position
        startPosition = frame.Position
    end
end)
connect(UserInputService.InputChanged, function(input)
    if dragging and (input == dragTouch or
        (not dragTouch and input.UserInputType == Enum.UserInputType.MouseMovement)) then
        local delta = input.Position - dragStart
        placeInside(startPosition.X.Offset + delta.X, startPosition.Y.Offset + delta.Y)
    end
end)
connect(UserInputService.InputEnded, function(input)
    if input == dragTouch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging, dragTouch = false, nil
    end
end)
connect(UserInputService.WindowFocusReleased, function()
    dragging, dragTouch = false, nil
end)

-- Inicio: perfil, vida, ouro e informacoes locais da sessao.
local order = 0
local function homeItem(className, properties)
    order = order + 1
    properties.LayoutOrder = order
    return create(className, properties, tabHome)
end
local function section(text)
    return homeItem("TextLabel", {
        Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1,
        Text = text, TextColor3 = Theme.Red, TextSize = 12,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
    })
end
local function card(text, height)
    local label = homeItem("TextLabel", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Color3.fromRGB(26, 10, 15), BorderSizePixel = 0,
        Text = text, TextColor3 = Theme.Text, TextSize = 13,
        Font = Enum.Font.GothamMedium, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    round(label, 10)
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
    }, label)
    return label
end

section("SEU PERSONAGEM")
local profileCard = homeItem("Frame", {
    Name = "PlayerProfile", Size = UDim2.new(1, 0, 0, 84),
    BackgroundColor3 = Color3.fromRGB(26, 10, 15), BorderSizePixel = 0,
})
round(profileCard, 10)
local avatar = create("ImageLabel", {
    Size = UDim2.fromOffset(56, 56), Position = UDim2.new(0, 12, 0.5, -28),
    BackgroundColor3 = Theme.Second, BorderSizePixel = 0,
    Image = "", ScaleType = Enum.ScaleType.Crop,
}, profileCard)
round(avatar, 28)
create("UIStroke", {Color = Theme.Red, Transparency = 0.35}, avatar)
local profile = create("TextLabel", {
    Position = UDim2.fromOffset(80, 8), Size = UDim2.new(1, -94, 1, -16),
    BackgroundTransparency = 1, Text = player.DisplayName,
    TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 13,
    TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
}, profileCard)
task.spawn(function()
    local ok, content = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId,
            Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if ok and avatar.Parent then avatar.Image = content end
end)

local health = card("Vida: aguardando personagem", 62)
local track = create("Frame", {
    Position = UDim2.new(0, 0, 1, -10), Size = UDim2.new(1, 0, 0, 4),
    BackgroundColor3 = Theme.Second, BorderSizePixel = 0,
}, health)
round(track, 2)
local healthFill = create("Frame", {
    Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.Red, BorderSizePixel = 0,
}, track)
round(healthFill, 2)
local resources = card("Ouro: indisponível", 52)
section("BUILD A BOAT FOR TREASURE")
card("Construa seu barco e navegue em busca do tesouro!\nPlayer: movimento. Auto Farm: percurso até o baú.", 82)
section("ATALHOS")
card("G · Abrir / recolher menu\nArraste o cabeçalho para mover a janela.", 62)
local center = homeItem("TextButton", {
    Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Theme.DarkRed,
    BorderSizePixel = 0, Text = "Centralizar janela", TextColor3 = Theme.Text,
    Font = Enum.Font.GothamMedium, TextSize = 13,
})
round(center, 8)
center.Activated:Connect(fitHUD)

local footer = create("TextLabel", {
    Position = UDim2.new(0, 18, 1, -32), Size = UDim2.new(1, -36, 0, 22),
    BackgroundTransparency = 1, Text = "PUDIMHUB / BUILD A BOAT",
    TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamMedium,
    TextSize = 11, TextColor3 = Theme.Muted,
}, frame)
connect(UserInputService.InputBegan, function(input, processed)
    if processed or UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.G then
        frame.Visible = not frame.Visible
        dragging, dragTouch = false, nil
    end
end)

-- Leitura somente: usa Gold replicado, quando disponivel, sem alterar recursos.
local function goldText()
    local function read(parent)
        local value = parent and parent:FindFirstChild("Gold")
        if value and (value:IsA("IntValue") or value:IsA("NumberValue")) then
            return tostring(value.Value)
        end
        return nil
    end
    return read(player:FindFirstChild("leaderstats"))
        or read(player:FindFirstChild("Data")) or read(player) or "indisponível"
end
local sessionStart = os.clock()
local elapsed, frames = 0, 0
local function refresh(fps)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local team = player.Team and player.Team.Name or "Sem time"
    profile.Text = player.DisplayName .. "  (@" .. player.Name .. ")\nTime: " .. team
    local ratio = humanoid and math.clamp(humanoid.Health / math.max(1, humanoid.MaxHealth), 0, 1) or 0
    health.Text = humanoid and ("Vida  " .. math.floor(humanoid.Health) .. " / " .. math.floor(humanoid.MaxHealth))
        or "Aguardando personagem…"
    healthFill.Size = UDim2.fromScale(ratio, 1)
    healthFill.BackgroundColor3 = ratio < 0.3 and Theme.Red or Color3.fromRGB(86, 205, 159)
    resources.Text = "Ouro: " .. goldText()
    local seconds = math.floor(os.clock() - sessionStart)
    footer.Text = string.format("%s FPS  /  %d jogadores  /  %02d:%02d no HUD  /  G: menu",
        tostring(fps), #Players:GetPlayers(), math.floor(seconds / 60), seconds % 60)
end
refresh("—")
connect(RunService.RenderStepped, function(dt)
    elapsed = elapsed + dt
    frames = frames + 1
    if elapsed < 1 then return end
    refresh(math.floor(frames / elapsed + 0.5))
    elapsed, frames = 0, 0
end)
-- Controles compartilhados das abas.
-- Persistencia opcional do ambiente. LocalScripts comuns nao possuem readfile/writefile.
local preferences = {controls = {}, loading = true, closed = false, revision = 0}
local settingsFile = "PudimHub_BuildABoat_" .. tostring(player.UserId) .. "_settings_v1.json"
local storageStatus
local hasStorage = type(readfile) == "function" and type(writefile) == "function"
local function storageMessage(message)
    if storageStatus and storageStatus.Parent then storageStatus.Text = message end
end
local function saveSettings()
    if preferences.loading or preferences.closed then return end
    if not hasStorage then
        storageMessage("Salvamento indisponível: este ambiente não oferece readfile/writefile.")
        return
    end
    local values = {}
    for key, entry in pairs(preferences.controls) do values[key] = entry.get() end
    local ok, message = pcall(function()
        local encoded = HttpService:JSONEncode({version = 1, userId = player.UserId, values = values})
        writefile(settingsFile, encoded)
    end)
    storageMessage(ok and "Preferências salvas automaticamente por conta."
        or ("Falha ao salvar: " .. tostring(message):sub(1, 140)))
end
local function preferencesChanged()
    if preferences.loading or preferences.closed then return end
    preferences.revision = preferences.revision + 1
    local revision = preferences.revision
    task.delay(0.7, function()
        if not preferences.closed and preferences.revision == revision then saveSettings() end
    end)
end
local controlOrder = {}
local function control(page, className, text, height)
    controlOrder[page] = (controlOrder[page] or 0) + 1
    local object = create(className, {
        Size = UDim2.new(1, 0, 0, height or 44), LayoutOrder = controlOrder[page],
        BackgroundColor3 = Theme.Button, BorderSizePixel = 0,
        Text = text, TextColor3 = Theme.Text, TextSize = 13,
        TextWrapped = true, Font = Enum.Font.GothamMedium,
    }, page)
    round(object, 8)
    local outline = edge(object)
    object:SetAttribute("SearchText", text)
    if object:IsA("TextButton") then feedback(object, outline) end
    if className == "TextLabel" then
        object.TextXAlignment = Enum.TextXAlignment.Left
        create("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)}, object)
        if (height or 44) <= 28 then
            object.TextColor3 = Color3.fromRGB(237, 116, 127)
            object.Font = Enum.Font.GothamBold
            object.TextSize = 12
            outline.Enabled = false
        end
    end
    return object
end
local function toggle(page, name, callback)
    local enabled = false
    local button = control(page, "TextButton", "", 46)
    button:SetAttribute("SearchText", name)
    create("TextLabel", {Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -78, 1, 0),
        BackgroundTransparency = 1, Text = name, Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, button)
    local track = create("Frame", {Size = UDim2.fromOffset(40, 22),
        Position = UDim2.new(1, -52, 0.5, -11), BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(55, 18, 25)}, button)
    round(track, 11)
    local dot = create("Frame", {Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(3, 3),
        BorderSizePixel = 0, BackgroundColor3 = Theme.Text}, track)
    round(dot, 8)
    local function set(value)
        if enabled == value then return end
        enabled = value
        animate(track, {BackgroundColor3 = value and Theme.Red or Color3.fromRGB(55, 18, 25)})
        animate(dot, {Position = UDim2.fromOffset(value and 21 or 3, 3)})
        callback(value)
        preferencesChanged()
    end
    preferences.controls[page.Name .. "/" .. name] = {
        kind = "boolean", get = function() return enabled end, set = set,
    }
    button.Activated:Connect(function() set(not enabled) end)
    return set
end
local function numberField(page, name, initial, minimum, maximum, callback)
    controlOrder[page] = (controlOrder[page] or 0) + 1
    local row = create("Frame", {Size = UDim2.new(1, 0, 0, 82), LayoutOrder = controlOrder[page],
        BackgroundColor3 = Theme.Second, BorderSizePixel = 0}, page)
    row:SetAttribute("SearchText", name)
    round(row, 8); edge(row)
    create("TextLabel", {Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -94, 0, 28),
        BackgroundTransparency = 1, Text = name, TextWrapped = true,
        TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left}, row)
    local box = create("TextBox", {Size = UDim2.fromOffset(62, 26), Position = UDim2.new(1, -74, 0, 9),
        Text = tostring(initial), BackgroundColor3 = Theme.Button, TextColor3 = Theme.Text,
        TextSize = 12, Font = Enum.Font.GothamBold, BorderSizePixel = 0}, row)
    round(box, 6)
    box.ClearTextOnFocus = false
    local current = initial
    local hit = create("TextButton", {Size = UDim2.new(1, -24, 0, 36),
        Position = UDim2.fromOffset(12, 38), Text = "", BorderSizePixel = 0}, row)
    hit.BackgroundTransparency = 1
    hit.AutoButtonColor = false
    local bar = create("Frame", {Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0.5, -3), BackgroundColor3 = Theme.DarkRed,
        BorderSizePixel = 0}, hit)
    round(bar, 3)
    local fill = create("Frame", {Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Theme.Red, BorderSizePixel = 0}, bar)
    round(fill, 3)
    local knob = create("Frame", {Size = UDim2.fromOffset(16, 16),
        AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0}, bar)
    round(knob, 8)
    local function show(value, notify)
        current = math.clamp(value, minimum, maximum)
        local ratio = (current - minimum) / (maximum - minimum)
        fill.Size = UDim2.fromScale(ratio, 1)
        knob.Position = UDim2.fromScale(ratio, 0.5)
        box.Text = string.format("%.2f", current):gsub("%.?0+$", "")
        if notify then callback(current) end
        preferencesChanged()
    end
    local sliding, touch
    local previousScrolling
    local function release()
        if sliding then page.ScrollingEnabled = previousScrolling end
        sliding, touch = false, nil
    end
    local function move(x)
        if bar.AbsoluteSize.X <= 0 then return end
        local ratio = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local value = minimum + ratio * (maximum - minimum)
        local step = maximum <= 30 and 0.1 or 1
        show(math.floor(value / step + 0.5) * step, true)
    end
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if sliding then return end
            previousScrolling = page.ScrollingEnabled
            page.ScrollingEnabled = false
            sliding = true
            touch = input.UserInputType == Enum.UserInputType.Touch and input or nil
            move(input.Position.X)
        end
    end)
    connect(UserInputService.InputChanged, function(input)
        if sliding and (input == touch or (not touch and input.UserInputType == Enum.UserInputType.MouseMovement)) then move(input.Position.X) end
    end)
    connect(UserInputService.InputEnded, function(input)
        if input == touch or input.UserInputType == Enum.UserInputType.MouseButton1 then release() end
    end)
    connect(UserInputService.WindowFocusReleased, release)
    connect(frame:GetPropertyChangedSignal("Visible"), release)
    connect(page:GetPropertyChangedSignal("Visible"), release)
    connect(row:GetPropertyChangedSignal("Visible"), release)
    box.FocusLost:Connect(function()
        local value = tonumber((box.Text:gsub(",", ".")))
        if value and value == value and math.abs(value) < math.huge then
            show(value, true)
        end
        box.Text = string.format("%.2f", current):gsub("%.?0+$", "")
    end)
    show(initial, false)
    preferences.controls[page.Name .. "/" .. name] = {
        kind = "number", get = function() return current end,
        set = function(value) show(value, true) end,
    }
    return function(value) show(value, false) end
end

local alive = true
local movement = {speed = nil, jump = nil, noclip = false, water = false}
local originals = setmetatable({}, {__mode = "k"})
local collisions = {}
local function characterParts()
    local character = player.Character
    return character, character and character:FindFirstChildOfClass("Humanoid"),
        character and character:FindFirstChild("HumanoidRootPart")
end
local function applyMovement()
    local _, humanoid = characterParts()
    if not humanoid then return end
    if not originals[humanoid] then
        originals[humanoid] = {speed = humanoid.WalkSpeed, power = humanoid.JumpPower,
            height = humanoid.JumpHeight}
    end
    if movement.speed then humanoid.WalkSpeed = movement.speed end
    if movement.jump then
        if humanoid.UseJumpPower then humanoid.JumpPower = movement.jump
        else humanoid.JumpHeight = movement.jump ^ 2 / (2 * math.max(workspace.Gravity, 1)) end
    end
end
local function restoreMovement()
    movement.speed, movement.jump = nil, nil
    for humanoid, saved in pairs(originals) do
        if humanoid.Parent then
            humanoid.WalkSpeed, humanoid.JumpPower, humanoid.JumpHeight = saved.speed, saved.power, saved.height
        end
    end
end
local function restoreCollisions()
    for part, value in pairs(collisions) do
        if part.Parent then part.CanCollide = value end
        collisions[part] = nil
    end
end
control(tabPlayer, "TextLabel", "MOVIMENTO", 28).BackgroundTransparency = 1
local _, initialHumanoid = characterParts()
local initialSpeed = initialHumanoid and initialHumanoid.WalkSpeed or 16
local initialJump = initialHumanoid and (initialHumanoid.UseJumpPower and initialHumanoid.JumpPower
    or math.sqrt(2 * workspace.Gravity * initialHumanoid.JumpHeight)) or 50
local showSpeed = numberField(tabPlayer, "Velocidade normal (WalkSpeed)", initialSpeed, 0, 150, function(value)
    movement.speed = value; applyMovement()
end)
local showJump = numberField(tabPlayer, "Força do pulo", math.floor(initialJump), 0, 200, function(value)
    movement.jump = value; applyMovement()
end)
local setWater
local setNoclip = toggle(tabPlayer, "Noclip", function(value)
    movement.noclip = value
    if not value then restoreCollisions() end
end)
local waterFloor
local function removeFloor()
    if waterFloor then waterFloor:Destroy(); waterFloor = nil end
end
setWater = toggle(tabPlayer, "Water Walk", function(value)
    movement.water = value
    if not value then removeFloor() end
end)
local waterClearance = 3
numberField(tabPlayer, "Water Walk: distância da água", 3, 2, 8, function(value)
    waterClearance = value
end)
control(tabPlayer, "TextLabel", "Water Walk funciona junto com Noclip, mantendo a altura sobre a água. Pausa no barco e durante o farm. Não bloqueia dano aplicado pelo servidor.", 78).BackgroundTransparency = 1
local function waterSurface(hit)
    if not hit then return false end
    if hit.Material == Enum.Material.Water then return true end
    -- Alguns mapas representam a agua com Parts em vez de Terrain.
    local item = hit.Instance
    for _ = 1, 3 do
        if not item or item == workspace then break end
        local name = string.lower(item.Name)
        if name == "water" or name == "waterpart" or name == "river"
            or name == "waterparts" then return true end
        item = item.Parent
    end
    return false
end
control(tabPlayer, "TextButton", "Restaurar movimento original").Activated:Connect(function()
    restoreMovement(); setNoclip(false); setWater(false)
    local _, humanoid = characterParts()
    if humanoid then
        showSpeed(humanoid.WalkSpeed)
        showJump(math.floor(humanoid.UseJumpPower and humanoid.JumpPower
            or math.sqrt(2 * workspace.Gravity * humanoid.JumpHeight)))
    end
end)
connect(RunService.Stepped, function()
    local character, humanoid, rootPart = characterParts()
    if movement.noclip and character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if collisions[part] == nil then collisions[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    end
    if not movement.water or movement.farming or not rootPart
        or not humanoid or humanoid.Health <= 0 or humanoid.SeatPart then
        removeFloor(); return
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = waterFloor and {character, waterFloor} or {character}
    params.IgnoreWater = false
    -- Comeca acima dos pes para detectar a superficie mesmo apos uma queda curta.
    local origin = rootPart.Position + Vector3.new(0, 16, 0)
    local hit = workspace:Raycast(origin, Vector3.new(0, -64, 0), params)
    if waterSurface(hit) then
        local velocity = rootPart.AssemblyLinearVelocity
        local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
        local width = math.clamp(20 + horizontalSpeed * 0.3, 20, 64)
        local surfaceY = hit.Position.Y + waterClearance
        if not waterFloor then
            waterFloor = create("Part", {Name = "PudimHub_WaterFloor", Anchored = true,
                Size = Vector3.new(width, 1, width), Transparency = 1, CanCollide = true,
                CanTouch = false, CanQuery = false}, workspace)
        end
        waterFloor.Size = Vector3.new(width, 1, width)
        -- Com Noclip, a correcao vertical abaixo sustenta o personagem sem colisao.
        waterFloor.CanCollide = not movement.noclip
        waterFloor.Position = Vector3.new(rootPart.Position.X, surfaceY - 0.5, rootPart.Position.Z)
        local feetOffset = humanoid.HipHeight + rootPart.Size.Y / 2
        if humanoid.RigType == Enum.HumanoidRigType.R6 then feetOffset = feetOffset + 2 end
        local safeRootY = surfaceY + feetOffset + 0.1
        if rootPart.Position.Y < safeRootY then
            -- Correcao apenas vertical: nao altera o WalkSpeed nem o movimento horizontal.
            rootPart.CFrame = rootPart.CFrame + Vector3.new(0, safeRootY - rootPart.Position.Y, 0)
            rootPart.AssemblyLinearVelocity = Vector3.new(velocity.X, math.max(0, velocity.Y), velocity.Z)
            if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    else removeFloor() end
end)
connect(player.CharacterAdded, function(character)
    restoreCollisions(); removeFloor()
    task.spawn(function()
        local humanoid = character:WaitForChild("Humanoid", 10)
        if alive and humanoid and player.Character == character then applyMovement() end
    end)
end)

-- Estrutura de mapa conhecida: BoatStages/NormalStages/CaveStageN e TheEnd/GoldenChest/Trigger.
-- Referencia de estrutura: github.com/Stefanuk12/ROBLOX (Build A Boat For Treasure/Autofarm.lua).
local farm = {enabled = false, token = 0, stageDelay = 2, respawnDelay = 5,
    trips = 0, speed = 250, seconds = 0, gold = 0, lastGold = nil, goldObserved = false}
local farmPlatforms = {}
local function clearFarmPlatforms()
    for part in pairs(farmPlatforms) do part:Destroy(); farmPlatforms[part] = nil end
end
local setFarm
control(tabAutoFarm, "TextLabel", "PERCURSO ATÉ O TESOURO", 28).BackgroundTransparency = 1
local status = control(tabAutoFarm, "TextLabel", "Parado", 68)
local function farmStatus(text)
    if alive then status.Text = text .. "\nPercursos até o baú: " .. farm.trips end
end
local function valid(token)
    return alive and farm.enabled and farm.token == token
end
local function pause(seconds, token)
    local deadline = os.clock() + seconds
    repeat
        if not valid(token) then return false end
        task.wait(0.05)
    until os.clock() >= deadline
    return valid(token)
end
local function travel(rootPart, target, token, sameCharacter)
    local start = rootPart.CFrame
    local distance = (start.Position - target.Position).Magnitude
    local covered = 0
    while covered < distance do
        local dt = RunService.Heartbeat:Wait()
        if not valid(token) or not sameCharacter() then return false end
        covered = math.min(distance, covered + farm.speed * math.min(dt, 0.1))
        rootPart.CFrame = start:Lerp(target, covered / distance)
        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
    end
    return valid(token) and sameCharacter()
end
local function route()
    local stages = workspace:FindFirstChild("BoatStages")
    stages = stages and stages:FindFirstChild("NormalStages")
    if not stages then return nil, nil, "Mapa não encontrado: BoatStages/NormalStages." end
    local points = {}
    for _, stage in ipairs(stages:GetChildren()) do
        local index = tonumber(stage.Name:match("^CaveStage(%d+)$"))
        if index then
            local marker = stage:FindFirstChild("DarknessPart", true)
            if not marker or not marker:IsA("BasePart") then
                return nil, nil, "Etapa sem marcador: " .. stage.Name
            end
            table.insert(points, {index = index, marker = marker})
        end
    end
    table.sort(points, function(a, b) return a.index < b.index end)
    local ending = stages:FindFirstChild("TheEnd")
    local chest = ending and ending:FindFirstChild("GoldenChest")
    local trigger = chest and chest:FindFirstChild("Trigger")
    if #points == 0 or not trigger or not trigger:IsA("BasePart") then
        return nil, nil, "Etapas ou gatilho do baú indisponíveis. Aguarde o mapa carregar."
    end
    return points, trigger
end
local function runFarm(token)
    while valid(token) do
        farmStatus("Aguardando personagem vivo…")
        local character, humanoid, rootPart
        local deadline = os.clock() + 60
        repeat
            if not pause(0.1, token) then return end
            character, humanoid, rootPart = characterParts()
        until (humanoid and humanoid.Health > 0 and rootPart) or os.clock() > deadline
        if not humanoid or humanoid.Health <= 0 or not rootPart then error("Personagem indisponível por 60 segundos.", 0) end
        local points, trigger, reason = route()
        local mapDeadline = os.clock() + 30
        while not points and valid(token) and os.clock() < mapDeadline do
            farmStatus("Aguardando o mapa carregar…")
            if not pause(0.5, token) then return end
            points, trigger, reason = route()
        end
        if not points then error(reason, 0) end
        local function sameCharacter()
            return player.Character == character and rootPart.Parent and humanoid.Health > 0
        end
        local interrupted = false
        for _, point in ipairs(points) do
            if not valid(token) then return end
            if not sameCharacter() then interrupted = true; break end
            if not point.marker.Parent then error("O mapa mudou. Reinicie o farm.", 0) end
            farmStatus("Passando pela etapa " .. point.index .. "…")
            if not travel(rootPart, point.marker.CFrame, token, sameCharacter) then interrupted = true; break end
            rootPart.AssemblyLinearVelocity = Vector3.zero
            rootPart.AssemblyAngularVelocity = Vector3.zero
            local footOffset = humanoid.HipHeight + rootPart.Size.Y / 2
            if humanoid.RigType == Enum.HumanoidRigType.R6 then footOffset = footOffset + 2 end
            local support = create("Part", {
                Name = "PudimHub_FarmSupport", Anchored = true, Transparency = 1,
                Size = Vector3.new(12, 0.5, 12), CanCollide = true, CanTouch = false,
                Position = rootPart.Position - Vector3.new(0, footOffset + 0.25, 0),
            }, workspace)
            farmPlatforms[support] = true
            local continuing = pause(farm.stageDelay, token)
            support:Destroy(); farmPlatforms[support] = nil
            if not continuing then return end
        end
        if not interrupted and sameCharacter() then
            farmStatus("Chegando ao baú…")
            if not trigger.Parent then error("O baú não está mais disponível.", 0) end
            if not travel(rootPart, trigger.CFrame, token, sameCharacter) then
                if not valid(token) then return end
                interrupted = true
            end
            if not interrupted then
            rootPart.AssemblyLinearVelocity = Vector3.zero
            farm.trips = farm.trips + 1
            farmStatus("Aguardando recompensa e renascimento…")
            deadline = os.clock() + 60
            while valid(token) and sameCharacter() and os.clock() < deadline do
                if not pause(0.2, token) then return end
            end
            if valid(token) and sameCharacter() then
                error("Sem renascimento após 60 s. A coleta do baú não foi confirmada.", 0)
            end
            end
        end
        if not pause(farm.respawnDelay, token) then return end
    end
end
setFarm = toggle(tabAutoFarm, "Auto Farm", function(enabled)
    farm.token = farm.token + 1
    farm.enabled = enabled
    movement.farming = enabled
    if enabled then removeFloor() end
    if not enabled then clearFarmPlatforms(); farmStatus("Parado"); return end
    farm.lastGold = tonumber(goldText())
    local token = farm.token
    task.spawn(function()
        local ok, message = pcall(runFarm, token)
        if not ok and valid(token) then
            setFarm(false)
            farmStatus("Farm interrompido: " .. tostring(message))
        end
    end)
end)
numberField(tabAutoFarm, "Velocidade do percurso (studs/s)", 250, 50, 600, function(value) farm.speed = value end)
numberField(tabAutoFarm, "Segundos em cada etapa", 2, 0.5, 10, function(value) farm.stageDelay = value end)
numberField(tabAutoFarm, "Pausa entre percursos (segundos)", 5, 1, 30, function(value) farm.respawnDelay = value end)
control(tabAutoFarm, "TextLabel", "Arraste as barras ou digite os valores. O farm move o personagem entre etapas; Player usa WalkSpeed.\nChegar ao baú não confirma recompensa.", 86).BackgroundTransparency = 1

local stats = control(tabStats, "TextLabel", "Preparando estatísticas…", 164)
control(tabStats, "TextLabel", "Ouro ganho = soma dos aumentos de saldo observados enquanto o farm está ligado. Pode incluir outras fontes de ouro. Gastos não são descontados.\nO tempo inclui as esperas com o farm ligado.", 106).BackgroundTransparency = 1
local compactStats = control(tabAutoFarm, "TextLabel", "", 88)
local function renderStats()
    local total = math.floor(farm.seconds)
    local clockText = string.format("%02d:%02d:%02d", math.floor(total / 3600), math.floor(total / 60) % 60, total % 60)
    local money = farm.goldObserved and tostring(farm.gold) or "indisponível"
    compactStats.Text = string.format("Chegadas ao final: %d\nOuro ganho: %s  |  Tempo: %s", farm.trips, money, clockText)
    stats.Text = compactStats.Text .. "\nSaldo atual: " .. goldText()
        .. "\nEstado: " .. (farm.enabled and "Farm ligado" or "Farm parado")
end
local statsElapsed = 0
connect(RunService.Heartbeat, function(dt)
    if farm.enabled then
        farm.seconds = farm.seconds + dt
        local balance = tonumber(goldText())
        if balance then
            farm.goldObserved = true
            if farm.lastGold then farm.gold = farm.gold + math.max(0, balance - farm.lastGold) end
        end
        farm.lastGold = balance
    end
    statsElapsed = statsElapsed + dt
    if statsElapsed >= 0.5 then statsElapsed = 0; renderStats() end
end)
control(tabStats, "TextButton", "Zerar contadores da sessão").Activated:Connect(function()
    farm.trips, farm.seconds, farm.gold = 0, 0, 0
    farm.lastGold = tonumber(goldText())
    farm.goldObserved = farm.lastGold ~= nil
    renderStats()
end)
renderStats()

local Lighting = game:GetService("Lighting")
local savedLighting
local setLight = toggle(tabVisual, "Iluminação clara", function(enabled)
    if enabled then
        savedLighting = {Brightness = Lighting.Brightness, Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient, GlobalShadows = Lighting.GlobalShadows}
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        Lighting.GlobalShadows = false
    elseif savedLighting then
        for property, value in pairs(savedLighting) do Lighting[property] = value end
        savedLighting = nil
    end
end)
local cameras = setmetatable({}, {__mode = "k"})
local selectedFov
local function applyFov()
    local camera = workspace.CurrentCamera
    if camera and selectedFov then
        if not cameras[camera] then cameras[camera] = camera.FieldOfView end
        camera.FieldOfView = selectedFov
    end
end
local showFov = numberField(tabVisual, "Campo de visão (FOV)", workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70, 40, 110, function(value)
    selectedFov = value; applyFov()
end)
connect(workspace:GetPropertyChangedSignal("CurrentCamera"), applyFov)
local function restoreVisual()
    setLight(false)
    selectedFov = nil
    for camera, value in pairs(cameras) do
        if camera.Parent then camera.FieldOfView = value end
        cameras[camera] = nil
    end
    if workspace.CurrentCamera then showFov(workspace.CurrentCamera.FieldOfView) end
end
control(tabVisual, "TextButton", "Restaurar visual original").Activated:Connect(restoreVisual)
control(tabSettings, "TextButton", "Centralizar janela").Activated:Connect(fitHUD)
local antiAfkEnabled = false
local antiAfkStatus = control(tabSettings, "TextLabel", "Anti-AFK: desligado", 52)
local setAntiAfk = toggle(tabSettings, "Anti-AFK", function(enabled)
    antiAfkEnabled = enabled
    antiAfkStatus.Text = enabled and "Anti-AFK: aguardando inatividade" or "Anti-AFK: desligado"
end)
connect(player.Idled, function()
    if not antiAfkEnabled then return end
    local ok = pcall(function()
        local virtualUser = game:GetService("VirtualUser")
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new(0, 0))
    end)
    antiAfkStatus.Text = ok and "Anti-AFK: entrada enviada após inatividade"
        or "Anti-AFK indisponível: este ambiente bloqueou a entrada virtual."
end)
setAntiAfk(true)
numberField(tabSettings, "Transparência do HUD (%)", 5, 0, 80, function(value) frame.BackgroundTransparency = value / 100 end)
control(tabSettings, "TextButton", "Parar farm e restaurar personagem").Activated:Connect(function()
    setFarm(false); restoreMovement(); setNoclip(false); setWater(false)
    local _, humanoid = characterParts()
    if humanoid then
        showSpeed(humanoid.WalkSpeed)
        showJump(humanoid.UseJumpPower and humanoid.JumpPower or math.sqrt(2 * workspace.Gravity * humanoid.JumpHeight))
    end
end)
control(tabSettings, "TextButton", "Fechar e remover HUD").Activated:Connect(function() gui:Destroy() end)
control(tabSettings, "TextLabel", "G: abrir / recolher. Fechar o HUD encerra o farm e restaura as alterações locais. Contadores valem somente nesta execução.", 80).BackgroundTransparency = 1

storageStatus = control(tabSettings, "TextLabel", "Carregando preferências…", 76)
control(tabSettings, "TextButton", "Salvar preferências agora").Activated:Connect(saveSettings)
control(tabSettings, "TextLabel", "Sliders e opções são salvos por conta, incluindo Auto Farm e Anti-AFK. O farm retoma se foi salvo ligado. As estatísticas são apenas desta sessão.\nReabra o menu com G.", 106).BackgroundTransparency = 1

local function loadSettings()
    if not hasStorage then
        storageMessage("Sem salvamento em disco: readfile/writefile não estão disponíveis. Ajustes valem apenas nesta execução.")
        return
    end
    if type(isfile) == "function" then
        local checked, exists = pcall(isfile, settingsFile)
        if checked and not exists then
            storageMessage("Primeiro uso: suas alterações serão salvas automaticamente.")
            return
        end
    end
    local readOk, contents = pcall(readfile, settingsFile)
    if not readOk then
        storageMessage("Sem arquivo legível. Altere uma opção para tentar salvar suas preferências.")
        return
    end
    local ok, saved = pcall(function()
        assert(type(contents) == "string" and #contents <= 65536, "Arquivo inválido ou grande demais")
        local data = HttpService:JSONDecode(contents)
        assert(type(data) == "table" and data.version == 1 and data.userId == player.UserId
            and type(data.values) == "table", "Formato ou conta incompatível")
        return data
    end)
    if not ok then
        storageMessage("Preferências inválidas; usando padrões. O próximo salvamento substituirá o arquivo.")
        return
    end
    -- Sliders primeiro; alternadores depois. Auto Farm e aplicado por ultimo.
    local failed = false
    for _, kind in ipairs({"number", "boolean"}) do
        for key, entry in pairs(preferences.controls) do
            local value = saved.values[key]
            if key ~= "Auto Farm/Auto Farm" and entry.kind == kind and type(value) == kind then
                if kind ~= "number" or (value == value and math.abs(value) < math.huge) then
                    local applied = pcall(entry.set, value)
                    if not applied then failed = true end
                end
            end
        end
    end
    local savedFarm = saved.values["Auto Farm/Auto Farm"]
    if type(savedFarm) == "boolean" then
        local applied = pcall(setFarm, savedFarm)
        if not applied then failed = true end
    end
    storageMessage(failed and "Preferências carregadas parcialmente; alguns controles falharam."
        or "Preferências restauradas. Salvamento automático ativo.")
end
loadSettings()
preferences.loading = false

-- Acabamento consistente dos cartoes da pagina inicial.
for _, item in ipairs(tabHome:GetChildren()) do
    if item:IsA("GuiObject") and item.BackgroundTransparency < 1 then
        edge(item)
        if item:IsA("TextButton") then feedback(item, item:FindFirstChildOfClass("UIStroke")) end
    end
end

gui.Destroying:Connect(function()
    -- Salva antes de restaurar o personagem: a limpeza nao apaga as preferencias.
    saveSettings()
    preferences.closed = true
    alive = false
    farm.enabled = false
    farm.token = farm.token + 1
    clearFarmPlatforms()
    restoreVisual()
    for _, connection in ipairs(connections) do connection:Disconnect() end
    restoreMovement()
    restoreCollisions()
    removeFloor()
end)
