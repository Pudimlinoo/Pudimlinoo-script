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
