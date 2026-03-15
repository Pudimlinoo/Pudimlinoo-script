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

	Main = Color3.fromRGB(18,18,18),       -- fundo principal
	Second = Color3.fromRGB(25,25,25),     -- fundo interno
	Button = Color3.fromRGB(35,35,35),     -- botão neutro
	
	Red = Color3.fromRGB(200,40,40),       -- vermelho principal
	DarkRed = Color3.fromRGB(140,25,25),   -- vermelho escuro
	
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

-- ================= GUI =================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "ModMenu"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,460,0,430)
frame.Position = UDim2.new(0.03,0,0.35,0)
frame.BackgroundColor3 = Theme.Main
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke",frame)
stroke.Color = Theme.Red
stroke.Thickness = 1.5

-- ================= ANIMAÇÃO DE ABERTURA =================
local TweenService = game:GetService("TweenService")

-- estado inicial (invisível)
frame.Size = UDim2.new(0,0,0,0)
frame.BackgroundTransparency = 1
frame.Visible = true



local openTween = TweenService:Create(
	frame,
	TweenInfo.new(
		0.45, -- duração
		Enum.EasingStyle.Back, -- efeito elástico
		Enum.EasingDirection.Out
	),
	{
		Size = OPEN_SIZE,
		BackgroundTransparency = OPEN_TRANSP
	}
)

openTween:Play()
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
-- ================= SIDEBAR =================

local sidebar = Instance.new("Frame",frame)
sidebar.Size = UDim2.new(0,120,1,-40)
sidebar.Position = UDim2.new(0,0,0,40)
sidebar.BackgroundColor3 = Theme.Second
sidebar.BorderSizePixel = 0

Instance.new("UICorner",sidebar)

-- ================= CONTAINER =================

local container = Instance.new("Frame",frame)
container.Size = UDim2.new(1,-130,1,-45)
container.Position = UDim2.new(0,125,0,40)
container.BackgroundTransparency = 1

local tabs = {}
local currentTab

