repeat task.wait() until game:IsLoaded()

local player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- [[ MELHORIA ]] Novo nome de arquivo para o novo formato de dados
local FILE_NAME = "bounty_tracker_.txt"

-- [[ MELHORIA ]] Nova variável para o contador de kills
local today = 0
local killsToday = 0
local lastChange = 0
local lastBounty = 0
local lastResetDay = os.date("%d")
local isStabilizing = false

-- LOAD (com suporte para kills)
pcall(function()
	if isfile and isfile(FILE_NAME) then
		local data = readfile(FILE_NAME)
		-- [[ MELHORIA ]] Padrão de busca atualizado para incluir kills
		local tdy, kls, day = string.match(data, "(-?%d+)|(-?%d+)|(%d+)")
		if tdy then today = tonumber(tdy) end
		if kls then killsToday = tonumber(kls) end
		if day then lastResetDay = tonumber(day) end
	end
end)

-- SAVE (com suporte para kills)
local function saveData()
	pcall(function()
		if writefile then
			-- [[ MELHORIA ]] Salva o bounty E os kills
			writefile(FILE_NAME, today.."|"..killsToday.."|"..os.date("%d"))
		end
	end)
end

-- ESPERAR E ENCONTRAR STATS
repeat task.wait() until player and player:FindFirstChild("leaderstats")
local stats = player.leaderstats

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
	warn("❌ Bounty Tracker: Não encontrou stats de bounty/honor.")
	return
end

lastBounty = bountyStat.Value

-- Proteção contra respawn/teleporte
player.CharacterAdded:Connect(function()
	isStabilizing = true
	task.wait(3) -- Espera 3 segundos para o bounty carregar
	lastBounty = bountyStat.Value
	isStabilizing = false
end)

-- FORMAT
local function format(n)
    local num = math.floor(math.abs(n) + 0.5)
	local sign = n >= 0 and "+" or "-"
	return sign .. tostring(num):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- ================= UI (sem mudanças visuais, apenas o texto será atualizado) =================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "BountyTrackerGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 85)
frame.Position = UDim2.new(1, -260, 1, -105)
frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255,60,60)
stroke.Thickness = 1.2

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,20)
title.BackgroundTransparency = 1
title.Text = "🍮 Bounty Tracker"
title.TextColor3 = Color3.fromRGB(180,180,180)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Center
title.Position = UDim2.new(0,0,0,2)

local todayText = Instance.new("TextLabel", frame)
todayText.Position = UDim2.new(0,0,0,22)
todayText.Size = UDim2.new(1,0,0,30)
todayText.BackgroundTransparency = 1
todayText.Font = Enum.Font.GothamBlack
todayText.TextSize = 22
todayText.TextXAlignment = Enum.TextXAlignment.Center
todayText.TextColor3 = Color3.fromRGB(0,255,120)

local lastText = Instance.new("TextLabel", frame)
lastText.Position = UDim2.new(0,0,0,52)
lastText.Size = UDim2.new(1,0,0,20)
lastText.BackgroundTransparency = 1
lastText.TextColor3 = Color3.fromRGB(200,200,200)
lastText.Font = Enum.Font.Gotham
lastText.TextSize = 13
lastText.TextXAlignment = Enum.TextXAlignment.Center


-- Motor de Animação (sem mudanças)
local targetToday = today
local displayToday = today
local todayVelocity = 0
local SPRING_TENSION = 0.1
local SPRING_DAMPING = 0.82

RunService.RenderStepped:Connect(function(dt)
    local force = targetToday - displayToday
    if math.abs(force) < 0.1 and math.abs(todayVelocity) < 0.1 then
        displayToday = targetToday
        todayVelocity = 0
    else
        todayVelocity = (todayVelocity * SPRING_DAMPING) + (force * SPRING_TENSION)
        displayToday += todayVelocity * dt * 60
    end

    if today >= 0 then
        todayText.TextColor3 = Color3.fromRGB(0,255,120)
    else
        todayText.TextColor3 = Color3.fromRGB(255,70,70)
    end
    todayText.Text = "Hoje: " .. format(displayToday)
end)


-- =================================================================
-- LOOP DE LÓGICA PRINCIPAL (COM CONTAGEM DE KILLS)
-- =================================================================

task.spawn(function()
	while task.wait(1) do
		if isStabilizing then
			lastBounty = bountyStat.Value
			continue 
		end

		local current = bountyStat.Value
		local diff = current - lastBounty

		if diff ~= 0 and math.abs(diff) < 500000 then
			lastChange = diff
			today += diff
			
			-- [[ MELHORIA ]] Se o bounty AUMENTOU, conta como uma kill
			if diff > 0 then
				killsToday = killsToday + 1
			end
			
			targetToday = today
			saveData()
		end

		-- Reset diário
		local currentDay = tonumber(os.date("%d"))
		if currentDay ~= lastResetDay then
			today = 0
			lastChange = 0
			killsToday = 0 -- << MELHORIA >> Zera os kills também
			lastResetDay = currentDay
			
			targetToday = today
			saveData()
		end

		-- [[ MELHORIA ]] Atualiza o texto para incluir os kills
		lastText.Text = "Último: " .. format(lastChange) .. " | Kills: " .. killsToday

		lastBounty = current
	end
end)
