repeat task.wait() until game:IsLoaded()

local player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local FILE_NAME = "bounty_tracker.txt"

local today = 0
local lastChange = 0
local lastBounty = 0
local lastResetDay = os.date("%d")
local isStabilizing = false -- << NOVO: Controle de estabilização

-- LOAD
pcall(function()
	if isfile and isfile(FILE_NAME) then
		local data = readfile(FILE_NAME)
		local tdy, day = string.match(data, "(-?%d+)|(%d+)")
		
		if tdy then today = tonumber(tdy) end
		if day then lastResetDay = day end
	end
end)

-- SAVE
local function saveData()
	pcall(function()
		if writefile then
			writefile(FILE_NAME, today.."|"..os.date("%d"))
		end
	end)
end

-- ESPERAR
repeat task.wait() until player
repeat task.wait() until player:FindFirstChild("leaderstats")

local stats = player.leaderstats

-- DETECTAR BOUNTY
local bountyStat
for _,v in pairs(stats:GetChildren()) do
	if v:IsA("IntValue") or v:IsA("NumberValue") then
		if string.find(v.Name:lower(), "bounty") or string.find(v.Name:lower(), "honor") then
			bountyStat = v
			break
		end
	end
end

if not bountyStat then
	warn("❌ Não encontrou bounty")
	return
end

lastBounty = bountyStat.Value

-- << NOVO: Proteção contra respawn/teleporte >>
player.CharacterAdded:Connect(function()
	isStabilizing = true
	task.wait(3) -- Espera 3 segundos para o bounty carregar
	lastBounty = bountyStat.Value -- Sincroniza com o valor real
	isStabilizing = false
end)

-- FORMAT
local function format(n)
	local sign = n >= 0 and "+" or "-"
	n = math.abs(n)
	return sign .. tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- ================= UI FINAL CLEAN =================
local gui = Instance.new("ScreenGui", CoreGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 85)
frame.Position = UDim2.new(1, -260, 1, -105)
frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

-- 🔴 BORDA
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255,60,60)
stroke.Thickness = 1.2

-- 🧭 TÍTULO
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,20)
title.BackgroundTransparency = 1
title.Text = "🍮 Bounty Tracker"
title.TextColor3 = Color3.fromRGB(180,180,180)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Center
title.Position = UDim2.new(0,0,0,2)

-- 🟢 HOJE CENTRALIZADO
local todayText = Instance.new("TextLabel", frame)
todayText.Position = UDim2.new(0,0,0,22)
todayText.Size = UDim2.new(1,0,0,30)
todayText.BackgroundTransparency = 1
todayText.Font = Enum.Font.GothamBlack
todayText.TextSize = 22
todayText.TextXAlignment = Enum.TextXAlignment.Center
todayText.TextColor3 = Color3.fromRGB(0,255,120)

-- ⚪ ÚLTIMO CENTRALIZADO
local lastText = Instance.new("TextLabel", frame)
lastText.Position = UDim2.new(0,0,0,52)
lastText.Size = UDim2.new(1,0,0,20)
lastText.BackgroundTransparency = 1
lastText.TextColor3 = Color3.fromRGB(200,200,200)
lastText.Font = Enum.Font.Gotham
lastText.TextSize = 13
lastText.TextXAlignment = Enum.TextXAlignment.Center

-- ================= ANIMAÇÃO DO HOJE =================
local displayToday = today

local function animateToday(target)
	task.spawn(function()
		while math.floor(displayToday) ~= math.floor(target) do
			local diff = target - displayToday
			displayToday += diff * 0.15
			
			if math.abs(diff) < 1 then
				displayToday = target
			end
			
			task.wait(0.03)
		end
	end)
end

-- LOOP
task.spawn(function()
	while true do
		task.wait(1)

		-- << NOVO: Pula se estiver estabilizando (respawn/teleporte) >>
		if isStabilizing then
			lastBounty = bountyStat.Value -- Mantém sincronizado
			continue 
		end

		local current = bountyStat.Value
		local diff = current - lastBounty

		-- << NOVO: Só conta se a mudança for razoável (menor que 500k) >>
		if diff ~= 0 and math.abs(diff) < 500000 then
			lastChange = diff
			today += diff
			saveData()
			animateToday(today)
		end

		-- reset diário
		local currentDay = os.date("%d")
		if currentDay ~= lastResetDay then
			today = 0
			lastResetDay = currentDay
			saveData()
			animateToday(today)
		end

		-- 🔥 COR DINÂMICA
		if today >= 0 then
			todayText.TextColor3 = Color3.fromRGB(0,255,120)
		else
			todayText.TextColor3 = Color3.fromRGB(255,70,70)
		end

		todayText.Text = "Hoje: "..format(displayToday)
		lastText.Text = "Último: "..format(lastChange)

		lastBounty = current
	end
end)