local function createTab(name)

	local btn = Instance.new("TextButton",sidebar)
	btn.Size = UDim2.new(1,-10,0,36)
	btn.Position = UDim2.new(0,5,0,#tabs*40+10)
	btn.BackgroundColor3 = Theme.Button
	btn.Text = name
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Theme.Text
	btn.TextSize = 16

	Instance.new("UICorner",btn)

	local page = Instance.new("ScrollingFrame",container)
	page.Size = UDim2.new(1,0,1,0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = Theme.Red
	page.BackgroundTransparency = 1
	page.Visible = false
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page
	btn.MouseButton1Click:Connect(function()

		for _,v in pairs(container:GetChildren()) do
			if v:IsA("ScrollingFrame") then
				v.Visible = false
			end
		end

		page.Visible = true
		currentTab = page

	end)

	table.insert(tabs,page)

	if not currentTab then
		page.Visible = true
		currentTab = page
	end

	return page
end

local tabPlayer = createTab("PLAYER")
local tabFarm = createTab("Auto-Farm")
local tabESP = createTab("ESP")
local tabTeleport = createTab("TELEPORT")
local tabAimbot = createTab("AIMBOT")
local tabSistema = createTab("SISTEMA")


-- ================= UI HELPERS =================
local function criarSecao(txt,y,p)

	local l = Instance.new("TextLabel",p)
	l.Size = UDim2.new(1,-10,0,24)
	l.Position = UDim2.new(0,5,0,y)

	l.BackgroundTransparency = 1
	l.Text = txt

	l.TextColor3 = Theme.Red
	l.Font = Enum.Font.GothamBold
	l.TextSize = 18
	l.TextXAlignment = Enum.TextXAlignment.Left

end

local function criarBotaoToggle(txt,y,p,cb)

	local frame = Instance.new("Frame",p)
	frame.Position = UDim2.new(0,10,0,y)
	frame.Size = UDim2.new(1,-20,0,32)
	frame.BackgroundTransparency = 1

	local label = Instance.new("TextLabel",frame)
	label.Size = UDim2.new(0.7,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = txt
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Theme.Text
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left

	local toggle = Instance.new("Frame",frame)
	toggle.Size = UDim2.new(0,46,0,22)
	toggle.Position = UDim2.new(1,-46,0.5,-11)
	toggle.BackgroundColor3 = Theme.Button

	Instance.new("UICorner",toggle)

	local circle = Instance.new("Frame",toggle)
	circle.Size = UDim2.new(0,18,0,18)
	circle.Position = UDim2.new(0,2,0.5,-9)
	circle.BackgroundColor3 = Color3.new(1,1,1)

	Instance.new("UICorner",circle)

	local state = false

	toggle.InputBegan:Connect(function(i)

		if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

		state = not state

		if state then

			toggle.BackgroundColor3 = Theme.Red

			TweenService:Create(circle,
				TweenInfo.new(0.2),
				{Position = UDim2.new(1,-20,0.5,-9)}
			):Play()

		else

			toggle.BackgroundColor3 = Theme.Button

			TweenService:Create(circle,
				TweenInfo.new(0.2),
				{Position = UDim2.new(0,2,0.5,-9)}
			):Play()

		end

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
	bar.BackgroundColor3 = Theme.Second
	Instance.new("UICorner",bar)

	local fill = Instance.new("Frame",bar)
	fill.Size = UDim2.new((init-min)/(max-min),0,1,0)
	fill.BackgroundColor3 = Theme.Red
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
local ESPAtivo = false
-- ESP FRUTAS
local fruitESPEnabled = false
local fruitEspObjects = {}

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

	if fruitEspObjects[tool] then return end

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

criarSlider("Pulo",25,500,50,150,tabPlayer,function(v)
	getHumanoid().JumpPower = v
end)

criarSlider("Velocidade TP",0,10,0,220,tabPlayer,function(v)
	tpSpeed = v
end)

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
end)

-- ================= SISTEMA =================
criarSecao("SISTEMA",0,tabSistema)

local rejoin = Instance.new("TextButton",tabSistema)
rejoin.Position = UDim2.new(0,10,0,30)
rejoin.Size = UDim2.new(1,-20,0,32)
rejoin.BackgroundColor3 = Theme.Red
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
marine.Font=Enum.Font.SourceSansBold
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
pirate.Font=Enum.Font.SourceSansBold
pirate.TextSize=18
Instance.new("UICorner",pirate)
pirate.MouseButton1Click:Connect(function()
	setTeam("Pirates")
end)
-- ================= TELEPORT =================
criarSecao("TELEPORT",190,tabTeleport)


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

local dropdownOpen = false

local dropdownBtn = Instance.new("TextButton", tabTeleport)
dropdownBtn.Position = UDim2.new(0,10,0,220)
dropdownBtn.Size = UDim2.new(1,-20,0,36)
dropdownBtn.BackgroundColor3 = Theme.Button
dropdownBtn.Text = "ESCOLHER ILHA ▼"
dropdownBtn.TextColor3 = Theme.Text
dropdownBtn.Font = Enum.Font.GothamBold
dropdownBtn.TextSize = 16
Instance.new("UICorner", dropdownBtn)

local dropdownFrame = Instance.new("Frame", tabTeleport)
dropdownFrame.Position = UDim2.new(0,10,0,260)
dropdownFrame.Size = UDim2.new(1,-20,0,0)
dropdownFrame.BackgroundTransparency = 1
dropdownFrame.ClipsDescendants = true

local function createTPButton(name, cf, index)

	local btn = Instance.new("TextButton", dropdownFrame)
	btn.Size = UDim2.new(1,0,0,32)
	btn.Position = UDim2.new(0,0,0,(index-1)*34)
	btn.BackgroundColor3 = Theme.Button
	btn.Text = name
	btn.TextColor3 = Theme.Text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 15

	Instance.new("UICorner",btn)

	btn.MouseButton1Click:Connect(function()
		TweenTeleport(cf)
	end)

end

for i,island in pairs(TeleportIslands) do
	createTPButton(island.nome,island.cf,i)
end

dropdownBtn.MouseButton1Click:Connect(function()

	dropdownOpen = not dropdownOpen

	if dropdownOpen then

		local size = #TeleportIslands * 34

		TweenService:Create(
			dropdownFrame,
			TweenInfo.new(0.25),
			{Size = UDim2.new(1,-20,0,size)}
		):Play()

		dropdownBtn.Text = "ESCOLHER ILHA ▲"

	else

		TweenService:Create(
			dropdownFrame,
			TweenInfo.new(0.25),
			{Size = UDim2.new(1,-20,0,0)}
		):Play()

		dropdownBtn.Text = "ESCOLHER ILHA ▼"

	end

end)

-- ================= BOTÃO CANCELAR =================
local cancelBtn = Instance.new("TextButton", tabTeleport)
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
-- FOV Circle (visual)
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 80
fovCircle.Filled = false
fovCircle.Color = Theme.Red

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



-- ================= AUTO FARM =================

if autoFarmEnabled then

	if not farmTarget or not farmTarget.Parent then
		farmTarget = getClosestEnemy()
	end

	if farmTarget then

		local root = getRoot()
		local npcRoot = farmTarget:FindFirstChild("HumanoidRootPart")
		local hum = farmTarget:FindFirstChild("Humanoid")

if npcRoot and hum and hum.Health > 0 then

	

	root.CFrame = CFrame.new(
	npcRoot.Position + Vector3.new(0,farmHeight,farmDistance),
	npcRoot.Position
)

			if not attacking then
				attacking = true

				task.spawn(function()

while autoFarmEnabled and hum.Health > 0 do

	if fastAttackEnabled then

		for i = 1,12 do
			mouse1click()
		end

	end

	task.wait()

end

					attacking = false

				end)

			end

		else
			farmTarget = nil
		end

	end

end

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

RunService.RenderStepped:Connect(function()

	if not fruitESPEnabled then
		for _,v in pairs(fruitEspObjects) do
			v.gui.Enabled = false
		end
		return
	end

	local root = getRoot()
	if not root then return end

	for tool,data in pairs(fruitEspObjects) do

		if not tool.Parent then
			data.gui.Enabled = false
			continue
		end

		data.gui.Enabled = true

		local fruitName = tool.Name:gsub(" Fruit","")
		local rarity = FruitRarity[fruitName] or "Common"

		data.label.TextColor3 = RarityColors[rarity]

		local dist = math.floor((root.Position - data.part.Position).Magnitude)

		data.label.Text =
			fruitName..
			"\n📏 "..dist.."m"..
			"\n💎 "..rarity

	end

end)

task.spawn(function()

	while true do
		task.wait(3)

		for _,v in pairs(workspace:GetDescendants()) do
			if v:IsA("Tool") and v.Name:find("Fruit") then
				createFruitESP(v)
			end
		end

	end

end)

local function scanFruits()

	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Tool") and v.Name:find("Fruit") then
			createFruitESP(v)
		end
	end

end

scanFruits()

workspace.DescendantAdded:Connect(function(v)

	if v:IsA("Tool") and v.Name:find("Fruit") then
		task.wait(0.5)
		createFruitESP(v)
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
		txt.TextScaled = false
txt.TextSize = 14

		espObjects[plr] = bill

RunService.RenderStepped:Connect(function()

	if not ESPAtivo then
		bill.Enabled = false
		return
	end

	if not char or hum.Health <= 0 then
		bill.Enabled = false
		return
	end

	local sameTeam = false

	if player.Team and plr.Team then
		sameTeam = player.Team == plr.Team
	elseif player.TeamColor and plr.TeamColor then
		sameTeam = player.TeamColor == plr.TeamColor
	end

	-- modo só inimigos
	if espOnlyEnemies and sameTeam then
		bill.Enabled = false
		return
	end

	bill.Enabled = true

	-- cores por time
	if sameTeam then
		txt.TextColor3 = Color3.fromRGB(0,170,255) -- seu time
	else
		txt.TextColor3 = Color3.fromRGB(255,70,70) -- inimigo
	end

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

-- ================= TOGGLE MENU ANIMADO NO G & BOTÃO MOBILE =================

local menuOpen = true
local busy = false

local OPEN_SIZE = UDim2.new(0,460,0,460)
local CLOSED_SIZE = UDim2.new(0,0,0,0)

local OPEN_TRANSP = 0.15
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
UserInputService.InputBegan:Connect(function(input, gp)
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

-- ================= CRIANDO O BOTÃO MOBILE PREMIUM =================

-- 1. Base do Botão (Agora Menor: 42x42)
local mobileBtn = Instance.new("TextButton", gui)
mobileBtn.Size = UDim2.new(0, 42, 0, 42)
mobileBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
mobileBtn.BackgroundTransparency = 1
mobileBtn.Text = ""

-- 2. Visual do Botão (Onde ficam as cores)
local btnVisual = Instance.new("Frame", mobileBtn)
btnVisual.Size = UDim2.new(1, 0, 1, 0)
btnVisual.AnchorPoint = Vector2.new(0.5, 0.5)
btnVisual.Position = UDim2.new(0.5, 0, 0.5, 0)
btnVisual.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", btnVisual).CornerRadius = UDim.new(1, 0)

-- Gradiente (Preto para Vermelho Escuro)
local gradiente = Instance.new("UIGradient", btnVisual)
gradiente.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Theme.Second),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 15, 15)) -- Fundo vermelho escuro
})
gradiente.Rotation = 45

-- Borda Externa (Vermelho Vivo)
local btnStroke = Instance.new("UIStroke", btnVisual)
btnStroke.Color = Theme.Red
btnStroke.Thickness = 2.5

-- 3. Anel Interno (Ajustado para o botão menor)
local anelInterno = Instance.new("Frame", btnVisual)
anelInterno.Size = UDim2.new(1, -6, 1, -6)
anelInterno.AnchorPoint = Vector2.new(0.5, 0.5)
anelInterno.Position = UDim2.new(0.5, 0, 0.5, 0)
anelInterno.BackgroundTransparency = 1
Instance.new("UICorner", anelInterno).CornerRadius = UDim.new(1, 0)
local anelStroke = Instance.new("UIStroke", anelInterno)
anelStroke.Color = Color3.fromRGB(255, 100, 100)
anelStroke.Thickness = 1
anelStroke.Transparency = 0.5

-- 4. Ícone do Pudim (Texto Menor)
local iconeLabel = Instance.new("TextLabel", btnVisual)
iconeLabel.Size = UDim2.new(1, 0, 1, 0)
iconeLabel.BackgroundTransparency = 1
iconeLabel.Text = "🍮"
iconeLabel.TextSize = 20

-- 5. Brilho Vermelho (Sombra menor também)
local glowShadow = Instance.new("ImageLabel", btnVisual)
glowShadow.AnchorPoint = Vector2.new(0.5, 0.5)
glowShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
glowShadow.Size = UDim2.new(1, 35, 1, 35) -- Brilho proporcional
glowShadow.Image = "rbxassetid://1316045217"
glowShadow.ImageColor3 = Theme.Red 
glowShadow.ImageTransparency = 0.4
glowShadow.BackgroundTransparency = 1
glowShadow.ZIndex = -1

-- Animação e Função de Clique do Botão
mobileBtn.MouseButton1Click:Connect(function()
	if busy then return end
	busy = true
	
	-- Efeito de clique Animado (Usa escala relativa para não bugar o tamanho menor)
	TweenService:Create(btnVisual, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.8, 0, 0.8, 0),
		Rotation = -15
	}):Play()
	task.wait(0.15)
	TweenService:Create(btnVisual, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0),
		Rotation = 0
	}):Play()

	if menuOpen then
		-- Fechando o Menu (Fica mais escuro)
		tweenClose:Play()
		TweenService:Create(btnStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(80, 80, 80)}):Play()
		TweenService:Create(glowShadow, TweenInfo.new(0.3), {ImageTransparency = 0.8, ImageColor3 = Color3.fromRGB(0,0,0)}):Play()
		
		tweenClose.Completed:Wait()
		frame.Visible = false
		menuOpen = false
	else
		-- Abrindo o Menu (Brilho e Borda vermelhos)
		frame.Visible = true
		TweenService:Create(btnStroke, TweenInfo.new(0.3), {Color = Theme.Red}):Play()
		TweenService:Create(glowShadow, TweenInfo.new(0.3), {ImageTransparency = 0.4, ImageColor3 = Theme.Red}):Play()
		
		tweenOpen:Play()
		menuOpen = true
	end

	task.wait(0.05)
	busy = false
end)

-- Sistema para Arrastar o Botão (Draggable)
local draggingBtn, dragInputBtn, dragStartBtn, startPosBtn
mobileBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingBtn = true
		dragStartBtn = input.Position
		startPosBtn = mobileBtn.Position
		
		-- Botão "incha" de leve quando você segura para arrastar
		TweenService:Create(btnVisual, TweenInfo.new(0.2), {Size = UDim2.new(1.15, 0, 1.15, 0)}):Play()
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
		
		-- Volta ao tamanho original ao soltar
		TweenService:Create(btnVisual, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 1, 0)}):Play()
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

player.CharacterAdded:Connect(function(char)
	task.wait(1)
	local root = char:FindFirstChild("HumanoidRootPart")
	if root then
		root.Anchored = false
	end
	flying = false
end)
