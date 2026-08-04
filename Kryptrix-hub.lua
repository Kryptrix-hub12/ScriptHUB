-- Advanced Anti‑Lag Mobility (Speed 65, Infinite Jump + Air Control, NoClip, Max Performance)
-- Draggable GUI with close/reopen (N key), all toggles persist across respawns.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- ---------- Advanced Anti‑Lag Settings ----------
local function applyPerformance(enable)
	if enable then
		-- Graphics quality: lowest possible (0 is lowest, but 1 is safe)
		game:GetService("UserSettings"):GetService("UserGameSettings").GraphicsQualityLevel = 1
		
		-- Lighting: no shadows, minimal fog, fixed time
		Lighting.GlobalShadows = false
		Lighting.ClockTime = 12
		Lighting.FogEnd = 100
		Lighting.FogStart = 0
		
		-- Workspace: reduce render distance, disable smooth movement
		Workspace.RenderDistance = 500  -- minimum is 500
		Workspace.StreamingEnabled = true
		
		-- Disable particles, decals, and other visual effects
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = 1
			elseif v:IsA("Beam") then
				v.Enabled = false
			end
		end
		-- Disable water reflections (if any)
		if Workspace.Terrain then
			Workspace.Terrain.WaterReflectance = 0
			Workspace.Terrain.WaterTransparency = 1
		end
		-- Reduce texture quality via ContentProvider
		game:GetService("ContentProvider").TextureQuality = Enum.TextureQuality.QualityLevelLowest
	else
		-- Restore to moderate settings
		game:GetService("UserSettings"):GetService("UserGameSettings").GraphicsQualityLevel = 3
		Lighting.GlobalShadows = true
		Lighting.ClockTime = 14
		Lighting.FogEnd = 1000
		Lighting.FogStart = 100
		Workspace.RenderDistance = 5000
		Workspace.StreamingEnabled = false
		game:GetService("ContentProvider").TextureQuality = Enum.TextureQuality.QualityLevelMedium
		-- Re‑enable particles/decals (only on existing, not newly added; but that's fine)
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = 0
			elseif v:IsA("Beam") then
				v.Enabled = true
			end
		end
		if Workspace.Terrain then
			Workspace.Terrain.WaterReflectance = 0.5
			Workspace.Terrain.WaterTransparency = 0.7
		end
	end
end

-- ---------- GUI Creation ----------
local gui = Instance.new("ScreenGui")
gui.Name = "AdvancedAntiLagGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 310)
frame.Position = UDim2.new(0.5, -160, 0.5, -155)
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

-- Title Bar (draggable)
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
titleLabel.Text = "⚡ Advanced Mobility"
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

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

-- ---------- Toggle Buttons (two columns) ----------
local function createToggle(text, x, y, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 130, 0, 40)
	btn.Position = UDim2.new(x, 0, 0, y)
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

local speedBtn   = createToggle("Speed 65", 0.1, 50, Color3.fromRGB(70, 120, 200))
local jumpBtn    = createToggle("Infinite Jump", 0.55, 50, Color3.fromRGB(70, 120, 200))
local noclipBtn  = createToggle("NoClip", 0.1, 110, Color3.fromRGB(70, 120, 200))
local airJumpBtn = createToggle("Air Jump", 0.55, 110, Color3.fromRGB(150, 70, 200))  -- advanced feature
local perfBtn    = createToggle("Ultra Anti‑Lag", 0.1, 170, Color3.fromRGB(200, 150, 50))

-- Additional button for "Hold to Fly" (combined with jump)
local flyBtn = createToggle("Hold Fly", 0.55, 170, Color3.fromRGB(200, 70, 150))

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
	jump = false,          -- infinite jump (hold space to jump repeatedly)
	airJump = false,       -- can jump in mid-air (even without ground)
	flyHold = false,       -- hold space to ascend (like fly up)
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

-- Apply all to a character
local function applyAll(character)
	if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	updateSpeed(humanoid)
	humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if state.speed and humanoid.WalkSpeed ~= 65 then
			humanoid.WalkSpeed = 65
		end
	end)
	applyNoClip(character, state.noclip)
	-- Set jump power higher for better feeling
	if state.jump or state.airJump then
		humanoid.JumpPower = 70  -- slightly higher than default 50
	else
		humanoid.JumpPower = 50
	end
	-- Watch for new parts for noclip
	character.DescendantAdded:Connect(function(desc)
		if state.noclip and desc:IsA("BasePart") then
			desc.CanCollide = false
		end
	end)
