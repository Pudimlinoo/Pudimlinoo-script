-- ================= KEY SYSTEM =================
local KEY_CORRETA = "Pudimlinoo"

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GUI SAFE (executor friendly)
local function getParentGui()
	if gethui then
		return gethui()
	end
	return player:WaitForChild("PlayerGui")
end

local function pedirKey()
	-- evita duplicar
	if getParentGui():FindFirstChild("KeySystem") then
		return
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "KeySystem"
	gui.ResetOnSpawn = false
	gui.Parent = getParentGui()

	local frame = Instance.new("Frame", gui)
	frame.Size = UDim2.new(0,300,0,160)
	frame.Position = UDim2.new(0.5,-150,0.5,-80)
	frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
	frame.BorderSizePixel = 0
	Instance.new("UICorner", frame)

	local title = Instance.new("TextLabel", frame)
	title.Size = UDim2.new(1,0,0,35)
	title.BackgroundTransparency = 1
	title.Text = "🔐 Key System"
	title.TextColor3 = Color3.new(1,1,1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20

	local box = Instance.new("TextBox", frame)
	box.Position = UDim2.new(0.1,0,0,55)
	box.Size = UDim2.new(0.8,0,0,30)
	box.PlaceholderText = "Digite a key"
	box.ClearTextOnFocus = false
	box.Text = ""
	box.Font = Enum.Font.SourceSansBold
	box.TextSize = 18
	box.BackgroundColor3 = Color3.fromRGB(40,40,40)
	box.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", box)

	local btn = Instance.new("TextButton", frame)
	btn.Position = UDim2.new(0.1,0,0,100)
	btn.Size = UDim2.new(0.8,0,0,30)
	btn.Text = "CONFIRMAR"
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	btn.BackgroundColor3 = Color3.fromRGB(0,140,0)
	btn.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", btn)

	btn.MouseButton1Click:Connect(function()
		if box.Text == KEY_CORRETA then
			gui:Destroy()

			-- proteção extra
			local ok, err = pcall(function()
				ScriptPrincipal()
			end)

			if not ok then
				warn("Erro ao iniciar script:", err)
			end
		else
			box.Text = ""
			box.PlaceholderText = "Key incorreta!"
		end
	end)
end

-- ================= SCRIPT PRINCIPAL =================
function ScriptPrincipal()
-- ================= SERVIÇOS =================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

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

-- ================= GUI =================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "ModMenu"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,460,0,430)
frame.Position = UDim2.new(0.03,0,0.35,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)

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
title.BackgroundColor3 = Color3.fromRGB(18,18,18)
title.BackgroundTransparency = 0.2
title.Text = "🍮 PudimLinoo Script"
title.TextColor3 = Color3.fromRGB(235,235,235)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
Instance.new("UICorner", title).CornerRadius = UDim.new(0,16)

-- ================= DRAG =================
local dragging, dragStart, startPos
title.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = frame.Position
	end
end)

UserInputService.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = i.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

title.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- ================= COLUNAS =================
local left = Instance.new("Frame", frame)
left.Size = UDim2.new(0.48,0,1,-45)
left.Position = UDim2.new(0.02,0,0,40)
left.BackgroundTransparency = 1

-- 👉 Agora a direita vira SCROLLINGFRAME
local right = Instance.new("ScrollingFrame", frame)
right.Size = UDim2.new(0.48,0,1,-45)
right.Position = UDim2.new(0.5,0,0,40)
right.BackgroundTransparency = 1
right.CanvasSize = UDim2.new(0,0,0,650) -- 👈 altura total do conteúdo
right.ScrollBarImageTransparency = 0.2
right.ScrollBarThickness = 6
right.AutomaticCanvasSize = Enum.AutomaticSize.None

-- ================= UI HELPERS =================
local function criarSecao(txt,y,p)
	local l = Instance.new("TextLabel",p)
	l.Size = UDim2.new(1,-10,0,24)
	l.Position = UDim2.new(0,5,0,y)
	l.BackgroundColor3 = Color3.fromRGB(25,25,25)
	l.Text = txt
	l.TextColor3 = Color3.new(1,1,1)
	l.Font = Enum.Font.GothamBold
	l.BackgroundTransparency = 0.25
	l.TextScaled = true
	Instance.new("UICorner",l)
