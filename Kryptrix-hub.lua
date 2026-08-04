-- Anti‑Lag Mobility GUI (Speed 65, Infinite Jump, NoClip, Low Graphics)
-- Draggable, closable/reopen with N, all toggles persist across respawns.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- ---------- GUI Creation ----------
local gui = Instance.new("ScreenGui")
gui.Name = "AntiLagGUI"
gui.ResetOnSpawn = false

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 280)
frame.Position = UDim2.new(0.5, -150, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
frame.Parent = gui

-- Shadow
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045756"
shadow.ImageColor3 = Color3.new(0,0,0)
shadow.ImageTransparency = 0.6
shadow.Parent = frame

-- ---------- Title Bar (draggable) ----------
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
titleBar.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ Anti‑Lag Controls"
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -36, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BackgroundTransparency = 0.2
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
closeBtn.Parent = titleBar

-- ---------- Toggle Buttons ----------
local function createToggle(text, yPos, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 130, 0, 40)
	btn.Position = UDim2.new(0.5, -145, 0, yPos)
	btn.BackgroundColor3 = color
	btn.BackgroundTransparency = 0.3
	btn.BorderSizePixel = 0
	btn.Text = text .. ": OFF"
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.TextSize = 15
	btn.Font = Enum.Font.GothamSemibold
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	btn.Parent = frame
	return btn
end

local speedBtn   = createToggle("Speed 65", 50, Color3.fromRGB(70, 120, 200))
local jumpBtn    = createToggle("Infinite Jump", 105, Color3.fromRGB(70, 120, 200))
local noclipBtn  = createToggle("NoClip", 160, Color3.fromRGB(70, 120, 200))
local perfBtn    = createToggle("Low Graphics", 215, Color3.fromRGB(200, 150, 50))

-- Adjust second column? We'll keep them stacked for simplicity.

-- ---------- GUI Visibility ----------
local guiVisible = true
local function toggleGUI(visible)
	gui.Enabled = visible
	guiVisible = visible
end

closeBtn.MouseButton1Click:Connect(function()
	toggleGUI(false)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.N and not guiVisible then
		toggleGUI(true)
	end
end)

-- ---------- Dragging Logic ----------
local dragData = { dragging = false, startPos = nil, startMouse = nil }

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragData.dragging = true
		dragData.startPos = frame.Position
		dragData.startMouse = input.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragData.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragData.startMouse
		frame.Position = UDim2.new(
			dragData.startPos.X.Scale,
			dragData.startPos.X.Offset + delta.X,
			dragData.startPos.Y.Scale,
			dragData.startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragData.dragging = false
	end
end)

-- ---------- State ----------
local state = {
	speed = false,
	jump = false,
	noclip = false,
	perf = false,
}

-- ---------- Core Functions ----------
local function updateSpeed(humanoid)
	if not humanoid then return end
	if state.speed then
		humanoid.WalkSpeed = 65
	else
		humanoid.WalkSpeed = 16
	end
end

local function applyNoClip(character, enable)
	if not character then return end
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = not enable
		end
	end
end

local function applyPerformance(enable)
	if enable then
		-- Lowest graphics, shadows off, low textures
		game:GetService("UserSettings"):GetService("UserGameSettings").GraphicsQualityLevel = 1
		Lighting.GlobalShadows = false
		Lighting.ClockTime = 12
		Lighting.FogEnd = 500
		Lighting.FogStart = 0
	else
		-- Reset to medium (adjust as needed)
		game:GetService("UserSettings"):GetService("UserGameSettings").GraphicsQualityLevel = 3
		Lighting.GlobalShadows = true
		Lighting.ClockTime = 14
		Lighting.FogEnd = 1000
		Lighting.FogStart = 100
	end
end

-- Apply all settings to a character
local function applyAll(character)
	if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	-- Speed
	updateSpeed(humanoid)
	-- Watch for speed changes
	humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if state.speed and humanoid.WalkSpeed ~= 65 then
			humanoid.WalkSpeed = 65
		end
	end)
	-- NoClip
	applyNoClip(character, state.noclip)
	-- Infinite jump is handled in loop
end

-- ---------- Character Respawn ----------
local function onCharacterAdded(character)
	character:WaitForChild("Humanoid")
	applyAll(character)
	-- Watch for new parts for noclip
	character.DescendantAdded:Connect(function(desc)
		if state.noclip and desc:IsA("BasePart") then
			desc.CanCollide = false
		end
	end)
end

if player.Character then
	onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- ---------- Main Loop (Infinite Jump) ----------
RunService.Heartbeat:Connect(function()
	if not state.jump then return end
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChild("Humanoid")
	if not humanoid then return end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) and humanoid:GetState() == Enum.HumanoidStateType.Landed then
		humanoid.Jump = true
	end
end)

-- ---------- Toggle Functions ----------
local function toggleSpeed()
	state.speed = not state.speed
	speedBtn.Text = "Speed 65: " .. (state.speed and "ON" or "OFF")
	speedBtn.BackgroundColor3 = state.speed and Color3.fromRGB(70, 200, 70) or Color3.fromRGB(70, 120, 200)
	updateSpeed(player.Character and player.Character:FindFirstChild("Humanoid"))
end

local function toggleJump()
	state.jump = not state.jump
	jumpBtn.Text = "Infinite Jump: " .. (state.jump and "ON" or "OFF")
	jumpBtn.BackgroundColor3 = state.jump and Color3.fromRGB(70, 200, 70) or Color3.fromRGB(70, 120, 200)
end

local function toggleNoclip()
	state.noclip = not state.noclip
	noclipBtn.Text = "NoClip: " .. (state.noclip and "ON" or "OFF")
	noclipBtn.BackgroundColor3 = state.noclip and Color3.fromRGB(70, 200, 70) or Color3.fromRGB(70, 120, 200)
	applyNoClip(player.Character, state.noclip)
end

local function togglePerf()
	state.perf = not state.perf
	perfBtn.Text = "Low Graphics: " .. (state.perf and "ON" or "OFF")
	perfBtn.BackgroundColor3 = state.perf and Color3.fromRGB(70, 200, 70) or Color3.fromRGB(200, 150, 50)
	applyPerformance(state.perf)
end

speedBtn.MouseButton1Click:Connect(toggleSpeed)
jumpBtn.MouseButton1Click:Connect(toggleJump)
noclipBtn.MouseButton1Click:Connect(toggleNoclip)
perfBtn.MouseButton1Click:Connect(togglePerf)

-- ---------- Finalize ----------
gui.Parent = player:WaitForChild("PlayerGui")
