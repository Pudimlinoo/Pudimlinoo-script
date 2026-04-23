-- ================================================================= --
--   PudimLinoo Hub — Aimbot + ESP (Aprimorado)                      --
--   Teclas: G = Menu | H = ESP Toggle                              --
-- ================================================================= --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Nome EXCLUSIVO do seu Hub (Para não confundir com outros scripts)
local NOME_DO_HUB = "PudimHub_AimbotESP_Only"

-- Remove Hub antigo se já existir
if player and player:FindFirstChild("PlayerGui") then
    if player.PlayerGui:FindFirstChild(NOME_DO_HUB) then
        player.PlayerGui[NOME_DO_HUB]:Destroy()
    end
end
if CoreGui:FindFirstChild(NOME_DO_HUB) then
    CoreGui[NOME_DO_HUB]:Destroy()
end

-- ================= TEMA =================
local Theme = {
    Red = Color3.fromRGB(200, 40, 40),
    DarkRed = Color3.fromRGB(140, 25, 25),
    Text = Color3.fromRGB(240, 240, 240),
    Button = Color3.fromRGB(35, 35, 35),
    Second = Color3.fromRGB(25, 25, 25),
    Main = Color3.fromRGB(18, 18, 18),
}

-- ================= GUI =================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = NOME_DO_HUB
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 260)
frame.Position = UDim2.new(0.03, 0, 0.35, 0)
frame.BackgroundColor3 = Theme.Main
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Visible = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Theme.Red
stroke.Thickness = 1.5

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 38)
title.BackgroundColor3 = Theme.DarkRed
title.Text = "🎯 Aimbot + ESP (PudimLinoo)  —  G: Menu  |  H: ESP"
title.TextColor3 = Theme.Text
title.Font = Enum.Font.GothamBold
title.TextSize = 16
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)

-- ================= HELPERS =================
local function criarSecao(txt, y, p)
    local l = Instance.new("TextLabel", p)
    l.Size = UDim2.new(1, -10, 0, 24)
    l.Position = UDim2.new(0, 5, 0, y)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Theme.Red
    l.Font = Enum.Font.GothamBold
    l.TextSize = 18
    l.TextXAlignment = Enum.TextXAlignment.Left
end

local function criarBotaoToggle(txt, y, p, cb)
    local frame = Instance.new("Frame", p)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.Size = UDim2.new(1, -20, 0, 32)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = txt
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Theme.Text
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("Frame", frame)
    toggle.Size = UDim2.new(0, 46, 0, 22)
    toggle.Position = UDim2.new(1, -46, 0.5, -11)
    toggle.BackgroundColor3 = Theme.Button
    Instance.new("UICorner", toggle)

    local circle = Instance.new("Frame", toggle)
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = UDim2.new(0, 2, 0.5, -9)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", circle)

    local state = false
    local btn = Instance.new("TextButton", toggle)
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.fromScale(1, 1)
    btn.Text = ""

    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            toggle.BackgroundColor3 = Theme.Red
            circle.Position = UDim2.new(1, -20, 0.5, -9)
        else
            toggle.BackgroundColor3 = Theme.Button
            circle.Position = UDim2.new(0, 2, 0.5, -9)
        end
        cb(state)
    end)

    return function(newState)
        if newState ~= state then
            state = newState
            if state then
                toggle.BackgroundColor3 = Theme.Red
                circle.Position = UDim2.new(1, -20, 0.5, -9)
            else
                toggle.BackgroundColor3 = Theme.Button
                circle.Position = UDim2.new(0, 2, 0.5, -9)
            end
        end
    end
end