end

-- ---------- Character Respawn ----------
local function onCharacterAdded(character)
	character:WaitForChild("Humanoid")
	applyAll(character)
end

if player.Character then
	onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- ---------- Advanced Jump / Fly Logic ----------
local jumpKeyDown = false
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Space then
		jumpKeyDown = true
	end
end)
UserInputService.InputEnded:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Space then
		jumpKeyDown = false
	end
end)

-- Main loop for jump and fly
RunService.Heartbeat:Connect(function()
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChild("Humanoid")
	if not humanoid then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- Infinite Jump (hold space to keep jumping, even if in air)
	if state.jump and jumpKeyDown then
		-- Standard: if on ground or air (with airJump enabled), jump
		local canJump = (humanoid:GetState() == Enum.HumanoidStateType.Landed) or state.airJump
		if canJump then
			humanoid.Jump = true
		end
	end

	-- Hold Fly: gives upward velocity when holding space, but only if the "Hold Fly" toggle is on
	if state.flyHold and jumpKeyDown then
		-- We want to keep the player floating upward, but not interfere with normal jump if toggled
		-- Use a BodyVelocity or just set jump repeatedly? Better to apply velocity.
		-- We'll use a BodyVelocity if not already present.
		local bv = root:FindFirstChild("FlyBodyVelocity")
		if not bv then
			bv = Instance.new("BodyVelocity")
			bv.Name = "FlyBodyVelocity"
			bv.MaxForce = Vector3.new(0, 10000, 0)  -- only upward
			bv.Velocity = Vector3.new(0, 50, 0)  -- upward speed
			bv.Parent = root
		end
		-- Keep it alive; if space is held, the velocity stays.
		-- If not held, we remove it.
	else
		-- Remove fly velocity if it exists
		local bv = root:FindFirstChild("FlyBodyVelocity")
		if bv then bv:Destroy() end
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
	-- update jump power
	local hum = player.Character and player.Character:FindFirstChild("Humanoid")
	if hum then
		if state.jump or state.airJump then
			hum.JumpPower = 70
		else
			hum.JumpPower = 50
		end
	end
end

local function toggleAirJump()
	state.airJump = not state.airJump
	airJumpBtn.Text = "Air Jump: " .. (state.airJump and "ON" or "OFF")
	airJumpBtn.BackgroundColor3 = state.airJump and Color3.fromRGB(70, 200, 70) or Color3.fromRGB(150, 70, 200)
	local hum = player.Character and player.Character:FindFirstChild("Humanoid")
	if hum then
		if state.jump or state.airJump then
			hum.JumpPower = 70
		else
			hum.JumpPower = 50
		end
	end
end

local function toggleFlyHold()
	state.flyHold = not state.flyHold
	flyBtn.Text = "Hold Fly: " .. (state.flyHold and "ON" or "OFF")
	flyBtn.BackgroundColor3 = state.flyHold and Color3.fromRGB(70, 200, 70) or Color3.fromRGB(200, 70, 150)
	-- If turning off, remove any existing fly velocity
	if not state.flyHold then
		local char = player.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local bv = root:FindFirstChild("FlyBodyVelocity")
				if bv then bv:Destroy() end
			end
		end
	end
end

local function toggleNoclip()
	state.noclip = not state.noclip
	noclipBtn.Text = "NoClip: " .. (state.noclip and "ON" or "OFF")
	noclipBtn.BackgroundColor3 = state.noclip and Color3.fromRGB(70, 200, 70) or Color3.fromRGB(70, 120, 200)
	applyNoClip(player.Character, state.noclip)
end

local function togglePerf()
	state.perf = not state.perf
	perfBtn.Text = "Ultra Anti‑Lag: " .. (state.perf and "ON" or "OFF")
	perfBtn.BackgroundColor3 = state.perf and Color3.fromRGB(70, 200, 70) or Color3.fromRGB(200, 150, 50)
	applyPerformance(state.perf)
end

speedBtn.MouseButton1Click:Connect(toggleSpeed)
jumpBtn.MouseButton1Click:Connect(toggleJump)
airJumpBtn.MouseButton1Click:Connect(toggleAirJump)
flyBtn.MouseButton1Click:Connect(toggleFlyHold)
noclipBtn.MouseButton1Click:Connect(toggleNoclip)
perfBtn.MouseButton1Click:Connect(togglePerf)

-- ---------- Finalize ----------
gui.Parent = player:WaitForChild("PlayerGui")