end

local function criarBotaoToggle(txt,y,p,cb)
	local b = Instance.new("TextButton",p)
	b.Position = UDim2.new(0,10,0,y)
	b.Size = UDim2.new(1,-20,0,32)

	-- VISUAL NOVO
	b.BackgroundColor3 = Color3.fromRGB(140,40,40)
	b.BackgroundTransparency = 0.2
	b.Text = txt..": OFF"
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 18
	Instance.new("UICorner",b)

	-- HOVER (passar o mouse)
	b.MouseEnter:Connect(function()
		b.BackgroundTransparency = 0
	end)

	b.MouseLeave:Connect(function()
		b.BackgroundTransparency = 0.2
	end)

	-- LÓGICA ORIGINAL (SEM MUDAR)
	local state = false
	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = txt..": "..(state and "ON" or "OFF")
		b.BackgroundColor3 = state and Color3.fromRGB(0,140,0) or Color3.fromRGB(140,40,40)
		cb(state)
	end)
end

local function criarSlider(txt,min,max,init,y,p,cb)
	local label = Instance.new("TextLabel",p)
	label.Position = UDim2.new(0,10,0,y)
	label.Size = UDim2.new(1,-20,0,20)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(230,230,230)
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 18
	label.Text = txt..": "..init

	local bar = Instance.new("Frame",p)
	bar.Position = UDim2.new(0,10,0,y+24)
	bar.Size = UDim2.new(1,-20,0,10)
	bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
	Instance.new("UICorner",bar)

	local fill = Instance.new("Frame",bar)
	fill.Size = UDim2.new((init-min)/(max-min),0,1,0)
	fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
	Instance.new("UICorner",fill)

	cb(init)

	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			local conn
			conn = UserInputService.InputChanged:Connect(function(m)
				if m.UserInputType == Enum.UserInputType.MouseMovement then
					local r = math.clamp((m.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
					local v = math.floor(min+(max-min)*r)
					fill.Size = UDim2.new(r,0,1,0)
					label.Text = txt..": "..v
					cb(v)
				end
			end)
			bar.InputEnded:Wait()
			conn:Disconnect()
		end
	end)
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

-- ================= PLAYER =================
criarSecao("PLAYER",0,left)

criarBotaoToggle("NOCLIP",30,left,function(v)
	noclip = v
end)

criarBotaoToggle("CHÃO INFINITO",70,left,function(v)
	floorEnabled = v
	if not v and floor then
		floor:Destroy()
		floor = nil
	end
end)

-- ================= MOVIMENTO =================
criarSecao("MOVIMENTO",120,left)

criarSlider("Pulo",25,500,50,150,left,function(v)
	getHumanoid().JumpPower = v
end)

criarSlider("Velocidade TP",0,10,0,220,left,function(v)
	tpSpeed = v
end)

-- ================= ESP =================
criarSecao("ESP",300,left)

criarBotaoToggle("SÓ INIMIGOS",330,left,function(v)
	espOnlyEnemies = v
end)


-- ================= SISTEMA =================
criarSecao("SISTEMA",0,right)

local rejoin = Instance.new("TextButton",right)
rejoin.Position = UDim2.new(0,10,0,30)
rejoin.Size = UDim2.new(1,-20,0,32)
rejoin.BackgroundColor3 = Color3.fromRGB(0,90,160)
rejoin.Text="REJOIN"
rejoin.TextColor3=Color3.new(1,1,1)
rejoin.Font=Enum.Font.SourceSansBold
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
criarSecao("TIME (BLOX FRUITS)",80,right)

local function setTeam(team)
	pcall(function()
		CommF:InvokeServer("SetTeam",team)
	end)
end

local marine = Instance.new("TextButton",right)
marine.Position = UDim2.new(0,10,0,110)
marine.Size = UDim2.new(1,-20,0,32)
marine.BackgroundColor3 = Color3.fromRGB(0,90,160)
marine.Text="ENTRAR MARINE"
marine.TextColor3=Color3.new(1,1,1)
marine.Font=Enum.Font.SourceSansBold
marine.TextSize=18
Instance.new("UICorner",marine)
marine.MouseButton1Click:Connect(function()
	setTeam("Marines")
end)

local pirate = Instance.new("TextButton",right)
pirate.Position = UDim2.new(0,10,0,150)
pirate.Size = UDim2.new(1,-20,0,32)
pirate.BackgroundColor3 = Color3.fromRGB(160,40,40)
pirate.Text="ENTRAR PIRATA"
pirate.TextColor3=Color3.new(1,1,1)
pirate.Font=Enum.Font.SourceSansBold
pirate.TextSize=18
Instance.new("UICorner",pirate)
pirate.MouseButton1Click:Connect(function()
	setTeam("Pirates")
end)
-- ================= TELEPORT =================
criarSecao("TELEPORT",190,right)

local TweenService = game:GetService("TweenService")
local currentTween = nil

local function TweenTeleport(cf)
	local root = getRoot()

	-- cancela tween antigo se existir
	if currentTween then
		currentTween:Cancel()
		currentTween = nil
	end

	local dist = (root.Position - cf.Position).Magnitude
	local speed = tpSpeed > 0 and tpSpeed or 300
	local time = dist / speed

	currentTween = TweenService:Create(
		root,
		TweenInfo.new(time, Enum.EasingStyle.Linear),
		{CFrame = cf}
	)
	currentTween:Play()
end

local function CancelTeleport()
	if currentTween then
		currentTween:Cancel()
		currentTween = nil
	end
end

-- ================= ILHAS SEA 2 =================
local TeleportIslands = {
	{nome = "Café",              cf = CFrame.new(-380, 80, 300)},
	{nome = "mansão",            cf = CFrame.new(-390, 332, 715)},
	{nome = "Green Zone",        cf = CFrame.new(-2221, 80,  -2704)},
	{nome = "Graveyard",         cf = CFrame.new(-5429, 55,  -745)},
	{nome = "Cursed Ship",       cf = CFrame.new(-6528, 90,  -162)},
	{nome = "Snow Mountain",     cf = CFrame.new(950,   440, -5181)},
	{nome = "Hot and Cold",      cf = CFrame.new(-5701, 15,  -5003)},
	{nome = "Ice Castle",        cf = CFrame.new(5589,  35,  -6354)},
	{nome = "Forgotten Island",  cf = CFrame.new(-3050, 255, -10170)},
}

local islandIndex = 1

-- ================= SELETOR DE ILHA COM SETAS =================
local islandFrame = Instance.new("Frame", right)
islandFrame.Position = UDim2.new(0,10,0,220)
islandFrame.Size = UDim2.new(1,-20,0,32)
islandFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
islandFrame.BackgroundTransparency = 0.25
islandFrame.BorderSizePixel = 0
Instance.new("UICorner", islandFrame)

-- BOTÃO <
local prevBtn = Instance.new("TextButton", islandFrame)
prevBtn.Size = UDim2.new(0,32,1,0)
prevBtn.Position = UDim2.new(0,0,0,0)
prevBtn.Text = "<"
prevBtn.Font = Enum.Font.GothamBold
prevBtn.TextSize = 22
prevBtn.TextColor3 = Color3.new(1,1,1)
prevBtn.BackgroundTransparency = 1

-- TEXTO ILHA
local islandLabel = Instance.new("TextLabel", islandFrame)
islandLabel.Size = UDim2.new(1,-64,1,0)
islandLabel.Position = UDim2.new(0,32,0,0)
islandLabel.BackgroundTransparency = 1
islandLabel.TextColor3 = Color3.new(1,1,1)
islandLabel.Font = Enum.Font.GothamBold
islandLabel.TextSize = 16
islandLabel.Text = "ILHA: "..TeleportIslands[islandIndex].nome

-- BOTÃO >
local nextBtn = Instance.new("TextButton", islandFrame)
nextBtn.Size = UDim2.new(0,32,1,0)
nextBtn.Position = UDim2.new(1,-32,0,0)
nextBtn.Text = ">"
nextBtn.Font = Enum.Font.GothamBold
nextBtn.TextSize = 22
nextBtn.TextColor3 = Color3.new(1,1,1)
nextBtn.BackgroundTransparency = 1

-- FUNÇÕES
local function atualizarIlha()
	islandLabel.Text = "ILHA: "..TeleportIslands[islandIndex].nome
end

prevBtn.MouseButton1Click:Connect(function()
	islandIndex -= 1
	if islandIndex < 1 then
		islandIndex = #TeleportIslands
	end
	atualizarIlha()
end)

nextBtn.MouseButton1Click:Connect(function()
	islandIndex += 1
	if islandIndex > #TeleportIslands then
		islandIndex = 1
	end
	atualizarIlha()
end)

-- ================= BOTÃO TELEPORTAR =================
local teleportBtn = Instance.new("TextButton", right)
teleportBtn.Position = UDim2.new(0,10,0,260)
teleportBtn.Size = UDim2.new(1,-20,0,36)
teleportBtn.BackgroundColor3 = Color3.fromRGB(0,120,180)
teleportBtn.Text = "TELEPORTAR"
teleportBtn.TextColor3 = Color3.new(1,1,1)
teleportBtn.Font = Enum.Font.SourceSansBold
teleportBtn.TextSize = 18
Instance.new("UICorner", teleportBtn)

teleportBtn.MouseButton1Click:Connect(function()
	TweenTeleport(TeleportIslands[islandIndex].cf)
end)

-- ================= BOTÃO CANCELAR =================
local cancelBtn = Instance.new("TextButton", right)
cancelBtn.Position = UDim2.new(0,10,0,302)
cancelBtn.Size = UDim2.new(1,-20,0,32)
cancelBtn.BackgroundColor3 = Color3.fromRGB(140,40,40)
cancelBtn.Text = "CANCELAR TP"
cancelBtn.TextColor3 = Color3.new(1,1,1)
cancelBtn.Font = Enum.Font.SourceSansBold
cancelBtn.TextSize = 16
Instance.new("UICorner", cancelBtn)

cancelBtn.MouseButton1Click:Connect(function()
	CancelTeleport()
end)
-- ================= AIMBOT (DEPOIS DO TELEPORT) =================
criarSecao("AIMBOT",370,right)

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

RunService.RenderStepped:Connect(function()
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
UserInputService.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.F then
		aimbotEnabled = not aimbotEnabled
		lockedPart, lockedHumanoid = nil, nil
	end
end)

criarBotaoToggle("SÓ INIMIGOS",405,right,function(v)

	aimMode = v and "ENEMIES" or "ALL"
	lockedPart = nil
end)

criarBotaoToggle("MIRA: CABEÇA",450,right,function(v)
	if v then
		aimPartMode = "HEAD"
	else
		aimPartMode = "BOTH"
	end
	lockedPart = nil
end)

criarSlider("FOV AIM",AIM_MIN_FOV,AIM_MAX_FOV,AIM_FOV_RADIUS,500,right,function(v)
	AIM_FOV_RADIUS = v
end)

-- FOV Circle (visual)
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 80
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(0,170,255)

RunService.RenderStepped:Connect(function()
	fovCircle.Visible = aimbotEnabled
	fovCircle.Radius = AIM_FOV_RADIUS
	fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

-- ================= LOOP =================
RunService.RenderStepped:Connect(function()
	local char = getChar()
	local hum = getHumanoid()
	local root = getRoot()

	if tpSpeed > 0 and hum.MoveDirection.Magnitude > 0 then
		root.CFrame += hum.MoveDirection * tpSpeed
	end

	if noclip then
		for _,v in ipairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
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

-- ================= ESP JOGADORES (INALTERADO NO VISUAL) =================
local function criarESP(plr)
	if plr == player then return end

	local function apply(char)
		local head = char:WaitForChild("Head")
		local hum = char:WaitForChild("Humanoid")
		local root = char:WaitForChild("HumanoidRootPart")

		if espObjects[plr] then espObjects[plr]:Destroy() end

		local bill = Instance.new("BillboardGui",head)
		bill.Adornee = head
		bill.Size = UDim2.new(0,200,0,80)
		bill.AlwaysOnTop = true

		local txt = Instance.new("TextLabel",bill)
		txt.Size = UDim2.new(1,0,1,0)
		txt.BackgroundTransparency = 1
		txt.TextColor3 = Color3.new(1,1,1)
		txt.TextStrokeTransparency = 0
		txt.Font = Enum.Font.SourceSansBold
		txt.TextScaled = true

		espObjects[plr] = bill

		RunService.RenderStepped:Connect(function()
			if not char or hum.Health <= 0 then return end

			if espOnlyEnemies and plr.Team == player.Team then
				bill.Enabled = false
				return
			end

			bill.Enabled = true
			local dist = math.floor((getRoot().Position - root.Position).Magnitude)
			local level = plr:FindFirstChild("Data")
				and plr.Data:FindFirstChild("Level")
				and plr.Data.Level.Value or "?"

			txt.Text = plr.Name..
				"\nHP: "..math.floor(hum.Health)..
				"\nLVL: "..level..
				"\nDist: "..dist.."m"
		end)
	end

	if plr.Character then apply(plr.Character) end
	plr.CharacterAdded:Connect(apply)
end

for _,p in ipairs(Players:GetPlayers()) do
	criarESP(p)
end
Players.PlayerAdded:Connect(criarESP)


-- ================= TOGGLE MENU =================
UserInputService.InputBegan:Connect(function(i,gp)
	if not gp and i.KeyCode == Enum.KeyCode.G then
		frame.Visible = not frame.Visible
	end
end)

-- ================= TIRAR FOG =================


local Lighting = game:GetService("Lighting")

-- Neblina clássica
Lighting.FogStart = 1000000
Lighting.FogEnd = 10000000
Lighting.FogColor = Color3.fromRGB(255, 255, 255)

for _, v in pairs(Lighting:GetChildren()) do
    if v:IsA("Atmosphere") then
        v:Destroy()
    end
end

Lighting.Brightness = 2
Lighting.GlobalShadows = true
Lighting.ExposureCompensation = 0
Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)

-- ================= ZOOM =================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function aplicarZoom()
	player.CameraMinZoomDistance = 0.5
	player.CameraMaxZoomDistance = 1000
	Camera.CameraType = Enum.CameraType.Custom

	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.CameraOffset = Vector3.new(0, 0, 0)
		end
	end
end

aplicarZoom()

player.CharacterAdded:Connect(function()
	task.wait(1)
	aplicarZoom()
end)

-- ================= FLY TELEPORT =================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local flying = false
local speed = 3

local keys = {
	W=false, A=false, S=false, D=false,
	Space=false, Ctrl=false
}

local function getFlyRoot()
	return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

-- ================= INPUT =================
UserInputService.InputBegan:Connect(function(i, gp)
	if gp then return end

	-- ALT pressionado
	if i.KeyCode == Enum.KeyCode.LeftAlt or i.KeyCode == Enum.KeyCode.RightAlt then
		altPressed = true
	end

	-- ALT + CLICK ESQUERDO
	if altPressed and i.UserInputType == Enum.UserInputType.MouseButton1 then
		flying = not flying
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

UserInputService.InputEnded:Connect(function(i)
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
RunService.RenderStepped:Connect(function()
	if not flying then return end

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

-- ================= SEGURANÇA AO MORRER =================
player.CharacterAdded:Connect(function(char)
	task.wait(1)
	local root = char:FindFirstChild("HumanoidRootPart")
	if root then
		root.Anchored = false
	end
	flying = false
end)
-- inicia o key system
pedirKey()