local function criarSlider(txt, min, max, init, y, p, cb)
    local label = Instance.new("TextLabel", p)
    label.Position = UDim2.new(0, 10, 0, y)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.Text = txt .. ": " .. init

    local bar = Instance.new("Frame", p)
    bar.Position = UDim2.new(0, 10, 0, y + 24)
    bar.Size = UDim2.new(1, -20, 0, 10)
    bar.BackgroundColor3 = Theme.Second
    Instance.new("UICorner", bar)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((init - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Red
    Instance.new("UICorner", fill)

    cb(init)

    local function updateSlider(input)
        local r = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * r)
        fill.Size = UDim2.new(r, 0, 1, 0)
        label.Text = txt .. ": " .. v
        cb(v)
    end

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(i)
            local conn
            conn = UserInputService.InputChanged:Connect(function(m)
                if m.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(m)
                end
            end)
            UserInputService.InputEnded:Wait()
            conn:Disconnect()
        end
    end)
end

-- ================= VARIÁVEIS =================
local espObjects = {}
local ESPAtivo = false
local espOnlyEnemies = false

local aimbotEnabled = false
local aimMode = "ALL" -- ALL | ENEMIES
local aimPartMode = "BOTH" -- HEAD | TORSO | BOTH
local lockedPart, lockedHumanoid

local AIM_MAX_DISTANCE = 500
local AIM_MIN_FOV = 50
local AIM_MAX_FOV = 500
local AIM_FOV_RADIUS = 200

-- ================= MENU =================
criarSecao("ESP", 0, frame)
local setESPBtn = criarBotaoToggle("ESP JOGADORES", 30, frame, function(v) ESPAtivo = v end)
local setESPOnlyBtn = criarBotaoToggle("SÓ INIMIGOS", 70, frame, function(v) espOnlyEnemies = v end)

criarSecao("AIMBOT (TECLA F)", 110, frame)
local setAimOnlyBtn = criarBotaoToggle("SÓ INIMIGOS", 140, frame, function(v)
    aimMode = v and "ENEMIES" or "ALL"
    lockedPart = nil
end)
local setAimHeadBtn = criarBotaoToggle("MIRA: CABEÇA", 180, frame, function(v)
    aimPartMode = v and "HEAD" or "BOTH"
    lockedPart = nil
end)
criarSlider("FOV AIM", AIM_MIN_FOV, AIM_MAX_FOV, AIM_FOV_RADIUS, 220, frame, function(v)
    AIM_FOV_RADIUS = v
end)

-- ================= ANIMAÇÃO MENU =================
local menuOpen = true
local busy = false
local OPEN_SIZE = UDim2.new(0, 320, 0, 260)
local CLOSED_SIZE = UDim2.new(0, 0, 0, 0)
local OPEN_TRANSP = 0.05
local CLOSED_TRANSP = 1

local tweenOpen = TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = OPEN_SIZE, BackgroundTransparency = OPEN_TRANSP })
local tweenClose = TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = CLOSED_SIZE, BackgroundTransparency = CLOSED_TRANSP })

local function ToggleMenu()
    if busy then return end
    busy = true
    if menuOpen then
        tweenClose:Play()
        tweenClose.Completed:Wait()
        frame.Visible = false
    else
        frame.Visible = true
        tweenOpen:Play()
    end
    menuOpen = not menuOpen
    task.wait(0.05)
    busy = false
end

-- ================= CONTROLES DE TECLADO =================
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end

    -- G: Menu
    if i.KeyCode == Enum.KeyCode.G then
        ToggleMenu()
    end

    -- H: ESP Toggle
    if i.KeyCode == Enum.KeyCode.H then
        ESPAtivo = not ESPAtivo
        if setESPBtn then setESPBtn(ESPAtivo) end
    end

    -- F: Aimbot Toggle
    if i.KeyCode == Enum.KeyCode.F then
        aimbotEnabled = not aimbotEnabled
        lockedPart, lockedHumanoid = nil, nil
    end
end)

-- ================= BOTÃO MOBILE =================
local mobileBtn = Instance.new("TextButton", gui)
mobileBtn.Size = UDim2.new(0, 42, 0, 42)
mobileBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
mobileBtn.BackgroundTransparency = 1
mobileBtn.Text = ""

