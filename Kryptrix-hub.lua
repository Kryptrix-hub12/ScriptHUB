-- Spawn Return & Fly-Around Button (Movable GUI)
-- Records your spawn position on script start.
-- Click the button to fly back there with style (speed 120, orbital approach, NoClip auto).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ---------- Get Spawn Position ----------
local spawnPos = Vector3.new(0, 0, 0)  -- fallback
local function recordSpawn()
	local character = player.Character
	if character then
		local root = character:FindFirstChild("HumanoidRootPart")
		if root then
			spawnPos = root.Position
		end
	end
end
recordSpawn()  -- initial record
-- Update on respawn? We'll keep the first one, but you can uncomment below to update.
-- player.CharacterAdded:Connect(recordSpawn)

-- ---------- GUI Creation ----------
local gui = Instance.new("ScreenGui")
gui.Name = "SpawnReturnGUI"
gui.ResetOnSpawn = false

-- Main button frame (movable)
local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(0, 70, 0, 70)
buttonFrame.Position = UDim2.new(0.85, -35, 0.8, -35)  -- bottom-right
buttonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
buttonFrame.BackgroundTransparency = 0.2
buttonFrame.BorderSizePixel = 0
Instance.new("UICorner", buttonFrame).CornerRadius = UDim.new(1, 0)  -- circle
buttonFrame.Parent = gui

-- Inner button (clickable)
local button = Instance.new("TextButton")
button.Size = UDim2.new(0.8, 0, 0.8, 0)
button.Position = UDim2.new(0.1, 0, 0.1, 0)
button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
button.BackgroundTransparency = 0.3
button.BorderSizePixel = 0
button.Text = "🏠"
button.TextColor3 = Color3.fromRGB(255,255,255)
button.TextSize = 28
button.Font = Enum.Font.GothamBold
Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)
button.Parent = buttonFrame

-- Shadow for depth
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 8, 1, 8)
shadow.Position = UDim2.new(0, -4, 0, -4)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045756"
shadow.ImageColor3 = Color3.new(0,0,0)
shadow.ImageTransparency = 0.5
shadow.Parent = buttonFrame

-- ---------- Dragging Logic (move the button) ----------
local dragData = { dragging = false, startPos = nil, startMouse = nil }

buttonFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragData.dragging = true
		dragData.startPos = buttonFrame.Position
		dragData.startMouse = input.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragData.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragData.startMouse
		buttonFrame.Position = UDim2.new(
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

-- ---------- Flight & Return Logic ----------
local isReturning = false
local bodyVelocity = nil
local bodyGyro = nil
local currentTarget = Vector3.new()
local phase = 0  -- 0: orbiting, 1: approaching
local orbitTimer = 0
local orbitDuration = 4  -- seconds to circle

local function stopFlight()
	if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
	isReturning = false
	-- Reset speed
	local char = player.Character
	if char then
		local hum = char:FindFirstChild("Humanoid")
		if hum then hum.WalkSpeed = 16 end
	end
	-- Turn off NoClip
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
	end
end

local function startReturn()
	if isReturning then return end  -- already returning
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local hum = char:FindFirstChild("Humanoid")
	if not hum then return end

	-- Enable NoClip
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
	-- Set speed to 120 (will be overridden by BodyVelocity, but keep for safety)
	hum.WalkSpeed = 120

	-- Create movement objects
	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
	bodyVelocity.Velocity = Vector3.new(0,0,0)
	bodyVelocity.Parent = root

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
	bodyGyro.CFrame = root.CFrame
	bodyGyro.Parent = root

	isReturning = true
	phase = 0  -- start with orbit
	orbitTimer = 0
	currentTarget = spawnPos

	-- Connect heartbeat update
	local heartbeatConn
	heartbeatConn = RunService.Heartbeat:Connect(function(dt)
		if not isReturning then
			heartbeatConn:Disconnect()
			return
		end
		local charNow = player.Character
		if not charNow then
			stopFlight()
			heartbeatConn:Disconnect()
			return
		end
		local rootNow = charNow:FindFirstChild("HumanoidRootPart")
		if not rootNow then
			stopFlight()
			heartbeatConn:Disconnect()
			return
		end

		local pos = rootNow.Position
		local dist = (pos - spawnPos).Magnitude

		-- If very close, stop
		if dist < 3 then
			stopFlight()
			heartbeatConn:Disconnect()
			return
		end

		if phase == 0 then
			-- Orbit around spawnPos
			orbitTimer = orbitTimer + dt
			local angle = orbitTimer * 2.5  -- radians per second
			local radius = 20
			local heightOffset = 10 + math.sin(orbitTimer * 1.2) * 5  -- bobbing
			local orbitX = spawnPos.X + math.cos(angle) * radius
			local orbitZ = spawnPos.Z + math.sin(angle) * radius
			local orbitY = spawnPos.Y + heightOffset
			currentTarget = Vector3.new(orbitX, orbitY, orbitZ)

			-- Transition to approach after orbitDuration seconds
			if orbitTimer > orbitDuration then
				phase = 1
				-- Approach target is directly spawnPos with a slight offset to land smoothly
				currentTarget = spawnPos + Vector3.new(0, 2, 0)  -- land slightly above
			end
		elseif phase == 1 then
			-- Approach directly to spawnPos
			currentTarget = spawnPos + Vector3.new(0, 2, 0)  -- keep a small height
			-- If close enough, finalize
			if dist < 5 then
				-- Land exactly
				currentTarget = spawnPos
				-- Force position to spawnPos (optional)
				rootNow.Position = spawnPos
				stopFlight()
				heartbeatConn:Disconnect()
				return
			end
		end

		-- Move towards currentTarget
		local direction = (currentTarget - pos).Unit
		local speed = 120
		-- If approaching, maybe slow down? We'll keep constant.
		bodyVelocity.Velocity = direction * speed
		-- Align gyro to look at target
		bodyGyro.CFrame = CFrame.lookAt(pos, currentTarget)
	end)
end

-- ---------- Button Click ----------
button.MouseButton1Click:Connect(startReturn)

-- ---------- Finalize ----------
gui.Parent = player:WaitForChild("PlayerGui")

-- Also ensure that if the button is clicked while already returning, it does nothing (already handled)
