repeat task.wait() until game:IsLoaded()

local player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local FILE_NAME = "bounty_tracker.txt"

local today = 0
local lastChange = 0
local lastBounty = 0
local lastResetDay = os.date("%d")
local isStabilizing = false

-- LOAD
pcall(function()
	if isfile and isfile(FILE_NAME) then
		local data = readfile(FILE_NAME)
		local tdy, day = string.match(data, "(-?%d+)|(%d+)")
		if tdy then today = tonumber(tdy) end
		if day then lastResetDay = tonumber(day) end
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

-- ================= UI FINAL CLEAN =================
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

-- =================================================================
-- << MELHORIA >> NOVO MOTOR DE ANIMAÇÃO COM "BOUNCE" (MOLA)
-- =================================================================

-- Variáveis de controle da animação
local targetToday = today      -- O valor que queremos alcançar
local displayToday = today     -- O valor que está sendo mostrado na tela
local todayVelocity = 0        -- A "velocidade" da animação do número

-- Configurações da física da mola (ajuste para mudar o efeito)
local SPRING_TENSION = 0.1   -- Quão "forte" a mola é. (Valores maiores = mais rápido)
local SPRING_DAMPING = 0.82  -- Amortecimento. (Valores menores = mais "saltitante")

-- Loop de animação contínuo (roda a cada frame)
RunService.RenderStepped:Connect(function(dt)
    -- Calcula a diferença entre o alvo e o valor atual
    local force = targetToday - displayToday
    
    -- Se estivermos perto o suficiente e quase parados, trava no valor final para evitar tremer
    if math.abs(force) < 0.1 and math.abs(todayVelocity) < 0.1 then
        displayToday = targetToday
        todayVelocity = 0
    else
        -- Aplica a física da mola para criar o efeito de "bounce"
        todayVelocity = (todayVelocity * SPRING_DAMPING) + (force * SPRING_TENSION)
        displayToday += todayVelocity * dt * 60 -- Multiplica por dt para ser independente de FPS
    end

    -- Atualiza o texto da UI a cada frame
    if today >= 0 then
        todayText.TextColor3 = Color3.fromRGB(0,255,120) -- Verde
    else
        todayText.TextColor3 = Color3.fromRGB(255,70,70) -- Vermelho
    end
    todayText.Text = "Hoje: " .. format(displayToday)
end)


-- =================================================================
-- LOOP DE LÓGICA PRINCIPAL (SEPARADO DA ANIMAÇÃO)
-- =================================================================

task.spawn(function()
	while task.wait(1) do
		-- Pula se estiver estabilizando (respawn/teleporte)
		if isStabilizing then
			lastBounty = bountyStat.Value -- Mantém sincronizado
			continue 
		end

		local current = bountyStat.Value
		local diff = current - lastBounty

		-- Só conta se a mudança for razoável (evita bugs de reset)
		if diff ~= 0 and math.abs(diff) < 500000 then
			lastChange = diff
			today += diff
			
			targetToday = today -- << MELHORIA >> Apenas atualiza o ALVO da animação
			
			saveData()
		end

		-- Reset diário
		local currentDay = tonumber(os.date("%d"))
		if currentDay ~= lastResetDay then
			today = 0
			lastChange = 0
			lastResetDay = currentDay
			
			targetToday = today -- << MELHORIA >> Atualiza o ALVO para zero
			
			saveData()
		end

		-- Atualiza o texto "Último"
		lastText.Text = "Último: " .. format(lastChange)

		-- Sincroniza o bounty para a próxima verificação
		lastBounty = current
	end
end)