local btnVisual = Instance.new("Frame", mobileBtn)
btnVisual.Size = UDim2.fromScale(1, 1)
btnVisual.AnchorPoint = Vector2.new(0.5, 0.5)
btnVisual.Position = UDim2.fromScale(0.5, 0.5)
btnVisual.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", btnVisual).CornerRadius = UDim.new(1, 0)

local gradiente = Instance.new("UIGradient", btnVisual)
gradiente.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Second),
    ColorSequenceKeypoint.new(1, Theme.DarkRed)
})
gradiente.Rotation = 45

local btnStroke = Instance.new("UIStroke", btnVisual)
btnStroke.Color = Theme.Red
btnStroke.Thickness = 2.5

local anelInterno = Instance.new("Frame", btnVisual)
anelInterno.Size = UDim2.new(1, -6, 1, -6)
anelInterno.AnchorPoint = Vector2.new(0.5, 0.5)
anelInterno.Position = UDim2.fromScale(0.5, 0.5)
anelInterno.BackgroundTransparency = 1
Instance.new("UICorner", anelInterno).CornerRadius = UDim.new(1, 0)
local anelStroke = Instance.new("UIStroke", anelInterno)
anelStroke.Color = Color3.fromRGB(255, 100, 100)
anelStroke.Thickness = 1
anelStroke.Transparency = 0.5

local iconeLabel = Instance.new("TextLabel", btnVisual)
iconeLabel.Size = UDim2.fromScale(1, 1)
iconeLabel.BackgroundTransparency = 1
iconeLabel.Text = "🎯"
iconeLabel.TextSize = 20

local glowShadow = Instance.new("ImageLabel", btnVisual)
glowShadow.AnchorPoint = Vector2.new(0.5, 0.5)
glowShadow.Position = UDim2.fromScale(0.5, 0.5)
glowShadow.Size = UDim2.new(1, 35, 1, 35)
glowShadow.Image = "rbxassetid://1316045217"
glowShadow.ImageColor3 = Theme.Red
glowShadow.ImageTransparency = 0.4
glowShadow.BackgroundTransparency = 1
glowShadow.ZIndex = -1

mobileBtn.MouseButton1Click:Connect(ToggleMenu)

-- Arrastar botão mobile
local draggingBtn, dragInputBtn, dragStartBtn, startPosBtn
mobileBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = true
        dragStartBtn = input.Position
        startPosBtn = mobileBtn.Position
        TweenService:Create(btnVisual, TweenInfo.new(0.2), { Size = UDim2.new(1.15, 0, 1.15, 0) }):Play()
    end
end)
mobileBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInputBtn = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInputBtn and draggingBtn then
        local delta = input.Position - dragStartBtn
        mobileBtn.Position = UDim2.new(
            startPosBtn.X.Scale, startPosBtn.X.Offset + delta.X,
            startPosBtn.Y.Scale, startPosBtn.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = false
        TweenService:Create(btnVisual, TweenInfo.new(0.2), { Size = UDim2.fromScale(1, 1) }):Play()
    end
end)

-- ================= AIMBOT =================
local function getTorso(char)
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
end

local function sameTeam(plr)
    if player.Team and plr.Team then return player.Team == plr.Team end
    if player.TeamColor and plr.TeamColor then return player.TeamColor == plr.TeamColor end
    return false
end

local function isEnemyAim(plr)
    return aimMode == "ALL" or not sameTeam(plr)
end

local function hasLineOfSight(char, part)
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { player.Character, gui }
    params.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, params)
    return not result or result.Instance:IsDescendantOf(char)
end

local function getTarget()
    local bestPart, bestHum, bestDist = nil, nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and isEnemyAim(plr) then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local head = plr.Character:FindFirstChild("Head")
                local torso = getTorso(plr.Character)

                local parts = {}
                if aimPartMode == "HEAD" and head then parts = { head }
                elseif aimPartMode == "TORSO" and torso then parts = { torso }
                else
                    if head then table.insert(parts, head) end
                    if torso then table.insert(parts, torso) end
                end

                for _, part in ipairs(parts) do
                    local dist = (part.Position - Camera.CFrame.Position).Magnitude
                    if dist <= AIM_MAX_DISTANCE then
                        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen
                           and (Vector2.new(sp.X, sp.Y) - center).Magnitude <= AIM_FOV_RADIUS
                           and hasLineOfSight(plr.Character, part) then
                            if dist < bestDist then
                                bestDist, bestPart, bestHum = dist, part, hum
                            end
                        end
                    end
                end
            end
        end
    end

    lockedHumanoid = bestHum
    return bestPart
end

-- Círculo de FOV (depende do 'Drawing' do executor)
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 80
fovCircle.Filled = false
fovCircle.Color = Theme.Red
fovCircle.Visible = false

RunService.RenderStepped:Connect(function()
    pcall(function()
        fovCircle.Visible = aimbotEnabled
        if not aimbotEnabled then return end

        fovCircle.Radius = AIM_FOV_RADIUS
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        if not lockedPart or not lockedHumanoid or lockedHumanoid.Health <= 0 then
            lockedPart = getTarget()
        end

        if lockedPart and lockedHumanoid and lockedHumanoid.Health > 0 then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedPart.Position)
        else
            lockedPart, lockedHumanoid = nil, nil
        end
    end)
end)

-- ================= ESP =================
local function createPlayerESP(plr)
    if plr == player then return end

    local function apply(char)
        local head = char:WaitForChild("Head")
        if espObjects[plr] then
            espObjects[plr].conn:Disconnect()
            espObjects[plr].esp:Destroy()
            espObjects[plr] = nil
        end

        local bill = Instance.new("BillboardGui", head)
        bill.Adornee = head
        bill.Size = UDim2.new(0, 200, 0, 80)
        bill.AlwaysOnTop = true

        local txt = Instance.new("TextLabel", bill)
        txt.Size = UDim2.fromScale(1, 1)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.new(1, 1, 1)
        txt.TextStrokeTransparency = 0
        txt.Font = Enum.Font.SourceSansBold
        txt.TextSize = 14

        local connection
        connection = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not char or not char.Parent or char:FindFirstChildOfClass("Humanoid").Health <= 0 then
                    bill:Destroy()
                    connection:Disconnect()
                    return
                end

                local isSameTeam = sameTeam(plr)
                if (not ESPAtivo) or (espOnlyEnemies and isSameTeam) then
                    bill.Enabled = false
                    return
                end

                bill.Enabled = true
                txt.TextColor3 = isSameTeam and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(255, 70, 70)

                local otherRoot = char:FindFirstChild("HumanoidRootPart")
                if not otherRoot then return end

                local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local dist = math.floor((root.Position - otherRoot.Position).Magnitude)
                local level = plr:FindFirstChild("Data") and plr.Data:FindFirstChild("Level") and plr.Data.Level.Value or "?"
                txt.Text = plr.Name ..
                    "\nHP: " .. math.floor(char.Humanoid.Health) ..
                    "\nLVL: " .. level ..
                    "\nDist: " .. dist .. "m"
            end)
        end)

        espObjects[plr] = { esp = bill, conn = connection }
    end

    if plr.Character then apply(plr.Character) end
    plr.CharacterAdded:Connect(apply)
    plr.CharacterRemoving:Connect(function()
        if espObjects[plr] then
            espObjects[plr].conn:Disconnect()
            espObjects[plr].esp:Destroy()
            espObjects[plr] = nil
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do createPlayerESP(p) end
Players.PlayerAdded:Connect(createPlayerESP)
Players.PlayerRemoving:Connect(function(p)
    if espObjects[p] then
        espObjects[p].conn:Disconnect()
        espObjects[p].esp:Destroy()
        espObjects[p] = nil
    end
end)
